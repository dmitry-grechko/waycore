"""Tests for app manifest schema validation."""

from __future__ import annotations

import pytest
from pydantic import ValidationError

from device.libs.schemas.app_manifest import (
    AIConfig,
    AppCategory,
    AppEntry,
    AppManifest,
    DatabaseColumn,
    DatabaseConfig,
    DatabaseIndex,
    DatabaseMigration,
    DatabaseTable,
    LifecycleHooks,
    SensorRequirement,
)


class TestAppManifestBasic:
    """Tests for basic manifest validation."""

    def test_minimal_valid_manifest(self) -> None:
        """Test creating a manifest with only required fields."""
        manifest = AppManifest(
            id="com.waycore.test",
            name="Test App",
            version="1.0.0",
            icon="🧪",
            entry=AppEntry(qml="qml/Main.qml"),
        )

        assert manifest.id == "com.waycore.test"
        assert manifest.name == "Test App"
        assert manifest.version == "1.0.0"
        assert manifest.icon == "🧪"
        assert manifest.entry.qml == "qml/Main.qml"
        assert manifest.entry.backend is None
        assert manifest.tier == 2  # Default
        assert manifest.enabled is True  # Default

    def test_full_manifest(self) -> None:
        """Test creating a manifest with all optional fields."""
        manifest = AppManifest(
            id="com.waycore.compass",
            name="Compass",
            version="1.2.3",
            description="Navigation compass with magnetic heading",
            icon="🧭",
            category=AppCategory.NAVIGATION,
            entry=AppEntry(qml="qml/CompassMain.qml", backend="backend/service.py"),
            permissions=["sensors.magnetometer", "sensors.gps"],
            sensors=[
                SensorRequirement(type="magnetometer", required=True),
                SensorRequirement(type="gps", required=False),
            ],
            tier=1,
            homePosition=2,
            enabled=True,
            minCoreVersion="1.0.0",
        )

        assert manifest.id == "com.waycore.compass"
        assert manifest.category == AppCategory.NAVIGATION
        assert manifest.tier == 1
        assert manifest.home_position == 2
        assert manifest.min_core_version == "1.0.0"
        assert len(manifest.sensors) == 2
        assert manifest.has_backend() is True


class TestAppManifestIdValidation:
    """Tests for app ID validation."""

    def test_valid_id_formats(self) -> None:
        """Test various valid ID formats."""
        valid_ids = [
            "com.waycore.test",
            "com.example.myapp",
            "org.opensource.app123",
            "io.github.user.project",
        ]

        for app_id in valid_ids:
            manifest = AppManifest(
                id=app_id,
                name="Test",
                version="1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
            )
            assert manifest.id == app_id

    def test_invalid_id_single_segment(self) -> None:
        """Test that single segment IDs are rejected."""
        with pytest.raises(ValidationError) as exc:
            AppManifest(
                id="myapp",
                name="Test",
                version="1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
            )

        assert "id" in str(exc.value)

    def test_invalid_id_starts_with_number(self) -> None:
        """Test that IDs starting with numbers are rejected."""
        with pytest.raises(ValidationError):
            AppManifest(
                id="1com.waycore.test",
                name="Test",
                version="1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
            )

    def test_invalid_id_uppercase(self) -> None:
        """Test that uppercase IDs are rejected."""
        with pytest.raises(ValidationError):
            AppManifest(
                id="com.Waycore.Test",
                name="Test",
                version="1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
            )


class TestAppManifestVersionValidation:
    """Tests for version format validation."""

    def test_valid_version_formats(self) -> None:
        """Test valid semantic version formats."""
        valid_versions = ["1.0.0", "0.1.0", "10.20.30", "1.2.3"]

        for version in valid_versions:
            manifest = AppManifest(
                id="com.waycore.test",
                name="Test",
                version=version,
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
            )
            assert manifest.version == version

    def test_invalid_version_two_parts(self) -> None:
        """Test that two-part versions are rejected."""
        with pytest.raises(ValidationError):
            AppManifest(
                id="com.waycore.test",
                name="Test",
                version="1.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
            )

    def test_invalid_version_with_prefix(self) -> None:
        """Test that versions with prefixes are rejected."""
        with pytest.raises(ValidationError):
            AppManifest(
                id="com.waycore.test",
                name="Test",
                version="v1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
            )


