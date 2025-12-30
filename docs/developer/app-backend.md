# App Backend Integration

This guide covers how modular apps integrate with backend services in Waycore.

## Overview

Apps can access backend functionality through:

1. **Core Bridges**: Pre-registered bridges available to all apps
2. **Sensor API**: Unified access to sensor data
3. **Core Services**: Registry of shared services
4. **App Backends**: Custom backend modules per app

## Core Bridges

Core bridges are automatically available to all QML apps:

| Bridge       | Purpose            | Context Property |
| ------------ | ------------------ | ---------------- |
| SensorBridge | Sensor data access | `SensorBridge`   |
| NotesBridge  | Note storage       | `NotesBridge`    |
| MeshBridge   | Mesh network       | `MeshBridge`     |
| CameraBridge | Camera capture     | `CameraBridge`   |
| AIBridge     | AI inference       | `AIBridge`       |
| AppBridge    | App registry       | `AppBridge`      |

### Using Core Bridges in QML

```qml
import QtQuick 2.15

Rectangle {
    // Access sensor data
    property real heading: SensorBridge ? SensorBridge.compassHeading : 0

    // Check if services are available
    Component.onCompleted: {
        if (SensorBridge) {
            console.log("Sensor bridge available")
        }
    }
}
```

## Sensor API

The Sensor API provides a unified interface for sensor access.

### Python Usage

```python
from device.apps.core.sensor_api import get_sensor_api

sensor_api = get_sensor_api()

# Check availability
if sensor_api.is_available("magnetometer"):
    # Subscribe to updates
    sensor_api.subscribe("magnetometer")

    # Get current value
    heading = sensor_api.get_value("magnetometer", "heading")

    # Unsubscribe when done
    sensor_api.unsubscribe("magnetometer")
```

### Available Sensors

| Sensor          | Properties                         |
| --------------- | ---------------------------------- |
| `magnetometer`  | heading, cardinal, calibrated      |
| `gps`           | latitude, longitude, accuracy, fix |
| `barometer`     | pressure, elevation                |
| `temperature`   | celsius, fahrenheit                |
| `humidity`      | percentage                         |
| `accelerometer` | x, y, z                            |
| `light`         | lux                                |

### Subscription Reference Counting

The Sensor API uses reference counting for subscriptions:

```python
sensor_api.subscribe("gps")  # refcount = 1
sensor_api.subscribe("gps")  # refcount = 2
sensor_api.unsubscribe("gps")  # refcount = 1
sensor_api.unsubscribe("gps")  # refcount = 0, sensor stopped
```

## Core Services Registry

The CoreServices registry provides access to shared services.

### Python Usage

```python
from device.apps.core.services import get_core_services

services = get_core_services()

# Get a registered service
sensor_bridge = services.get("sensor_bridge")

# Check if service exists
if services.has("database"):
    db = services.get("database")

# List all services
names = services.get_all_names()
```

### Registering Services

```python
from device.apps.core.services import get_core_services

services = get_core_services()

# Register with factory
services.register(
    name="my_service",
    factory=lambda: MyService(),
    singleton=True,
    description="Custom service"
)

# Register existing instance
services.register_instance(
    name="existing",
    instance=my_instance,
    description="Pre-created service"
)
```

## App Backend Modules

Apps can include their own backend modules for complex functionality.

### Directory Structure

```
device/apps/myapp/
├── manifest.json
├── qml/
│   └── MyAppMain.qml
├── backend/
│   └── service.py    # Backend module
└── README.md
```

### Manifest Configuration

```json
{
  "id": "com.waycore.myapp",
  "name": "My App",
  "version": "1.0.0",
  "entry": {
    "qml": "qml/MyAppMain.qml",
    "backend": "backend/service.py"
  }
}
```

### Backend Module Pattern

```python
# backend/service.py
from __future__ import annotations

from PySide6.QtCore import QObject, Signal, Slot

from device.apps.core.services import get_core_services


class MyAppBackend(QObject):
    """Backend service for My App."""

    dataChanged = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        # Access core services
        services = get_core_services()
        self._db = services.get("database")

    @Slot(str, result=str)
    def processData(self, input_data: str) -> str:
        """Process data and return result."""
        return f"Processed: {input_data}"

    @Slot(result="QVariantList")
    def getItems(self) -> list[dict]:
        """Get list of items."""
        return [{"id": 1, "name": "Item 1"}]


def create_bridge() -> QObject:
    """Factory function called by BridgeLoader."""
    return MyAppBackend()
```

### Loading App Backends

```python
from device.apps.core.bridge_loader import get_bridge_loader
from pathlib import Path

loader = get_bridge_loader()

# Load app backend
bridge = loader.load_bridge(
    app_dir=Path("device/apps/myapp"),
    backend_path="backend/service.py"
)

if bridge:
    result = bridge.processData("test")
```

## Best Practices

### 1. Use Core Services

Don't create new database connections or clients. Use the core services
registry:

```python
# Good
services = get_core_services()
db = services.get("database")

# Bad
from device.libs.database import create_connection
db = create_connection()
```

### 2. Clean Up Subscriptions

Always unsubscribe from sensors when done:

```python
def start(self):
    self._sensor_api.subscribe("gps")

def stop(self):
    self._sensor_api.unsubscribe("gps")
```

### 3. Handle Missing Services

Check if services exist before using them:

```python
services = get_core_services()
if services.has("optional_service"):
    service = services.get("optional_service")
    service.do_something()
```

### 4. Type Hints for Slots

Use type hints for PySide6 slots:

```python
from PySide6.QtCore import Slot

@Slot(str, int, result=bool)
def myMethod(self, name: str, count: int) -> bool:
    return True
```

### 5. Signal Naming

Use past tense for signals that indicate something happened:

```python
dataChanged = Signal()
itemAdded = Signal(str)  # item_id
connectionLost = Signal()
```

## Error Handling

### BridgeLoadError

Raised when a backend module fails to load:

```python
from device.apps.core.bridge_loader import BridgeLoadError

try:
    bridge = loader.load_bridge(app_dir, backend_path)
except BridgeLoadError as e:
    print(f"Failed to load {e.app_id}: {e}")
    print(f"Details: {e.details}")
```

### Missing Sensor

Handle unavailable sensors gracefully:

```python
if sensor_api.is_available("barometer"):
    sensor_api.subscribe("barometer")
else:
    # Use fallback or show message
    self.show_sensor_unavailable("barometer")
```

## Testing App Backends

```python
import pytest
from pathlib import Path
from device.apps.core.bridge_loader import BridgeLoader

@pytest.fixture
def loader():
    return BridgeLoader()

def test_my_app_backend(loader, tmp_path):
    # Create test backend
    app_dir = tmp_path / "myapp"
    app_dir.mkdir()
    (app_dir / "backend").mkdir()
    (app_dir / "backend" / "service.py").write_text('''
def create_bridge():
    return {"test": True}
''')

    bridge = loader.load_bridge(app_dir, "backend/service.py")
    assert bridge["test"] is True
```

## Related Documentation

- [App Manifest Reference](./app-manifest.md)
- [UI Components](./ui-components.md)
- [Sensor Bridge API](../api/core-daemon.openapi.json)
