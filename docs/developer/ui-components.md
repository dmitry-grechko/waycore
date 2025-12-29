# Core UI Component Library

The Core UI library provides a consistent set of QML components and a power-efficient theme for building Waycore applications.

## Getting Started

### Importing the Library

```qml
import QtQuick 2.15
import Core 1.0 as Core

// Now you can use Core.Theme and Core.Button, Core.Card, etc.
```

### Using the Theme

The theme is a singleton that provides colors, typography, spacing, and animation values:

```qml
Rectangle {
    color: Core.Theme.background

    Text {
        text: "Hello"
        color: Core.Theme.textPrimary
        font.pixelSize: Core.Theme.bodySize
    }
}
```

## Theme Reference

### Colors

| Property | Description | Default (Dark) |
|----------|-------------|----------------|
| `background` | Main background | `#000000` |
| `surface` | Card/container background | `#0A0A0A` |
| `surfaceElevated` | Raised surfaces | `#141414` |
| `surfaceHighlight` | Pressed/hover states | `#1F1F1F` |
| `divider` | Borders and separators | `#2A2A2A` |
| `textPrimary` | Main text | `#FFFFFF` |
| `textSecondary` | Muted text | `#9CA3AF` |
| `textTertiary` | Disabled/hint text | `#6B7280` |

### Semantic Colors

| Property | Description |
|----------|-------------|
| `primary` | Brand color (outdoor amber) |
| `accent` | Accent color (high-viz orange) |
| `success` | Success states |
| `warning` | Warning states |
| `error` | Error states |
| `emergency` | Emergency/SOS (red) |

### Typography

| Property | Size | Usage |
|----------|------|-------|
| `h1Size` | 28px | Page titles |
| `h2Size` | 24px | Section headers |
| `h3Size` | 20px | Card titles |
| `bodySize` | 16px | Body text |
| `captionSize` | 14px | Captions, labels |
| `smallSize` | 12px | Small text |

### Spacing

| Property | Value | Usage |
|----------|-------|-------|
| `spacingXS` | 4px | Tight gaps |
| `spacingSmall` | 8px | Small gaps |
| `spacingMedium` | 12px | Medium gaps |
| `spacingLarge` | 16px | Large gaps |
| `spacingXL` | 24px | Section spacing |
| `spacingXXL` | 32px | Page padding |

### Touch Targets

| Property | Value | Usage |
|----------|-------|-------|
| `touchTarget` | 44px | Standard touch target |
| `touchTargetSmall` | 36px | Compact targets |
| `touchTargetLarge` | 56px | Primary actions |

## Components

### Button

A versatile button with multiple variants:

```qml
Core.Button {
    text: "Primary Action"
    variant: "primary"  // primary | secondary | ghost | danger
    fullWidth: true
    onClicked: doSomething()
}
```

**Props:**
- `text`: Button label
- `icon`: Optional leading icon (emoji)
- `variant`: "primary" | "secondary" | "ghost" | "danger"
- `size`: "small" | "medium" | "large"
- `fullWidth`: Whether button fills container width
- `loading`: Show loading state
- `enabled`: Enable/disable button

### Card

A container with elevated surface styling:

```qml
Core.Card {
    title: "Sensor Data"
    subtitle: "Updated 5 min ago"

    // Card content
    Text { text: "Content here" }
}
```

**Props:**
- `title`: Optional header title
- `subtitle`: Optional subtitle
- `pressable`: Enable click interaction
- `showDivider`: Show header divider

### ListItem

A standardized list row:

```qml
Core.ListItem {
    leadingIcon: "📍"
    title: "Current Location"
    subtitle: "Lat: 45.0°, Lon: -120.0°"
    trailingText: "GPS"
    onClicked: showDetails()
}
```

**Props:**
- `leadingIcon`: Left icon/emoji
- `title`: Primary text
- `subtitle`: Secondary text
- `trailingText`: Right-side text
- `trailingIcon`: Right-side icon
- `showDivider`: Show bottom divider

### AppTile

A tile for displaying apps on the home grid:

```qml
Core.AppTile {
    appId: "com.waycore.compass"
    appName: "Compass"
    appIcon: "🧭"
    isEmergency: false
    onClicked: launchApp(appId)
}
```

### StatusIndicator

An icon for showing connectivity or status:

