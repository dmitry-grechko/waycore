import QtQuick 2.15
import QtQuick.Controls 2.15
import ".." as Core

TextField {
    id: tf

    property string errorText: ""
    property bool showCharacterCount: false
    property int maxCharacters: -1

    font.pixelSize: Core.Theme.bodySize
    height: Core.Theme.inputHeight

    background: Rectangle {
        color: Core.Theme.surfaceElevated
        radius: Core.Theme.borderRadius
        border.color: tf.errorText !== "" ? Core.Theme.error : (tf.activeFocus ? Core.Theme.accent : Core.Theme.divider)
        border.width: tf.activeFocus ? 2 : 1

        Behavior on border.color {
            ColorAnimation { duration: Core.Theme.animationFast }
        }
    }

    color: Core.Theme.textPrimary
    placeholderTextColor: Core.Theme.textSecondary
    selectionColor: Core.Theme.accent
    selectedTextColor: Core.Theme.textPrimary

    leftPadding: Core.Theme.spacingMedium
    rightPadding: Core.Theme.spacingMedium

    // Error text display
    Text {
        visible: tf.errorText !== ""
        anchors.top: parent.bottom
        anchors.left: parent.left
        anchors.topMargin: Core.Theme.spacingXS
        text: tf.errorText
        color: Core.Theme.error
        font.pixelSize: Core.Theme.captionSize
    }

    // Character count
    Text {
        visible: tf.showCharacterCount
        anchors.top: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: Core.Theme.spacingXS
        text: tf.maxCharacters > 0 ? tf.text.length + "/" + tf.maxCharacters : tf.text.length
        color: tf.maxCharacters > 0 && tf.text.length > tf.maxCharacters ? Core.Theme.error : Core.Theme.textSecondary
        font.pixelSize: Core.Theme.captionSize
    }
}
