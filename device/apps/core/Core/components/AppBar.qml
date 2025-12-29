import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Core

Rectangle {
    id: bar

    property string title: ""
    property bool showBackButton: false
    property alias showBack: bar.showBackButton  // Compatibility alias
    property string rightIcon: ""
    property bool truncateTitle: true
    property Item rightContent: null  // Custom right content (e.g., IconButton)

    signal backClicked()
    signal rightIconClicked()

    color: Core.Theme.surface
    height: Core.Theme.appBarHeight

    onRightContentChanged: {
        if (rightContent) {
            rightContent.parent = rightContentContainer
            rightContent.anchors.centerIn = rightContentContainer
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Core.Theme.spacingMedium
        anchors.rightMargin: Core.Theme.spacingMedium
        spacing: Core.Theme.spacingSmall

        // Back button
        Rectangle {
            id: backBtn
            visible: bar.showBackButton
            width: Core.Theme.touchTargetMin
            height: Core.Theme.touchTargetMin
            color: backArea.pressed ? Core.Theme.surfaceHighlight : "transparent"
            radius: Core.Theme.borderRadius
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: "←"
                color: Core.Theme.textPrimary
                font.pixelSize: Core.Theme.h2Size
                font.weight: Core.Theme.fontWeightBold
            }

            MouseArea {
                id: backArea
                anchors.fill: parent
                onClicked: bar.backClicked()
            }

            Behavior on color {
                ColorAnimation { duration: Core.Theme.animationFast }
            }
        }

        // Title
        Text {
            id: titleText
            text: bar.title.toUpperCase()
            color: Core.Theme.textPrimary
            font.pixelSize: Core.Theme.h3Size
            font.weight: Core.Theme.fontWeightBold
            font.letterSpacing: 1
            elide: bar.truncateTitle ? Text.ElideRight : Text.ElideNone
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        // Right content container (for custom components)
        Item {
            id: rightContentContainer
            visible: bar.rightContent !== null
            width: Core.Theme.touchTargetMin
            height: Core.Theme.touchTargetMin
            Layout.alignment: Qt.AlignVCenter
        }

        // Right icon (optional, legacy support)
        Rectangle {
            id: rightBtn
            visible: bar.rightIcon !== "" && bar.rightContent === null
            width: Core.Theme.touchTargetMin
            height: Core.Theme.touchTargetMin
            color: rightArea.pressed ? Core.Theme.surfaceHighlight : "transparent"
            radius: Core.Theme.borderRadius
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: bar.rightIcon
                font.pixelSize: Core.Theme.iconSizeLarge
            }

            MouseArea {
                id: rightArea
                anchors.fill: parent
                onClicked: bar.rightIconClicked()
            }

            Behavior on color {
                ColorAnimation { duration: Core.Theme.animationFast }
            }
        }
    }

    // Bottom border
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Core.Theme.divider
    }
}
