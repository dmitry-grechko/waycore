import QtQuick 2.15
import ".." as Core

Rectangle {
    id: badge

    property string text: ""
    property string variant: "default"  // default | success | warning | error | accent
    property bool dot: false  // Show as simple dot indicator

    visible: text !== "" || dot
    width: dot ? dotSize : Math.max(minWidth, label.implicitWidth + Core.Theme.spacingSmall * 2)
    height: dot ? dotSize : Core.Theme.spacingLarge
    radius: height / 2

    readonly property int dotSize: 8
    readonly property int minWidth: Core.Theme.spacingLarge

    color: {
        switch(variant) {
            case "success": return Core.Theme.success
            case "warning": return Core.Theme.warning
            case "error": return Core.Theme.error
            case "accent": return Core.Theme.accent
            default: return Core.Theme.surfaceHighlight
        }
    }

    Text {
        id: label
        visible: !badge.dot
        anchors.centerIn: parent
        text: badge.text
        color: {
            if (badge.variant === "default") return Core.Theme.textSecondary
            return Core.Theme.textPrimary
        }
        font.pixelSize: Core.Theme.smallSize
        font.weight: Core.Theme.fontWeightBold
    }
}
