# Waycore App Development Guide

This guide covers everything you need to build apps for the Waycore platform.

## Introduction

### What is a Waycore App?

A Waycore app is a self-contained module that runs within the Waycore platform. Apps can:

- Display custom UI using QML
- Access sensor data (GPS, compass, temperature, etc.)
- Store data in a private SQLite database
- Read shared system data (with permission)
- Register backend services for complex processing

### App Architecture Overview

```
your-app/
├── manifest.json        # Required: App metadata and configuration
├── qml/
│   └── Main.qml        # Required: Main QML entry point
├── backend/             # Optional: Python backend
│   ├── __init__.py
│   └── service.py
└── README.md           # Recommended: App documentation
```

### Prerequisites

- Python 3.12+
- Qt 6.x / PySide6
- Poetry for dependency management
- Basic knowledge of QML and Python

## Quick Start

### 1. Create App Structure

```bash
# Using the scaffolding script
python scripts/create-app.py my-app

# Or with backend support
python scripts/create-app.py my-app --backend
```

This creates:
```
device/apps/my-app/
├── manifest.json
├── qml/
│   └── Main.qml
└── README.md
```

### 2. Edit manifest.json

```json
{
  "id": "com.waycore.myapp",
  "name": "My App",
  "version": "1.0.0",
  "description": "A custom Waycore app",
  "icon": "📱",
  "category": "utilities",
  "entry": {
    "qml": "qml/Main.qml"
  },
  "tier": 2,
  "enabled": true
}
```

### 3. Edit Main.qml

```qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import Core as Core

Rectangle {
    id: root
    color: Core.Theme.background

    signal closeRequested()

    property string appId: "com.waycore.myapp"
    property string appTitle: "My App"

    Core.AppBar {
        id: appBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        title: root.appTitle
        showBack: true
        onBackClicked: root.closeRequested()
    }

    // Your content here
    ColumnLayout {
        anchors.top: appBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Core.Theme.spacingMedium

        Text {
            text: "Hello from " + root.appTitle
            color: Core.Theme.textPrimary
            font.pixelSize: Core.Theme.h2Size
            Layout.alignment: Qt.AlignCenter
        }
    }
}
```

### 4. Test Your App

Run the UI and navigate to your app from the System Hub:

```bash
cd device/apps/ui && python main.py
```

## App Structure

### Directory Layout

| Path | Purpose |
|------|---------|
| `manifest.json` | App configuration and metadata |
| `qml/Main.qml` | Main QML entry point |
| `qml/*.qml` | Additional QML files |
| `backend/` | Python backend (optional) |
| `assets/` | Static assets (images, etc.) |
| `README.md` | Documentation |

### Entry Points

#### QML Entry (Required)

The main QML file must:
1. Be a `Rectangle` or `Item` as the root element
2. Define `signal closeRequested()` for navigation
3. Define `property string appId` and `property string appTitle`
4. Use `Core.AppBar` with back navigation

#### Backend Entry (Optional)

If your app needs Python logic:

```python
# backend/service.py
from PySide6.QtCore import QObject, Signal, Slot

class MyAppBackend(QObject):
    dataChanged = Signal()

    @Slot(str, result=str)
    def processData(self, input: str) -> str:
        return input.upper()

def create_bridge() -> QObject:
    """Factory function - REQUIRED"""
    return MyAppBackend()
```

Add to manifest:
```json
{
  "entry": {
    "qml": "qml/Main.qml",
    "backend": "backend/service.py"
  }
}
```

## App Tiers

Apps are organized into tiers:

| Tier | Location | Description |
|------|----------|-------------|
| **Tier 1** | Home Grid | Primary apps (max 6 slots) |
| **Tier 2** | System Hub | Secondary apps |

Set tier in manifest:
```json
{
  "tier": 1,
  "homePosition": 3  // Position 0-5 for tier 1 apps
}
```

## App Categories

| Category | Description |
|----------|-------------|
| `emergency` | Emergency/SOS features |
| `communication` | Messaging, radio |
| `navigation` | Maps, compass |
| `media` | Camera, gallery |
| `ai` | AI assistants |
| `sensors` | Sensor monitoring |
| `utilities` | Tools, notes |
| `system` | System settings |

## Permissions

Declare required permissions in manifest:

```json
{
  "permissions": [
    "camera",
    "location",
    "storage",
    "network",
    "flashlight"
  ]
}
```

## Next Steps

- [Manifest Reference](app-manifest.md) - Complete manifest documentation
- [UI Components](ui-components.md) - Available UI components
- [Sensor Access](app-sensors.md) - Working with sensors
- [Database Patterns](app-database.md) - Data storage
- [Backend Patterns](app-backend.md) - Python backends

## Example Apps

See `device/apps/` for example implementations:

- **Compass** - Sensor-based app with real-time updates
- **Notes** - CRUD app with database storage
- **Settings** - Multi-page navigation
- **Meshtastic** - Complex communication app
