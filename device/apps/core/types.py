"""Core types for the modular app ecosystem.

This module defines the runtime types used by the app loader and registry.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from device.libs.schemas.app_manifest import AppManifest


@dataclass
class LoadedApp:
    """A loaded app with resolved paths and optional backend.

    This represents an app that has been discovered, validated, and is ready
    to be launched. It includes resolved filesystem paths and optionally
    a loaded backend module.
    """

    manifest: AppManifest
    app_dir: Path
    qml_entry: Path
    backend_module: object | None = None

    @property
    def id(self) -> str:
        """Get the app's unique identifier."""
        return self.manifest.id

    @property
    def name(self) -> str:
        """Get the app's display name."""
        return self.manifest.name

    @property
    def tier(self) -> int:
        """Get the app's UI tier."""
        return self.manifest.tier

    def has_backend(self) -> bool:
        """Check if this app has a loaded backend module."""
        return self.backend_module is not None


@dataclass
class AppLoadError:
    """Error information when an app fails to load."""

    app_dir: Path
    error_type: str
    message: str
    details: dict[str, Any] | None = None

    def __str__(self) -> str:
        """Return a human-readable error message."""
        return f"{self.error_type}: {self.message} ({self.app_dir.name})"


@dataclass
class AppDiscoveryResult:
    """Result of app discovery, including loaded apps and any errors."""

    apps: list[LoadedApp] = field(default_factory=list)
    errors: list[AppLoadError] = field(default_factory=list)

    @property
    def success_count(self) -> int:
        """Number of successfully loaded apps."""
        return len(self.apps)

    @property
    def error_count(self) -> int:
        """Number of apps that failed to load."""
        return len(self.errors)

    def get_apps_by_tier(self, tier: int) -> list[LoadedApp]:
        """Get all apps of a specific tier."""
        return [app for app in self.apps if app.tier == tier]

    def get_tier1_apps(self) -> list[LoadedApp]:
        """Get apps for the home screen (tier 1)."""
        return self.get_apps_by_tier(1)

    def get_tier2_apps(self) -> list[LoadedApp]:
        """Get apps for the system hub (tier 2)."""
        return self.get_apps_by_tier(2)
