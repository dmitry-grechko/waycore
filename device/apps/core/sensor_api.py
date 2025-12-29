"""Unified sensor access API for modular apps.

This module provides a consistent API for apps to access sensor data,
abstracting away the underlying sensor bridge implementation.
"""

from __future__ import annotations

import logging
from typing import Any, Callable

logger = logging.getLogger(__name__)

# Known sensor types
SENSOR_TYPES = {
    "magnetometer": {
        "description": "Magnetic heading and calibration",
        "properties": ["heading", "cardinal", "calibrated"],
    },
    "gps": {
        "description": "GPS location and accuracy",
        "properties": ["latitude", "longitude", "accuracy", "fix"],
    },
    "barometer": {
        "description": "Atmospheric pressure and elevation",
        "properties": ["pressure", "elevation"],
    },
    "temperature": {
        "description": "Ambient temperature",
        "properties": ["celsius", "fahrenheit"],
    },
    "humidity": {
        "description": "Relative humidity",
        "properties": ["percentage"],
    },
    "accelerometer": {
        "description": "Acceleration in 3 axes",
        "properties": ["x", "y", "z"],
    },
    "light": {
        "description": "Ambient light level",
        "properties": ["lux"],
    },
}


class SensorAPI:
    """
    Unified API for apps to access sensor data.

    Apps request sensors by type. The API handles:
    - Checking if sensor is available
    - Subscribing to sensor updates
    - Providing latest values
    - Handling sensor errors

    Example:
        sensor_api = SensorAPI(sensor_bridge)
        if sensor_api.is_available("magnetometer"):
            sensor_api.subscribe("magnetometer")
            heading = sensor_api.get_value("magnetometer", "heading")
            sensor_api.unsubscribe("magnetometer")
    """

    def __init__(self, sensor_bridge: Any | None = None) -> None:
        """Initialize the sensor API.

        Args:
            sensor_bridge: The underlying sensor bridge (optional)
        """
        self._sensor_bridge = sensor_bridge
        self._subscriptions: dict[str, int] = {}  # sensor_type -> refcount
        self._latest_values: dict[str, dict[str, Any]] = {}  # sensor_type -> {prop: value}
        self._listeners: list[SensorListener] = []

    def set_sensor_bridge(self, bridge: Any) -> None:
        """Set the sensor bridge.

        Args:
            bridge: The underlying sensor bridge
        """
        self._sensor_bridge = bridge

    def is_available(self, sensor_type: str) -> bool:
        """Check if a sensor type is available.

        Args:
            sensor_type: The sensor type (e.g., "magnetometer", "gps")

        Returns:
            True if the sensor is available
        """
        if sensor_type not in SENSOR_TYPES:
            return False

        # If we have a sensor bridge, check with it
        if self._sensor_bridge is not None:
            # Map sensor types to bridge properties
            bridge_checks: dict[str, Callable[[Any], bool]] = {
                "magnetometer": lambda b: True,  # Always available in mock
                "gps": lambda b: getattr(b, "hasGpsFix", False) or True,
                "barometer": lambda b: getattr(b, "hasElevation", False) or True,
                "temperature": lambda b: True,
                "humidity": lambda b: True,
            }
            check = bridge_checks.get(sensor_type)
            if check:
                return check(self._sensor_bridge)

        # Default: assume available if sensor type is known
        return sensor_type in SENSOR_TYPES

    def get_available_sensors(self) -> list[str]:
        """Get list of available sensor types.

        Returns:
            List of sensor type names
        """
        return [s for s in SENSOR_TYPES if self.is_available(s)]

    def get_sensor_info(self, sensor_type: str) -> dict[str, Any] | None:
        """Get information about a sensor type.

        Args:
            sensor_type: The sensor type

        Returns:
            Dictionary with sensor info, or None if not found
        """
        if sensor_type not in SENSOR_TYPES:
            return None
        return SENSOR_TYPES[sensor_type].copy()

    def subscribe(self, sensor_type: str) -> bool:
        """Subscribe to sensor updates.

        Multiple subscriptions are ref-counted, so you must call
        unsubscribe() the same number of times.

        Args:
            sensor_type: The sensor type to subscribe to

        Returns:
            True if subscription was successful
        """
        if not self.is_available(sensor_type):
            logger.warning(f"Cannot subscribe to unavailable sensor: {sensor_type}")
            return False

        if sensor_type in self._subscriptions:
            self._subscriptions[sensor_type] += 1
        else:
            self._subscriptions[sensor_type] = 1
            self._start_sensor(sensor_type)

        logger.debug(f"Subscribed to {sensor_type} (refcount: {self._subscriptions[sensor_type]})")
        return True

    def unsubscribe(self, sensor_type: str) -> None:
        """Unsubscribe from sensor updates.

        Args:
            sensor_type: The sensor type to unsubscribe from
        """
        if sensor_type not in self._subscriptions:
            return

        self._subscriptions[sensor_type] -= 1
        logger.debug(
            f"Unsubscribed from {sensor_type} (refcount: {self._subscriptions[sensor_type]})"
        )

        if self._subscriptions[sensor_type] <= 0:
            del self._subscriptions[sensor_type]
            self._stop_sensor(sensor_type)

    def is_subscribed(self, sensor_type: str) -> bool:
        """Check if subscribed to a sensor.

        Args:
            sensor_type: The sensor type

        Returns:
            True if currently subscribed
        """
        return sensor_type in self._subscriptions

    def get_subscription_count(self, sensor_type: str) -> int:
        """Get the subscription refcount for a sensor.

        Args:
            sensor_type: The sensor type

        Returns:
            Number of active subscriptions
        """
        return self._subscriptions.get(sensor_type, 0)

    def get_value(self, sensor_type: str, property_name: str) -> Any | None:
        """Get a specific sensor value.

        Args:
            sensor_type: The sensor type
            property_name: The property to get (e.g., "heading", "latitude")

        Returns:
            The sensor value, or None if not available
        """
        # Get from bridge if available
        if self._sensor_bridge is not None:
            return self._get_bridge_value(sensor_type, property_name)

        # Fallback to cached values
        if sensor_type in self._latest_values:
            return self._latest_values[sensor_type].get(property_name)

        return None

    def get_all_values(self, sensor_type: str) -> dict[str, Any] | None:
        """Get all values for a sensor.

        Args:
            sensor_type: The sensor type

        Returns:
            Dictionary of property names to values, or None if not available
        """
        if self._sensor_bridge is not None:
            info = SENSOR_TYPES.get(sensor_type)
            if info:
                values = {}
                for prop in info["properties"]:
                    val = self._get_bridge_value(sensor_type, prop)
                    if val is not None:
                        values[prop] = val
                return values if values else None

        return self._latest_values.get(sensor_type)

    def _get_bridge_value(self, sensor_type: str, property_name: str) -> Any | None:
        """Get a value from the sensor bridge.

        Args:
            sensor_type: The sensor type
            property_name: The property to get

        Returns:
            The value, or None if not available
        """
        if self._sensor_bridge is None:
            return None

        # Map sensor/property to bridge attributes
        bridge_mapping = {
            ("magnetometer", "heading"): "compassHeading",
            ("magnetometer", "cardinal"): "compassCardinal",
            ("magnetometer", "calibrated"): "compassCalibrated",
            ("gps", "latitude"): "gpsLatitude",
            ("gps", "longitude"): "gpsLongitude",
            ("gps", "accuracy"): "gpsAccuracy",
            ("gps", "fix"): "hasGpsFix",
            ("barometer", "elevation"): "elevationMeters",
            ("barometer", "pressure"): "pressureHpa",
        }

        key = (sensor_type, property_name)
        if key in bridge_mapping:
            attr = bridge_mapping[key]
            return getattr(self._sensor_bridge, attr, None)

        return None

    def _start_sensor(self, sensor_type: str) -> None:
        """Start receiving updates for a sensor.

        Args:
            sensor_type: The sensor type
        """
        logger.debug(f"Starting sensor: {sensor_type}")
        # Initialize latest values dict for this sensor
        if sensor_type not in self._latest_values:
            self._latest_values[sensor_type] = {}

    def _stop_sensor(self, sensor_type: str) -> None:
        """Stop receiving updates for a sensor.

        Args:
            sensor_type: The sensor type
        """
        logger.debug(f"Stopping sensor: {sensor_type}")

    def update_value(self, sensor_type: str, property_name: str, value: Any) -> None:
        """Update a sensor value (called by bridge or driver).

        Args:
            sensor_type: The sensor type
            property_name: The property to update
            value: The new value
        """
        if sensor_type not in self._latest_values:
            self._latest_values[sensor_type] = {}

        self._latest_values[sensor_type][property_name] = value

        # Notify listeners
        for listener in self._listeners:
            listener.on_sensor_updated(sensor_type, property_name, value)

    def add_listener(self, listener: SensorListener) -> None:
        """Add a sensor update listener.

        Args:
            listener: The listener to add
        """
        if listener not in self._listeners:
            self._listeners.append(listener)

    def remove_listener(self, listener: SensorListener) -> None:
        """Remove a sensor update listener.

        Args:
            listener: The listener to remove
        """
        if listener in self._listeners:
            self._listeners.remove(listener)


class SensorListener:
    """Interface for receiving sensor updates."""

    def on_sensor_updated(self, sensor_type: str, property_name: str, value: Any) -> None:
        """Called when a sensor value is updated.

        Args:
            sensor_type: The sensor type
            property_name: The property that was updated
            value: The new value
        """
        pass

    def on_sensor_error(self, sensor_type: str, error: str) -> None:
        """Called when a sensor error occurs.

        Args:
            sensor_type: The sensor type
            error: The error message
        """
        pass

    def on_sensor_availability_changed(self, sensor_type: str, available: bool) -> None:
        """Called when sensor availability changes.

        Args:
            sensor_type: The sensor type
            available: Whether the sensor is now available
        """
        pass


# Global instance
_sensor_api: SensorAPI | None = None


def get_sensor_api() -> SensorAPI:
    """Get the global sensor API instance.

    Returns:
        The SensorAPI singleton
    """
    global _sensor_api
    if _sensor_api is None:
        _sensor_api = SensorAPI()
    return _sensor_api


def reset_sensor_api() -> None:
    """Reset the global sensor API instance.

    This is mainly useful for testing.
    """
    global _sensor_api
    _sensor_api = None
