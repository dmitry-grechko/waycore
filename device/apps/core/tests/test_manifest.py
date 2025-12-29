"""Tests for manifest loading and validation."""

from __future__ import annotations

import json
from pathlib import Path

import pytest
from device.apps.core.manifest import (
    ManifestLoadError,
    load_manifest,
    resolve_entry_paths,
    validate_manifest_data,
)
from device.libs.schemas.app_manifest import AppEntry, AppManifest


class TestLoadManifest:
    """Tests for loading manifests from files."""

    def test_load_valid_manifest(self, tmp_path: Path) -> None:
        """Test loading a valid manifest file."""
        manifest_data = {
            "id": "com.waycore.test",
            "name": "Test App",
            "version": "1.0.0",
            "icon": "🧪",
            "entry": {"qml": "qml/Main.qml"},
        }

        manifest_path = tmp_path / "manifest.json"
        manifest_path.write_text(json.dumps(manifest_data))

        manifest = load_manifest(manifest_path)

        assert manifest.id == "com.waycore.test"
        assert manifest.name == "Test App"
        assert manifest.version == "1.0.0"

    def test_load_manifest_file_not_found(self, tmp_path: Path) -> None:
        """Test error when manifest file doesn't exist."""
        manifest_path = tmp_path / "nonexistent" / "manifest.json"

        with pytest.raises(ManifestLoadError) as exc:
            load_manifest(manifest_path)

        assert "File not found" in str(exc.value)
        assert exc.value.path == manifest_path

    def test_load_manifest_invalid_json(self, tmp_path: Path) -> None:
        """Test error when manifest contains invalid JSON."""
        manifest_path = tmp_path / "manifest.json"
        manifest_path.write_text("{ invalid json }")

        with pytest.raises(ManifestLoadError) as exc:
            load_manifest(manifest_path)

        assert "Invalid JSON" in str(exc.value)

    def test_load_manifest_validation_error(self, tmp_path: Path) -> None:
        """Test error when manifest fails validation."""
        manifest_data = {
            "id": "invalid",  # Invalid: single segment
            "name": "Test",
            "version": "1.0.0",
            "icon": "📱",
            "entry": {"qml": "qml/Main.qml"},
        }

        manifest_path = tmp_path / "manifest.json"
        manifest_path.write_text(json.dumps(manifest_data))

        with pytest.raises(ManifestLoadError) as exc:
            load_manifest(manifest_path)

        assert "Validation failed" in str(exc.value)
        assert exc.value.details is not None
        assert "validation_errors" in exc.value.details

    def test_load_manifest_missing_required_field(self, tmp_path: Path) -> None:
        """Test error when manifest is missing required fields."""
        manifest_data = {
            "id": "com.waycore.test",
            # Missing: name, version, icon, entry
        }

        manifest_path = tmp_path / "manifest.json"
        manifest_path.write_text(json.dumps(manifest_data))

        with pytest.raises(ManifestLoadError) as exc:
            load_manifest(manifest_path)

        assert "Validation failed" in str(exc.value)

    def test_load_manifest_with_optional_fields(self, tmp_path: Path) -> None:
        """Test loading manifest with optional fields."""
        manifest_data = {
            "id": "com.waycore.compass",
            "name": "Compass",
            "version": "1.0.0",
            "description": "Navigation compass",
            "icon": "🧭",
            "category": "navigation",
            "entry": {
                "qml": "qml/CompassMain.qml",
                "backend": "backend/service.py",
            },
            "permissions": ["sensors.magnetometer"],
            "sensors": [{"type": "magnetometer", "required": True}],
            "tier": 1,
            "homePosition": 2,
            "enabled": True,
            "minCoreVersion": "1.0.0",
        }

        manifest_path = tmp_path / "manifest.json"
        manifest_path.write_text(json.dumps(manifest_data))

        manifest = load_manifest(manifest_path)

        assert manifest.description == "Navigation compass"
        assert manifest.category.value == "navigation"  # type: ignore[union-attr]
        assert manifest.entry.backend == "backend/service.py"
        assert manifest.tier == 1
        assert manifest.home_position == 2


