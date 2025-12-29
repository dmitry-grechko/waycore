from __future__ import annotations

import json
import logging
import os
import shutil
from pathlib import Path
from typing import Any

from device.libs.schemas.ai import (
    AIInferenceRequest,
    AIInferenceResponse,
    InferenceType,
)
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.responses import JSONResponse

from .engine import run_inference
from .models.runtime import registry
from .preprocessing import PreprocessingError, preprocess_for_inference
from .service import AIService

logger = logging.getLogger(__name__)

# Model storage path
MODEL_DIR = Path(os.getenv("WAYCORE_MODEL_PATH", "/opt/waycore/models"))
REGISTRY_FILE = MODEL_DIR / "registry.json"


def _load_registry() -> dict[str, Any]:
    """Load model registry from disk."""
    if REGISTRY_FILE.exists():
        try:
            with open(REGISTRY_FILE) as f:
                data: dict[str, Any] = json.load(f)
                return data
        except Exception as e:
            logger.warning(f"Failed to load registry: {e}")
    return {"models": {}, "active": {"language": None, "vision": None}}


def _save_registry(data: dict[str, Any]) -> None:
    """Save model registry to disk."""
    REGISTRY_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(REGISTRY_FILE, "w") as f:
        json.dump(data, f, indent=2)


def _get_model_size_mb(path: Path) -> float:
    """Get model file size in MB."""
    if path.exists():
        return path.stat().st_size / (1024 * 1024)
    return 0


def _detect_models() -> dict[str, Any]:
    """Detect models from filesystem and merge with registry."""
    reg = _load_registry()
    models = reg.get("models", {})

    # Scan language models
    lang_dir = MODEL_DIR / "language"
    if lang_dir.exists():
        for f in lang_dir.glob("*.gguf"):
            model_id = f.stem.replace(".", "-").lower()
            if model_id not in models:
                models[model_id] = {
                    "id": model_id,
                    "type": "language",
                    "name": f.stem,
                    "format": "gguf",
                    "path": str(f),
                    "size_mb": round(_get_model_size_mb(f), 1),
                }

    # Scan vision models
    vision_dir = MODEL_DIR / "vision"
    if vision_dir.exists():
        for f in vision_dir.glob("*.tflite"):
            model_id = f.stem.replace(".", "-").replace("_", "-").lower()
            if model_id not in models:
                models[model_id] = {
                    "id": model_id,
                    "type": "vision",
                    "name": f.stem,
                    "format": "tflite",
                    "path": str(f),
                    "size_mb": round(_get_model_size_mb(f), 1),
                }

    reg["models"] = models

    # Set defaults if no active models
    if not reg.get("active", {}).get("language"):
        for mid, info in models.items():
            if info.get("type") == "language":
                reg.setdefault("active", {})["language"] = mid
                break

    if not reg.get("active", {}).get("vision"):
        for mid, info in models.items():
            if info.get("type") == "vision":
                reg.setdefault("active", {})["vision"] = mid
                break

    _save_registry(reg)
    return reg


