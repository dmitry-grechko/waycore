import QtQuick 2.15
import ".." as Core

Item {
    id: iconButton

    property string icon: "●"
    property color iconColor: Core.Theme.textPrimary
    property string size: "medium"  // small | medium | large
    property bool enabled: true
    property string tooltip: ""

    signal clicked()
    signal pressAndHold()

    opacity: enabled ? 1.0 : 0.5

    width: sizeValue
    height: sizeValue

    readonly property int sizeValue: {
        switch(size) {
            case "small": return Core.Theme.touchTargetSmall
            case "large": return Core.Theme.touchTargetLarge
            default: return Core.Theme.touchTarget
        }
    }

    readonly property int iconSizeValue: {
        switch(size) {
            case "small": return Core.Theme.iconSizeMedium
            case "large": return Core.Theme.iconSizeXL
            default: return Core.Theme.iconSizeLarge
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.width / 2
        color: area.pressed && iconButton.enabled ? Core.Theme.surfaceHighlight : "transparent"

        Behavior on color {
            ColorAnimation { duration: Core.Theme.animationFast }
        }
    }

    Text {
        anchors.centerIn: parent
        text: iconButton.icon
        color: iconButton.iconColor
        font.pixelSize: iconButton.iconSizeValue
    }

    MouseArea {
        id: area
        anchors.fill: parent
        enabled: iconButton.enabled

        onClicked: iconButton.clicked()
        onPressAndHold: iconButton.pressAndHold()
    }

    // Tooltip on hover (for desktop)
    ToolTip {
        id: tooltipItem
        visible: iconButton.tooltip !== "" && area.containsMouse
        text: iconButton.tooltip
    }

    // Simple ToolTip implementation
    Item {
        id: ToolTip
        property bool visible: false
        property string text: ""

        Rectangle {
            visible: parent.visible && parent.text !== ""
            anchors.bottom: iconButton.top
            anchors.horizontalCenter: iconButton.horizontalCenter
            anchors.bottomMargin: Core.Theme.spacingSmall
            width: tooltipText.implicitWidth + Core.Theme.spacingMedium
            height: tooltipText.implicitHeight + Core.Theme.spacingSmall
            color: Core.Theme.surface
            radius: Core.Theme.borderRadius
            border.color: Core.Theme.divider

            Text {
                id: tooltipText
                anchors.centerIn: parent
                text: ToolTip.text
                color: Core.Theme.textPrimary
                font.pixelSize: Core.Theme.smallSize
            }
        }
    }
}
