"""Real Phi-3 Mini model runner using llama-cpp-python."""

from __future__ import annotations

import logging
import os
from pathlib import Path
from typing import Any

from device.libs.schemas.ai import InferenceResult, InferenceType

from ..preprocessing import ImagePreprocessed, QAPreprocessed
from .runtime import ModelRunner

logger = logging.getLogger(__name__)

# Default model path
DEFAULT_MODEL_PATH = (
    Path(os.getenv("WAYCORE_MODEL_PATH", "/opt/waycore/models"))
    / "language"
    / "phi-3-mini-4k-instruct.Q4_K_M.gguf"
)

# System prompt configuration
SYSTEM_PROMPT_PATH = Path(__file__).parent.parent / "config" / "system_prompt.txt"

# Fallback system prompt if config file not found
FALLBACK_SYSTEM_PROMPT = """You are Waycore AI, an assistant for outdoor and survival.

Key traits:
- Concise and direct responses
- Safety-first mentality
- Practical, actionable advice
- Assume limited resources and no internet connectivity

Keep responses brief. User has limited screen space and battery."""


def _load_system_prompt() -> str:
    """Load system prompt from config file, falling back to default."""
    if SYSTEM_PROMPT_PATH.exists():
        try:
            return SYSTEM_PROMPT_PATH.read_text().strip()
        except Exception as e:
            logger.warning(f"Failed to load system prompt from {SYSTEM_PROMPT_PATH}: {e}")
    return FALLBACK_SYSTEM_PROMPT


# Load system prompt at module load time
SYSTEM_PROMPT = _load_system_prompt()


