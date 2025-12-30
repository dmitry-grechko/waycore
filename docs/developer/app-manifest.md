# App Manifest Reference

Every Waycore app must include a `manifest.json` file in its root directory.
This file declares the app's identity, capabilities, dependencies, and entry
points.

## Quick Example

```json
{
  "id": "com.waycore.compass",
  "name": "Compass",
  "version": "1.0.0",
  "description": "Navigation compass with magnetic heading",
  "icon": "🧭",
  "category": "navigation",
  "entry": {
    "qml": "qml/CompassMain.qml"
  },
  "sensors": [
    { "type": "magnetometer", "required": true },
    { "type": "gps", "required": false }
  ],
  "tier": 2,
  "enabled": true
}
```

## Required Fields

| Field       | Type   | Description                                                              |
| ----------- | ------ | ------------------------------------------------------------------------ |
| `id`        | string | Unique identifier in reverse domain format (e.g., `com.waycore.compass`) |
| `name`      | string | Display name (max 12 characters for UI)                                  |
| `version`   | string | Semantic version (`X.Y.Z` format)                                        |
| `icon`      | string | Emoji or icon name for display                                           |
| `entry.qml` | string | Path to main QML file (relative to app directory)                        |

### ID Format

The app ID must:

- Use reverse domain notation (e.g., `com.example.myapp`)
- Start with a lowercase letter
- Contain only lowercase letters and numbers
- Have at least two segments separated by dots

**Valid:** `com.waycore.compass`, `io.github.user.project`, `org.example.app123`

**Invalid:** `MyApp`, `com.Example.App`, `compass`, `123.app.test`

### Name Constraints

- Maximum 12 characters to fit in the UI grid
- Whitespace is trimmed automatically
- Should be descriptive but concise

### Version Format

Semantic versioning is required: `MAJOR.MINOR.PATCH`

**Valid:** `1.0.0`, `0.1.0`, `10.20.30`

**Invalid:** `1.0`, `v1.0.0`, `1.0.0-beta`

## Optional Fields

| Field            | Type   | Default | Description                                       |
| ---------------- | ------ | ------- | ------------------------------------------------- |
| `description`    | string | `null`  | Short description of the app                      |
| `category`       | enum   | `null`  | App category for grouping (see below)             |
| `entry.backend`  | string | `null`  | Path to backend module                            |
| `permissions`    | array  | `[]`    | Required system permissions                       |
| `sensors`        | array  | `[]`    | Sensor requirements                               |
| `tier`           | int    | `2`     | UI tier (1=home screen, 2=system hub)             |
| `homePosition`   | int    | `null`  | Fixed position on home grid (0-5) for tier 1 apps |
| `enabled`        | bool   | `true`  | Whether the app is enabled                        |
| `minCoreVersion` | string | `null`  | Minimum core version required                     |
| `database`       | object | `null`  | Database configuration                            |
| `lifecycle`      | object | `null`  | Lifecycle event hooks                             |
| `ai`             | object | `null`  | AI integration configuration                      |

## Categories

Apps must choose from these predefined categories:

| Category        | Description                       | Example Apps                    |
| --------------- | --------------------------------- | ------------------------------- |
| `emergency`     | SOS, emergency features           | SOS Beacon, Emergency Alerts    |
| `communication` | Messaging, radio, mesh networking | Meshtastic, Radio, Contacts     |
| `navigation`    | Maps, compass, GPS, waypoints     | Compass, Maps, GPS Tracker      |
| `media`         | Camera, gallery, audio/video      | Camera, Gallery, Voice Recorder |
| `ai`            | AI-powered features               | AI Assistant, Image Recognition |
| `utilities`     | General-purpose tools             | Calculator, Flashlight, Notes   |
| `sport`         | Fitness, training, outdoor sports | Shot Timer, Step Counter        |
| `health`        | Health monitoring, biometrics     | Heart Rate, First Aid Guide     |
| `weather`       | Weather and environmental data    | Weather, Barometer, UV Index    |
| `sensors`       | Raw sensor access, diagnostics    | Sensor Viewer, Altimeter        |
| `system`        | Device settings, configuration    | Settings, Modules, About        |

## Tiers

The tier determines where the app appears in the UI:

- **Tier 1:** Home screen (maximum 6 apps)
  - Directly accessible from main screen
  - Use `homePosition` (0-5) for fixed placement
  - Reserved for essential/frequently-used apps

- **Tier 2:** System Hub (default)
  - Accessed via System tile on home screen
  - Grouped by category
  - Suitable for most apps

## Sensor Requirements

Declare sensors your app needs:

```json
{
  "sensors": [
    { "type": "magnetometer", "required": true },
    { "type": "gps", "required": false }
  ]
}
```

- `required: true` — App won't work without this sensor
- `required: false` — App works but with reduced functionality

### Available Sensors

