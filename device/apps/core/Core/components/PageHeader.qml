import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Core
import "." as Components

/**
 * PageHeader - Standardized tactical page header with back button and title
 *
 * Usage:
 *   PageHeader {
 *       title: "NOTES"
 *       showBack: true
 *       onBackClicked: navigateBack()
 *   }
 *
 * Properties:
 *   - title: Header title text
 *   - showBack: Show back button (default: true)
 *   - rightIcon: Material icon name for right action
 *   - subtitle: Optional subtitle text
 *   - transparent: Use transparent background (default: false)
 */
Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool showBack: true
    property string rightIcon: ""
    property bool transparent: false

    signal backClicked()
    signal rightClicked()

    height: Core.Theme.appBarHeight
    color: transparent ? "transparent" : Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.9)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Core.Theme.spacingMedium
        anchors.rightMargin: Core.Theme.spacingMedium
        spacing: Core.Theme.spacingMedium

        // Back button
        Rectangle {
            visible: root.showBack
            width: 48
            height: 48
            color: "transparent"
            Layout.alignment: Qt.AlignVCenter

            Components.MaterialIcon {
                anchors.centerIn: parent
                name: "chevron-left"
                size: 28
                iconColor: backArea.containsMouse ? Core.Theme.warning : Core.Theme.textSecondary

                Behavior on iconColor {
                    ColorAnimation { duration: 150 }
                }

                // Hover animation
                x: backArea.containsMouse ? -2 : 0
                Behavior on x {
                    NumberAnimation { duration: 150 }
                }
            }

            MouseArea {
                id: backArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.backClicked()
            }
        }

        // Spacer when no back button
        Item {
            visible: !root.showBack
            width: 48
            height: 48
        }

        // Title section
        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.title.toUpperCase()
                color: root.subtitle ? Core.Theme.warning : Core.Theme.textSecondary
                font.pixelSize: root.subtitle ? 16 : 14
                font.weight: Font.Bold
                font.letterSpacing: root.subtitle ? 4 : 3
            }

            Text {
                visible: root.subtitle !== ""
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.subtitle.toUpperCase()
                color: Core.Theme.divider
                font.pixelSize: 10
                font.family: Core.Theme.fontFamilyMono
                font.letterSpacing: 2
                opacity: 0.8
            }
        }

        // Right action button
        Rectangle {
            visible: root.rightIcon !== ""
            width: 48
            height: 48
            color: "transparent"
            Layout.alignment: Qt.AlignVCenter

            Components.MaterialIcon {
                anchors.centerIn: parent
                name: root.rightIcon
                size: 24
                iconColor: rightArea.containsMouse ? Core.Theme.warning : Core.Theme.textSecondary

                Behavior on iconColor {
                    ColorAnimation { duration: 150 }
                }
            }

            MouseArea {
                id: rightArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.rightClicked()
            }
        }

        // Spacer when no right icon
        Item {
            visible: root.rightIcon === ""
            width: 48
            height: 48
        }
    }

    // Bottom border
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
    }
}
