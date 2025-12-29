"""QML bridge for app registry access.

This module provides a QML-accessible interface to the app registry.
"""

from __future__ import annotations

import logging

from device.apps.core.registry import AppRegistry
from device.libs.schemas.app_manifest import AppManifest
from PySide6.QtCore import Property, QObject, Signal, Slot

logger = logging.getLogger(__name__)


class AppBridge(QObject):
    """QML bridge for accessing app registry."""

    appsChanged = Signal()

    def __init__(self, registry: AppRegistry, parent: QObject | None = None) -> None:
        """
        Initialize the app bridge.

        Args:
            registry: The app registry to expose
            parent: Optional parent QObject
        """
        super().__init__(parent)
        self._registry = registry
        # Listen for registry changes
        self._registry.add_listener(self._on_registry_changed)

    def _on_registry_changed(self, event_type: str, app_id: str) -> None:
        """Handle registry change events."""
        self.appsChanged.emit()

    @Property("QVariantList", notify=appsChanged)  # type: ignore[arg-type]
    def tier1Apps(self) -> list[dict]:  # type: ignore[type-arg]
        """Apps for home screen (tier 1)."""
        return [self._manifest_to_dict(m) for m in self._registry.get_tier1_apps()]

    @Property("QVariantList", notify=appsChanged)  # type: ignore[arg-type]
    def tier2Apps(self) -> list[dict]:  # type: ignore[type-arg]
        """Apps for system hub (tier 2)."""
        return [self._manifest_to_dict(m) for m in self._registry.get_tier2_apps()]

    @Property("QVariantList", notify=appsChanged)  # type: ignore[arg-type]
    def allApps(self) -> list[dict]:  # type: ignore[type-arg]
        """All registered apps."""
        return [self._manifest_to_dict(m) for m in self._registry.get_all_apps()]

    @Property(int, notify=appsChanged)
    def appCount(self) -> int:
        """Number of registered apps."""
        return self._registry.count()

    @Slot(str, result=str)
    def getAppEntry(self, app_id: str) -> str:
        """
        Get QML entry path for an app.

        Args:
            app_id: The app's unique identifier

        Returns:
            Path to the app's main QML file, or empty string if not found
        """
        app = self._registry.get(app_id)
        if app:
            return str(app.qml_entry)
        return ""

    @Slot(str, result=bool)
    def isAppEnabled(self, app_id: str) -> bool:
        """
        Check if an app is enabled.

        Args:
            app_id: The app's unique identifier

        Returns:
            True if app is registered and enabled
        """
        app = self._registry.get(app_id)
        return app is not None and app.manifest.enabled

    @Slot(str, result=bool)
    def isAppRegistered(self, app_id: str) -> bool:
        """
        Check if an app is registered.

        Args:
            app_id: The app's unique identifier

        Returns:
            True if app is registered
        """
        return self._registry.is_registered(app_id)

    @Slot(str, result="QVariant")
    def getAppInfo(self, app_id: str) -> dict | None:  # type: ignore[type-arg]
        """
        Get full info for an app.

        Args:
            app_id: The app's unique identifier

        Returns:
            App info dict or None if not found
        """
        app = self._registry.get(app_id)
        if app:
            return self._manifest_to_dict(app.manifest)
        return None

    @Slot(str, result=str)
    def getAppIdByName(self, name: str) -> str:
        """
        Find an app ID by its display name.

        This performs a case-insensitive search.

        Args:
            name: The app's display name

        Returns:
            App ID if found, empty string otherwise
        """
        name_lower = name.lower()
        for manifest in self._registry.get_all_apps():
            if manifest.name.lower() == name_lower:
                return manifest.id
        return ""

    @Slot(str, result="QVariantList")
    def getAppsByCategory(self, category: str) -> list[dict]:  # type: ignore[type-arg]
        """
        Get apps of a specific category.

        Args:
            category: Category name (e.g., 'navigation', 'utilities')

        Returns:
            List of app info dicts
        """
        from device.libs.schemas.app_manifest import AppCategory

        try:
            cat = AppCategory(category)
            apps = self._registry.get_apps_by_category(cat)
            return [self._manifest_to_dict(m) for m in apps]
        except ValueError:
            return []

    def _manifest_to_dict(self, m: AppManifest) -> dict:  # type: ignore[type-arg]
        """
        Convert manifest to QML-friendly dict.

        Args:
            m: The manifest to convert

        Returns:
            Dictionary with app info
        """
        return {
            "id": m.id,
            "name": m.name,
            "version": m.version,
            "description": m.description or "",
            "icon": m.icon,
            "category": m.category.value if m.category else "",
            "tier": m.tier,
            "homePosition": m.home_position,
            "enabled": m.enabled,
            "hasBackend": m.has_backend(),
            "isEmergency": m.is_emergency_app(),
        }
