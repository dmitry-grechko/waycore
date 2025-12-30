import QtQuick 2.15
import QtQuick.Controls 2.15
import ".." as Core

/**
 * TacticalInput - Styled input field with accent left border
 *
 * Usage:
 *   TacticalInput {
 *       label: "TITLE"
 *       placeholder: "Enter title..."
 *       text: noteTitle
 *       onTextChanged: noteTitle = text
 *   }
 *
 * Properties:
 *   - label: Label text above the input (optional)
 *   - placeholder: Placeholder text
 *   - text: Input text value
 *   - monospace: Use monospace font (default: true)
 */
Column {
    id: root

    property string label: ""
    property string placeholder: ""
    property alias text: input.text
    property bool monospace: true
    readonly property bool inputFocused: input.activeFocus

    width: parent ? parent.width : 200
    spacing: 4

    // Label
    Text {
        visible: root.label !== ""
        text: root.label.toUpperCase()
        color: Core.Theme.textSecondary
        font.pixelSize: 10
        font.weight: Font.Bold
        font.letterSpacing: 2
        leftPadding: 4
    }

    // Input container
    Rectangle {
        width: parent.width
        height: Core.Theme.inputHeight
        color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3)
        radius: Core.Theme.borderRadius

        // Left accent border
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 2
            color: input.activeFocus ? Core.Theme.warning : Core.Theme.divider

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: Core.Theme.spacingMedium
            anchors.rightMargin: Core.Theme.spacingMedium
            verticalAlignment: TextInput.AlignVCenter
            color: Core.Theme.textPrimary
            font.pixelSize: 20
            font.weight: Font.Bold
            font.family: root.monospace ? Core.Theme.fontFamilyMono : Core.Theme.fontFamily
            clip: true
            selectByMouse: true

            // Placeholder
            Text {
                visible: !input.text && !input.activeFocus
                text: root.placeholder.toUpperCase()
                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)
                font: input.font
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
