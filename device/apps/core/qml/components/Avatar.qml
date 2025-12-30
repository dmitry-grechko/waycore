import QtQuick 2.15
import ".." as Core

Rectangle {
    id: avatar

    property string text: ""  // Initials or emoji
    property string size: "medium"  // small | medium | large
    property color backgroundColor: Core.Theme.surfaceElevated
    property color textColor: Core.Theme.textPrimary

    readonly property int sizeValue: {
        switch(size) {
            case "small": return Core.Theme.iconSizeLarge
            case "large": return 56
            default: return Core.Theme.touchTarget
        }
    }

    readonly property int fontSizeValue: {
        switch(size) {
            case "small": return Core.Theme.captionSize
            case "large": return Core.Theme.h2Size
            default: return Core.Theme.bodySize
        }
    }

    width: sizeValue
    height: sizeValue
    radius: sizeValue / 2
    color: backgroundColor

    Text {
        anchors.centerIn: parent
        text: avatar.text.slice(0, 2).toUpperCase()
        color: avatar.textColor
        font.pixelSize: fontSizeValue
        font.weight: Core.Theme.fontWeightBold
    }
}
