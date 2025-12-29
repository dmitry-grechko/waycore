# Waycore Scripts

Utility scripts for development, task management, code generation, and AI model management.

## Quick Reference

| Script | Description |
|--------|-------------|
| `dev-start.sh` | Start Docker services |
| `dev-stop.sh` | Stop Docker services |
| `task-start.sh TASK_ID` | Start a task |
| `task-complete.sh TASK_ID` | Complete a task |
| `create-app.py APP_NAME` | Scaffold a new app |

## Development Environment

Scripts for managing Docker development services.

```bash
# Start all development services (Mosquitto, etc.)
./scripts/dev-start.sh

# Stop all services
./scripts/dev-stop.sh

# Restart services
./scripts/dev-restart.sh

# Check status of running services
./scripts/dev-status.sh
```

## Task Management

Scripts for the file-based progress tracking system. See `docs/ai_instructions/progress_tracking.md`.

```bash
# Start working on a task (moves to IN_PROGRESS)
./scripts/task-start.sh 18.1

# Complete a task (moves to COMPLETED/YYYY-MM/)
./scripts/task-complete.sh 18.1

# Generate a progress summary
poetry run python scripts/generate-summary.py

# Generate new task files from template
poetry run python scripts/generate-tasks.py
```

## App Development

Scripts for creating and managing apps.

```bash
# Create a new app with QML only
poetry run python scripts/create-app.py my-app

# Create a new app with Python backend
poetry run python scripts/create-app.py my-app --backend
```

## AI Models

Scripts for managing AI models (language, vision, embeddings).

```bash
# Download required AI models
./scripts/download-models.sh

# Upload a model to storage
./scripts/upload-model.sh /path/to/model.gguf
```

## Knowledge Base / RAG

Scripts for managing the outdoor knowledge base.

```bash
# Download RAG source documents
./scripts/download-rag-sources.sh

# Verify RAG sources are present
./scripts/verify-rag-sources.sh

# Build/rebuild the RAG index
poetry run python scripts/build-rag-index.py

# Download pre-built knowledge base
./scripts/download-knowledge.sh

# Verify knowledge base integrity
./scripts/verify-knowledge.sh

# Show knowledge base info
./scripts/knowledge-info.sh
```

## Code Generation

Scripts for generating documentation and specs.

```bash
# Generate OpenAPI specs for all services
poetry run python scripts/generate-openapi.py

# Generate progress summary markdown
poetry run python scripts/generate-summary.py
```

## QML Validation

```bash
# Validate QML syntax (requires qmlscene)
./scripts/validate-qml.sh
```

## Script Categories

### Shell Scripts (`.sh`)

- **Development**: `dev-*.sh` - Docker environment management
- **Task Management**: `task-*.sh` - Shell wrappers for Python scripts
- **Models**: `download-models.sh`, `upload-model.sh`
- **Knowledge**: `*-knowledge.sh`, `*-rag-*.sh`

### Python Scripts (`.py`)

- **App Development**: `create-app.py`
- **Code Generation**: `generate-*.py`
- **RAG**: `build-rag-index.py`
- **Task Management**: `task_start.py`, `task_complete.py`

## Running Python Scripts

All Python scripts should be run with Poetry:

```bash
poetry run python scripts/SCRIPT_NAME.py [args]
```

Or with the Python path configured:

```bash
cd /path/to/waycore
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
python scripts/SCRIPT_NAME.py [args]
```
