import QtQuick 2.15
import ".." as Core

Item {
    id: switchControl

    property bool checked: false
    property bool enabled: true

    signal toggled(bool value)

    width: 52
    height: 32
    opacity: enabled ? 1.0 : 0.5

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: switchControl.checked ? Core.Theme.success : Core.Theme.surfaceElevated
        border.color: switchControl.checked ? Core.Theme.success : Core.Theme.divider
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: Core.Theme.animationNormal }
        }
    }

    Rectangle {
        id: thumb
        width: 26
        height: 26
        radius: width / 2
        color: Core.Theme.textPrimary
        anchors.verticalCenter: parent.verticalCenter
        x: switchControl.checked ? parent.width - width - 3 : 3

        Behavior on x {
            NumberAnimation { duration: Core.Theme.animationNormal; easing.type: Easing.OutQuad }
        }

        // Subtle shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: parent.radius + 1
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.1)
            border.width: 1
            z: -1
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: switchControl.enabled
        onClicked: {
            switchControl.checked = !switchControl.checked
            switchControl.toggled(switchControl.checked)
        }
    }
}
