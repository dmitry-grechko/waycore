import QtQuick 2.15
import ".." as Core

Rectangle {
    id: tabBar

    property var tabs: []
    property int currentIndex: 0
    property bool showLabels: true

    signal tabClicked(int index)

    color: Core.Theme.surfaceElevated
    height: Core.Theme.touchTargetLarge

    Row {
        anchors.fill: parent

        Repeater {
            model: tabBar.tabs

            Item {
                width: tabBar.width / tabBar.tabs.length
                height: parent.height

                Rectangle {
                    anchors.fill: parent
                    color: tabArea.pressed ? Core.Theme.surfaceHighlight : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: Core.Theme.animationFast }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: Core.Theme.spacingXS

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.icon || "●"
                        color: index === tabBar.currentIndex ? Core.Theme.accent : Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.iconSizeMedium

                        Behavior on color {
                            ColorAnimation { duration: Core.Theme.animationFast }
                        }
                    }

                    Text {
                        visible: tabBar.showLabels
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.label || modelData
                        color: index === tabBar.currentIndex ? Core.Theme.accent : Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.captionSize
                        font.weight: index === tabBar.currentIndex ? Core.Theme.fontWeightBold : Core.Theme.fontWeightNormal

                        Behavior on color {
                            ColorAnimation { duration: Core.Theme.animationFast }
                        }
                    }
                }

                // Active indicator
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.6
                    height: 3
                    radius: 2
                    color: Core.Theme.accent
                    opacity: index === tabBar.currentIndex ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: Core.Theme.animationNormal }
                    }
                }

                MouseArea {
                    id: tabArea
                    anchors.fill: parent
                    onClicked: {
                        tabBar.currentIndex = index
                        tabBar.tabClicked(index)
                    }
                }
            }
        }
    }
}
