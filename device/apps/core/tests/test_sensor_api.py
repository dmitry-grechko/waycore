"""Tests for SensorAPI."""

from __future__ import annotations

from typing import Any
from unittest.mock import MagicMock

import pytest
from device.apps.core.sensor_api import (
    SENSOR_TYPES,
    SensorAPI,
    SensorListener,
    get_sensor_api,
    reset_sensor_api,
)


@pytest.fixture
def sensor_api() -> SensorAPI:
    """Create a fresh SensorAPI instance for testing."""
    return SensorAPI()


@pytest.fixture
def mock_bridge() -> MagicMock:
    """Create a mock sensor bridge."""
    bridge = MagicMock()
    bridge.compassHeading = 45.0
    bridge.compassCardinal = "NE"
    bridge.compassCalibrated = True
    bridge.gpsLatitude = 45.5231
    bridge.gpsLongitude = -122.6765
    bridge.gpsAccuracy = 5.0
    bridge.hasGpsFix = True
    bridge.elevationMeters = 100.0
    bridge.pressureHpa = 1013.25
    return bridge


@pytest.fixture(autouse=True)
def reset_global() -> None:
    """Reset global sensor API before each test."""
    reset_sensor_api()
    yield
    reset_sensor_api()


class TestSensorAPI:
    """Tests for the SensorAPI class."""

    def test_is_available_known_sensors(self, sensor_api: SensorAPI) -> None:
        """Test that known sensors are available."""
        assert sensor_api.is_available("magnetometer") is True
        assert sensor_api.is_available("gps") is True
        assert sensor_api.is_available("barometer") is True

    def test_is_available_unknown_sensor(self, sensor_api: SensorAPI) -> None:
        """Test that unknown sensors are not available."""
        assert sensor_api.is_available("unknown_sensor") is False

    def test_get_available_sensors(self, sensor_api: SensorAPI) -> None:
        """Test getting list of available sensors."""
        available = sensor_api.get_available_sensors()
        assert "magnetometer" in available
        assert "gps" in available

    def test_get_sensor_info(self, sensor_api: SensorAPI) -> None:
        """Test getting sensor info."""
        info = sensor_api.get_sensor_info("magnetometer")
        assert info is not None
        assert "description" in info
        assert "properties" in info
        assert "heading" in info["properties"]

    def test_get_sensor_info_unknown(self, sensor_api: SensorAPI) -> None:
        """Test getting info for unknown sensor."""
        info = sensor_api.get_sensor_info("unknown")
        assert info is None

    def test_subscribe_increments_refcount(self, sensor_api: SensorAPI) -> None:
        """Test that subscribing increments the refcount."""
        assert sensor_api.get_subscription_count("magnetometer") == 0

        sensor_api.subscribe("magnetometer")
        assert sensor_api.get_subscription_count("magnetometer") == 1

        sensor_api.subscribe("magnetometer")
        assert sensor_api.get_subscription_count("magnetometer") == 2

    def test_unsubscribe_decrements_refcount(self, sensor_api: SensorAPI) -> None:
        """Test that unsubscribing decrements the refcount."""
        sensor_api.subscribe("magnetometer")
        sensor_api.subscribe("magnetometer")
        assert sensor_api.get_subscription_count("magnetometer") == 2

        sensor_api.unsubscribe("magnetometer")
        assert sensor_api.get_subscription_count("magnetometer") == 1

        sensor_api.unsubscribe("magnetometer")
        assert sensor_api.get_subscription_count("magnetometer") == 0

    def test_unsubscribe_not_subscribed_is_safe(self, sensor_api: SensorAPI) -> None:
        """Test that unsubscribing when not subscribed is safe."""
        # Should not raise
        sensor_api.unsubscribe("magnetometer")
        assert sensor_api.get_subscription_count("magnetometer") == 0

    def test_is_subscribed(self, sensor_api: SensorAPI) -> None:
        """Test checking subscription status."""
        assert sensor_api.is_subscribed("magnetometer") is False

        sensor_api.subscribe("magnetometer")
        assert sensor_api.is_subscribed("magnetometer") is True

        sensor_api.unsubscribe("magnetometer")
        assert sensor_api.is_subscribed("magnetometer") is False

    def test_subscribe_unavailable_sensor(self, sensor_api: SensorAPI) -> None:
        """Test subscribing to unavailable sensor."""
        result = sensor_api.subscribe("unknown_sensor")
        assert result is False
        assert sensor_api.is_subscribed("unknown_sensor") is False

    def test_get_value_from_bridge(self, sensor_api: SensorAPI, mock_bridge: MagicMock) -> None:
        """Test getting values from the sensor bridge."""
        sensor_api.set_sensor_bridge(mock_bridge)

        heading = sensor_api.get_value("magnetometer", "heading")
        assert heading == 45.0

        cardinal = sensor_api.get_value("magnetometer", "cardinal")
        assert cardinal == "NE"

        latitude = sensor_api.get_value("gps", "latitude")
        assert latitude == 45.5231

    def test_get_value_unmapped_property(self, sensor_api: SensorAPI) -> None:
        """Test getting unmapped property returns None."""
        value = sensor_api.get_value("magnetometer", "unknown_prop")
        assert value is None

    def test_get_all_values(self, sensor_api: SensorAPI, mock_bridge: MagicMock) -> None:
        """Test getting all values for a sensor."""
        sensor_api.set_sensor_bridge(mock_bridge)

        values = sensor_api.get_all_values("magnetometer")
        assert values is not None
        assert "heading" in values
        assert "cardinal" in values
        assert "calibrated" in values

    def test_update_value_and_cache(self, sensor_api: SensorAPI) -> None:
        """Test updating and caching values."""
        sensor_api.update_value("magnetometer", "heading", 90.0)

        # Get without bridge should use cached value
        _value = sensor_api.get_value("magnetometer", "heading")
        # Note: With no bridge, it falls back to cache
        assert sensor_api._latest_values["magnetometer"]["heading"] == 90.0


