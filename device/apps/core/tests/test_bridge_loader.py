"""Tests for BridgeLoader."""

from __future__ import annotations

from pathlib import Path

import pytest
from device.apps.core.bridge_loader import (
    BridgeLoader,
    BridgeLoadError,
    get_bridge_loader,
    reset_bridge_loader,
)


@pytest.fixture
def loader() -> BridgeLoader:
    """Create a fresh BridgeLoader instance for testing."""
    return BridgeLoader()


@pytest.fixture
def temp_app_dir(tmp_path: Path) -> Path:
    """Create a temporary app directory structure."""
    app_dir = tmp_path / "test_app"
    app_dir.mkdir()
    backend_dir = app_dir / "backend"
    backend_dir.mkdir()
    return app_dir


@pytest.fixture(autouse=True)
def reset_global() -> None:
    """Reset global bridge loader before each test."""
    reset_bridge_loader()
    yield
    reset_bridge_loader()


class TestBridgeLoader:
    """Tests for the BridgeLoader class."""

    def test_load_bridge_success(self, loader: BridgeLoader, temp_app_dir: Path) -> None:
        """Test successfully loading a bridge."""
        # Create a valid backend module
        backend_file = temp_app_dir / "backend" / "service.py"
        backend_file.write_text(
            """
class TestBridge:
    def __init__(self):
        self.name = "test_bridge"

def create_bridge():
    return TestBridge()
"""
        )

        bridge = loader.load_bridge(temp_app_dir, "backend/service.py")

        assert bridge is not None
        assert bridge.name == "test_bridge"

    def test_load_bridge_missing_module(self, loader: BridgeLoader, temp_app_dir: Path) -> None:
        """Test loading a bridge with missing module file."""
        bridge = loader.load_bridge(temp_app_dir, "backend/nonexistent.py")
        assert bridge is None

    def test_load_bridge_no_factory(self, loader: BridgeLoader, temp_app_dir: Path) -> None:
        """Test loading a bridge without factory function."""
        # Create a module without create_bridge
        backend_file = temp_app_dir / "backend" / "service.py"
        backend_file.write_text(
            """
class TestBridge:
    pass

# No create_bridge function
"""
        )

        bridge = loader.load_bridge(temp_app_dir, "backend/service.py")
        assert bridge is None

    def test_load_bridge_factory_error(self, loader: BridgeLoader, temp_app_dir: Path) -> None:
        """Test loading a bridge with factory that raises."""
        # Create a module with failing factory
        backend_file = temp_app_dir / "backend" / "service.py"
        backend_file.write_text(
            """
def create_bridge():
    raise ValueError("Factory error")
"""
        )

        with pytest.raises(BridgeLoadError) as exc_info:
            loader.load_bridge(temp_app_dir, "backend/service.py")

        assert "Factory error" in str(exc_info.value.details)

    def test_load_bridge_custom_factory_name(
        self, loader: BridgeLoader, temp_app_dir: Path
    ) -> None:
        """Test loading a bridge with custom factory name."""
        backend_file = temp_app_dir / "backend" / "service.py"
        backend_file.write_text(
            """
def custom_factory():
    return {"custom": True}
"""
        )

        bridge = loader.load_bridge(
            temp_app_dir, "backend/service.py", factory_name="custom_factory"
        )

        assert bridge is not None
        assert bridge["custom"] is True

    def test_load_module_success(self, loader: BridgeLoader, temp_app_dir: Path) -> None:
        """Test loading a module without instantiating."""
        backend_file = temp_app_dir / "backend" / "service.py"
        backend_file.write_text(
            """
MODULE_VAR = "test_value"

def some_function():
    return 42
"""
        )

        module = loader.load_module(temp_app_dir, "backend/service.py")

        assert module is not None
        assert module.MODULE_VAR == "test_value"
        assert module.some_function() == 42

    def test_is_loaded(self, loader: BridgeLoader, temp_app_dir: Path) -> None:
        """Test checking if a module is loaded."""
        backend_file = temp_app_dir / "backend" / "service.py"
        backend_file.write_text("x = 1")

        assert loader.is_loaded("test_app") is False

        loader.load_module(temp_app_dir, "backend/service.py")

        assert loader.is_loaded("test_app") is True

    def test_unload_module(self, loader: BridgeLoader, temp_app_dir: Path) -> None:
        """Test unloading a module."""
        backend_file = temp_app_dir / "backend" / "service.py"
        backend_file.write_text("x = 1")

        loader.load_module(temp_app_dir, "backend/service.py")
        assert loader.is_loaded("test_app") is True

        result = loader.unload_module("test_app")
        assert result is True
        assert loader.is_loaded("test_app") is False

    def test_unload_not_loaded(self, loader: BridgeLoader) -> None:
        """Test unloading a module that wasn't loaded."""
        result = loader.unload_module("not_loaded")
        assert result is False

    def test_get_loaded_modules(self, loader: BridgeLoader, temp_app_dir: Path) -> None:
        """Test getting list of loaded modules."""
        assert loader.get_loaded_modules() == []

        backend_file = temp_app_dir / "backend" / "service.py"
        backend_file.write_text("x = 1")
        loader.load_module(temp_app_dir, "backend/service.py")

        loaded = loader.get_loaded_modules()
        assert len(loaded) == 1
        assert "waycore_app_test_app_backend" in loaded[0]

    def test_clear_modules(self, loader: BridgeLoader, temp_app_dir: Path) -> None:
        """Test clearing all loaded modules."""
        backend_file = temp_app_dir / "backend" / "service.py"
        backend_file.write_text("x = 1")
        loader.load_module(temp_app_dir, "backend/service.py")

        loader.clear()

        assert loader.get_loaded_modules() == []


class TestGlobalBridgeLoader:
    """Tests for global bridge loader functions."""

    def test_get_bridge_loader_returns_singleton(self) -> None:
        """Test that get_bridge_loader returns the same instance."""
        first = get_bridge_loader()
        second = get_bridge_loader()
        assert first is second

    def test_reset_bridge_loader(self, temp_app_dir: Path) -> None:
        """Test that reset clears the global instance."""
        loader = get_bridge_loader()

        backend_file = temp_app_dir / "backend" / "service.py"
        backend_file.write_text("x = 1")
        loader.load_module(temp_app_dir, "backend/service.py")

        reset_bridge_loader()
        new_loader = get_bridge_loader()

        assert new_loader is not loader
        assert new_loader.get_loaded_modules() == []


class TestBridgeLoadError:
    """Tests for BridgeLoadError exception."""

    def test_error_has_app_id(self) -> None:
        """Test that error contains app_id."""
        error = BridgeLoadError("Test error", app_id="com.test.app")
        assert error.app_id == "com.test.app"

    def test_error_has_details(self) -> None:
        """Test that error contains details."""
        error = BridgeLoadError("Test error", app_id="com.test.app", details="More info")
        assert error.details == "More info"
