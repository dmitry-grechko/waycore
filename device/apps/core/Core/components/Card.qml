import QtQuick 2.15
import ".." as Core

/**
 * Card - Tactical styled content container
 *
 * Matches the HTML design with:
 * - Semi-transparent surface background
 * - Border with highlight/divider color
 * - Proper padding and radius
 *
 * Usage:
 *   Core.Card {
 *       ColumnLayout {
 *           width: parent.width
 *           // Card content
 *       }
 *   }
 */
Rectangle {
    id: card

    property string title: ""
    property bool elevated: false
    property bool pressable: false
    property int minHeight: 0
    property bool accentBorder: false  // Use accent color for border (like danger zone)
    property color accentColor: Core.Theme.warning  // Color for accent border

    signal clicked()

    default property alias children: content.data

    // Semi-transparent surface background matching HTML
    color: {
        if (pressable && mouseArea.pressed) {
            return Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3)
        }
        if (pressable && mouseArea.containsMouse) {
            return Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2)
        }
        // bg-surface/10 from HTML
        return Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.1)
    }

    radius: Core.Theme.borderRadius
    border.color: {
        if (accentBorder) {
            return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.4)
        }
        if (pressable && mouseArea.containsMouse) {
            return Core.Theme.warning
        }
        // border-highlight from HTML
        return Core.Theme.divider
    }
    border.width: 1

    // Ensure minimum height when not explicitly set
    implicitHeight: Math.max(content.childrenRect.height + Core.Theme.spacingMedium * 2, minHeight, Core.Theme.touchTargetMin)

    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    // Content container - fills card with padding
    Item {
        id: content
        anchors.fill: parent
        anchors.margins: Core.Theme.spacingMedium
    }

    // MouseArea for pressable cards (behind content so children are clickable)
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: card.pressable
        hoverEnabled: card.pressable
        z: -1
        onClicked: card.clicked()
    }
}
