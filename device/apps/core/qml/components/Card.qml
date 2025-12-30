import QtQuick 2.15
import ".." as Core

Rectangle {
    id: card

    property string title: ""
    property bool elevated: false

    default property alias children: content.data

    color: elevated ? Core.Theme.surfaceElevated : Core.Theme.surface
    radius: Core.Theme.borderRadiusLarge
    border.color: Core.Theme.divider
    border.width: elevated ? 0 : 1
    implicitHeight: innerColumn.implicitHeight + Core.Theme.spacingMedium * 2

    Column {
        id: innerColumn
        anchors.fill: parent
        anchors.margins: Core.Theme.spacingMedium
        spacing: Core.Theme.spacingSmall

        // Title (optional)
        Text {
            visible: card.title !== ""
            text: card.title.toUpperCase()
            color: Core.Theme.textSecondary
            font.pixelSize: Core.Theme.labelSize
            font.weight: Core.Theme.fontWeightBold
            font.letterSpacing: 1
        }

        // Content
        Column {
            id: content
            width: parent.width
            spacing: Core.Theme.spacingSmall
        }
    }
}