class TestValidateManifestData:
    """Tests for validating manifest data dictionaries."""

    def test_validate_valid_data(self) -> None:
        """Test validation of valid manifest data."""
        data = {
            "id": "com.waycore.test",
            "name": "Test",
            "version": "1.0.0",
            "icon": "📱",
            "entry": {"qml": "qml/Main.qml"},
        }

        is_valid, error, manifest = validate_manifest_data(data)

        assert is_valid is True
        assert error is None
        assert manifest is not None
        assert manifest.id == "com.waycore.test"

    def test_validate_invalid_data(self) -> None:
        """Test validation of invalid manifest data."""
        data = {
            "id": "invalid",  # Invalid format
            "name": "Test",
            "version": "1.0",  # Invalid format
            "icon": "📱",
            "entry": {"qml": "qml/Main.qml"},
        }

        is_valid, error, manifest = validate_manifest_data(data)

        assert is_valid is False
        assert error is not None
        assert manifest is None
        assert "id" in error or "version" in error


class TestResolveEntryPaths:
    """Tests for resolving entry point paths."""

    def test_resolve_qml_entry(self, tmp_path: Path) -> None:
        """Test resolving QML entry path."""
        # Create app structure
        qml_dir = tmp_path / "qml"
        qml_dir.mkdir()
        qml_file = qml_dir / "Main.qml"
        qml_file.write_text("// QML content")

        manifest = AppManifest(
            id="com.waycore.test",
            name="Test",
            version="1.0.0",
            icon="📱",
            entry=AppEntry(qml="qml/Main.qml"),
        )

        qml_path, backend_path = resolve_entry_paths(manifest, tmp_path)

        assert qml_path == qml_file
        assert qml_path.exists()
        assert backend_path is None

    def test_resolve_with_backend(self, tmp_path: Path) -> None:
        """Test resolving paths with backend module."""
        # Create app structure
        qml_dir = tmp_path / "qml"
        qml_dir.mkdir()
        qml_file = qml_dir / "Main.qml"
        qml_file.write_text("// QML content")

        backend_dir = tmp_path / "backend"
        backend_dir.mkdir()
        backend_file = backend_dir / "service.py"
        backend_file.write_text("# Python backend")

        manifest = AppManifest(
            id="com.waycore.test",
            name="Test",
            version="1.0.0",
            icon="📱",
            entry=AppEntry(qml="qml/Main.qml", backend="backend/service.py"),
        )

        qml_path, backend_path = resolve_entry_paths(manifest, tmp_path)

        assert qml_path.exists()
        assert backend_path is not None
        assert backend_path.exists()

    def test_resolve_missing_qml(self, tmp_path: Path) -> None:
        """Test error when QML entry doesn't exist."""
        manifest = AppManifest(
            id="com.waycore.test",
            name="Test",
            version="1.0.0",
            icon="📱",
            entry=AppEntry(qml="qml/Main.qml"),
        )

        with pytest.raises(ManifestLoadError) as exc:
            resolve_entry_paths(manifest, tmp_path)

        assert "QML entry point not found" in str(exc.value)

    def test_resolve_missing_backend_logs_warning(
        self, tmp_path: Path, caplog: pytest.LogCaptureFixture
    ) -> None:
        """Test that missing backend logs a warning but doesn't fail."""
        # Create QML but not backend
        qml_dir = tmp_path / "qml"
        qml_dir.mkdir()
        qml_file = qml_dir / "Main.qml"
        qml_file.write_text("// QML content")

        manifest = AppManifest(
            id="com.waycore.test",
            name="Test",
            version="1.0.0",
            icon="📱",
            entry=AppEntry(qml="qml/Main.qml", backend="backend/service.py"),
        )

        qml_path, backend_path = resolve_entry_paths(manifest, tmp_path)

        assert qml_path.exists()
        assert backend_path is None  # Returns None for missing backend
        assert "Backend declared but not found" in caplog.text
