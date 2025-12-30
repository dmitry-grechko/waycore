import QtQuick 2.15
import ".." as Core

/**
 * AppTile - Tactical-styled app tile with gradient overlay
 *
 * Supports both emoji icons (legacy) and Material icon names.
 * Material icons are lowercase with underscores (e.g., "map", "radio").
 * Emojis are detected by their Unicode range.
 *
 * Features:
 * - Dark green card background (tactical-card)
 * - Gradient overlay for depth
 * - Border styling
 * - Press animation with color change
 * - Icon and uppercase label
 */
Rectangle {
    id: tile

    property string appId: ""
    property string appName: ""
    property string appIcon: ""
    property bool isEmergency: false
    property bool compact: false

    signal clicked()

    width: compact ? 100 : Core.Theme.appTileSize
    height: compact ? 100 : Core.Theme.appTileSize
    radius: Core.Theme.borderRadiusLarge

    // Determine if icon is emoji (has high Unicode codepoint) or material icon name
    readonly property bool isEmoji: {
        if (appIcon.length === 0) return false
        var code = appIcon.charCodeAt(0)
        // Emojis typically start at U+1F000 or higher, or are in specific ranges
        // Also check for variation selectors and ZWJ sequences
        return code > 0x1000 || (code >= 0x2600 && code <= 0x27BF)
    }

    // Tactical card colors
    color: {
        if (isEmergency) {
            // Use warning (bronze/tan) color for emergency apps like SOS
            return mouseArea.pressed ? Qt.darker(Core.Theme.warning, 1.2) : Core.Theme.warning
        }
        return mouseArea.pressed ? Qt.lighter(Core.Theme.surface, 1.3) : Core.Theme.surface
    }

    border.color: isEmergency ? Qt.lighter(Core.Theme.warning, 1.3) : Core.Theme.divider
    border.width: 1

    // Gradient overlay for depth (from-black/40 to transparent)
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.4) }
            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0.2) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // Diagonal gradient for tactical look
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        rotation: -45
        transformOrigin: Item.Center
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.15) }
            GradientStop { position: 1.0; color: "transparent" }
        }
        visible: !mouseArea.pressed
    }

    Column {
        anchors.centerIn: parent
        spacing: compact ? Core.Theme.spacingSmall : Core.Theme.spacingSmall
        z: 10

        // Emoji icon (for legacy compatibility)
        Text {
            visible: tile.isEmoji
            anchors.horizontalCenter: parent.horizontalCenter
            text: tile.appIcon
            font.pixelSize: compact ? 36 : Core.Theme.iconSizeXL
        }

        // Material icon (for new tactical style)
        MaterialIcon {
            visible: !tile.isEmoji
            anchors.horizontalCenter: parent.horizontalCenter
            name: tile.appIcon
            size: compact ? 36 : Core.Theme.iconSizeXL
            // Use dark color for emergency tiles (bronze bg), white for normal tiles
            iconColor: tile.isEmergency ? Core.Theme.background : Core.Theme.textPrimary
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tile.appName.toUpperCase()
            // Use dark color for emergency tiles (bronze bg)
            color: tile.isEmergency ? Core.Theme.background : Core.Theme.textSecondary
            font.pixelSize: compact ? Core.Theme.tinySize : Core.Theme.labelSize
            font.weight: Core.Theme.fontWeightBold
            font.letterSpacing: Core.Theme.letterSpacingWide
            horizontalAlignment: Text.AlignHCenter
            width: tile.width - Core.Theme.spacingSmall * 2
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: tile.clicked()
    }

    // Press animation
    scale: mouseArea.pressed ? 0.95 : 1.0
    Behavior on scale {
        NumberAnimation { duration: Core.Theme.animationFast }
    }

    Behavior on color {
        ColorAnimation { duration: Core.Theme.animationFast }
    }
}