class TestAppManifestNameValidation:
    """Tests for name validation."""

    def test_name_max_length(self) -> None:
        """Test that names up to 12 characters are allowed."""
        manifest = AppManifest(
            id="com.waycore.test",
            name="123456789012",  # Exactly 12 chars
            version="1.0.0",
            icon="📱",
            entry=AppEntry(qml="qml/Main.qml"),
        )
        assert manifest.name == "123456789012"

    def test_name_too_long(self) -> None:
        """Test that names over 12 characters are rejected."""
        with pytest.raises(ValidationError):
            AppManifest(
                id="com.waycore.test",
                name="1234567890123",  # 13 chars
                version="1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
            )

    def test_name_empty_rejected(self) -> None:
        """Test that empty names are rejected."""
        with pytest.raises(ValidationError):
            AppManifest(
                id="com.waycore.test",
                name="",
                version="1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
            )

    def test_name_whitespace_trimmed(self) -> None:
        """Test that whitespace is trimmed from names."""
        manifest = AppManifest(
            id="com.waycore.test",
            name="  Test  ",
            version="1.0.0",
            icon="📱",
            entry=AppEntry(qml="qml/Main.qml"),
        )
        assert manifest.name == "Test"


class TestAppManifestTierValidation:
    """Tests for tier validation."""

    def test_tier_default(self) -> None:
        """Test that tier defaults to 2."""
        manifest = AppManifest(
            id="com.waycore.test",
            name="Test",
            version="1.0.0",
            icon="📱",
            entry=AppEntry(qml="qml/Main.qml"),
        )
        assert manifest.tier == 2

    def test_tier_valid_values(self) -> None:
        """Test valid tier values."""
        for tier in [1, 2]:
            manifest = AppManifest(
                id="com.waycore.test",
                name="Test",
                version="1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
                tier=tier,
            )
            assert manifest.tier == tier

    def test_tier_out_of_range(self) -> None:
        """Test that tier values outside 1-2 are rejected."""
        with pytest.raises(ValidationError):
            AppManifest(
                id="com.waycore.test",
                name="Test",
                version="1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
                tier=3,
            )


class TestAppManifestSensorRequirements:
    """Tests for sensor requirement parsing."""

    def test_sensor_requirements(self) -> None:
        """Test parsing sensor requirements."""
        manifest = AppManifest(
            id="com.waycore.test",
            name="Test",
            version="1.0.0",
            icon="📱",
            entry=AppEntry(qml="qml/Main.qml"),
            sensors=[
                SensorRequirement(type="magnetometer", required=True),
                SensorRequirement(type="gps", required=False),
                SensorRequirement(type="barometer", required=True),
            ],
        )

        assert len(manifest.sensors) == 3
        assert manifest.get_required_sensors() == ["magnetometer", "barometer"]
        assert manifest.get_optional_sensors() == ["gps"]

    def test_sensor_default_required(self) -> None:
        """Test that sensors default to required=True."""
        sensor = SensorRequirement(type="temperature")
        assert sensor.required is True


class TestAppManifestCategories:
    """Tests for category validation."""

    def test_valid_categories(self) -> None:
        """Test all valid category values."""
        for category in AppCategory:
            manifest = AppManifest(
                id="com.waycore.test",
                name="Test",
                version="1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
                category=category,
            )
            assert manifest.category == category

    def test_invalid_category(self) -> None:
        """Test that invalid categories are rejected."""
        with pytest.raises(ValidationError):
            AppManifest(
                id="com.waycore.test",
                name="Test",
                version="1.0.0",
                icon="📱",
                entry=AppEntry(qml="qml/Main.qml"),
                category="invalid_category",  # type: ignore[arg-type]
            )

    def test_emergency_app_detection(self) -> None:
        """Test emergency app detection."""
        manifest = AppManifest(
            id="com.waycore.sos",
            name="SOS",
            version="1.0.0",
            icon="🚨",
            entry=AppEntry(qml="qml/Main.qml"),
            category=AppCategory.EMERGENCY,
        )
        assert manifest.is_emergency_app() is True

        manifest2 = AppManifest(
            id="com.waycore.notes",
            name="Notes",
            version="1.0.0",
            icon="📝",
            entry=AppEntry(qml="qml/Main.qml"),
            category=AppCategory.UTILITIES,
        )
        assert manifest2.is_emergency_app() is False


