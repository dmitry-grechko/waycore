import QtQuick 2.15
import ".." as Core

Rectangle {
    id: chip

    property string text: ""
    property string icon: ""
    property bool selected: false
    property bool deletable: false
    property bool enabled: true

    signal clicked()
    signal deleteClicked()

    opacity: enabled ? 1.0 : 0.5
    width: row.implicitWidth + Core.Theme.spacingMedium * 2
    height: Core.Theme.buttonHeight
    radius: height / 2
    color: {
        if (area.pressed && enabled) return Core.Theme.surfaceHighlight
        if (selected) return Core.Theme.accent
        return Core.Theme.surfaceElevated
    }
    border.color: selected ? Core.Theme.accent : Core.Theme.divider
    border.width: 1

    Behavior on color {
        ColorAnimation { duration: Core.Theme.animationFast }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Core.Theme.spacingXS

        // Leading icon
        Text {
            visible: chip.icon !== ""
            text: chip.icon
            color: chip.selected ? Core.Theme.textPrimary : Core.Theme.textSecondary
            font.pixelSize: Core.Theme.iconSizeSmall
            anchors.verticalCenter: parent.verticalCenter
        }

        // Label
        Text {
            text: chip.text
            color: chip.selected ? Core.Theme.textPrimary : Core.Theme.textSecondary
            font.pixelSize: Core.Theme.bodySize
            anchors.verticalCenter: parent.verticalCenter
        }

        // Delete button
        Item {
            visible: chip.deletable
            width: Core.Theme.iconSizeMedium
            height: Core.Theme.iconSizeMedium
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: chip.selected ? Core.Theme.textPrimary : Core.Theme.textSecondary
                font.pixelSize: Core.Theme.iconSizeSmall
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -Core.Theme.spacingXS
                onClicked: {
                    if (chip.enabled) chip.deleteClicked()
                }
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        enabled: chip.enabled

        onClicked: chip.clicked()
    }
}
