import QtQuick 2.15
import ".." as Core

Rectangle {
    id: btn

    property string text: ""
    property string variant: "contained" // contained | outlined | text
    property bool enabled: true
    property string icon: ""
    property bool loading: false

    signal clicked()

    height: Core.Theme.buttonHeight
    radius: Core.Theme.borderRadius
    opacity: enabled ? 1.0 : 0.5

    color: {
        if (!enabled) return Core.Theme.disabled
        if (variant === "contained") {
            return mouseArea.pressed ? Core.Theme.primaryDark : Core.Theme.primary
        }
        if (mouseArea.pressed) return Core.Theme.surfaceHighlight
        return "transparent"
    }

    border.color: {
        if (variant === "outlined") return Core.Theme.primaryLight
        return "transparent"
    }
    border.width: variant === "outlined" ? 1 : 0

    Row {
        anchors.centerIn: parent
        spacing: Core.Theme.spacingSmall

        // Loading indicator
        Rectangle {
            visible: btn.loading
            width: Core.Theme.iconSizeMedium
            height: Core.Theme.iconSizeMedium
            radius: width / 2
            color: "transparent"
            border.color: Core.Theme.textPrimary
            border.width: 2
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: parent.width / 2
                height: parent.height / 2
                color: Core.Theme.textPrimary
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
            }

            RotationAnimator on rotation {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: btn.loading
            }
        }

        // Icon
        Text {
            visible: btn.icon !== "" && !btn.loading
            text: btn.icon
            font.pixelSize: Core.Theme.iconSizeMedium
            anchors.verticalCenter: parent.verticalCenter
        }

        // Label
        Text {
            visible: !btn.loading
            text: btn.text.toUpperCase()
            color: variant === "contained" ? Core.Theme.textPrimary : Core.Theme.textPrimary
            font.pixelSize: Core.Theme.bodySize
            font.weight: Core.Theme.fontWeightBold
            font.letterSpacing: 1
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: btn.enabled && !btn.loading
        onClicked: btn.clicked()
    }

    Behavior on color {
        ColorAnimation { duration: Core.Theme.animationFast }
    }

    Behavior on opacity {
        NumberAnimation { duration: Core.Theme.animationFast }
    }
}