def create_app(service: AIService) -> FastAPI:
    app = FastAPI(title="AI Service API")

    @app.get("/health")
    async def health() -> dict[str, Any]:
        if service.is_healthy():
            return {"status": "ok"}
        raise HTTPException(status_code=503, detail="not ready")

    @app.get("/health/detailed")
    async def health_detailed() -> dict[str, Any]:
        """Get detailed health status including knowledge base and models."""
        from device.libs.knowledge.manager import KnowledgeBaseManager

        kb_manager = KnowledgeBaseManager()
        kb_status = kb_manager.get_stats()

        # Get model info
        model_info: dict[str, Any] = {}
        reg = _load_registry()
        active = reg.get("active", {})
        model_info["language"] = active.get("language")
        model_info["vision"] = active.get("vision")

        return {
            "status": "ok" if service.is_healthy() else "degraded",
            "knowledge_base": {
                "version": kb_status.get("version"),
                "installed": kb_status.get("installed"),
                "integrity": kb_status.get("integrity"),
                "update_available": kb_status.get("update_available"),
            },
            "models": model_info,
            "mcp": {
                "connected": service.mcp.is_connected if service.mcp else False,
                "tool_count": len(service.mcp.list_tools()) if service.mcp else 0,
            },
        }

    @app.get("/debug/agent")
    async def debug_agent() -> JSONResponse:
        """Debug endpoint to check agent and MCP status."""
        mcp_info: dict[str, Any] = {"connected": False, "tools": []}
        agent_info: dict[str, Any] = {"initialized": False, "has_llm": False}

        if service.mcp:
            mcp_info["connected"] = service.mcp.is_connected
            mcp_info["tools"] = [
                {"name": name, "server": server} for name, (server, _) in service.mcp._tools.items()
            ]

        if service.agent:
            agent_info["initialized"] = True
            agent_info["has_llm"] = service.agent.llm_generate is not None
            agent_info["has_final_response"] = service.agent.llm_final_response is not None

        return JSONResponse(
            {
                "mcp": mcp_info,
                "agent": agent_info,
            }
        )

    # --- Inference Endpoints ---

    @app.post("/api/inference")
    async def inference(req: AIInferenceRequest) -> AIInferenceResponse:
        try:
            pre = preprocess_for_inference(req)
            resp = run_inference(req, pre, response_source=service.response_source)
        except PreprocessingError as exc:
            resp = AIInferenceResponse(
                source=service.response_source,
                request_id=req.msg_id,
                inference_type=req.inference_type,
                model_id=req.model_id,
                results=[],
                processing_time_ms=0,
                success=False,
                error_message=str(exc),
            )

        # Publish to MQTT for logging (data-logger captures this)
        if service.bus:
            try:
                await service.bus.publish("ai/inference/response", resp.model_dump_json())
            except Exception as e:
                logger.warning(f"Failed to publish inference response: {e}")

        return resp

    @app.post("/api/image/classify")
    async def image_classify(body: dict[str, Any]) -> AIInferenceResponse:
        model_id = str(body.get("model_id", "mobilenetv3"))
        input_data = body.get("input_data", {})
        req = AIInferenceRequest(
            source=service.response_source,
            inference_type=InferenceType.image_classification,
            model_id=model_id,
            input_data=input_data,
            options={},
        )
        pre = preprocess_for_inference(req)
        resp = run_inference(req, pre, response_source=service.response_source)

        # Publish to MQTT for logging
        if service.bus:
            try:
                await service.bus.publish("ai/inference/response", resp.model_dump_json())
            except Exception as e:
                logger.warning(f"Failed to publish image classify response: {e}")

        return resp

    @app.post("/api/chat/multimodal")
    async def chat_multimodal(body: dict[str, Any]) -> JSONResponse:
        """Multimodal chat endpoint combining image + text question.

        Request body:
            question: str - User's question about the image (optional)
            image_b64: str - Base64-encoded image (optional)
            model_id: str - Model to use (default: phi3-mini)

        Supports three modes:
        1. Image + Question: Two-stage pipeline (vision → LLM)
        2. Image only: Returns classification results
        3. Question only: Standard chat (redirects to /api/chat)

        Returns:
            JSONResponse with response text and metadata
        """
        question = str(body.get("question", "")).strip()
        image_b64 = str(body.get("image_b64", "")).strip()
        model_id = str(body.get("model_id", "phi3-mini"))

        # Mode 1: Question only → redirect to regular chat
        if question and not image_b64:
            return await chat({"question": question, "model_id": model_id})

        # Mode 2: Image only → return classification
        if image_b64 and not question:
            req = AIInferenceRequest(
                source=service.response_source,
                inference_type=InferenceType.image_classification,
                model_id="mobilenetv3",
                input_data={"image_b64": image_b64},
                options={},
            )
            pre = preprocess_for_inference(req)
            result = run_inference(req, pre, response_source=service.response_source)

            # Format classification results
            if result.success and result.results:
                lines = ["**Image Classification Results:**\n"]
                for r in result.results[:5]:
                    pct = f"{r.confidence * 100:.1f}%"
                    lines.append(f"• **{r.label}**: {pct}")
                response_text = "\n".join(lines)
            else:
                response_text = "Could not classify the image."

            return JSONResponse(
                {
                    "success": True,
                    "response": response_text,
                    "results": [{"label": response_text}],
                    "mode": "classification_only",
                }
            )

        # Mode 3: Image + Question → two-stage multimodal pipeline
        if not image_b64:
            return JSONResponse(
                {"error": "No image or question provided"},
                status_code=400,
            )

        # Stage 1: Get image classification results
        vision_context = ""
        try:
            req = AIInferenceRequest(
                source=service.response_source,
                inference_type=InferenceType.image_classification,
                model_id="mobilenetv3",
                input_data={"image_b64": image_b64},
                options={},
            )
            pre = preprocess_for_inference(req)
            vision_result = run_inference(req, pre, response_source=service.response_source)

            if vision_result.success and vision_result.results:
                lines = ["Image analysis results:"]
                for r in vision_result.results[:5]:
                    pct = f"{r.confidence * 100:.1f}%"
                    lines.append(f"- {r.label}: {pct}")
                vision_context = "\n".join(lines)
            else:
                vision_context = "Image analysis: Unable to identify contents."
        except Exception as e:
            logger.warning(f"Vision analysis failed: {e}")
            vision_context = "Image analysis: Analysis failed."

        # Stage 2: Generate LLM response with vision context
        multimodal_prompt = f"""The user has attached an image and asked a question about it.

{vision_context}

User's question: {question}

Based on the image analysis and your knowledge, provide a helpful answer.
If the image appears to show plants, mushrooms, or wildlife:
- Mention any safety considerations
- Recommend expert verification if identification is uncertain
- Err on the side of caution for edibility questions

Answer:"""

        # Use direct inference with the multimodal prompt
        qa_req = AIInferenceRequest(
            source=service.response_source,
            inference_type=InferenceType.qa,
            model_id=model_id,
            input_data={"question": multimodal_prompt, "context": ""},
            options={},
        )
        qa_pre = preprocess_for_inference(qa_req)
        qa_result = run_inference(qa_req, qa_pre, response_source=service.response_source)

        # Publish to MQTT for logging
        if service.bus:
            try:
                await service.bus.publish("ai/inference/response", qa_result.model_dump_json())
            except Exception as e:
                logger.warning(f"Failed to publish multimodal response: {e}")

        response_text = ""
        if qa_result.success and qa_result.results:
            response_text = qa_result.results[0].label
        else:
            # Fallback to vision context if LLM fails
            response_text = f"Based on the image:\n{vision_context}"

        return JSONResponse(
            {
                "success": True,
                "response": response_text,
                "results": [{"label": response_text}],
                "vision_context": vision_context,
                "mode": "multimodal",
            }
        )

    @app.post("/api/chat")
    async def chat(body: dict[str, Any]) -> JSONResponse:
        """Chat endpoint with optional MCP tool support.

        Request body:
            question: str - The user's question
            context: str - Optional context
            model_id: str - Model to use (default: phi3-mini)
            use_tools: bool - Enable MCP tools (default: true)
            conversation_history: list - Previous messages

        Returns:
            JSONResponse with response text and tool information
        """
        question = str(body.get("question", "")).strip()
        use_tools = body.get("use_tools", True)
        conversation_history = body.get("conversation_history", [])

        if not question:
            return JSONResponse(
                {"error": "No question provided"},
                status_code=400,
            )

        # Try agentic approach with tools if available
        if use_tools and service.agent:
            try:
                logger.info(f"Using agentic chat for: {question}")
                response_content = ""
                tool_calls_made: list[dict[str, Any]] = []

                async for agent_response in service.agent.process_message(
                    question, conversation_history
                ):
                    response_content = agent_response.content
                    logger.info(f"Agent response: {response_content[:100]}...")

                    if agent_response.tool_calls:
                        tool_calls_made = [
                            {"name": tc.name, "arguments": tc.arguments}
                            for tc in agent_response.tool_calls
                        ]
                        logger.info(f"Tool calls made: {tool_calls_made}")

                    if agent_response.requires_confirmation:
                        # Return confirmation request
                        return JSONResponse(
                            {
                                "success": True,
                                "results": [{"label": agent_response.content}],
                                "response": agent_response.content,
                                "requires_confirmation": [
                                    {"name": tc.name, "arguments": tc.arguments}
                                    for tc in agent_response.requires_confirmation
                                ],
                                "is_final": False,
                            }
                        )

                return JSONResponse(
                    {
                        "success": True,
                        "results": [{"label": response_content}],
                        "response": response_content,
                        "tool_calls": tool_calls_made,
                        "is_final": True,
                        "mode": "agentic",
                    }
                )

            except Exception as e:
                logger.error(f"Agentic chat failed, falling back to direct: {e}")
                import traceback

                logger.error(traceback.format_exc())
                # Fall through to direct inference

        # Direct inference without tools
        model_id = str(body.get("model_id", "phi3-mini"))
        context = body.get("context", "")
        req = AIInferenceRequest(
            source=service.response_source,
            inference_type=InferenceType.qa,
            model_id=model_id,
            input_data={"question": question, "context": context},
            options={},
        )
        pre = preprocess_for_inference(req)
        result = run_inference(req, pre, response_source=service.response_source)

        # Publish to MQTT for logging
        if service.bus:
            try:
                await service.bus.publish("ai/inference/response", result.model_dump_json())
            except Exception as e:
                logger.warning(f"Failed to publish chat response: {e}")

        # Extract response text
        response_text = ""
        if result.results and len(result.results) > 0:
            response_text = result.results[0].label

        return JSONResponse(
            {
                "success": True,
                "results": [{"label": response_text}],
                "response": response_text,
                "tool_calls": [],
                "is_final": True,
                "mode": "direct",
            }
        )

    # --- Model Management Endpoints ---

    @app.get("/api/models")
    async def list_models() -> JSONResponse:
        """List all installed models."""
        reg = _detect_models()
        models_list = list(reg.get("models", {}).values())

        # Mark active status
        active = reg.get("active", {})
        for m in models_list:
            m["active"] = m["id"] == active.get(m["type"])

        # Get storage info
        storage_used = sum(m.get("size_mb", 0) for m in models_list)
        try:
            disk_free = shutil.disk_usage(MODEL_DIR).free / (1024 * 1024)
        except Exception:
            disk_free = 0

        return JSONResponse(
            {
                "models": models_list,
                "active": active,
                "limits": {
                    "max_language": 1,
                    "max_vision": 1,
                    "storage_used_mb": round(storage_used, 1),
                    "storage_available_mb": round(disk_free, 1),
                },
            }
        )

    @app.post("/api/models/upload")
    async def upload_model(
        file: UploadFile = File(...),  # noqa: B008
        id: str = Form(...),  # noqa: B008
        type: str = Form(...),  # noqa: B008
        name: str = Form(None),  # noqa: B008
        activate: str = Form("false"),  # noqa: B008
    ) -> JSONResponse:
        """Upload a new model file."""
        if type not in ("language", "vision"):
            raise HTTPException(400, "type must be 'language' or 'vision'")

        # Determine format from filename
        filename = file.filename or "model"
        if type == "language" and not filename.endswith(".gguf"):
            raise HTTPException(400, "Language models must be GGUF format (.gguf)")
        if type == "vision" and not filename.endswith(".tflite"):
            raise HTTPException(400, "Vision models must be TFLite format (.tflite)")

        # Create target directory
        ext = ".gguf" if type == "language" else ".tflite"
        target_dir = MODEL_DIR / type
        target_dir.mkdir(parents=True, exist_ok=True)
        target_path = target_dir / f"{id}{ext}"

        # Save file
        try:
            with open(target_path, "wb") as f:
                while chunk := await file.read(1024 * 1024):  # 1MB chunks
                    f.write(chunk)
        except Exception as e:
            logger.error(f"Failed to save model: {e}")
            raise HTTPException(500, f"Failed to save model: {e}") from e

        size_mb = round(_get_model_size_mb(target_path), 1)
        model_name = name or id

        # Update JSON registry (for filesystem compatibility)
        reg = _load_registry()
        reg.setdefault("models", {})[id] = {
            "id": id,
            "type": type,
            "name": model_name,
            "format": ext[1:],
            "path": str(target_path),
            "size_mb": size_mb,
        }

        # Activate if requested
        should_activate = activate.lower() == "true"
        if should_activate:
            old_active = reg.get("active", {}).get(type)
            if old_active:
                registry.unload(old_active)
            reg.setdefault("active", {})[type] = id

        _save_registry(reg)

        # Also persist to database
        if service.db:
            await service.db.add_model(
                model_id=id,
                model_type=type,
                name=model_name,
                fmt=ext[1:],
                path=str(target_path),
                size_mb=size_mb,
            )
            if should_activate:
                await service.db.set_model_active(id, type)

        return JSONResponse(
            {
                "success": True,
                "model_id": id,
                "size_mb": size_mb,
                "message": f"Model uploaded to {target_path}",
            }
        )

    @app.post("/api/models/{model_id}/activate")
    async def activate_model(model_id: str) -> JSONResponse:
        """Activate a model (deactivates previous model of same type)."""
        reg = _detect_models()
        models = reg.get("models", {})

        if model_id not in models:
            raise HTTPException(404, f"Model '{model_id}' not found")

        model_info = models[model_id]
        model_type = model_info["type"]

        # Unload current active model
        old_active = reg.get("active", {}).get(model_type)
        if old_active and old_active != model_id:
            registry.unload(old_active)

        # Set new active in JSON registry
        reg.setdefault("active", {})[model_type] = model_id
        _save_registry(reg)

        # Also update database
        if service.db:
            await service.db.set_model_active(model_id, model_type)

        return JSONResponse(
            {
                "success": True,
                "model_id": model_id,
                "previous": old_active,
                "message": f"Model '{model_id}' is now active for {model_type} tasks.",
            }
        )

    @app.delete("/api/models/{model_id}")
    async def delete_model(model_id: str) -> JSONResponse:
        """Delete a model from the device."""
        reg = _detect_models()
        models = reg.get("models", {})

        if model_id not in models:
            raise HTTPException(404, f"Model '{model_id}' not found")

        model_info = models[model_id]
        model_type = model_info["type"]

        # Check if active
        if reg.get("active", {}).get(model_type) == model_id:
            raise HTTPException(
                400, f"Cannot delete active model. Activate another {model_type} model first."
            )

        # Delete file
        model_path = Path(model_info["path"])
        size_mb = round(_get_model_size_mb(model_path), 1)

        if model_path.exists():
            model_path.unlink()

        # Remove from JSON registry
        del models[model_id]
        reg["models"] = models
        _save_registry(reg)

        # Also remove from database
        if service.db:
            await service.db.delete_model(model_id)

        return JSONResponse(
            {
                "success": True,
                "model_id": model_id,
                "freed_mb": size_mb,
                "message": f"Model '{model_id}' deleted.",
            }
        )

    @app.get("/api/models/{model_id}/info")
    async def get_model_info(model_id: str) -> JSONResponse:
        """Get detailed information about a model."""
        reg = _detect_models()
        models = reg.get("models", {})

        if model_id not in models:
            raise HTTPException(404, f"Model '{model_id}' not found")

        model_info = models[model_id].copy()
        model_info["active"] = model_id == reg.get("active", {}).get(model_info["type"])

        return JSONResponse(model_info)

    @app.post("/api/models/rescan")
    async def rescan_models() -> JSONResponse:
        """Rescan model directory for new models."""
        reg = _detect_models()

        # Sync detected models to database
        if service.db:
            for model_id, info in reg.get("models", {}).items():
                await service.db.add_model(
                    model_id=model_id,
                    model_type=info.get("type", "unknown"),
                    name=info.get("name", model_id),
                    fmt=info.get("format", "unknown"),
                    path=info.get("path", ""),
                    size_mb=info.get("size_mb", 0),
                )
                # Set active status in database
                active = reg.get("active", {})
                if active.get(info.get("type")) == model_id:
                    await service.db.set_model_active(model_id, info.get("type", "unknown"))

        return JSONResponse(
            {
                "success": True,
                "models_found": len(reg.get("models", {})),
            }
        )

    # --- Factory Reset ---

    @app.post("/api/factory-reset")
    async def factory_reset() -> JSONResponse:
        """
        Factory reset: Delete all AI data including conversations, messages, and model registry.

        WARNING: This is destructive and cannot be undone!
        Model files are NOT deleted (only the database entries).
        """
        result: dict[str, int] = {}

        # Reset database
        if service.db:
            result = await service.db.factory_reset()

        # Clear JSON registry (but keep model files)
        if REGISTRY_FILE.exists():
            REGISTRY_FILE.unlink()
            result["registry_cleared"] = 1

        # Unload all models from memory
        registry.unload_all()
        result["models_unloaded"] = 1

        return JSONResponse(
            {
                "success": True,
                "message": "Factory reset completed. All AI data has been cleared.",
                "deleted": result,
            }
        )

    @app.delete("/api/conversations")
    async def delete_all_conversations() -> JSONResponse:
        """Delete all conversations and messages."""
        count = 0
        if service.db:
            count = await service.db.delete_all_conversations()

        return JSONResponse(
            {
                "success": True,
                "deleted_conversations": count,
            }
        )

    @app.delete("/api/inferences")
    async def delete_all_inferences() -> JSONResponse:
        """Delete all inference logs."""
        count = 0
        if service.db:
            count = await service.db.delete_all_inferences()

        return JSONResponse(
            {
                "success": True,
                "deleted_inferences": count,
            }
        )

    # --- Conversation & Message Persistence Endpoints ---

    @app.get("/api/conversations")
    async def list_conversations(limit: int = 100) -> JSONResponse:
        """List all conversations, most recent first."""
        if not service.db:
            return JSONResponse({"conversations": []})

        conversations = await service.db.get_all_conversations(limit)
        return JSONResponse({"conversations": conversations})

    @app.post("/api/conversations")
    async def create_conversation(body: dict[str, Any]) -> JSONResponse:
        """Create a new conversation."""
        if not service.db:
            raise HTTPException(503, "Database not available")

        title = body.get("title")
        model_id = body.get("model_id", "phi3-mini")

        conv_id = await service.db.create_conversation(title=title, model_id=model_id)
        return JSONResponse(
            {
                "success": True,
                "conversation_id": conv_id,
            }
        )

    @app.get("/api/conversations/{conversation_id}")
    async def get_conversation(conversation_id: int) -> JSONResponse:
        """Get a specific conversation."""
        if not service.db:
            raise HTTPException(503, "Database not available")

        conversation = await service.db.get_conversation(conversation_id)
        if not conversation:
            raise HTTPException(404, "Conversation not found")

        return JSONResponse(conversation)

    @app.put("/api/conversations/{conversation_id}")
    async def update_conversation(conversation_id: int, body: dict[str, Any]) -> JSONResponse:
        """Update a conversation."""
        if not service.db:
            raise HTTPException(503, "Database not available")

        title = body.get("title")
        model_id = body.get("model_id")

        await service.db.update_conversation(conversation_id, title=title, model_id=model_id)
        return JSONResponse({"success": True, "conversation_id": conversation_id})

    @app.delete("/api/conversations/{conversation_id}")
    async def delete_conversation(conversation_id: int) -> JSONResponse:
        """Delete a conversation and all its messages."""
        if not service.db:
            raise HTTPException(503, "Database not available")

        await service.db.delete_conversation(conversation_id)
        return JSONResponse({"success": True, "deleted": conversation_id})

    @app.get("/api/conversations/{conversation_id}/messages")
    async def get_messages(conversation_id: int, limit: int = 100) -> JSONResponse:
        """Get messages for a conversation."""
        if not service.db:
            return JSONResponse({"messages": []})

        messages = await service.db.get_messages(conversation_id, limit)
        return JSONResponse({"messages": messages})

    @app.post("/api/conversations/{conversation_id}/messages")
    async def add_message(conversation_id: int, body: dict[str, Any]) -> JSONResponse:
        """Add a message to a conversation."""
        if not service.db:
            raise HTTPException(503, "Database not available")

        role = body.get("role", "user")
        content = body.get("content", "")

        if not content:
            raise HTTPException(400, "Message content is required")

        msg_id = await service.db.add_message(conversation_id, role, content)
        return JSONResponse(
            {
                "success": True,
                "message_id": msg_id,
            }
        )

    @app.delete("/api/conversations/{conversation_id}/messages")
    async def clear_messages(conversation_id: int) -> JSONResponse:
        """Clear all messages from a conversation."""
        if not service.db:
            raise HTTPException(503, "Database not available")

        count = await service.db.clear_messages(conversation_id)
        return JSONResponse({"success": True, "deleted": count})

    return app
