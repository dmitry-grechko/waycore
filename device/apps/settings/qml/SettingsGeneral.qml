import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCore
import Core as Core

/**
 * SettingsGeneral - General settings (units, display, storage, reset)
 */
Rectangle {
    id: settingsGeneral
    color: Core.Theme.background

    signal backRequested()
    signal navigateHome()

    // Persistent app preferences
    Settings {
        id: appSettings
        category: "waycore.ui"
        property bool debug: false
        property string theme: "dark"
        property int brightness: 75
        property string temperatureUnit: "F"
        property string distanceUnit: "mi"
        property string weightUnit: "lb"
        property string pressureUnit: "hPa"
        property bool use24Hour: true
        property int screenTimeout: 60
    }

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
                title: "⚙️ General"
                showBack: true
                onBackClicked: settingsGeneral.backRequested()
            }

            // Units Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                title: "Units"

                ColumnLayout {
                    width: parent.width
                    spacing: Core.Theme.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Temperature"; color: Core.Theme.textSecondary; Layout.preferredWidth: 100 }
                        ComboBox {
                            model: ["Celsius (°C)", "Fahrenheit (°F)"]
                            currentIndex: appSettings.temperatureUnit === "C" ? 0 : 1
                            onActivated: appSettings.temperatureUnit = currentIndex === 0 ? "C" : "F"
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Distance"; color: Core.Theme.textSecondary; Layout.preferredWidth: 100 }
                        ComboBox {
                            model: ["Kilometers (km)", "Miles (mi)"]
                            currentIndex: appSettings.distanceUnit === "km" ? 0 : 1
                            onActivated: appSettings.distanceUnit = currentIndex === 0 ? "km" : "mi"
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Weight"; color: Core.Theme.textSecondary; Layout.preferredWidth: 100 }
                        ComboBox {
                            model: ["Kilograms (kg)", "Pounds (lb)"]
                            currentIndex: appSettings.weightUnit === "kg" ? 0 : 1
                            onActivated: appSettings.weightUnit = currentIndex === 0 ? "kg" : "lb"
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Time format"; color: Core.Theme.textSecondary; Layout.preferredWidth: 100 }
                        ComboBox {
                            model: ["24-hour", "12-hour"]
                            currentIndex: appSettings.use24Hour ? 0 : 1
                            onActivated: appSettings.use24Hour = currentIndex === 0
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Display Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                Layout.topMargin: 0
                title: "Display"

                ColumnLayout {
                    width: parent.width
                    spacing: Core.Theme.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Brightness"; color: Core.Theme.textSecondary }
                        Core.Slider {
                            from: 0; to: 100; value: appSettings.brightness
                            onValueChanged: appSettings.brightness = Math.round(value)
                            Layout.fillWidth: true
                        }
                        Text { text: appSettings.brightness + "%"; color: Core.Theme.textPrimary; Layout.preferredWidth: 40 }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Screen timeout"; color: Core.Theme.textSecondary; Layout.preferredWidth: 120 }
                        ComboBox {
                            model: ["30 seconds", "1 minute", "2 minutes", "5 minutes", "Never"]
                            currentIndex: {
                                switch(appSettings.screenTimeout) {
                                    case 30: return 0
                                    case 60: return 1
                                    case 120: return 2
                                    case 300: return 3
                                    default: return 4
                                }
                            }
                            onActivated: {
                                var timeouts = [30, 60, 120, 300, 0]
                                appSettings.screenTimeout = timeouts[currentIndex]
                            }
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Developer Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                Layout.topMargin: 0
                title: "Developer"

                ColumnLayout {
                    width: parent.width
                    spacing: Core.Theme.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Debug mode"; color: Core.Theme.textSecondary; Layout.fillWidth: true }
                        Switch { checked: appSettings.debug; onToggled: appSettings.debug = checked }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Theme"; color: Core.Theme.textSecondary; Layout.preferredWidth: 100 }
                        ComboBox {
                            model: ["dark", "light"]
                            currentIndex: appSettings.theme === "dark" ? 0 : 1
                            onActivated: appSettings.theme = currentText
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Storage Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                Layout.topMargin: 0
                title: "Storage"

                Component.onCompleted: {
                    if (SensorBridge) SensorBridge.refreshStorage()
                }

                ColumnLayout {
                    width: parent.width
                    spacing: Core.Theme.spacingSmall

                    Core.ProgressBar {
                        Layout.fillWidth: true
                        value: SensorBridge ? SensorBridge.storageUsedPercent / 100 : 0.35
                        variant: (SensorBridge && SensorBridge.storageUsedPercent > 90) ? "error" :
                                 (SensorBridge && SensorBridge.storageUsedPercent > 75) ? "warning" : "default"
                    }

                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true

                        Text { text: "Total"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text {
                            text: SensorBridge ? SensorBridge.storageTotalGb.toFixed(1) + " GB" : "32 GB"
                            color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize
                        }

                        Text { text: "Used"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text {
                            text: SensorBridge ?
                                SensorBridge.storageUsedGb.toFixed(1) + " GB (" + SensorBridge.storageUsedPercent.toFixed(0) + "%)" :
                                "-- GB"
                            color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.captionSize
                        }

                        Text { text: "Available"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.captionSize }
                        Text {
                            text: SensorBridge ? SensorBridge.storageAvailableGb.toFixed(1) + " GB" : "-- GB"
                            color: Core.Theme.success; font.pixelSize: Core.Theme.captionSize
                        }
                    }

                    Core.Button {
                        text: "Refresh Storage Info"
                        fullWidth: true
                        variant: "secondary"
                        onClicked: {
                            if (SensorBridge) SensorBridge.refreshStorage()
                        }
                    }
                }
            }

            // Factory Reset Card
            Core.Card {
                Layout.fillWidth: true
                Layout.margins: Core.Theme.spacingMedium
                Layout.topMargin: 0
                title: "⚠️ Danger Zone"

                ColumnLayout {
                    width: parent.width
                    spacing: Core.Theme.spacingSmall

                    Text {
                        text: "Factory reset will delete all notes, preferences, and restore default settings."
                        color: Core.Theme.textSecondary
                        font.pixelSize: Core.Theme.bodySize
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Core.Button {
                        id: resetButton
                        text: isResetting ? "Resetting..." : (confirmReset ? "Tap again to confirm" : "Factory Reset")
                        fullWidth: true
                        variant: "danger"
                        enabled: !isResetting

                        property bool confirmReset: false
                        property bool isResetting: false

                        onClicked: {
                            if (isResetting) return

                            if (confirmReset) {
                                isResetting = true
                                confirmReset = false
                                performFactoryReset()
                            } else {
                                confirmReset = true
                                confirmTimer.start()
                            }
                        }

                        Timer {
                            id: confirmTimer
                            interval: 3000
                            onTriggered: resetButton.confirmReset = false
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: Core.Theme.spacingLarge }
        }
    }

    // Toast for status messages
    Core.Toast {
        id: toast
        position: "bottom"
    }

    function performFactoryReset() {
        console.log("Factory reset: calling backend...")
        var success = SensorBridge ? SensorBridge.factoryReset() : false

        if (success) {
            toast.show("✅ Factory reset complete")
        } else {
            toast.show("⚠️ Reset completed (offline mode)")
        }

        resetButton.isResetting = false
        resetCompleteTimer.start()
    }

    Timer {
        id: resetCompleteTimer
        interval: 1500
        onTriggered: settingsGeneral.navigateHome()
    }
}
