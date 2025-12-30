import QtQuick 2.15
import QtQuick.Controls 2.15
import ".." as Core

/**
 * TacticalComboBox - Styled dropdown select matching tactical theme
 *
 * Usage:
 *   Core.TacticalComboBox {
 *       model: ["Option 1", "Option 2", "Option 3"]
 *       currentIndex: 0
 *       onActivated: console.log("Selected:", currentText)
 *   }
 */
ComboBox {
    id: control

    implicitWidth: 200
    implicitHeight: 44

    // Custom background
    background: Rectangle {
        color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.8)
        border.color: control.pressed ? Core.Theme.warning :
                     control.hovered ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.5) :
                     Core.Theme.divider
        border.width: 1
        radius: Core.Theme.borderRadius

        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }
    }

    // Content item (selected text)
    contentItem: Text {
        leftPadding: Core.Theme.spacingMedium
        rightPadding: control.indicator.width + Core.Theme.spacingMedium

        text: control.displayText
        font.family: Core.Theme.fontFamilyMono
        font.pixelSize: Core.Theme.bodySmallSize
        color: Core.Theme.textPrimary
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // Dropdown indicator (chevron)
    indicator: Item {
        x: control.width - width - Core.Theme.spacingSmall
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 24
        height: 24

        Core.MaterialIcon {
            anchors.centerIn: parent
            name: "chevron-down"
            size: 18
            iconColor: control.pressed ? Core.Theme.warning : Core.Theme.textSecondary

            rotation: control.popup.visible ? 180 : 0
            Behavior on rotation {
                NumberAnimation { duration: 200 }
            }
        }
    }

    // Popup container
    popup: Popup {
        y: control.height + 4
        width: control.width
        implicitHeight: contentItem.implicitHeight + 8
        padding: 4

        background: Rectangle {
            color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.98)
            border.color: Core.Theme.divider
            border.width: 1
            radius: Core.Theme.borderRadius

            // Subtle glow effect
            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                z: -1
                radius: parent.radius + 2
                color: "transparent"
                border.color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.15)
                border.width: 2
            }
        }

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            boundsBehavior: Flickable.StopAtBounds

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    // Dropdown items
    delegate: ItemDelegate {
        width: control.width - 8
        height: 40

        contentItem: Text {
            text: modelData
            color: highlighted ? Core.Theme.warning : Core.Theme.textPrimary
            font.family: Core.Theme.fontFamilyMono
            font.pixelSize: Core.Theme.bodySmallSize
            font.weight: highlighted ? Font.Bold : Font.Normal
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            leftPadding: Core.Theme.spacingSmall
        }

        background: Rectangle {
            color: highlighted ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.15) :
                   hovered ? Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3) :
                   "transparent"
            radius: Core.Theme.borderRadius - 2
        }

        highlighted: control.highlightedIndex === index
    }
}