```qml
Core.StatusIndicator {
    icon: "📶"
    active: isConnected
    tooltip: "GPS Connected"
}
```

### QuickAction

A button for the quick action strip:

```qml
Core.QuickAction {
    icon: "🔦"
    label: "Light"
    active: flashlightOn
    badge: ""  // Optional badge text
    onClicked: toggleFlashlight()
}
```

### Dialog

A modal dialog for confirmations:

```qml
Core.Dialog {
    id: confirmDialog
    title: "Delete Item?"
    message: "This action cannot be undone."
    confirmText: "Delete"
    cancelText: "Cancel"
    destructive: true

    onConfirmed: deleteItem()
    onCancelled: console.log("Cancelled")
}

// Show dialog
confirmDialog.open()
```

### Toast

A notification popup:

```qml
Core.Toast {
    id: toast
    position: "bottom"
    duration: 3000
}

// Show toast
toast.show("Changes saved", "UNDO")
```

### TextField

An enhanced text input:

```qml
Core.TextField {
    placeholderText: "Enter name..."
    errorText: nameError
    showCharacterCount: true
    maxCharacters: 50
}
```

### Switch

A toggle switch:

```qml
Core.Switch {
    checked: darkMode
    labelLeft: "Light"
    labelRight: "Dark"
    onCheckedChanged: toggleTheme()
}
```

### ProgressBar

A progress indicator:

```qml
Core.ProgressBar {
    value: 0.65
    showLabel: true
    variant: "success"  // default | success | warning | error
}
```

### LoadingIndicator

A spinning loader:

```qml
Core.LoadingIndicator {
    size: "medium"  // small | medium | large
    color: Core.Theme.accent
}
```

### Icon

An emoji or text-based icon with size presets:

```qml
Core.Icon {
    name: "🧭"
    size: "large"  // small | medium | large | xl
    iconColor: Core.Theme.accent
}
```

### SignalBars

Signal quality indicator for connectivity:

```qml
Core.SignalBars {
    snr: 8.5  // Signal-to-noise ratio in dB
    size: "medium"  // small | medium | large
    compact: false  // Hide tooltip
}
```

### Slider

A value slider with optional label:

```qml
Core.Slider {
    from: 0
    to: 100
    value: 50
    showLabel: true
    labelFormat: "%1%"
    onValueChanged: updateVolume(value)
}
```

### Badge

A small status indicator:

```qml
Core.Badge {
    text: "3"
    variant: "error"  // default | success | warning | error | accent
}

// Or as a dot indicator
Core.Badge {
    dot: true
    variant: "success"
}
```

### Chip

A selectable/deletable chip:

```qml
Core.Chip {
    text: "Outdoor"
    icon: "🏕️"
    selected: true
    deletable: true
    onClicked: toggleSelection()
    onDeleteClicked: removeChip()
}
```

### AppBar

A navigation header:

```qml
Core.AppBar {
    title: "Settings"
    showBack: true
    onBackClicked: navigation.pop()

    rightContent: Core.IconButton {
        icon: "⚙️"
        onClicked: openSettings()
    }
}
```

### TabBar

A tab navigation bar:

```qml
Core.TabBar {
    tabs: [
        { icon: "🏠", label: "Home" },
        { icon: "⚙️", label: "Settings" }
    ]
    currentIndex: 0
    onTabClicked: (index) => switchTab(index)
}
```

### EmptyState

A placeholder for empty content:

```qml
Core.EmptyState {
    icon: "📭"
    title: "No Messages"
    description: "Your inbox is empty"
    actionText: "Refresh"
    onActionClicked: refresh()
}
```

## Power Efficiency

The theme is optimized for OLED displays:

1. **Dark Background**: Pure black (`#000000`) saves power on OLED
2. **Minimal Borders**: Uses transparency and subtle dividers
3. **Efficient Animations**: Short durations (150-300ms)
4. **High Contrast**: Amber/orange accents for visibility

## Migration Guide

If migrating from the old `App.Theme`:

```qml
// Old
import "." as App
color: App.Theme.background

// New
import Core 1.0 as Core
color: Core.Theme.background
```

Most property names remain the same. Key changes:
- Import path: `"." as App` → `Core 1.0 as Core`
- Reference: `App.Theme` → `Core.Theme`
- Components: `App.Button` → `Core.Button`
