import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Core

Rectangle {
    id: item

    property string icon: ""
    property string text: ""
    property string secondaryText: ""
    property string trailing: ""
    property bool selected: false
    property bool showDivider: true

    signal clicked()
    signal longPressed()

    height: Math.max(Core.Theme.touchTargetLarge, contentLayout.implicitHeight + Core.Theme.spacingMedium * 2)
    color: {
        if (selected) return Core.Theme.surfaceHighlight
        if (mouseArea.pressed) return Core.Theme.surfaceElevated
        return "transparent"
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.leftMargin: Core.Theme.spacingMedium
        anchors.rightMargin: Core.Theme.spacingMedium
        spacing: Core.Theme.spacingMedium

        // Icon
        Text {
            visible: item.icon !== ""
            text: item.icon
            font.pixelSize: Core.Theme.iconSizeLarge
            Layout.alignment: Qt.AlignVCenter
        }

        // Text content
        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: item.text
                color: Core.Theme.textPrimary
                font.pixelSize: Core.Theme.bodySize
                font.weight: Core.Theme.fontWeightNormal
                width: parent.width
                elide: Text.ElideRight
            }

            Text {
                visible: item.secondaryText !== ""
                text: item.secondaryText
                color: Core.Theme.textSecondary
                font.pixelSize: Core.Theme.captionSize
                width: parent.width
                elide: Text.ElideRight
            }
        }

        // Trailing content
        Text {
            visible: item.trailing !== ""
            text: item.trailing
            color: Core.Theme.textSecondary
            font.pixelSize: Core.Theme.bodySize
            Layout.alignment: Qt.AlignVCenter
        }

        // Chevron
        Text {
            text: "›"
            color: Core.Theme.textDisabled
            font.pixelSize: Core.Theme.h2Size
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // Divider
    Rectangle {
        visible: item.showDivider
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: item.icon !== "" ? Core.Theme.spacingMedium + Core.Theme.iconSizeLarge + Core.Theme.spacingMedium : Core.Theme.spacingMedium
        height: 1
        color: Core.Theme.divider
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: item.clicked()
        onPressAndHold: item.longPressed()
    }

    Behavior on color {
        ColorAnimation { duration: Core.Theme.animationFast }
    }
}