class Phi3Runner(ModelRunner):
    """
    Real Phi-3 Mini model runner using llama-cpp-python.

    Loads the model lazily on first inference request.
    Uses 4-bit quantization (Q4_K_M) for Pi 5 compatibility.
    """

    # Default context size (can be overridden via env var)
    # 2048 saves ~500MB RAM vs 4096
    DEFAULT_N_CTX = int(os.getenv("PHI3_CONTEXT_SIZE", "2048"))

    def __init__(
        self,
        model_path: str | Path | None = None,
        n_ctx: int | None = None,
        n_threads: int = 4,
    ) -> None:
        self._model_path = Path(model_path) if model_path else DEFAULT_MODEL_PATH
        self._n_ctx = n_ctx if n_ctx is not None else self.DEFAULT_N_CTX
        self._n_threads = n_threads
        self._llm: Any = None  # Lazy loaded
        self._available: bool | None = None

    def _ensure_loaded(self) -> bool:
        """Ensure model is loaded. Returns True if available."""
        if self._available is not None:
            return self._available

        if not self._model_path.exists():
            logger.warning(f"Phi-3 model not found at {self._model_path}")
            self._available = False
            return False

        try:
            from llama_cpp import Llama

            logger.info(f"Loading Phi-3 model from {self._model_path}")
            self._llm = Llama(
                model_path=str(self._model_path),
                n_ctx=self._n_ctx,
                n_threads=self._n_threads,
                n_gpu_layers=0,  # CPU only for Pi 5
                verbose=False,
                use_mmap=True,  # Memory-map model for faster startup & lower RAM
                use_mlock=False,  # Allow swapping if needed on low-memory systems
            )
            self._available = True
            logger.info("Phi-3 model loaded successfully")
            return True
        except ImportError:
            logger.warning("llama-cpp-python not installed, using stub")
            self._available = False
            return False
        except Exception as e:
            logger.error(f"Failed to load Phi-3 model: {e}")
            self._available = False
            return False

    def supports(self, inference_type: InferenceType) -> bool:
        return inference_type is InferenceType.qa

    def infer_image(self, pre: ImagePreprocessed) -> list[InferenceResult]:
        raise NotImplementedError("Phi-3 does not support image tasks directly")

    def infer_qa(self, pre: QAPreprocessed) -> list[InferenceResult]:
        """Run Q&A inference with the Phi-3 model."""
        if not self._ensure_loaded():
            # Fallback to stub response
            return self._stub_response(pre)

        question = pre["question"]
        context_list = pre.get("context", [])
        context = "\n".join(context_list) if context_list else ""

        # Build prompt
        if context:
            user_content = f"Context:\n{context}\n\nQuestion: {question}"
        else:
            user_content = question

        messages = [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_content},
        ]

        try:
            response = self._llm.create_chat_completion(
                messages=messages,
                max_tokens=512,
                temperature=0.7,
                top_p=0.9,
                stop=["<|end|>", "<|user|>"],
            )

            # Extract the assistant's response
            content = response["choices"][0]["message"]["content"]
            content = content.strip()

            return [
                InferenceResult(
                    label=content,
                    confidence=1.0,
                    metadata={
                        "model": "phi3-mini",
                        "tokens_used": response.get("usage", {}).get("total_tokens", 0),
                    },
                )
            ]
        except Exception as e:
            logger.error(f"Phi-3 inference error: {e}")
            return [
                InferenceResult(
                    label=f"Error: {e}",
                    confidence=0.0,
                    metadata={"error": str(e)},
                )
            ]

    def _stub_response(self, pre: QAPreprocessed) -> list[InferenceResult]:
        """Fallback stub response when model not available."""
        question = pre["question"]
        context = pre.get("context", [])

        # Simple heuristic response
        if context:
            answer = context[0] if context[0] else "N/A"
        else:
            answer = f"[Model not loaded] You asked: {question}"

        return [
            InferenceResult(
                label=answer,
                confidence=0.0,
                metadata={"stub": True, "question": question},
            )
        ]

    def generate_with_tools(
        self,
        user_message: str,
        tool_prompt: str,
        conversation_history: list[dict[str, str]] | None = None,
    ) -> str:
        """Generate a response with tool awareness.

        This method includes tool descriptions in the system prompt and is used
        by the AgentController for agentic tool-using conversations.

        Args:
            user_message: The user's message.
            tool_prompt: System prompt section describing available tools.
            conversation_history: Previous messages in the conversation.

        Returns:
            The generated response text (may contain tool calls in JSON format).
        """
        if not self._ensure_loaded():
            return f"[Model not available] You asked: {user_message}"

        # For tool-aware generation, use a more focused system prompt
        tool_system_prompt = f"""You are Waycore AI with access to device tools.
{tool_prompt}

CRITICAL: If the user asks about device data (temperature, location, battery,
compass, time), respond with ONLY the tool call JSON. No other text."""

        # Build message history
        messages: list[dict[str, str]] = [
            {"role": "system", "content": tool_system_prompt},
        ]

        # Add conversation history
        if conversation_history:
            for msg in conversation_history:
                messages.append({"role": msg["role"], "content": msg["content"]})

        # Add current user message
        messages.append({"role": "user", "content": user_message})

        logger.info(f"Tool-aware generation for: {user_message}")
        logger.debug(f"System prompt length: {len(tool_system_prompt)}")

        try:
            response = self._llm.create_chat_completion(
                messages=messages,
                max_tokens=256,  # Shorter for tool calls
                temperature=0.3,  # Lower temp for more deterministic tool calls
                top_p=0.9,
                stop=["<|end|>", "<|user|>"],
            )

            content: str = response["choices"][0]["message"]["content"]
            logger.info(f"LLM response: {content[:200]}")
            return content.strip()
        except Exception as e:
            logger.error(f"Phi-3 generation error: {e}")
            return f"Error generating response: {e}"

    def generate_final_response(
        self,
        user_message: str,
        tool_results: str,
        conversation_history: list[dict[str, str]] | None = None,
    ) -> str:
        """Generate final response after tool execution.

        Args:
            user_message: The original user message.
            tool_results: Formatted results from tool execution.
            conversation_history: Previous messages.

        Returns:
            Final response incorporating tool results.
        """
        if not self._ensure_loaded():
            return tool_results  # Just return tool results if model unavailable

        # Build prompt that includes tool results
        messages: list[dict[str, str]] = [
            {"role": "system", "content": SYSTEM_PROMPT},
        ]

        # Add conversation history
        if conversation_history:
            for msg in conversation_history:
                messages.append({"role": msg["role"], "content": msg["content"]})

        # Add user message and tool results as context
        combined_content = (
            f"User question: {user_message}\n\n"
            f"I retrieved the following information:\n{tool_results}\n\n"
            f"Please provide a helpful response based on this information."
        )
        messages.append({"role": "user", "content": combined_content})

        try:
            response = self._llm.create_chat_completion(
                messages=messages,
                max_tokens=512,
                temperature=0.7,
                top_p=0.9,
                stop=["<|end|>", "<|user|>"],
            )

            content: str = response["choices"][0]["message"]["content"]
            return content.strip()
        except Exception as e:
            logger.error(f"Phi-3 final response error: {e}")
            # Fall back to returning just the tool results
            return tool_results

    def unload(self) -> None:
        """Unload the model to free memory."""
        if self._llm is not None:
            del self._llm
            self._llm = None
            self._available = None
            logger.info("Phi-3 model unloaded")

    @property
    def is_loaded(self) -> bool:
        """Check if model is currently loaded."""
        return self._llm is not None