class TestSensorListener:
    """Tests for sensor listener functionality."""

    def test_add_and_notify_listener(self, sensor_api: SensorAPI) -> None:
        """Test adding listener and receiving updates."""
        updates: list[tuple[str, str, Any]] = []

        class TestListener(SensorListener):
            def on_sensor_updated(self, sensor_type: str, property_name: str, value: Any) -> None:
                updates.append((sensor_type, property_name, value))

        listener = TestListener()
        sensor_api.add_listener(listener)

        sensor_api.update_value("magnetometer", "heading", 180.0)

        assert len(updates) == 1
        assert updates[0] == ("magnetometer", "heading", 180.0)

    def test_remove_listener(self, sensor_api: SensorAPI) -> None:
        """Test removing a listener."""
        updates: list[Any] = []

        class TestListener(SensorListener):
            def on_sensor_updated(self, sensor_type: str, property_name: str, value: Any) -> None:
                updates.append(value)

        listener = TestListener()
        sensor_api.add_listener(listener)
        sensor_api.remove_listener(listener)

        sensor_api.update_value("magnetometer", "heading", 270.0)

        assert len(updates) == 0


class TestGlobalSensorAPI:
    """Tests for global sensor API functions."""

    def test_get_sensor_api_returns_singleton(self) -> None:
        """Test that get_sensor_api returns the same instance."""
        first = get_sensor_api()
        second = get_sensor_api()
        assert first is second

    def test_reset_sensor_api(self) -> None:
        """Test that reset clears the global instance."""
        api = get_sensor_api()
        api.subscribe("magnetometer")

        reset_sensor_api()
        new_api = get_sensor_api()

        assert new_api is not api
        assert new_api.is_subscribed("magnetometer") is False


class TestSensorTypes:
    """Tests for the SENSOR_TYPES constant."""

    def test_sensor_types_has_required_sensors(self) -> None:
        """Test that required sensors are defined."""
        assert "magnetometer" in SENSOR_TYPES
        assert "gps" in SENSOR_TYPES
        assert "barometer" in SENSOR_TYPES

    def test_sensor_types_have_properties(self) -> None:
        """Test that sensor types have properties defined."""
        for _sensor_type, info in SENSOR_TYPES.items():
            assert "description" in info
            assert "properties" in info
            assert len(info["properties"]) > 0
