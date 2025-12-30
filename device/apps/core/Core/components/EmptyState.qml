import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Core

Item {
    id: emptyState

    property string icon: ""           // Emoji icon (deprecated, use iconName)
    property string iconName: ""       // MaterialIcon name
    property string title: "Nothing here"
    property string message: ""
    property alias description: emptyState.message  // Compatibility alias
    property string actionText: ""
    property string actionIcon: ""     // MaterialIcon name for action button
    property bool tacticalStyle: true  // Use tactical styling

    signal actionClicked()

    Column {
        anchors.centerIn: parent
        spacing: Core.Theme.spacingMedium
        width: parent.width - Core.Theme.spacingLarge * 2

        // Icon container with glow effect
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 120
            height: 120
            visible: emptyState.iconName !== "" || emptyState.icon !== ""

            // Glow effect
            Rectangle {
                visible: emptyState.tacticalStyle
                anchors.centerIn: parent
                width: 140
                height: 140
                radius: 70
                color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.1)

                Behavior on scale {
                    NumberAnimation { duration: 700; easing.type: Easing.InOutQuad }
                }

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.15; duration: 1500; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutQuad }
                }
            }

            // Icon card
            Rectangle {
                anchors.centerIn: parent
                width: 96
                height: 96
                radius: 16
                color: Core.Theme.surface
                border.color: Core.Theme.divider
                border.width: 1

                // Gradient overlay
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.05) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // Icon
                Core.MaterialIcon {
                    visible: emptyState.iconName !== ""
                    anchors.centerIn: parent
                    name: emptyState.iconName
                    size: 64
                    iconColor: Core.Theme.textSecondary
                }

                // Legacy emoji icon
                Text {
                    visible: emptyState.icon !== "" && emptyState.iconName === ""
                    anchors.centerIn: parent
                    text: emptyState.icon
                    font.pixelSize: 48
                    opacity: 0.6
                }
            }
        }

        // Title
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: emptyState.title.toUpperCase()
            color: Core.Theme.textPrimary
            font.pixelSize: 20
            font.weight: Font.Bold
            font.letterSpacing: 3
        }

        // Message
        Text {
            visible: emptyState.message !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(280, parent.width)
            text: emptyState.message
            color: Core.Theme.textSecondary
            font.pixelSize: Core.Theme.bodySmallSize
            font.family: Core.Theme.fontFamilyMono
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            lineHeight: 1.4
        }

        // Spacer
        Item { width: 1; height: Core.Theme.spacingMedium }

        // Action button
        Rectangle {
            visible: emptyState.actionText !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(240, parent.width)
            height: 56
            radius: Core.Theme.borderRadius
            color: actionArea.pressed ? Qt.darker(Core.Theme.warning, 1.1) : Core.Theme.warning

            Row {
                anchors.centerIn: parent
                spacing: Core.Theme.spacingSmall

                Core.MaterialIcon {
                    visible: emptyState.actionIcon !== ""
                    name: emptyState.actionIcon
                    size: 24
                    iconColor: Core.Theme.background
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: emptyState.actionText.toUpperCase()
                    color: Core.Theme.background
                    font.pixelSize: Core.Theme.bodySmallSize
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                }
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
