"""Dynamic backend module loading for apps.

This module provides utilities for dynamically loading app backend modules.
"""

from __future__ import annotations

import importlib.util
import logging
import sys
from pathlib import Path
from typing import Any

from PySide6.QtCore import QObject

logger = logging.getLogger(__name__)


class BackendLoadError(Exception):
    """Exception raised when a backend module cannot be loaded."""

    pass


class BackendLoader:
    """Dynamically loads app backend modules."""

    def load_bridge(self, app_dir: Path, backend_path: str) -> QObject | None:
        """
        Load and instantiate an app's backend bridge.

        The backend module must define a `create_bridge()` factory function
        that returns a QObject instance.

        Args:
            app_dir: App's root directory
            backend_path: Relative path to backend module

        Returns:
            Instantiated bridge QObject or None if loading fails
        """
        module_path = app_dir / backend_path
        if not module_path.exists():
            logger.warning(f"Backend module not found: {module_path}")
            return None

        try:
            module = self._load_module(module_path, app_dir.name)
        except BackendLoadError as e:
            logger.error(f"Failed to load backend module: {e}")
            return None

        # Look for create_bridge factory function
        if not hasattr(module, "create_bridge"):
            logger.warning(f"Backend module {module_path} has no create_bridge() function")
            return None

        try:
            bridge = module.create_bridge()
            if not isinstance(bridge, QObject):
                logger.warning(f"create_bridge() in {module_path} did not return a QObject")
                return None
            return bridge
        except Exception as e:
            logger.exception(f"Error calling create_bridge() in {module_path}: {e}")
            return None

    def _load_module(self, module_path: Path, app_name: str) -> Any:
        """
        Dynamically import a Python module from a file path.

        Args:
            module_path: Path to the Python module file
            app_name: Name of the app (used for module naming)

        Returns:
            The loaded module

        Raises:
            BackendLoadError: If the module cannot be loaded
        """
        module_name = f"waycore_app_{app_name}_backend"

        try:
            spec = importlib.util.spec_from_file_location(module_name, module_path)
            if spec is None or spec.loader is None:
                raise BackendLoadError(f"Cannot create spec for {module_path}")

            module = importlib.util.module_from_spec(spec)

            # Add to sys.modules to allow relative imports
            sys.modules[module_name] = module

            spec.loader.exec_module(module)
            return module

        except Exception as e:
            raise BackendLoadError(f"Failed to load {module_path}: {e}") from e

    def unload_module(self, app_name: str) -> bool:
        """
        Unload a previously loaded backend module.

        Args:
            app_name: Name of the app whose module to unload

        Returns:
            True if module was unloaded, False if not found
        """
        module_name = f"waycore_app_{app_name}_backend"
        if module_name in sys.modules:
            del sys.modules[module_name]
            return True
        return False
