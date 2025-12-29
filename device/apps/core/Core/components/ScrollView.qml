import QtQuick 2.15
import QtQuick.Controls 2.15
import ".." as Core

ScrollView {
    id: scrollView

    property bool showIndicator: true
    property bool bouncing: true

    clip: true

    ScrollBar.vertical: ScrollBar {
        parent: scrollView
        anchors.top: scrollView.top
        anchors.right: scrollView.right
        anchors.bottom: scrollView.bottom
        visible: scrollView.showIndicator
        width: 4

        contentItem: Rectangle {
            color: Core.Theme.textSecondary
            opacity: parent.active ? 0.8 : 0.3
            radius: 2

            Behavior on opacity {
                NumberAnimation { duration: Core.Theme.animationNormal }
            }
        }

        background: Rectangle {
            color: "transparent"
        }

        policy: ScrollBar.AsNeeded
    }

    ScrollBar.horizontal: ScrollBar {
        visible: false
    }
}
