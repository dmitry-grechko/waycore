import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Core
import "." as Components

/**
 * ActionBar - Bottom action bar with primary and secondary buttons
 *
 * Usage:
 *   ActionBar {
 *       primaryText: "SAVE"
 *       primaryIcon: "save"
 *       onPrimaryClicked: saveNote()
 *
 *       secondaryIcon: "delete"
 *       secondaryDestructive: true
 *       onSecondaryClicked: deleteNote()
 *   }
 *
 * Properties:
 *   - primaryText: Text for primary button
 *   - primaryIcon: Icon name for primary button
 *   - primaryEnabled: Enable primary button (default: true)
 *   - primaryLoading: Show loading state (default: false)
 *   - secondaryIcon: Icon for secondary button (optional)
 *   - secondaryDestructive: Style as destructive action (default: false)
 *   - showHomeIndicator: Show home indicator bar (default: true)
 */
Rectangle {
    id: root

    property string primaryText: ""
    property string primaryIcon: ""
    property bool primaryEnabled: true
    property bool primaryLoading: false

    property string secondaryIcon: ""
    property bool secondaryDestructive: false

    property bool showHomeIndicator: true

    signal primaryClicked()
    signal secondaryClicked()

    height: 100
    color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.95)

    // Top border
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)
    }

    // Gradient fade above (for floating effect)
    Rectangle {
        anchors.bottom: parent.top
        width: parent.width
        height: 48
        gradient: Gradient {
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 1; color: Core.Theme.background }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Core.Theme.spacingMedium
        anchors.bottomMargin: root.showHomeIndicator ? Core.Theme.spacingLarge : Core.Theme.spacingMedium
        spacing: Core.Theme.spacingSmall

        // Primary button
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: primaryArea.pressed ? Qt.darker(Core.Theme.warning, 1.1) : Core.Theme.warning
            radius: Core.Theme.borderRadius
            opacity: root.primaryEnabled ? 1.0 : 0.5

            Row {
                anchors.centerIn: parent
                spacing: 8

                Components.MaterialIcon {
                    visible: root.primaryIcon !== "" && !root.primaryLoading
                    name: root.primaryIcon
                    size: 20
                    iconColor: Core.Theme.background
                }

                // Loading spinner
                Rectangle {
                    visible: root.primaryLoading
                    width: 20
                    height: 20
                    radius: 10
                    color: "transparent"
                    border.color: Core.Theme.background
                    border.width: 2

                    RotationAnimator on rotation {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: root.primaryLoading
                    }
                }

                Text {
                    visible: !root.primaryLoading
                    text: root.primaryText.toUpperCase()
                    color: Core.Theme.background
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: primaryArea
                anchors.fill: parent
                enabled: root.primaryEnabled && !root.primaryLoading
                onClicked: root.primaryClicked()
            }

            scale: primaryArea.pressed ? 0.98 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 100 }
            }
        }

        // Secondary button
        Rectangle {
            visible: root.secondaryIcon !== ""
            Layout.preferredWidth: 56
            Layout.fillHeight: true
            color: secondaryArea.pressed
                   ? (root.secondaryDestructive ? Qt.rgba(0.5, 0, 0, 0.3) : Core.Theme.surfaceHighlight)
                   : (root.secondaryDestructive ? Qt.rgba(0.5, 0, 0, 0.1) : Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2))
            radius: Core.Theme.borderRadius
            border.color: root.secondaryDestructive
                          ? Qt.rgba(0.5, 0, 0, 0.5)
                          : Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)
            border.width: 1

            Components.MaterialIcon {
                anchors.centerIn: parent
                name: root.secondaryIcon
                size: 20
                iconColor: root.secondaryDestructive
                           ? (secondaryArea.containsMouse ? "#F87171" : "#DC2626")
                           : (secondaryArea.containsMouse ? Core.Theme.warning : Core.Theme.textSecondary)
            }

            MouseArea {
                id: secondaryArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.secondaryClicked()
            }

            scale: secondaryArea.pressed ? 0.98 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 100 }
            }
        }
    }

    // Home indicator
    Rectangle {
        visible: root.showHomeIndicator
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: 128
        height: 4
        radius: 2
        color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
    }
}
