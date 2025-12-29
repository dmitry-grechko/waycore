import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * SettingsControls - Radio and connectivity settings
 */
Rectangle {
    id: settingsControls
    color: Core.Theme.background

    signal backRequested()

    // Radio states
    property bool loraEnabled: true
    property bool wifiEnabled: true
    property bool bluetoothEnabled: false
    property bool lteEnabled: false

    // Status
    property string loraStatus: loraEnabled ? "Connected" : "Off"
    property string wifiStatus: wifiEnabled ? "Connected" : "Off"
    property string bluetoothStatus: bluetoothEnabled ? "On" : "Off"
    property string lteStatus: lteEnabled ? "No Signal" : "Off"

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: 0

            // App bar
            Core.AppBar {
                Layout.fillWidth: true
                title: "📡 Controls"
                showBack: true
                onBackClicked: settingsControls.backRequested()
            }

            // LoRA Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium

                ColumnLayout {
                    width: parent.width
                    spacing: Core.Theme.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true

                        Text { text: "📡"; font.pixelSize: 24 }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: "LoRA (Meshtastic)"; color: Core.Theme.textPrimary; font.weight: Core.Theme.fontWeightBold }
                            Text { text: loraStatus; color: loraEnabled ? Core.Theme.success : Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        }

                        Switch {
                            checked: loraEnabled
                            onToggled: {
                                loraEnabled = checked
                                loraStatus = checked ? "Connecting..." : "Off"
                                if (checked) loraConnectTimer.start()
                            }
                        }
                    }

                    Core.Divider { visible: loraEnabled; Layout.fillWidth: true }

                    GridLayout {
                        visible: loraEnabled
                        columns: 2
                        Layout.fillWidth: true
                        Text { text: "Channel"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "LongFast"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "TX Power"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "20 dBm"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "Nodes"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "3 in range"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }
                    }
                }

                Timer { id: loraConnectTimer; interval: 1500; onTriggered: loraStatus = "Connected" }
            }

            // WiFi Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                Layout.topMargin: 0

                ColumnLayout {
                    width: parent.width
                    spacing: Core.Theme.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true

                        Text { text: "📶"; font.pixelSize: 24 }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: "WiFi"; color: Core.Theme.textPrimary; font.weight: Core.Theme.fontWeightBold }
                            Text { text: wifiStatus; color: wifiEnabled ? Core.Theme.success : Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        }

                        Switch {
                            checked: wifiEnabled
                            onToggled: {
                                wifiEnabled = checked
                                wifiStatus = checked ? "Scanning..." : "Off"
                                if (checked) wifiConnectTimer.start()
                            }
                        }
                    }

                    Core.Divider { visible: wifiEnabled; Layout.fillWidth: true }

                    GridLayout {
                        visible: wifiEnabled
                        columns: 2
                        Layout.fillWidth: true
                        Text { text: "Network"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "HomeNetwork"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "Signal"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "████░ Strong"; color: Core.Theme.success; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "IP"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "192.168.1.42"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize }
                    }
                }

                Timer { id: wifiConnectTimer; interval: 2000; onTriggered: wifiStatus = "Connected" }
            }

            // Bluetooth Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                Layout.topMargin: 0

                ColumnLayout {
                    width: parent.width
                    spacing: Core.Theme.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true

                        Text { text: "🔵"; font.pixelSize: 24 }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: "Bluetooth"; color: Core.Theme.textPrimary; font.weight: Core.Theme.fontWeightBold }
                            Text { text: bluetoothStatus; color: bluetoothEnabled ? Core.Theme.info : Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        }

                        Switch {
                            checked: bluetoothEnabled
                            onToggled: {
                                bluetoothEnabled = checked
                                bluetoothStatus = checked ? "On" : "Off"
                            }
                        }
                    }

                    Core.Divider { visible: bluetoothEnabled; Layout.fillWidth: true }

                    ColumnLayout {
                        visible: bluetoothEnabled
                        Layout.fillWidth: true
                        Text { text: "No paired devices"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Core.Button { text: "Scan for devices"; fullWidth: true; variant: "secondary" }
                    }
                }
            }

            // LTE Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                Layout.topMargin: 0

                ColumnLayout {
                    width: parent.width
                    spacing: Core.Theme.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true

                        Text { text: "📱"; font.pixelSize: 24 }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: "LTE / Cellular"; color: Core.Theme.textPrimary; font.weight: Core.Theme.fontWeightBold }
                            Text { text: lteStatus; color: lteEnabled ? (lteStatus === "Connected" ? Core.Theme.success : Core.Theme.warning) : Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        }

                        Switch {
                            checked: lteEnabled
                            onToggled: {
                                lteEnabled = checked
                                lteStatus = checked ? "Searching..." : "Off"
                                if (checked) lteConnectTimer.start()
                            }
                        }
                    }

                    Core.Divider { visible: lteEnabled; Layout.fillWidth: true }

                    GridLayout {
                        visible: lteEnabled
                        columns: 2
                        Layout.fillWidth: true
                        Text { text: "Carrier"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "No Service"; color: Core.Theme.warning; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "Signal"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text { text: "░░░░░ None"; color: Core.Theme.error; font.pixelSize: Core.Theme.captionSize }
                    }
                }

                Timer { id: lteConnectTimer; interval: 3000; onTriggered: lteStatus = "No Signal" }
            }

            Item { Layout.preferredHeight: Core.Theme.spacingLarge }
        }
    }
}
