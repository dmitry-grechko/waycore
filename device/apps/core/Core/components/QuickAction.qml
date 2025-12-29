import QtQuick 2.15
import ".." as Core

Rectangle {
    id: action

    property string icon: ""
    property string label: ""
    property bool active: false
    property int badge: 0

    signal clicked()

    width: 70
    height: 70
    radius: Core.Theme.borderRadiusLarge
    color: active ? Core.Theme.primaryAccent : "transparent"
    border.color: active ? "transparent" : Core.Theme.divider
    border.width: active ? 0 : 1

    Column {
        anchors.centerIn: parent
        spacing: Core.Theme.spacingXS

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: action.icon
            font.pixelSize: Core.Theme.iconSizeLarge
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: action.label.toUpperCase()
            color: active ? Core.Theme.textPrimary : Core.Theme.textSecondary
            font.pixelSize: 10
            font.weight: Font.Medium
            font.letterSpacing: 1
        }
    }

    // Badge for notifications
    Rectangle {
        visible: action.badge > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: -4
        width: 20
        height: 20
        radius: 10
        color: Core.Theme.error

        Text {
            anchors.centerIn: parent
            text: action.badge > 9 ? "9+" : action.badge
            color: Core.Theme.textPrimary
            font.pixelSize: 10
            font.bold: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: action.clicked()
    }

    // Press animation
    scale: mouseArea.pressed ? 0.95 : 1.0
    Behavior on scale {
        NumberAnimation { duration: Core.Theme.animationFast }
    }

    Behavior on color {
        ColorAnimation { duration: Core.Theme.animationNormal }
    }
}
