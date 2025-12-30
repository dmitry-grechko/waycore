import QtQuick 2.15
import ".." as Core

Rectangle {
    id: tile

    property string appId: ""
    property string appName: ""
    property string appIcon: ""
    property bool isEmergency: false
    property bool compact: false

    signal clicked()

    width: compact ? 80 : Core.Theme.appTileSize
    height: compact ? 80 : Core.Theme.appTileSize
    radius: Core.Theme.borderRadiusLarge

    color: {
        if (isEmergency) {
            return mouseArea.pressed ? Qt.darker(Core.Theme.emergency, 1.2) : Core.Theme.emergency
        }
        return mouseArea.pressed ? Core.Theme.surfaceHighlight : Core.Theme.surfaceElevated
    }

    border.color: isEmergency ? Qt.lighter(Core.Theme.emergency, 1.3) : Core.Theme.primaryLight
    border.width: 1

    Column {
        anchors.centerIn: parent
        spacing: compact ? Core.Theme.spacingXS : Core.Theme.spacingSmall

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tile.appIcon
            font.pixelSize: compact ? Core.Theme.iconSizeLarge : Core.Theme.iconSizeXL
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tile.appName.toUpperCase()
            color: Core.Theme.textPrimary
            font.pixelSize: compact ? 9 : Core.Theme.labelSize
            font.weight: Core.Theme.fontWeightBold
            font.letterSpacing: 1
            horizontalAlignment: Text.AlignHCenter
            width: tile.width - Core.Theme.spacingSmall * 2
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: tile.clicked()
    }

    // Press animation
    scale: mouseArea.pressed ? 0.95 : 1.0
    Behavior on scale {
        NumberAnimation { duration: Core.Theme.animationFast }
    }

    Behavior on color {
        ColorAnimation { duration: Core.Theme.animationFast }
    }
}
