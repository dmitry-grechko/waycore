import QtQuick 2.15
import ".." as Core

/**
 * Badge - Tactical styled status indicator badge
 *
 * Matches the HTML design with:
 * - Semi-transparent background with border
 * - Small rounded pill shape
 * - Monospace uppercase text
 * - Optional dot indicator
 *
 * Usage:
 *   Core.Badge {
 *       text: "Online"
 *       variant: "success"
 *   }
 */
Rectangle {
    id: badge

    property string text: ""
    property string variant: "default"  // default | success | warning | error
    property bool dot: false
    property bool outline: true  // Use outline style (default for tactical)

    visible: text !== "" || dot
    width: dot ? dotSize : Math.max(minWidth, label.implicitWidth + Core.Theme.spacingSmall * 2 + (statusDot.visible ? 12 : 0))
    height: dot ? dotSize : 22
    radius: height / 2

    readonly property int dotSize: 8
    readonly property int minWidth: 48

    // Get colors based on variant
    readonly property color variantColor: {
        switch(variant) {
            case "success": return "#4ADE80"  // Green
            case "warning": return Core.Theme.warning
            case "error": return Core.Theme.error
            default: return Core.Theme.divider
        }
    }

    // Background - semi-transparent with border
    color: Qt.rgba(variantColor.r, variantColor.g, variantColor.b, outline ? 0.1 : 0.8)
    border.color: Qt.rgba(variantColor.r, variantColor.g, variantColor.b, 0.3)
    border.width: 1

    Row {
        anchors.centerIn: parent
        spacing: 4
        visible: !badge.dot

        // Status dot inside badge
        Rectangle {
            id: statusDot
            visible: badge.variant !== "default"
            width: 6
            height: 6
            radius: 3
            anchors.verticalCenter: parent.verticalCenter
            color: badge.variantColor

            // Glow effect for success status
            Rectangle {
                visible: badge.variant === "success"
                anchors.centerIn: parent
                width: parent.width + 4
                height: parent.height + 4
                radius: width / 2
                color: "transparent"
                border.color: Qt.rgba(badge.variantColor.r, badge.variantColor.g, badge.variantColor.b, 0.4)
                border.width: 1
            }
        }

        Text {
            id: label
            text: badge.text.toUpperCase()
            color: {
                if (badge.variant === "success") return "#4ADE80"
                if (badge.variant === "warning") return Core.Theme.warning
                if (badge.variant === "error") return Core.Theme.error
                return Core.Theme.textSecondary
            }
            font.pixelSize: 10
            font.weight: Font.Bold
            font.family: Core.Theme.fontFamilyMono
            font.letterSpacing: 0.5
        }
    }
}
