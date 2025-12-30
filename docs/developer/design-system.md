# Waycore Design System

The Waycore Design System provides a tactical, military-inspired visual language optimized for outdoor use and OLED power efficiency. This document provides comprehensive API references for the Core component library and theme tokens.

## Table of Contents

- [Getting Started](#getting-started)
- [Theme Reference](#theme-reference)
  - [Color Palette](#color-palette)
  - [Typography](#typography)
  - [Spacing](#spacing)
  - [Dimensions](#dimensions)
  - [Animation](#animation)
- [Components Reference](#components-reference)
  - [Layout Components](#layout-components)
  - [Input Components](#input-components)
  - [Display Components](#display-components)
  - [Navigation Components](#navigation-components)
  - [Feedback Components](#feedback-components)
- [Design Patterns](#design-patterns)
- [Best Practices](#best-practices)

---

## Getting Started

### Importing the Core Library

```qml
import QtQuick 2.15
import Core 1.0 as Core

// Access theme singleton
Rectangle {
    color: Core.Theme.background
}

// Use components
Core.Button {
    text: "Action"
    variant: "tactical"
}
```

### Design Philosophy

1. **Tactical Aesthetic**: Military-inspired HUD design with green accent colors
2. **Outdoor Readability**: High contrast for visibility in all lighting conditions
3. **OLED Optimized**: Dark backgrounds save battery on OLED displays
4. **Touch-First**: Large touch targets (48dp minimum) for gloved use
5. **Power Efficient**: Minimal animations, short durations (100-300ms)

---

## Theme Reference

The `Theme` singleton provides all design tokens. Access via `Core.Theme.<property>`.

### Mode Toggle

The theme supports switching between dark mode (default) and daylight mode for outdoor visibility.

| Property | Type | Description |
|----------|------|-------------|
| `daylightMode` | `bool` | Toggle daylight mode (default: `false`) |

```qml
// Toggle daylight mode
Core.Theme.toggleDaylightMode()
```

---

### Color Palette

#### Primary Colors (Tactical Green)

| Property | Dark Mode | Daylight Mode | Description |
|----------|-----------|---------------|-------------|
| `primary` | `#2c583c` | `#2c583c` | Main green accent |
| `primaryDark` | `#1B3D2F` | `#1B3D2F` | Darker tactical card background |
| `primaryLight` | `#3D5A4D` | `#3D5A4D` | Lighter green for hover states |
| `primaryAccent` | `#5C7A65` | `#5C7A65` | Muted green accent |

#### Background Colors (OLED-Optimized)

| Property | Dark Mode | Daylight Mode | Description |
|----------|-----------|---------------|-------------|
| `background` | `#0A0F0A` | `#F8FAF9` | Main screen background |
| `backgroundAlt` | `#0D120D` | `#E8EFEB` | Alternate background |

#### Surface Colors

| Property | Dark Mode | Daylight Mode | Description |
|----------|-----------|---------------|-------------|
| `surface` | `#1B3D2F` | `#FFFFFF` | Card/container background |
| `surfaceElevated` | `#243D32` | `#F0F5F2` | Raised surfaces |
| `surfaceHighlight` | `#2D5A3D` | `#D4E4DA` | Active/highlighted states |

#### Border & Divider

| Property | Dark Mode | Daylight Mode | Description |
|----------|-----------|---------------|-------------|
| `divider` | `#2D5A3D` | `#D0DCD4` | Section dividers |
| `border` | `#2D5A3D` | `#C0CCC4` | Component borders |

#### Semantic Colors

| Property | Dark Mode | Daylight Mode | Description |
|----------|-----------|---------------|-------------|
| `success` | `#4ADE80` | `#16A34A` | Success states |
| `warning` | `#D4A574` | `#D97706` | Warning states (tactical tan) |
| `error` | `#C97064` | `#DC2626` | Error states |
| `emergency` | `#DC2626` | `#B91C1C` | Emergency/SOS |
| `info` | `#60A5FA` | `#2563EB` | Information states |

#### Accent Colors

| Property | Dark Mode | Daylight Mode | Description |
|----------|-----------|---------------|-------------|
| `accent` | `#2c583c` | `#2D5A3E` | Primary accent |
| `accentLight` | `#3D5A4D` | `#3D7A54` | Light accent for hover |

#### Text Colors

| Property | Dark Mode | Daylight Mode | Description |
|----------|-----------|---------------|-------------|
| `textPrimary` | `#FFFFFF` | `#0A0F0C` | Main text |
| `textSecondary` | `#a5b1a9` | `#3A453E` | Muted/secondary text |
| `textTertiary` | `#7B8B7F` | `#6A756E` | Tertiary text |
| `textDisabled` | `#6B7B6F` | `#8A958E` | Disabled text |
| `textInverse` | `#0A0F0A` | `#FFFFFF` | Text on inverse background |
| `textMono` | `#8B9B8F` | `#4A5A4E` | Monospace/coordinate text |

#### State Colors

| Property | Value | Description |
|----------|-------|-------------|
| `disabled` | `#4A5A50` / `#C5D0C9` | Disabled state color |
| `statusActive` | `#2c583c` | Active status indicator |
| `statusInactive` | `#2D5A3D` | Inactive status indicator |

---

### Typography

#### Font Families

| Property | Value | Description |
|----------|-------|-------------|
| `fontFamily` | `"Space Grotesk, system-ui, -apple-system, sans-serif"` | Primary display font |
| `fontFamilyMono` | `"SF Mono, Monaco, Cascadia Code, Roboto Mono, monospace"` | Monospace for data/coordinates |

#### Font Weights

| Property | Value | Description |
|----------|-------|-------------|
| `fontWeightNormal` | `Font.Medium` | Normal text weight |
| `fontWeightBold` | `Font.Bold` | Bold text weight |
| `fontWeightHeavy` | `Font.ExtraBold` | Heavy/extra bold weight |

#### Type Scale

| Property | Size | Usage |
|----------|------|-------|
| `h1Size` | `32px` | Page titles |
| `h2Size` | `24px` | Section headers |
| `h3Size` | `20px` | Card titles |
| `bodySize` | `16px` | Body text |
| `bodySmallSize` | `14px` | Secondary body text |
| `smallSize` | `12px` | Small text, captions |
| `captionSize` | `12px` | Caption text |
| `labelSize` | `11px` | ALL CAPS labels |
| `tinySize` | `10px` | Badges, small indicators |

#### Letter Spacing

| Property | Value | Usage |
|----------|-------|-------|
| `letterSpacingWide` | `2` | WAYCORE title, headers |
| `letterSpacingNormal` | `1` | Labels, buttons |
| `letterSpacingMono` | `0.5` | Coordinates, data |

---

### Spacing

Based on an 8dp grid system.

| Property | Value | Usage |
|----------|-------|-------|
| `spacingXS` | `4dp` | Tight gaps, inline spacing |
| `spacingSmall` | `8dp` | Small gaps between elements |
| `spacingMedium` | `16dp` | Standard component padding |
| `spacingLarge` | `24dp` | Section spacing |
| `spacingXL` | `32dp` | Large section gaps |
| `spacingXXL` | `48dp` | Page-level spacing |

---

### Dimensions

#### Touch Targets

| Property | Value | Usage |
|----------|-------|-------|
| `touchTargetSmall` | `36dp` | Compact buttons, icons |
| `touchTargetMin` | `48dp` | Minimum touch target |
| `touchTarget` | `48dp` | Standard touch target |
| `touchTargetLarge` | `64dp` | Primary actions |
| `touchTargetXL` | `80dp` | Large action areas |

#### Component Heights

| Property | Value | Description |
|----------|-------|-------------|
| `appBarHeight` | `56dp` | App bar / toolbar height |
| `statusBarHeight` | `80dp` | Tactical status HUD |
| `quickActionHeight` | `88dp` | Quick action dock |
| `buttonHeight` | `56dp` | Standard button height |
| `inputHeight` | `56dp` | Text input height |

#### Icon Sizes

| Property | Value | Usage |
|----------|-------|-------|
| `iconSizeSmall` | `20dp` | Small inline icons |
| `iconSizeMedium` | `24dp` | Standard icons |
| `iconSizeLarge` | `32dp` | Large icons |
| `iconSizeXL` | `48dp` | App tiles, hero icons |
| `appTileSize` | `120dp` | Home screen app tiles |

#### Border Radius

| Property | Value | Usage |
|----------|-------|-------|
| `borderRadius` | `4dp` | Standard corners (tactical) |
| `borderRadiusLarge` | `8dp` | Cards, dialogs |

#### Grid

| Property | Value | Description |
|----------|-------|-------------|
| `gridSize` | `40dp` | Background grid pattern size |

---

### Animation

Power-efficient animation durations.

| Property | Value | Usage |
|----------|-------|-------|
| `animationFast` | `100ms` | Button press, micro-interactions |
| `animationNormal` | `200ms` | Transitions, state changes |
| `animationSlow` | `300ms` | Complex transitions |
| `pulseInterval` | `1000ms` | Pulse animation timing |

---

## Components Reference

### Layout Components

#### TacticalBackground

Standardized tactical grid background with vignette effect.

```qml
Core.TacticalBackground {
    anchors.fill: parent
    gridSize: Core.Theme.gridSize
    gridOpacity: 0.1
    showVignette: true
    vignetteOpacity: 0.3
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `gridSize` | `int` | `Theme.gridSize` | Size of grid squares |
| `gridOpacity` | `real` | `0.1` | Opacity of grid lines |
| `showVignette` | `bool` | `true` | Show vignette effect |
| `vignetteOpacity` | `real` | `0.3` | Vignette opacity |

---

#### Card

Tactical styled content container with semi-transparent background.

```qml
Core.Card {
    title: "Settings"
    pressable: true
    onClicked: openSettings()

    ColumnLayout {
        width: parent.width
        // Card content
    }
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `string` | `""` | Optional header title |
| `elevated` | `bool` | `false` | Use elevated surface color |
| `pressable` | `bool` | `false` | Enable click interaction |
| `minHeight` | `int` | `0` | Minimum card height |
| `accentBorder` | `bool` | `false` | Use accent color for border |
| `accentColor` | `color` | `Theme.warning` | Color for accent border |

| Signal | Description |
|--------|-------------|
| `clicked()` | Emitted when pressable card is clicked |

---

#### ScrollView

Styled scroll container with tactical scrollbar.

```qml
Core.ScrollView {
    anchors.fill: parent
    showIndicator: true

    ColumnLayout {
        width: parent.width
        // Scrollable content
    }
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `showIndicator` | `bool` | `true` | Show scroll indicator |
| `bouncing` | `bool` | `true` | Enable bounce effect |

---

#### Divider

Section divider with variant styles.

```qml
Core.Divider {
    variant: "inset"  // full | inset | middle
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `vertical` | `bool` | `false` | Vertical divider |
| `variant` | `string` | `"full"` | `"full"` / `"inset"` / `"middle"` |

---

### Input Components

#### Button

Versatile button with multiple tactical variants.

```qml
// Primary tactical action
Core.Button {
    text: "Save"
    iconName: "save"
    variant: "tactical"
    onClicked: saveData()
}

// Secondary action
Core.Button {
    text: "Cancel"
    variant: "tacticalSecondary"
    onClicked: cancel()
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `string` | `""` | Button label |
| `variant` | `string` | `"contained"` | Button style variant |
| `icon` | `string` | `""` | Emoji icon (legacy) |
| `iconName` | `string` | `""` | Material icon name |
| `loading` | `bool` | `false` | Show loading spinner |
| `fullWidth` | `bool` | `false` | Fill container width |
| `size` | `string` | `"medium"` | `"small"` / `"medium"` / `"large"` |
| `enabled` | `bool` | `true` | Enable/disable button |

**Variants:**
- `contained` / `primary`: Filled primary button
- `outlined`: Outlined button
- `text`: Text-only button
- `secondary`: Secondary action
- `danger`: Destructive action
- `ghost`: Transparent background
- `tactical`: Warning-colored primary action
- `tacticalSecondary`: Outlined tactical style

| Signal | Description |
|--------|-------------|
| `clicked()` | Emitted when button is clicked |

---

#### TacticalInput

Styled text input with accent left border.

```qml
Core.TacticalInput {
    label: "TITLE"
    placeholder: "Enter title..."
    text: noteTitle
    onTextChanged: noteTitle = text
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `label` | `string` | `""` | Label above input |
| `placeholder` | `string` | `""` | Placeholder text |
| `text` | `string` | `""` | Input value (alias) |
| `monospace` | `bool` | `true` | Use monospace font |
| `inputFocused` | `bool` | readonly | Whether input is focused |

---

#### TacticalTextArea

Multi-line text area with corner decorations.

```qml
Core.TacticalTextArea {
    label: "CONTENT"
    placeholder: "Start typing..."
    text: noteContent
    minHeight: 200
    showCorners: true
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `label` | `string` | `""` | Label above area |
| `placeholder` | `string` | `""` | Placeholder text |
| `text` | `string` | `""` | Text value (alias) |
| `minHeight` | `int` | `200` | Minimum height |
| `showCorners` | `bool` | `true` | Show corner decorations |
| `inputFocused` | `bool` | readonly | Whether area is focused |

---

#### TacticalComboBox

Styled dropdown select.

```qml
Core.TacticalComboBox {
    model: ["Option 1", "Option 2", "Option 3"]
    currentIndex: 0
    onActivated: console.log("Selected:", currentText)
}
```

Inherits from Qt Quick Controls `ComboBox`. All standard ComboBox properties apply.

---

#### TextField

Enhanced text input with validation support.

```qml
Core.TextField {
    placeholderText: "Enter name..."
    errorText: nameError
    showCharacterCount: true
    maxCharacters: 50
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `errorText` | `string` | `""` | Error message to display |
| `showCharacterCount` | `bool` | `false` | Show character counter |
| `maxCharacters` | `int` | `-1` | Max characters (-1 = unlimited) |

---

#### Switch

Tactical styled toggle switch.

```qml
Core.Switch {
    checked: isEnabled
    onToggled: (value) => isEnabled = value
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `checked` | `bool` | `false` | Toggle state |
| `enabled` | `bool` | `true` | Enable/disable switch |

| Signal | Description |
|--------|-------------|
| `toggled(bool value)` | Emitted when state changes |

---

#### Slider

Tactical styled value slider with rectangular handle.

```qml
Core.Slider {
    from: 0
    to: 100
    value: 85
    showLabel: true
    labelFormat: "%1%"
    onValueChanged: updateBrightness(value)
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `from` | `real` | `0` | Minimum value |
| `to` | `real` | `100` | Maximum value |
| `value` | `real` | `0` | Current value |
| `stepSize` | `real` | `1` | Step increment |
| `showLabel` | `bool` | `false` | Show value label above handle |
| `labelFormat` | `string` | `"%1"` | Label format string |
| `labelDecimals` | `int` | `0` | Decimal places in label |

---

### Display Components

#### PageHeader

Navigation header with back button and title.

```qml
Core.PageHeader {
    title: "NOTES"
    subtitle: "12 entries"
    showBack: true
    rightIcon: "plus"
    onBackClicked: navigateBack()
    onRightClicked: addNew()
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `string` | `""` | Header title text |
| `subtitle` | `string` | `""` | Optional subtitle |
| `showBack` | `bool` | `true` | Show back button |
| `rightIcon` | `string` | `""` | Material icon for right action |
| `transparent` | `bool` | `false` | Transparent background |

| Signal | Description |
|--------|-------------|
| `backClicked()` | Emitted when back button clicked |
| `rightClicked()` | Emitted when right icon clicked |

---

#### MaterialIcon

Material Design Icons component using MDI font.

```qml
Core.MaterialIcon {
    name: "flashlight"
    size: 32
    iconColor: Core.Theme.textPrimary
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `name` | `string` | `""` | Icon name from available set |
| `size` | `int` | `Theme.iconSizeMedium` | Icon size in pixels |
| `iconColor` | `color` | `Theme.textPrimary` | Icon color |

**Available Icons:**

| Category | Icons |
|----------|-------|
| Time | `schedule`, `clock`, `clock-outline` |
| Battery | `battery`, `battery-high`, `battery-medium`, `battery-low`, `battery-outline`, `battery-charging` |
| Signal | `signal`, `wifi`, `wifi-off`, `radio`, `radio-tower`, `access-point`, `broadcast` |
| Navigation | `map`, `map-marker`, `navigation`, `compass`, `explore`, `crosshairs-gps` |
| Communication | `message`, `chat`, `forum`, `phone` |
| Medical | `medical-bag`, `first-aid` |
| Power | `flashlight`, `flashlight-off`, `torch`, `lightbulb`, `lock`, `power`, `restart` |
| Settings | `settings`, `cog`, `tune`, `wrench` |
| Media | `camera`, `image`, `video`, `microphone` |
| Files | `file`, `folder`, `note`, `edit_note` |
| Formatting | `format-bold`, `format-italic`, `format-underline`, `format-list-bulleted`, `code-tags`, `link` |
| AI | `robot`, `brain`, `chip` |
| Actions | `close`, `check`, `plus`, `minus`, `refresh`, `search`, `delete`, `edit`, `save`, `send` |
| Arrows | `arrow-back`, `chevron-left`, `chevron-right`, `chevron-up`, `chevron-down` |
| Status | `information`, `alert`, `warning`, `error`, `help`, `check-circle` |

---

#### Badge

Status indicator badge with semantic variants.

```qml
Core.Badge {
    text: "Online"
    variant: "success"
}

// Dot indicator only
Core.Badge {
    dot: true
    variant: "success"
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `string` | `""` | Badge label |
| `variant` | `string` | `"default"` | `"default"` / `"success"` / `"warning"` / `"error"` |
| `dot` | `bool` | `false` | Show as dot only |
| `outline` | `bool` | `true` | Use outline style |

---

#### ProgressBar

Tactical styled progress indicator.

```qml
Core.ProgressBar {
    value: 0.52
    variant: "warning"
}

// Indeterminate loading
Core.ProgressBar {
    indeterminate: true
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `value` | `real` | `0.0` | Progress value (0.0 to 1.0) |
| `indeterminate` | `bool` | `false` | Show indeterminate animation |
| `variant` | `string` | `"default"` | `"default"` / `"success"` / `"warning"` / `"error"` |
| `barColor` | `color` | auto | Custom bar color |

---

#### LoadingIndicator

Spinning loader animation.

```qml
Core.LoadingIndicator {
    size: "medium"
    color: Core.Theme.accent
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | `string` | `"medium"` | `"small"` / `"medium"` / `"large"` |
| `color` | `color` | `Theme.textPrimary` | Spinner color |

---

#### EmptyState

Placeholder for empty content with optional action.

```qml
Core.EmptyState {
    iconName: "note"
    title: "No Notes"
    message: "Create your first note to get started"
    actionText: "Create Note"
    actionIcon: "plus"
    onActionClicked: createNote()
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `icon` | `string` | `""` | Emoji icon (deprecated) |
| `iconName` | `string` | `""` | MaterialIcon name |
| `title` | `string` | `"Nothing here"` | Title text |
| `message` | `string` | `""` | Description text |
| `description` | `string` | alias | Alias for message |
| `actionText` | `string` | `""` | Action button text |
| `actionIcon` | `string` | `""` | Action button icon |
| `tacticalStyle` | `bool` | `true` | Use tactical styling |

| Signal | Description |
|--------|-------------|
| `actionClicked()` | Emitted when action button clicked |

---

#### ListItem

Standardized list row with icon and text.

```qml
Core.ListItem {
    icon: "📍"
    text: "Current Location"
    secondaryText: "Lat: 45.0°, Lon: -120.0°"
    trailing: "GPS"
    showDivider: true
    onClicked: showDetails()
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `icon` | `string` | `""` | Leading icon/emoji |
| `text` | `string` | `""` | Primary text |
| `secondaryText` | `string` | `""` | Secondary text |
| `trailing` | `string` | `""` | Trailing text |
| `selected` | `bool` | `false` | Selected state |
| `showDivider` | `bool` | `true` | Show bottom divider |

| Signal | Description |
|--------|-------------|
| `clicked()` | Emitted when item clicked |
| `longPressed()` | Emitted on long press |

---

#### Chip

Selectable/deletable chip component.

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

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `string` | `""` | Chip label |
| `icon` | `string` | `""` | Leading icon |
| `selected` | `bool` | `false` | Selected state |
| `deletable` | `bool` | `false` | Show delete button |
| `enabled` | `bool` | `true` | Enable/disable chip |

| Signal | Description |
|--------|-------------|
| `clicked()` | Emitted when chip clicked |
| `deleteClicked()` | Emitted when delete button clicked |

---

### Navigation Components

#### ActionBar

Bottom action bar with primary and secondary buttons.

```qml
Core.ActionBar {
    primaryText: "SAVE"
    primaryIcon: "save"
    primaryEnabled: isValid
    onPrimaryClicked: saveNote()

    secondaryIcon: "delete"
    secondaryDestructive: true
    onSecondaryClicked: deleteNote()
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `primaryText` | `string` | `""` | Primary button text |
| `primaryIcon` | `string` | `""` | Primary button icon |
| `primaryEnabled` | `bool` | `true` | Enable primary button |
| `primaryLoading` | `bool` | `false` | Show loading on primary |
| `secondaryIcon` | `string` | `""` | Secondary button icon |
| `secondaryDestructive` | `bool` | `false` | Destructive styling |
| `showHomeIndicator` | `bool` | `true` | Show home indicator bar |

| Signal | Description |
|--------|-------------|
| `primaryClicked()` | Emitted when primary button clicked |
| `secondaryClicked()` | Emitted when secondary button clicked |

---

#### TabBar

Tab navigation bar.

```qml
Core.TabBar {
    tabs: [
        { icon: "🏠", label: "Home" },
        { icon: "⚙️", label: "Settings" }
    ]
    currentIndex: 0
    showLabels: true
    onTabClicked: (index) => switchTab(index)
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `tabs` | `array` | `[]` | Array of `{icon, label}` objects |
| `currentIndex` | `int` | `0` | Active tab index |
| `showLabels` | `bool` | `true` | Show tab labels |

| Signal | Description |
|--------|-------------|
| `tabClicked(int index)` | Emitted when tab clicked |

---

#### IconButton

Circular icon button with tooltip.

```qml
Core.IconButton {
    icon: "⚙️"
    size: "medium"
    tooltip: "Settings"
    onClicked: openSettings()
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `icon` | `string` | `"●"` | Button icon/emoji |
| `iconColor` | `color` | `Theme.textPrimary` | Icon color |
| `size` | `string` | `"medium"` | `"small"` / `"medium"` / `"large"` |
| `enabled` | `bool` | `true` | Enable/disable button |
| `tooltip` | `string` | `""` | Tooltip text on hover |

| Signal | Description |
|--------|-------------|
| `clicked()` | Emitted when button clicked |
| `pressAndHold()` | Emitted on long press |

---

### Feedback Components

#### Dialog

Modal dialog for confirmations.

```qml
Core.Dialog {
    id: confirmDialog
    title: "Delete Item?"
    message: "This action cannot be undone."
    confirmText: "Delete"
    cancelText: "Cancel"
    showCancel: true
    destructive: true

    onConfirmed: deleteItem()
    onCancelled: console.log("Cancelled")
}

// Show dialog
confirmDialog.open()
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `string` | `""` | Dialog title |
| `message` | `string` | `""` | Dialog message |
| `confirmText` | `string` | `"OK"` | Confirm button text |
| `cancelText` | `string` | `"Cancel"` | Cancel button text |
| `showCancel` | `bool` | `true` | Show cancel button |
| `destructive` | `bool` | `false` | Destructive confirm styling |

| Signal | Description |
|--------|-------------|
| `confirmed()` | Emitted when confirmed |
| `cancelled()` | Emitted when cancelled |

---

#### Toast

Notification popup with auto-dismiss.

```qml
Core.Toast {
    id: toast
    position: "bottom"
    duration: 3000
}

// Show toast
toast.show("Changes saved", "UNDO")
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `message` | `string` | `""` | Toast message |
| `duration` | `int` | `3000` | Display duration (ms) |
| `position` | `string` | `"bottom"` | `"bottom"` / `"top"` |
| `actionText` | `string` | `""` | Action button text |

| Method | Description |
|--------|-------------|
| `show(text, actionLabel)` | Show toast with message |
| `hide()` | Hide toast immediately |

| Signal | Description |
|--------|-------------|
| `actionClicked()` | Emitted when action clicked |

---

## Design Patterns

### Standard App Layout

```qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import Core 1.0 as Core

Rectangle {
    anchors.fill: parent
    color: Core.Theme.background

    // Background grid
    Core.TacticalBackground {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Core.PageHeader {
            Layout.fillWidth: true
            title: "APP NAME"
            showBack: true
            onBackClicked: navigateBack()
        }

        // Content area
        Core.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                width: parent.width
                spacing: Core.Theme.spacingMedium
                padding: Core.Theme.spacingMedium

                // Content cards
                Core.Card {
                    Layout.fillWidth: true
                    // Card content
                }
            }
        }

        // Bottom action bar
        Core.ActionBar {
            Layout.fillWidth: true
            primaryText: "ACTION"
            primaryIcon: "check"
            onPrimaryClicked: performAction()
        }
    }
}
```

### Settings Screen Pattern

```qml
Core.ScrollView {
    ColumnLayout {
        width: parent.width
        spacing: 0

        // Section with switch
        Core.Card {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Column {
                    Layout.fillWidth: true
                    Text {
                        text: "Feature Name"
                        color: Core.Theme.textPrimary
                        font.pixelSize: Core.Theme.bodySize
                    }
                    Text {
                        text: "Feature description"
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.captionSize
                    }
                }

                Core.Switch {
                    checked: settings.featureEnabled
                    onToggled: settings.featureEnabled = checked
                }
            }
        }

        // Section with slider
        Core.Card {
            Layout.fillWidth: true

            Column {
                width: parent.width
                spacing: Core.Theme.spacingMedium

                Text {
                    text: "Volume"
                    color: Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.bodySize
                }

                Core.Slider {
                    width: parent.width
                    from: 0
                    to: 100
                    value: settings.volume
                    showLabel: true
                    labelFormat: "%1%"
                    onValueChanged: settings.volume = value
                }
            }
        }
    }
}
```

---

## Best Practices

### Do's

1. **Use Theme Tokens**: Always use `Core.Theme` for colors, spacing, and typography
2. **Respect Touch Targets**: Minimum 48dp for all interactive elements
3. **Provide Visual Feedback**: Use animations and state changes on interaction
4. **Support Both Modes**: Test in both dark and daylight modes
5. **Use Semantic Colors**: Apply success/warning/error colors appropriately
6. **Keep It Tactical**: Maintain the military-inspired aesthetic

### Don'ts

1. **Don't Hardcode Colors**: Always use theme tokens
2. **Don't Skip Touch Targets**: Never make buttons smaller than 48dp
3. **Don't Overuse Animation**: Keep animations short and purposeful
4. **Don't Ignore Contrast**: Ensure text is readable in all conditions
5. **Don't Mix Styles**: Stick to the tactical design language

### Performance Tips

1. Use `Behavior on` animations sparingly
2. Prefer opacity changes over color animations
3. Use `clip: true` only when necessary
4. Avoid deeply nested layouts
5. Use `Component` for complex repeated items

---

## Migration from App.Theme

If migrating from the old `App.Theme`:

```qml
// Old
import "." as App
color: App.Theme.background

// New
import Core 1.0 as Core
color: Core.Theme.background
```

Most property names remain compatible. Key changes:
- Import path: `"." as App` → `Core 1.0 as Core`
- Reference: `App.Theme` → `Core.Theme`
- Components: `App.Button` → `Core.Button`
