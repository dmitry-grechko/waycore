"""Runtime app registry.

This module provides a runtime registry for managing loaded apps.
"""

from __future__ import annotations

import logging
from typing import Callable

from device.apps.core.types import LoadedApp
from device.libs.schemas.app_manifest import AppCategory, AppManifest

logger = logging.getLogger(__name__)


class AppRegistry:
    """Runtime registry of loaded apps."""

    def __init__(self) -> None:
        """Initialize an empty registry."""
        self._apps: dict[str, LoadedApp] = {}
        self._listeners: list[Callable[[str, str], None]] = []

    def register(self, app: LoadedApp) -> None:
        """
        Register a loaded app.

        Args:
            app: The LoadedApp to register
        """
        self._apps[app.manifest.id] = app
        self._notify_listeners("registered", app.manifest.id)
        logger.debug(f"Registered app: {app.manifest.id}")

    def unregister(self, app_id: str) -> bool:
        """
        Unregister an app by ID.

        Args:
            app_id: The app's unique identifier

        Returns:
            True if app was removed, False if not found
        """
        if app_id in self._apps:
            del self._apps[app_id]
            self._notify_listeners("unregistered", app_id)
            logger.debug(f"Unregistered app: {app_id}")
            return True
        return False

    def get(self, app_id: str) -> LoadedApp | None:
        """
        Get a loaded app by ID.

        Args:
            app_id: The app's unique identifier

        Returns:
            LoadedApp if found, None otherwise
        """
        return self._apps.get(app_id)

    def get_manifest(self, app_id: str) -> AppManifest | None:
        """
        Get manifest for an app by ID.

        Args:
            app_id: The app's unique identifier

        Returns:
            AppManifest if found, None otherwise
        """
        app = self._apps.get(app_id)
        return app.manifest if app else None

    def get_tier1_apps(self) -> list[AppManifest]:
        """
        Get apps for the home screen (tier 1).

        Apps are sorted by homePosition if set, otherwise alphabetically by name.

        Returns:
            List of manifests for tier 1 apps
        """
        apps = [a.manifest for a in self._apps.values() if a.manifest.tier == 1]
        return sorted(
            apps,
            key=lambda a: (
                999 if a.home_position is None else a.home_position,
                a.name,
            ),
        )

    def get_tier2_apps(self) -> list[AppManifest]:
        """
        Get apps for the system hub (tier 2).

        Apps are sorted by category then by name.

        Returns:
            List of manifests for tier 2 apps
        """
        apps = [a.manifest for a in self._apps.values() if a.manifest.tier == 2]
        return sorted(
            apps,
            key=lambda a: (a.category.value if a.category else "", a.name),
        )

    def get_all_apps(self) -> list[AppManifest]:
        """
        Get all registered app manifests.

        Returns:
            List of all app manifests
        """
        return [a.manifest for a in self._apps.values()]

    def get_all_loaded_apps(self) -> list[LoadedApp]:
        """
        Get all registered LoadedApp instances.

        Returns:
            List of all LoadedApp instances
        """
        return list(self._apps.values())

    def get_apps_by_category(self, category: AppCategory) -> list[AppManifest]:
        """
        Get apps of a specific category.

        Args:
            category: The category to filter by

        Returns:
            List of manifests for apps in the category
        """
        return [a.manifest for a in self._apps.values() if a.manifest.category == category]

    def is_registered(self, app_id: str) -> bool:
        """
        Check if an app is registered.

        Args:
            app_id: The app's unique identifier

        Returns:
            True if app is registered, False otherwise
        """
        return app_id in self._apps

    def count(self) -> int:
        """
        Get the number of registered apps.

        Returns:
            Number of registered apps
        """
        return len(self._apps)

    def add_listener(self, listener: Callable[[str, str], None]) -> None:
        """
        Add a listener for registry changes.

        The listener is called with (event_type, app_id) when apps
        are registered or unregistered.

        Args:
            listener: Callback function (event_type, app_id) -> None
        """
        self._listeners.append(listener)

    def remove_listener(self, listener: Callable[[str, str], None]) -> None:
        """
        Remove a registry change listener.

        Args:
            listener: The listener to remove
        """
        if listener in self._listeners:
            self._listeners.remove(listener)

    def _notify_listeners(self, event_type: str, app_id: str) -> None:
        """Notify all listeners of a registry change."""
        for listener in self._listeners:
            try:
                listener(event_type, app_id)
            except Exception as e:
                logger.exception(f"Error in registry listener: {e}")

    def clear(self) -> None:
        """Remove all registered apps."""
        for app_id in list(self._apps.keys()):
            self.unregister(app_id)
