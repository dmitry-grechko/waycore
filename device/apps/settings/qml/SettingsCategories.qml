import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * SettingsCategories - Main settings hub
 */
Rectangle {
    id: categories
    color: Core.Theme.background

    signal backRequested()
    signal categorySelected(string category)

    // Settings categories
    ListModel {
        id: categoriesModel
        ListElement { name: "General"; icon: "⚙️"; description: "Units, display, storage & reset"; route: "general" }
        ListElement { name: "Controls"; icon: "📡"; description: "LoRA, WiFi, Bluetooth & LTE"; route: "controls" }
        ListElement { name: "Sensors"; icon: "🌡️"; description: "GPS, temperature, compass & more"; route: "sensors" }
        ListElement { name: "Info"; icon: "ℹ️"; description: "Device & software information"; route: "info" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // App bar
        Core.AppBar {
            Layout.fillWidth: true
            title: "Settings"
            showBack: true
            onBackClicked: categories.backRequested()
        }

        // Category tiles grid
        GridView {
            id: categoryGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Core.Theme.spacingMedium
            clip: true

            cellWidth: width / 2
            cellHeight: 140

            model: categoriesModel

            delegate: Item {
                width: categoryGrid.cellWidth
                height: categoryGrid.cellHeight

                Core.Card {
                    anchors.fill: parent
                    anchors.margins: Core.Theme.spacingSmall
                    pressable: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Core.Theme.spacingSmall

                        Text {
                            text: model.icon
                            font.pixelSize: 32
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: model.name
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.h3Size
                            font.weight: Core.Theme.fontWeightBold
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: model.description
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.captionSize
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    onClicked: categories.categorySelected(model.route)
                }
            }
        }

        // Connection status
        Core.Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            Layout.margins: Core.Theme.spacingMedium
            Layout.topMargin: 0

            RowLayout {
                anchors.fill: parent

                Text {
                    text: SensorBridge && SensorBridge.connected ? "🟢 Backend Connected" : "🟡 Offline Mode"
                    color: SensorBridge && SensorBridge.connected ? Core.Theme.success : Core.Theme.warning
                    font.pixelSize: Core.Theme.captionSize
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "v" + (SensorBridge ? SensorBridge.appVersion : "0.1.0")
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.captionSize
                }
            }
        }
    }
}
