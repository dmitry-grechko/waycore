"""App manifest schema for the modular app ecosystem.

This module defines the schema for app manifest files (manifest.json) that declare
app metadata, capabilities, dependencies, and entry points.
"""

from __future__ import annotations

from enum import Enum

from pydantic import BaseModel, ConfigDict, Field, field_validator


class AppCategory(str, Enum):
    """Valid app categories for grouping in the UI."""

    EMERGENCY = "emergency"
    COMMUNICATION = "communication"
    NAVIGATION = "navigation"
    MEDIA = "media"
    AI = "ai"
    UTILITIES = "utilities"
    SPORT = "sport"
    HEALTH = "health"
    WEATHER = "weather"
    SENSORS = "sensors"
    SYSTEM = "system"


class SensorRequirement(BaseModel):
    """A sensor required or optionally used by an app."""

    type: str = Field(..., description="Sensor type identifier (e.g., 'magnetometer', 'gps')")
    required: bool = Field(
        default=True,
        description="Whether the sensor is required for the app to function",
    )


class AppEntry(BaseModel):
    """Entry points for an app's frontend and backend."""

    qml: str = Field(..., description="Relative path to main QML file from app directory")
    backend: str | None = Field(None, description="Relative path to backend module (optional)")


class DatabaseColumn(BaseModel):
    """Definition of a database column for app-specific storage."""

    name: str = Field(..., description="Column name")
    type: str = Field(..., description="SQLite column type (TEXT, INTEGER, REAL, BLOB, TIMESTAMP)")
    primary: bool = Field(default=False, description="Whether this is the primary key")
    nullable: bool = Field(default=True, description="Whether NULL values are allowed")
    default: str | None = Field(None, description="Default value expression")
    references: str | None = Field(None, description="Foreign key reference (table.column)")


class DatabaseIndex(BaseModel):
    """Definition of a database index for app-specific storage."""

    name: str = Field(..., description="Index name")
    columns: list[str] = Field(..., description="Columns to index")


class DatabaseTable(BaseModel):
    """Definition of a database table for app-specific storage."""

    name: str = Field(..., description="Table name")
    columns: list[DatabaseColumn] = Field(..., description="Table columns")
    indexes: list[DatabaseIndex] = Field(default_factory=list, description="Table indexes")


class DatabaseMigration(BaseModel):
    """A database migration for schema changes."""

    version: int = Field(..., description="Target schema version")
    up: str = Field(..., description="SQL statements to apply migration")
    down: str | None = Field(None, description="SQL statements to reverse migration")


class DatabaseConfig(BaseModel):
    """Database configuration for an app."""

    version: int = Field(default=1, description="Current schema version")
    shared_data_access: list[str] = Field(
        default_factory=list,
        alias="sharedDataAccess",
        description="List of shared tables the app can read (e.g., 'sensors.latest_readings')",
    )
    tables: list[DatabaseTable] = Field(
        default_factory=list,
        description="App-specific tables to create",
    )
    migrations: list[DatabaseMigration] = Field(
        default_factory=list,
        description="Schema migrations",
    )


class LifecycleHooks(BaseModel):
    """Lifecycle hooks for app events."""

    on_reset: str | None = Field(
        None,
        alias="onReset",
        description="Handler for factory reset (module:function format)",
    )
    on_install: str | None = Field(
        None,
        alias="onInstall",
        description="Handler for app installation",
    )
    on_uninstall: str | None = Field(
        None,
        alias="onUninstall",
        description="Handler for app removal",
    )


class AIConfig(BaseModel):
    """AI integration configuration for an app."""

    enabled: bool = Field(default=False, description="Whether AI tools are enabled")
    tools: list[str] = Field(
        default_factory=list,
        description="List of operation IDs to expose as AI tools",
    )
    description: str = Field(default="", description="Description of AI capabilities")
    confirmation_required: list[str] = Field(
        default_factory=list,
        alias="confirmationRequired",
        description="Operations that require user confirmation",
    )


class AppManifest(BaseModel):
    """
    App manifest schema defining an app's metadata and capabilities.

    Every app must include a manifest.json file in its root directory.
    The manifest declares the app's identity, entry points, and requirements.
    """

    model_config = ConfigDict(
        populate_by_name=True,
        extra="allow",  # Allow future extensibility
    )

    # Required fields
    id: str = Field(
        ...,
        pattern=r"^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$",
        description="Unique identifier in reverse domain format (e.g., 'com.waycore.compass')",
    )
    name: str = Field(
        ...,
        max_length=12,
        description="Display name (max 12 characters for UI)",
    )
    version: str = Field(
        ...,
        pattern=r"^\d+\.\d+\.\d+$",
        description="Semantic version (X.Y.Z)",
    )
    icon: str = Field(
        ...,
        description="Emoji or icon name for display",
    )
    entry: AppEntry = Field(
        ...,
        description="Entry points for frontend and optional backend",
    )

    # Optional fields
    description: str | None = Field(None, description="Short description of the app")
    category: AppCategory | None = Field(None, description="App category for grouping")
    permissions: list[str] = Field(
        default_factory=list,
        description="Required system permissions (e.g., 'sensors.magnetometer')",
    )
    sensors: list[SensorRequirement] = Field(
        default_factory=list,
        description="Sensor requirements",
    )
    tier: int = Field(
        default=2,
        ge=1,
        le=2,
        description="UI tier: 1=home screen (max 6), 2=system hub",
    )
    home_position: int | None = Field(
        None,
        alias="homePosition",
        ge=0,
        le=5,
        description="Fixed position on home grid (0-5) for tier 1 apps",
    )
    enabled: bool = Field(default=True, description="Whether the app is enabled")
    min_core_version: str | None = Field(
        None,
        alias="minCoreVersion",
        pattern=r"^\d+\.\d+\.\d+$",
        description="Minimum core version required",
    )

    # Advanced features
    database: DatabaseConfig | None = Field(None, description="Database configuration")
    lifecycle: LifecycleHooks | None = Field(None, description="Lifecycle event hooks")
    ai: AIConfig | None = Field(None, description="AI integration configuration")

    @field_validator("name")
    @classmethod
    def validate_name_not_empty(cls, v: str) -> str:
        """Ensure name is not empty or whitespace only."""
        if not v or not v.strip():
            raise ValueError("name cannot be empty")
        return v.strip()

    @field_validator("icon")
    @classmethod
    def validate_icon_not_empty(cls, v: str) -> str:
        """Ensure icon is provided."""
        if not v or not v.strip():
            raise ValueError("icon is required")
        return v.strip()

    def get_required_sensors(self) -> list[str]:
        """Get list of required sensor types."""
        return [s.type for s in self.sensors if s.required]

    def get_optional_sensors(self) -> list[str]:
        """Get list of optional sensor types."""
        return [s.type for s in self.sensors if not s.required]

    def has_backend(self) -> bool:
        """Check if this app has a backend module."""
        return self.entry.backend is not None

    def is_emergency_app(self) -> bool:
        """Check if this is an emergency app (shown with special styling)."""
        return self.category == AppCategory.EMERGENCY
