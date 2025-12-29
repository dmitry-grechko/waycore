"""Dynamic bridge loading for app backends.

This module provides functionality to load app-specific backend modules
(bridges) at runtime based on the app manifest.
"""

from __future__ import annotations

import importlib.util
import logging
import sys
from pathlib import Path
from types import ModuleType
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    pass

logger = logging.getLogger(__name__)


class BridgeLoadError(Exception):
    """Exception raised when a bridge fails to load."""

    def __init__(self, message: str, app_id: str, details: str | None = None) -> None:
        super().__init__(message)
        self.app_id = app_id
        self.details = details


class BridgeLoader:
    """Dynamically loads app backend modules.

    The BridgeLoader is responsible for loading Python modules specified
    in app manifests and instantiating their bridge objects.

    Example:
        loader = BridgeLoader()
        bridge = loader.load_bridge(
            app_dir=Path("device/apps/notes"),
            backend_path="backend/service.py"
        )
    """

    def __init__(self) -> None:
        """Initialize the bridge loader."""
        self._loaded_modules: dict[str, ModuleType] = {}

    def load_bridge(
        self,
        app_dir: Path,
        backend_path: str,
        factory_name: str = "create_bridge",
    ) -> Any | None:
        """Load and instantiate an app's backend bridge.

        The backend module should contain a factory function that creates
        the bridge instance.

        Args:
            app_dir: App's root directory
            backend_path: Relative path to backend module (e.g., "backend/service.py")
            factory_name: Name of the factory function (default: "create_bridge")

        Returns:
            Instantiated bridge object or None if loading fails

        Raises:
            BridgeLoadError: If the module cannot be loaded or factory fails
        """
        module_path = app_dir / backend_path
        if not module_path.exists():
            logger.warning(f"Backend module not found: {module_path}")
            return None

        app_id = app_dir.name
        module_name = f"waycore_app_{app_id}_backend"

        try:
            # Load the module
            module = self._load_module(module_path, module_name)
            if module is None:
                return None

            # Look for the factory function
            if not hasattr(module, factory_name):
                logger.warning(f"Backend module {module_path} has no {factory_name}() function")
                return None

            factory = getattr(module, factory_name)
            if not callable(factory):
                logger.warning(f"{factory_name} is not callable in {module_path}")
                return None

            # Call the factory to create the bridge
            bridge = factory()
            logger.info(f"Loaded backend bridge for {app_id}")
            return bridge

        except Exception as e:
            logger.exception(f"Failed to load backend for {app_id}: {e}")
            raise BridgeLoadError(
                f"Failed to load backend: {e}",
                app_id=app_id,
                details=str(e),
            ) from e

    def load_module(
        self,
        app_dir: Path,
        backend_path: str,
    ) -> ModuleType | None:
        """Load an app's backend module without instantiating.

        Useful when you need access to the module itself rather than
        a specific bridge instance.

        Args:
            app_dir: App's root directory
            backend_path: Relative path to backend module

        Returns:
            The loaded module, or None if loading fails
        """
        module_path = app_dir / backend_path
        if not module_path.exists():
            return None

        app_id = app_dir.name
        module_name = f"waycore_app_{app_id}_backend"

        return self._load_module(module_path, module_name)

    def _load_module(self, module_path: Path, module_name: str) -> ModuleType | None:
        """Load a Python module from a file path.

        Args:
            module_path: Full path to the Python file
            module_name: Name to give the module in sys.modules

        Returns:
            The loaded module, or None if loading fails
        """
        # Check if already loaded
        if module_name in self._loaded_modules:
            return self._loaded_modules[module_name]

        try:
            spec = importlib.util.spec_from_file_location(module_name, module_path)
            if spec is None or spec.loader is None:
                logger.warning(f"Could not create spec for {module_path}")
                return None

            module = importlib.util.module_from_spec(spec)
            sys.modules[module_name] = module
            spec.loader.exec_module(module)

            self._loaded_modules[module_name] = module
            logger.debug(f"Loaded module: {module_name}")
            return module

        except Exception as e:
            logger.exception(f"Failed to load module {module_path}: {e}")
            return None

    def unload_module(self, app_id: str) -> bool:
        """Unload an app's backend module.

        Args:
            app_id: The app's identifier

        Returns:
            True if the module was unloaded
        """
        module_name = f"waycore_app_{app_id}_backend"

        if module_name in self._loaded_modules:
            del self._loaded_modules[module_name]
            if module_name in sys.modules:
                del sys.modules[module_name]
            logger.debug(f"Unloaded module: {module_name}")
            return True

        return False

    def is_loaded(self, app_id: str) -> bool:
        """Check if an app's backend module is loaded.

        Args:
            app_id: The app's identifier

        Returns:
            True if the module is loaded
        """
        module_name = f"waycore_app_{app_id}_backend"
        return module_name in self._loaded_modules

    def get_loaded_modules(self) -> list[str]:
        """Get list of loaded module names.

        Returns:
            List of module names
        """
        return list(self._loaded_modules.keys())

    def clear(self) -> None:
        """Clear all loaded modules.

        This is mainly useful for testing.
        """
        for module_name in list(self._loaded_modules.keys()):
            if module_name in sys.modules:
                del sys.modules[module_name]
        self._loaded_modules.clear()


# Global instance
_bridge_loader: BridgeLoader | None = None


def get_bridge_loader() -> BridgeLoader:
    """Get the global bridge loader instance.

    Returns:
        The BridgeLoader singleton
    """
    global _bridge_loader
    if _bridge_loader is None:
        _bridge_loader = BridgeLoader()
    return _bridge_loader


def reset_bridge_loader() -> None:
    """Reset the global bridge loader instance.

    This is mainly useful for testing.
    """
    global _bridge_loader
    if _bridge_loader is not None:
        _bridge_loader.clear()
    _bridge_loader = None
