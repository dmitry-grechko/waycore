import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".." as Core

Popup {
    id: dialog

    property string title: ""
    property string message: ""
    property string confirmText: "OK"
    property string cancelText: "Cancel"
    property bool showCancel: true
    property bool destructive: false

    signal confirmed()
    signal cancelled()

    anchors.centerIn: parent
    width: Math.min(parent.width - Core.Theme.spacingLarge * 2, 320)
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: Core.Theme.surface
        radius: Core.Theme.borderRadiusLarge
        border.color: Core.Theme.divider
    }

    contentItem: ColumnLayout {
        spacing: Core.Theme.spacingMedium

        // Title
        Text {
            visible: dialog.title !== ""
            text: dialog.title
            color: Core.Theme.textPrimary
            font.pixelSize: Core.Theme.h3Size
            font.weight: Core.Theme.fontWeightBold
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // Message
        Text {
            visible: dialog.message !== ""
            text: dialog.message
            color: Core.Theme.textSecondary
            font.pixelSize: Core.Theme.bodySize
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // Buttons
        RowLayout {
            spacing: Core.Theme.spacingSmall
            Layout.fillWidth: true
            Layout.topMargin: Core.Theme.spacingSmall

            // Cancel button
            Rectangle {
                visible: dialog.showCancel
                Layout.fillWidth: true
                height: Core.Theme.buttonHeight
                radius: Core.Theme.borderRadius
                color: cancelArea.pressed ? Core.Theme.surfaceHighlight : "transparent"
                border.color: Core.Theme.divider

                Text {
                    anchors.centerIn: parent
                    text: dialog.cancelText.toUpperCase()
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.bodySize
                    font.weight: Core.Theme.fontWeightBold
                    font.letterSpacing: 1
                }

                MouseArea {
                    id: cancelArea
                    anchors.fill: parent
                    onClicked: {
                        dialog.cancelled()
                        dialog.close()
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: Core.Theme.animationFast }
                }
            }

            // Confirm button
            Rectangle {
                Layout.fillWidth: true
                height: Core.Theme.buttonHeight
                radius: Core.Theme.borderRadius
                color: {
                    if (confirmArea.pressed) {
                        return dialog.destructive ? Qt.darker(Core.Theme.error, 1.2) : Core.Theme.primaryDark
                    }
                    return dialog.destructive ? Core.Theme.error : Core.Theme.primary
                }

                Text {
                    anchors.centerIn: parent
                    text: dialog.confirmText.toUpperCase()
                    color: Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.bodySize
                    font.weight: Core.Theme.fontWeightBold
                    font.letterSpacing: 1
                }

                MouseArea {
                    id: confirmArea
                    anchors.fill: parent
                    onClicked: {
                        dialog.confirmed()
                        dialog.close()
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: Core.Theme.animationFast }
                }
            }
        }
    }

    padding: Core.Theme.spacingLarge

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Core.Theme.animationNormal }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: Core.Theme.animationNormal; easing.type: Easing.OutQuad }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: Core.Theme.animationFast }
    }
}
