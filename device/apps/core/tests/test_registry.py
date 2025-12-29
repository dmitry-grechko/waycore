"""Tests for app registry."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import MagicMock

from device.apps.core.registry import AppRegistry
from device.apps.core.types import LoadedApp
from device.libs.schemas.app_manifest import AppCategory, AppEntry, AppManifest


def make_loaded_app(
    app_id: str,
    name: str,
    tier: int = 2,
    category: AppCategory | None = None,
    home_position: int | None = None,
) -> LoadedApp:
    """Helper to create LoadedApp for testing."""
    manifest = AppManifest(
        id=app_id,
        name=name,
        version="1.0.0",
        icon="📱",
        entry=AppEntry(qml="qml/Main.qml"),
        tier=tier,
        category=category,
        homePosition=home_position,
    )
    return LoadedApp(
        manifest=manifest,
        app_dir=Path(f"/apps/{name.lower()}"),
        qml_entry=Path(f"/apps/{name.lower()}/qml/Main.qml"),
    )


class TestAppRegistry:
    """Tests for AppRegistry."""

    def test_register_and_get(self) -> None:
        """Test registering and retrieving an app."""
        registry = AppRegistry()
        app = make_loaded_app("com.waycore.test", "Test")

        registry.register(app)
        retrieved = registry.get("com.waycore.test")

        assert retrieved is not None
        assert retrieved.manifest.id == "com.waycore.test"

    def test_get_nonexistent_returns_none(self) -> None:
        """Test that getting nonexistent app returns None."""
        registry = AppRegistry()
        result = registry.get("com.waycore.nonexistent")

        assert result is None

    def test_unregister(self) -> None:
        """Test unregistering an app."""
        registry = AppRegistry()
        app = make_loaded_app("com.waycore.test", "Test")

        registry.register(app)
        assert registry.is_registered("com.waycore.test")

        result = registry.unregister("com.waycore.test")
        assert result is True
        assert not registry.is_registered("com.waycore.test")

    def test_unregister_nonexistent(self) -> None:
        """Test unregistering nonexistent app returns False."""
        registry = AppRegistry()
        result = registry.unregister("com.waycore.nonexistent")

        assert result is False

    def test_get_tier1_apps(self) -> None:
        """Test getting tier 1 apps."""
        registry = AppRegistry()
        registry.register(make_loaded_app("com.waycore.t1a", "T1A", tier=1))
        registry.register(make_loaded_app("com.waycore.t1b", "T1B", tier=1))
        registry.register(make_loaded_app("com.waycore.t2a", "T2A", tier=2))

        tier1 = registry.get_tier1_apps()

        assert len(tier1) == 2
        assert all(m.tier == 1 for m in tier1)

    def test_get_tier1_apps_sorted_by_position(self) -> None:
        """Test tier 1 apps are sorted by homePosition."""
        registry = AppRegistry()
        registry.register(make_loaded_app("com.waycore.last", "Last", tier=1, home_position=2))
        registry.register(make_loaded_app("com.waycore.first", "First", tier=1, home_position=0))
        registry.register(make_loaded_app("com.waycore.mid", "Mid", tier=1, home_position=1))

        tier1 = registry.get_tier1_apps()
        names = [m.name for m in tier1]

        assert names == ["First", "Mid", "Last"]

    def test_get_tier1_apps_sorted_by_name_when_no_position(self) -> None:
        """Test tier 1 apps sorted by name when no homePosition."""
        registry = AppRegistry()
        registry.register(make_loaded_app("com.waycore.zebra", "Zebra", tier=1))
        registry.register(make_loaded_app("com.waycore.alpha", "Alpha", tier=1))
        registry.register(make_loaded_app("com.waycore.beta", "Beta", tier=1))

        tier1 = registry.get_tier1_apps()
        names = [m.name for m in tier1]

        assert names == ["Alpha", "Beta", "Zebra"]

    def test_get_tier2_apps(self) -> None:
        """Test getting tier 2 apps."""
        registry = AppRegistry()
        registry.register(make_loaded_app("com.waycore.t1", "T1", tier=1))
        registry.register(make_loaded_app("com.waycore.t2a", "T2A", tier=2))
        registry.register(make_loaded_app("com.waycore.t2b", "T2B", tier=2))

        tier2 = registry.get_tier2_apps()

        assert len(tier2) == 2
        assert all(m.tier == 2 for m in tier2)

    def test_get_tier2_apps_sorted_by_category(self) -> None:
        """Test tier 2 apps are sorted by category then name."""
        registry = AppRegistry()
        registry.register(
            make_loaded_app("com.waycore.nav1", "Nav1", tier=2, category=AppCategory.NAVIGATION)
        )
        registry.register(
            make_loaded_app("com.waycore.ai1", "AI1", tier=2, category=AppCategory.AI)
        )
        registry.register(
            make_loaded_app("com.waycore.nav2", "Nav2", tier=2, category=AppCategory.NAVIGATION)
        )

        tier2 = registry.get_tier2_apps()
        names = [m.name for m in tier2]

        # AI comes before Navigation alphabetically
        assert names == ["AI1", "Nav1", "Nav2"]

    def test_get_all_apps(self) -> None:
        """Test getting all apps."""
        registry = AppRegistry()
        registry.register(make_loaded_app("com.waycore.a", "A"))
        registry.register(make_loaded_app("com.waycore.b", "B"))

        all_apps = registry.get_all_apps()

        assert len(all_apps) == 2

    def test_get_apps_by_category(self) -> None:
        """Test getting apps by category."""
        registry = AppRegistry()
        registry.register(
            make_loaded_app("com.waycore.nav", "Nav", category=AppCategory.NAVIGATION)
        )
        registry.register(make_loaded_app("com.waycore.ai", "AI", category=AppCategory.AI))
        registry.register(
            make_loaded_app("com.waycore.util", "Util", category=AppCategory.UTILITIES)
        )

        nav_apps = registry.get_apps_by_category(AppCategory.NAVIGATION)

        assert len(nav_apps) == 1
        assert nav_apps[0].name == "Nav"

    def test_is_registered(self) -> None:
        """Test checking if app is registered."""
        registry = AppRegistry()
        app = make_loaded_app("com.waycore.test", "Test")

        assert not registry.is_registered("com.waycore.test")
        registry.register(app)
        assert registry.is_registered("com.waycore.test")

    def test_count(self) -> None:
        """Test counting registered apps."""
        registry = AppRegistry()
        assert registry.count() == 0

        registry.register(make_loaded_app("com.waycore.a", "A"))
        assert registry.count() == 1

        registry.register(make_loaded_app("com.waycore.b", "B"))
        assert registry.count() == 2

    def test_listener_called_on_register(self) -> None:
        """Test that listeners are called when apps are registered."""
        registry = AppRegistry()
        listener = MagicMock()
        registry.add_listener(listener)

        app = make_loaded_app("com.waycore.test", "Test")
        registry.register(app)

        listener.assert_called_once_with("registered", "com.waycore.test")

    def test_listener_called_on_unregister(self) -> None:
        """Test that listeners are called when apps are unregistered."""
        registry = AppRegistry()
        listener = MagicMock()
        app = make_loaded_app("com.waycore.test", "Test")
        registry.register(app)

        registry.add_listener(listener)
        registry.unregister("com.waycore.test")

        listener.assert_called_once_with("unregistered", "com.waycore.test")

    def test_remove_listener(self) -> None:
        """Test removing a listener."""
        registry = AppRegistry()
        listener = MagicMock()
        registry.add_listener(listener)
        registry.remove_listener(listener)

        app = make_loaded_app("com.waycore.test", "Test")
        registry.register(app)

        listener.assert_not_called()

    def test_clear(self) -> None:
        """Test clearing all apps."""
        registry = AppRegistry()
        registry.register(make_loaded_app("com.waycore.a", "A"))
        registry.register(make_loaded_app("com.waycore.b", "B"))

        assert registry.count() == 2
        registry.clear()
        assert registry.count() == 0

    def test_get_manifest(self) -> None:
        """Test getting manifest by ID."""
        registry = AppRegistry()
        app = make_loaded_app("com.waycore.test", "Test")
        registry.register(app)

        manifest = registry.get_manifest("com.waycore.test")

        assert manifest is not None
        assert manifest.id == "com.waycore.test"

    def test_get_manifest_nonexistent(self) -> None:
        """Test getting manifest for nonexistent app."""
        registry = AppRegistry()
        manifest = registry.get_manifest("com.waycore.nonexistent")

        assert manifest is None
