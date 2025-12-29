"""Tests for app loader."""

from __future__ import annotations

import json
from pathlib import Path

from device.apps.core.loader import SKIP_DIRECTORIES, AppLoader


class TestAppLoader:
    """Tests for AppLoader."""

    def test_discover_no_apps(self, tmp_path: Path) -> None:
        """Test discovery with empty apps directory."""
        loader = AppLoader(tmp_path)
        result = loader.discover_apps()

        assert result.success_count == 0
        assert result.error_count == 0

    def test_discover_nonexistent_directory(self, tmp_path: Path) -> None:
        """Test discovery with nonexistent directory."""
        loader = AppLoader(tmp_path / "nonexistent")
        result = loader.discover_apps()

        assert result.success_count == 0
        assert result.error_count == 0

    def test_discover_single_app(self, tmp_path: Path) -> None:
        """Test discovery of a single valid app."""
        # Create app directory
        app_dir = tmp_path / "myapp"
        app_dir.mkdir()
        (app_dir / "qml").mkdir()
        (app_dir / "qml" / "Main.qml").write_text("// QML")

        manifest = {
            "id": "com.waycore.myapp",
            "name": "My App",
            "version": "1.0.0",
            "icon": "📱",
            "entry": {"qml": "qml/Main.qml"},
        }
        (app_dir / "manifest.json").write_text(json.dumps(manifest))

        loader = AppLoader(tmp_path)
        result = loader.discover_apps()

        assert result.success_count == 1
        assert result.error_count == 0
        assert result.apps[0].manifest.id == "com.waycore.myapp"
        assert result.apps[0].manifest.name == "My App"

    def test_discover_multiple_apps(self, tmp_path: Path) -> None:
        """Test discovery of multiple apps."""
        # Create two apps
        for name, icon in [("app1", "🅰️"), ("app2", "🅱️")]:
            app_dir = tmp_path / name
            app_dir.mkdir()
            (app_dir / "qml").mkdir()
            (app_dir / "qml" / "Main.qml").write_text("// QML")

            manifest = {
                "id": f"com.waycore.{name}",
                "name": name.upper(),
                "version": "1.0.0",
                "icon": icon,
                "entry": {"qml": "qml/Main.qml"},
            }
            (app_dir / "manifest.json").write_text(json.dumps(manifest))

        loader = AppLoader(tmp_path)
        result = loader.discover_apps()

        assert result.success_count == 2
        assert result.error_count == 0
        app_ids = {a.manifest.id for a in result.apps}
        assert app_ids == {"com.waycore.app1", "com.waycore.app2"}

    def test_discover_skips_special_directories(self, tmp_path: Path) -> None:
        """Test that special directories are skipped."""
        for dir_name in SKIP_DIRECTORIES:
            skip_dir = tmp_path / dir_name
            skip_dir.mkdir()
            # Add a valid manifest that should be ignored
            manifest = {
                "id": f"com.waycore.{dir_name}",
                "name": "Skip Me",
                "version": "1.0.0",
                "icon": "❌",
                "entry": {"qml": "qml/Main.qml"},
            }
            (skip_dir / "manifest.json").write_text(json.dumps(manifest))

        loader = AppLoader(tmp_path)
        result = loader.discover_apps()

        assert result.success_count == 0

    def test_discover_skips_hidden_directories(self, tmp_path: Path) -> None:
        """Test that hidden directories (starting with .) are skipped."""
        hidden_dir = tmp_path / ".hidden"
        hidden_dir.mkdir()
        (hidden_dir / "qml").mkdir()
        (hidden_dir / "qml" / "Main.qml").write_text("// QML")

        manifest = {
            "id": "com.waycore.hidden",
            "name": "Hidden",
            "version": "1.0.0",
            "icon": "👀",
            "entry": {"qml": "qml/Main.qml"},
        }
        (hidden_dir / "manifest.json").write_text(json.dumps(manifest))

        loader = AppLoader(tmp_path)
        result = loader.discover_apps()

        assert result.success_count == 0

    def test_discover_skips_underscore_directories(self, tmp_path: Path) -> None:
        """Test that directories starting with _ are skipped."""
        underscore_dir = tmp_path / "_private"
        underscore_dir.mkdir()
        (underscore_dir / "qml").mkdir()
        (underscore_dir / "qml" / "Main.qml").write_text("// QML")

        manifest = {
            "id": "com.waycore.private",
            "name": "Private",
            "version": "1.0.0",
            "icon": "🔒",
            "entry": {"qml": "qml/Main.qml"},
        }
        (underscore_dir / "manifest.json").write_text(json.dumps(manifest))

        loader = AppLoader(tmp_path)
        result = loader.discover_apps()

        assert result.success_count == 0

    def test_discover_skips_directories_without_manifest(self, tmp_path: Path) -> None:
        """Test that directories without manifest.json are skipped."""
        no_manifest_dir = tmp_path / "nomanifest"
        no_manifest_dir.mkdir()
        (no_manifest_dir / "qml").mkdir()
        (no_manifest_dir / "qml" / "Main.qml").write_text("// QML")

        loader = AppLoader(tmp_path)
        result = loader.discover_apps()

        assert result.success_count == 0
        assert result.error_count == 0

    def test_discover_invalid_manifest_creates_error(self, tmp_path: Path) -> None:
        """Test that invalid manifests are reported as errors."""
        app_dir = tmp_path / "badapp"
        app_dir.mkdir()
        (app_dir / "manifest.json").write_text('{"invalid": "manifest"}')

        loader = AppLoader(tmp_path)
        result = loader.discover_apps()

        assert result.success_count == 0
        assert result.error_count == 1
        assert result.errors[0].error_type == "manifest_error"

    def test_discover_disabled_app_not_included(self, tmp_path: Path) -> None:
        """Test that disabled apps are not included in results."""
        app_dir = tmp_path / "disabled"
        app_dir.mkdir()
        (app_dir / "qml").mkdir()
        (app_dir / "qml" / "Main.qml").write_text("// QML")

        manifest = {
            "id": "com.waycore.disabled",
            "name": "Disabled",
            "version": "1.0.0",
            "icon": "🚫",
            "entry": {"qml": "qml/Main.qml"},
            "enabled": False,
        }
        (app_dir / "manifest.json").write_text(json.dumps(manifest))

        loader = AppLoader(tmp_path)
        result = loader.discover_apps()

        assert result.success_count == 0
        assert result.error_count == 0

    def test_load_single_app(self, tmp_path: Path) -> None:
        """Test loading a single app by ID."""
        app_dir = tmp_path / "myapp"
        app_dir.mkdir()
        (app_dir / "qml").mkdir()
        (app_dir / "qml" / "Main.qml").write_text("// QML")

        manifest = {
            "id": "com.waycore.myapp",
            "name": "My App",
            "version": "1.0.0",
            "icon": "📱",
            "entry": {"qml": "qml/Main.qml"},
        }
        (app_dir / "manifest.json").write_text(json.dumps(manifest))

        loader = AppLoader(tmp_path)
        app = loader.load_single_app("com.waycore.myapp")

        assert app is not None
        assert app.manifest.id == "com.waycore.myapp"

    def test_load_single_app_not_found(self, tmp_path: Path) -> None:
        """Test loading nonexistent app returns None."""
        loader = AppLoader(tmp_path)
        app = loader.load_single_app("com.waycore.nonexistent")

        assert app is None

    def test_get_manifest(self, tmp_path: Path) -> None:
        """Test getting manifest for an app."""
        app_dir = tmp_path / "myapp"
        app_dir.mkdir()
        (app_dir / "qml").mkdir()
        (app_dir / "qml" / "Main.qml").write_text("// QML")

        manifest = {
            "id": "com.waycore.myapp",
            "name": "My App",
            "version": "1.0.0",
            "icon": "📱",
            "entry": {"qml": "qml/Main.qml"},
        }
        (app_dir / "manifest.json").write_text(json.dumps(manifest))

        loader = AppLoader(tmp_path)
        result = loader.get_manifest("com.waycore.myapp")

        assert result is not None
        assert result.id == "com.waycore.myapp"

    def test_apps_sorted_by_tier_and_name(self, tmp_path: Path) -> None:
        """Test that apps are sorted by tier then by name."""
        apps_data = [
            ("zebra", "Zebra", 2),
            ("alpha", "Alpha", 1),
            ("beta", "Beta", 2),
            ("gamma", "Gamma", 1),
        ]

        for name, display_name, tier in apps_data:
            app_dir = tmp_path / name
            app_dir.mkdir()
            (app_dir / "qml").mkdir()
            (app_dir / "qml" / "Main.qml").write_text("// QML")

            manifest = {
                "id": f"com.waycore.{name}",
                "name": display_name,
                "version": "1.0.0",
                "icon": "📱",
                "entry": {"qml": "qml/Main.qml"},
                "tier": tier,
            }
            (app_dir / "manifest.json").write_text(json.dumps(manifest))

        loader = AppLoader(tmp_path)
        result = loader.discover_apps()

        # Should be sorted: tier 1 (Alpha, Gamma), tier 2 (Beta, Zebra)
        names = [a.manifest.name for a in result.apps]
        assert names == ["Alpha", "Gamma", "Beta", "Zebra"]
