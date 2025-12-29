import QtQuick 2.15
import ".." as Core

Item {
    id: indicator

    property string size: "medium"  // small | medium | large
    property color color: Core.Theme.textPrimary

    width: sizeValue
    height: sizeValue

    readonly property int sizeValue: {
        switch(size) {
            case "small": return Core.Theme.iconSizeMedium
            case "large": return Core.Theme.iconSizeXL
            default: return Core.Theme.iconSizeLarge
        }
    }

    Rectangle {
        id: spinner
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: indicator.color
        border.width: size === "small" ? 2 : 3
        opacity: 0.3
    }

    Rectangle {
        id: arc
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: indicator.color
        border.width: size === "small" ? 2 : 3

        // Only show top-right quadrant using clip
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: parent.width / 2
            height: parent.height / 2
            color: indicator.color
            visible: false  // Hidden, just for clipping visualization
        }

        RotationAnimator on rotation {
            from: 0
            to: 360
            duration: 1200
            loops: Animation.Infinite
            running: indicator.visible
        }
    }

    // Alternative: Simple dots animation
    Row {
        id: dotsLoader
        visible: false  // Enable for dots style
        anchors.centerIn: parent
        spacing: Core.Theme.spacingXS

        Repeater {
            model: 3
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: indicator.color

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: dotsLoader.visible
                    NumberAnimation { to: 0.3; duration: 300; easing.type: Easing.InOutQuad }
                    PauseAnimation { duration: 100 * index }
                    NumberAnimation { to: 1.0; duration: 300; easing.type: Easing.InOutQuad }
                    PauseAnimation { duration: 100 * (2 - index) }
                }
            }
        }
    }
}