| Type            | Description          |
| --------------- | -------------------- |
| `magnetometer`  | Compass heading      |
| `gps`           | GPS location         |
| `barometer`     | Atmospheric pressure |
| `temperature`   | Temperature sensor   |
| `humidity`      | Humidity sensor      |
| `accelerometer` | Motion/acceleration  |

## Backend Module

Apps can optionally include a Python backend:

```json
{
  "entry": {
    "qml": "qml/Main.qml",
    "backend": "backend/service.py"
  }
}
```

The backend module must define a `create_bridge()` factory function:

```python
from PySide6.QtCore import QObject, Slot

class MyAppBackend(QObject):
    @Slot(result=str)
    def hello(self) -> str:
        return "Hello from backend!"

def create_bridge() -> QObject:
    return MyAppBackend()
```

## Database Configuration

Apps can declare database needs for persistent storage:

```json
{
  "database": {
    "version": 1,
    "sharedDataAccess": ["sensors.latest_readings"],
    "tables": [
      {
        "name": "notes",
        "columns": [
          { "name": "id", "type": "TEXT", "primary": true },
          { "name": "title", "type": "TEXT", "nullable": false },
          { "name": "content", "type": "TEXT" },
          {
            "name": "created_at",
            "type": "TIMESTAMP",
            "default": "CURRENT_TIMESTAMP"
          }
        ],
        "indexes": [
          { "name": "idx_created", "columns": ["created_at"] }
        ]
      }
    ],
    "migrations": [
      {
        "version": 2,
        "up": "ALTER TABLE notes ADD COLUMN category TEXT;"
      }
    ]
  }
}
```

### Shared Data Access

Apps can read (not write) specific core system tables:

- `sensors.latest_readings` — Recent sensor data
- `settings.user_preferences` — User settings
- `general.locations` — Saved locations

### Column Types

| Type        | SQLite Type | Description            |
| ----------- | ----------- | ---------------------- |
| `TEXT`      | TEXT        | String values          |
| `INTEGER`   | INTEGER     | Whole numbers          |
| `REAL`      | REAL        | Floating-point numbers |
| `BLOB`      | BLOB        | Binary data            |
| `TIMESTAMP` | TEXT        | ISO 8601 datetime      |

## Lifecycle Hooks

Apps can respond to system events:

```json
{
  "lifecycle": {
    "onReset": "backend/service.py:handle_reset",
    "onInstall": "backend/service.py:on_install",
    "onUninstall": "backend/service.py:on_uninstall"
  }
}
```

Hook format: `module_path:function_name`

## AI Integration

Apps can expose capabilities to the AI agent:

```json
{
  "ai": {
    "enabled": true,
    "tools": ["get_forecast", "get_current_conditions"],
    "description": "Weather forecasting capabilities",
    "confirmationRequired": ["set_alert"]
  }
}
```

This integrates with the OpenAPI spec at `/api/openapi.json` to auto-register AI
tools.

## Complete Example

```json
{
  "id": "com.waycore.notes",
  "name": "Notes",
  "version": "1.2.0",
  "description": "Create and manage text notes with location tagging",
  "icon": "📝",
  "category": "utilities",
  "entry": {
    "qml": "qml/NotesMain.qml",
    "backend": "backend/service.py"
  },
  "permissions": [
    "storage.write",
    "sensors.gps"
  ],
  "sensors": [
    { "type": "gps", "required": false }
  ],
  "tier": 2,
  "enabled": true,
  "minCoreVersion": "1.0.0",
  "database": {
    "version": 1,
    "tables": [
      {
        "name": "notes",
        "columns": [
          { "name": "id", "type": "TEXT", "primary": true },
          { "name": "title", "type": "TEXT", "nullable": false },
          { "name": "content", "type": "TEXT" },
          {
            "name": "created_at",
            "type": "TIMESTAMP",
            "default": "CURRENT_TIMESTAMP"
          },
          { "name": "latitude", "type": "REAL" },
          { "name": "longitude", "type": "REAL" }
        ],
        "indexes": [
          { "name": "idx_created", "columns": ["created_at"] }
        ]
      }
    ]
  }
}
```

## Validation

Manifests are validated on app load. Common errors:

| Error                                            | Cause             | Fix                                  |
| ------------------------------------------------ | ----------------- | ------------------------------------ |
| `id: String should match pattern`                | Invalid ID format | Use `com.domain.appname` format      |
| `version: String should match pattern`           | Invalid version   | Use `X.Y.Z` format                   |
| `name: String should have at most 12 characters` | Name too long     | Shorten the display name             |
| `entry.qml: Field required`                      | Missing QML entry | Add `entry.qml` path                 |
| `category: Input should be...`                   | Invalid category  | Use one of the predefined categories |

## Schema Location

The Pydantic schema is defined in:

- `device/libs/schemas/app_manifest.py`

Tests are in:

- `device/libs/schemas/tests/test_app_manifest.py`
- `device/apps/core/tests/test_manifest.py`
