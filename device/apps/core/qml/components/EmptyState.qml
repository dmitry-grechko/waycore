import QtQuick 2.15
import ".." as Core

Item {
    id: emptyState

    property string icon: "📭"
    property string title: "Nothing here"
    property string message: ""
    property string actionText: ""

    signal actionClicked()

    Column {
        anchors.centerIn: parent
        spacing: Core.Theme.spacingMedium
        width: parent.width - Core.Theme.spacingLarge * 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: emptyState.icon
            font.pixelSize: 64
            opacity: 0.6
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: emptyState.title
            color: Core.Theme.textPrimary
            font.pixelSize: Core.Theme.h3Size
            font.weight: Core.Theme.fontWeightBold
        }

        Text {
            visible: emptyState.message !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: emptyState.message
            color: Core.Theme.textSecondary
            font.pixelSize: Core.Theme.bodySize
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        // Action button (optional)
        Rectangle {
            visible: emptyState.actionText !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            width: actionLabel.width + Core.Theme.spacingLarge * 2
            height: Core.Theme.buttonHeight
            radius: Core.Theme.borderRadius
            color: actionArea.pressed ? Core.Theme.primaryDark : Core.Theme.primary

            Text {
                id: actionLabel
                anchors.centerIn: parent
                text: emptyState.actionText.toUpperCase()
                color: Core.Theme.textPrimary
                font.pixelSize: Core.Theme.bodySize
                font.weight: Core.Theme.fontWeightBold
                font.letterSpacing: 1
            }

            MouseArea {
                id: actionArea
                anchors.fill: parent
                onClicked: emptyState.actionClicked()
            }

            Behavior on color {
                ColorAnimation { duration: Core.Theme.animationFast }
            }
        }
    }
}
