"""App discovery and loading.

This module scans the apps directory for valid app packages and loads their manifests.
"""

from __future__ import annotations

import logging
from pathlib import Path

from device.apps.core.manifest import ManifestLoadError, load_manifest, resolve_entry_paths
from device.apps.core.types import AppDiscoveryResult, AppLoadError, LoadedApp
from device.libs.schemas.app_manifest import AppManifest

logger = logging.getLogger(__name__)

# Directories to skip when scanning for apps
SKIP_DIRECTORIES = {"core", "ui", "__pycache__", ".git", ".pytest_cache"}


class AppLoader:
    """Discovers and loads apps from the filesystem."""

    def __init__(self, apps_dir: Path) -> None:
        """
        Initialize the app loader.

        Args:
            apps_dir: Path to the apps directory (device/apps/)
        """
        self.apps_dir = apps_dir

    def discover_apps(self) -> AppDiscoveryResult:
        """
        Scan apps directory for valid app packages.

        This method discovers all valid apps in the apps directory, loading
        and validating their manifests. Apps with invalid manifests are
        reported as errors but don't prevent other apps from loading.

        Returns:
            AppDiscoveryResult containing loaded apps and any errors
        """
        result = AppDiscoveryResult()

        if not self.apps_dir.exists():
            logger.warning(f"Apps directory does not exist: {self.apps_dir}")
            return result

        for item in self.apps_dir.iterdir():
            # Skip non-directories
            if not item.is_dir():
                continue

            # Skip special directories
            if item.name.startswith(("_", ".")) or item.name in SKIP_DIRECTORIES:
                continue

            # Check for manifest
            manifest_path = item / "manifest.json"
            if not manifest_path.exists():
                continue

            # Try to load the app
            try:
                loaded_app = self._load_app(item)
                if loaded_app.manifest.enabled:
                    result.apps.append(loaded_app)
                    logger.debug(f"Loaded app: {loaded_app.manifest.id}")
                else:
                    logger.debug(f"Skipping disabled app: {loaded_app.manifest.id}")
            except ManifestLoadError as e:
                result.errors.append(
                    AppLoadError(
                        app_dir=item,
                        error_type="manifest_error",
                        message=str(e),
                        details=e.details,
                    )
                )
                logger.warning(f"Failed to load app {item.name}: {e}")
            except Exception as e:
                result.errors.append(
                    AppLoadError(
                        app_dir=item,
                        error_type="unexpected_error",
                        message=str(e),
                    )
                )
                logger.exception(f"Unexpected error loading app {item.name}")

        # Sort apps for consistent ordering
        result.apps.sort(key=lambda a: (a.manifest.tier, a.manifest.name))

        logger.info(f"Discovered {result.success_count} apps " f"({result.error_count} errors)")

        return result

    def _load_app(self, app_dir: Path) -> LoadedApp:
        """
        Load a single app from its directory.

        Args:
            app_dir: Path to the app directory

        Returns:
            LoadedApp instance

        Raises:
            ManifestLoadError: If manifest is invalid or entry points missing
        """
        manifest_path = app_dir / "manifest.json"
        manifest = load_manifest(manifest_path)

        qml_path, backend_path = resolve_entry_paths(manifest, app_dir)

        return LoadedApp(
            manifest=manifest,
            app_dir=app_dir,
            qml_entry=qml_path,
            backend_module=None,  # Backend loaded separately if needed
        )

    def load_single_app(self, app_id: str) -> LoadedApp | None:
        """
        Load a specific app by ID.

        This searches for an app with the matching ID in the apps directory.

        Args:
            app_id: The app's unique identifier

        Returns:
            LoadedApp if found and valid, None otherwise
        """
        for item in self.apps_dir.iterdir():
            if not item.is_dir():
                continue
            if item.name.startswith(("_", ".")) or item.name in SKIP_DIRECTORIES:
                continue

            manifest_path = item / "manifest.json"
            if not manifest_path.exists():
                continue

            try:
                manifest = load_manifest(manifest_path)
                if manifest.id == app_id:
                    qml_path, backend_path = resolve_entry_paths(manifest, item)
                    return LoadedApp(
                        manifest=manifest,
                        app_dir=item,
                        qml_entry=qml_path,
                        backend_module=None,
                    )
            except ManifestLoadError:
                continue

        return None

    def get_manifest(self, app_id: str) -> AppManifest | None:
        """
        Get manifest for a specific app without full loading.

        Args:
            app_id: The app's unique identifier

        Returns:
            AppManifest if found, None otherwise
        """
        loaded = self.load_single_app(app_id)
        return loaded.manifest if loaded else None
