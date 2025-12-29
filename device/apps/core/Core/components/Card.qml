import QtQuick 2.15
import ".." as Core

Rectangle {
    id: card

    property string title: ""
    property bool elevated: false
    property bool pressable: false
    property int minHeight: 0  // Optional minimum height

    signal clicked()

    default property alias children: content.data

    color: {
        if (pressable && mouseArea.pressed) {
            return Core.Theme.surfaceHighlight
        }
        return elevated ? Core.Theme.surfaceElevated : Core.Theme.surface
    }
    radius: Core.Theme.borderRadiusLarge
    border.color: Core.Theme.divider
    border.width: elevated ? 0 : 1

    // Ensure minimum height when not explicitly set
    implicitHeight: Math.max(content.childrenRect.height + Core.Theme.spacingMedium * 2, minHeight, Core.Theme.touchTargetMin)

    Behavior on color {
        ColorAnimation { duration: Core.Theme.animationFast }
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
        z: -1  // Behind content
        onClicked: card.clicked()
    }
}
