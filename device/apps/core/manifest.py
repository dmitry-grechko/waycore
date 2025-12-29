"""App manifest loading and validation.

This module provides utilities for reading, validating, and working with
app manifest files.
"""

from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Any

from device.libs.schemas.app_manifest import AppManifest
from pydantic import ValidationError

logger = logging.getLogger(__name__)


class ManifestLoadError(Exception):
    """Exception raised when a manifest cannot be loaded or is invalid."""

    def __init__(self, path: Path, message: str, details: dict[str, Any] | None = None) -> None:
        self.path = path
        self.details = details or {}
        super().__init__(f"Failed to load manifest at {path}: {message}")


def load_manifest(manifest_path: Path) -> AppManifest:
    """
    Load and validate an app manifest from a JSON file.

    Args:
        manifest_path: Path to the manifest.json file

    Returns:
        Validated AppManifest object

    Raises:
        ManifestLoadError: If the file cannot be read or validation fails
    """
    if not manifest_path.exists():
        raise ManifestLoadError(manifest_path, "File not found")

    if not manifest_path.is_file():
        raise ManifestLoadError(manifest_path, "Path is not a file")

    try:
        with open(manifest_path, encoding="utf-8") as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        raise ManifestLoadError(
            manifest_path,
            f"Invalid JSON: {e.msg}",
            {"line": e.lineno, "column": e.colno},
        ) from e
    except OSError as e:
        raise ManifestLoadError(manifest_path, f"Cannot read file: {e}") from e

    try:
        return AppManifest(**data)
    except ValidationError as e:
        # Format validation errors for better readability
        error_details = []
        for error in e.errors():
            loc = ".".join(str(x) for x in error["loc"])
            error_details.append(f"  - {loc}: {error['msg']}")

        raise ManifestLoadError(
            manifest_path,
            "Validation failed:\n" + "\n".join(error_details),
            {"validation_errors": e.errors()},
        ) from e


def validate_manifest_data(
    data: dict[str, Any],
) -> tuple[bool, str | None, AppManifest | None]:
    """
    Validate manifest data without loading from file.

    Args:
        data: Dictionary containing manifest data

    Returns:
        Tuple of (is_valid, error_message, manifest_or_none)
    """
    try:
        manifest = AppManifest(**data)
        return True, None, manifest
    except ValidationError as e:
        error_msgs = []
        for error in e.errors():
            loc = ".".join(str(x) for x in error["loc"])
            error_msgs.append(f"{loc}: {error['msg']}")
        return False, "; ".join(error_msgs), None


def resolve_entry_paths(manifest: AppManifest, app_dir: Path) -> tuple[Path, Path | None]:
    """
    Resolve the QML and backend entry paths relative to app directory.

    Args:
        manifest: The app manifest
        app_dir: The app's root directory

    Returns:
        Tuple of (qml_entry_path, backend_path_or_none)

    Raises:
        ManifestLoadError: If required QML entry does not exist
    """
    qml_path = app_dir / manifest.entry.qml

    if not qml_path.exists():
        raise ManifestLoadError(
            app_dir / "manifest.json",
            f"QML entry point not found: {manifest.entry.qml}",
            {"expected_path": str(qml_path)},
        )

    backend_path = None
    if manifest.entry.backend:
        backend_path = app_dir / manifest.entry.backend
        # Backend is optional - don't fail if it doesn't exist yet
        if not backend_path.exists():
            logger.warning(
                f"Backend declared but not found: {manifest.entry.backend} in {app_dir.name}"
            )
            backend_path = None

    return qml_path, backend_path