class TestDatabaseConfig:
    """Tests for database configuration."""

    def test_database_config_full(self) -> None:
        """Test full database configuration."""
        manifest = AppManifest(
            id="com.waycore.notes",
            name="Notes",
            version="1.0.0",
            icon="📝",
            entry=AppEntry(qml="qml/Main.qml"),
            database=DatabaseConfig(
                version=2,
                sharedDataAccess=["sensors.latest_readings", "settings.user_preferences"],
                tables=[
                    DatabaseTable(
                        name="notes",
                        columns=[
                            DatabaseColumn(name="id", type="TEXT", primary=True),
                            DatabaseColumn(name="title", type="TEXT", nullable=False),
                            DatabaseColumn(name="content", type="TEXT"),
                            DatabaseColumn(
                                name="created_at",
                                type="TIMESTAMP",
                                default="CURRENT_TIMESTAMP",
                            ),
                        ],
                        indexes=[
                            DatabaseIndex(name="idx_notes_created", columns=["created_at"]),
                        ],
                    ),
                ],
                migrations=[
                    DatabaseMigration(
                        version=2,
                        up="ALTER TABLE notes ADD COLUMN location REAL;",
                    ),
                ],
            ),
        )

        assert manifest.database is not None
        assert manifest.database.version == 2
        assert len(manifest.database.shared_data_access) == 2
        assert len(manifest.database.tables) == 1
        assert manifest.database.tables[0].name == "notes"
        assert len(manifest.database.tables[0].columns) == 4
        assert len(manifest.database.migrations) == 1


class TestLifecycleHooks:
    """Tests for lifecycle hooks."""

    def test_lifecycle_hooks(self) -> None:
        """Test lifecycle hook configuration."""
        manifest = AppManifest(
            id="com.waycore.test",
            name="Test",
            version="1.0.0",
            icon="📱",
            entry=AppEntry(qml="qml/Main.qml"),
            lifecycle=LifecycleHooks(
                onReset="backend/service.py:handle_reset",
                onInstall="backend/service.py:on_install",
            ),
        )

        assert manifest.lifecycle is not None
        assert manifest.lifecycle.on_reset == "backend/service.py:handle_reset"
        assert manifest.lifecycle.on_install == "backend/service.py:on_install"
        assert manifest.lifecycle.on_uninstall is None


class TestAIConfig:
    """Tests for AI configuration."""

    def test_ai_config(self) -> None:
        """Test AI configuration."""
        manifest = AppManifest(
            id="com.waycore.weather",
            name="Weather",
            version="1.0.0",
            icon="🌤️",
            entry=AppEntry(qml="qml/Main.qml"),
            ai=AIConfig(
                enabled=True,
                tools=["get_forecast", "get_current_conditions"],
                description="Weather forecasting capabilities",
                confirmationRequired=["set_alert"],
            ),
        )

        assert manifest.ai is not None
        assert manifest.ai.enabled is True
        assert len(manifest.ai.tools) == 2
        assert manifest.ai.description == "Weather forecasting capabilities"
        assert manifest.ai.confirmation_required == ["set_alert"]


class TestExtraFieldsAllowed:
    """Tests for future extensibility."""

    def test_extra_fields_preserved(self) -> None:
        """Test that unknown fields are preserved for extensibility."""
        manifest = AppManifest(
            id="com.waycore.test",
            name="Test",
            version="1.0.0",
            icon="📱",
            entry=AppEntry(qml="qml/Main.qml"),
            future_feature="some_value",  # Unknown field
        )

        # Extra fields should be accessible via model_extra
        assert "future_feature" in manifest.model_extra
        assert manifest.model_extra["future_feature"] == "some_value"
