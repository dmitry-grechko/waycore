import QtQuick 2.15
import QtQuick.Controls 2.15
import ".." as Core

/**
 * TacticalTextArea - Multi-line text area with corner decorations
 *
 * Usage:
 *   TacticalTextArea {
 *       label: "CONTENT"
 *       placeholder: "Start typing..."
 *       text: noteContent
 *       onTextChanged: noteContent = text
 *   }
 *
 * Properties:
 *   - label: Label text above the area (optional)
 *   - placeholder: Placeholder text
 *   - text: Text value
 *   - minHeight: Minimum height (default: 200)
 *   - showCorners: Show corner decorations (default: true)
 */
Column {
    id: root

    property string label: ""
    property string placeholder: ""
    property alias text: textArea.text
    property int minHeight: 200
    property bool showCorners: true
    readonly property bool inputFocused: textArea.activeFocus

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

    // Text area container
    Item {
        width: parent.width
        height: Math.max(root.minHeight, textArea.contentHeight + Core.Theme.spacingLarge)

        // Border
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: textArea.activeFocus ? Core.Theme.warning : Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
            border.width: 1
            radius: Core.Theme.borderRadius

            Behavior on border.color {
                ColorAnimation { duration: 200 }
            }
        }

        // Corner decorations
        CornerDecoration {
            visible: root.showCorners
            anchors.top: parent.top
            anchors.left: parent.left
            rotation: 0
        }
        CornerDecoration {
            visible: root.showCorners
            anchors.top: parent.top
            anchors.right: parent.right
            rotation: 90
        }
        CornerDecoration {
            visible: root.showCorners
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            rotation: 270
        }
        CornerDecoration {
            visible: root.showCorners
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            rotation: 180
        }

        TextArea {
            id: textArea
            anchors.fill: parent
            anchors.margins: Core.Theme.spacingMedium
            wrapMode: TextEdit.Wrap
            font.pixelSize: 16
            font.family: Core.Theme.fontFamilyMono
            color: Core.Theme.textPrimary
            background: Rectangle { color: "transparent" }
            placeholderText: root.placeholder
            placeholderTextColor: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)
            selectByMouse: true
        }
    }

    // Corner decoration component
    component CornerDecoration: Item {
        width: 8
        height: 8

        Rectangle {
            width: 8
            height: 2
            color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.5)
            anchors.top: parent.top
            anchors.left: parent.left
        }

        Rectangle {
            width: 2
            height: 8
            color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.5)
            anchors.top: parent.top
            anchors.left: parent.left
        }
    }
}
