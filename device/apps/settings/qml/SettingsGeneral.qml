import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCore
import Core as Core

/**
 * SettingsGeneral - System configuration, display & power settings
 *
 * Uses standardized Core components:
 * - TacticalBackground for grid + vignette
 * - PageHeader for navigation
 * - Card for content sections
 * - Theme colors for consistency
 * - MaterialIcon for icons
 * - Switch, Slider for controls
 */
Rectangle {
    id: settingsGeneral
    color: Core.Theme.background

    // Navigation signals
    signal backRequested()
    signal navigateHome()

    // Persistent settings
    Settings {
        id: appSettings
        category: "waycore.ui"
        property bool debug: false
        property string theme: "dark"
        property int brightness: 85
        property string temperatureUnit: "C"
        property string distanceUnit: "km"
        property string weightUnit: "kg"
        property bool use24Hour: true
        property int screenTimeout: 60
    }

    // Factory reset
    function performFactoryReset() {
        console.log("Factory reset: calling backend...")
        var success = SensorBridge ? SensorBridge.factoryReset() : false
        resetButton.isResetting = false
        settingsGeneral.navigateHome()
    }

    // Tactical background using standardized component
    Core.TacticalBackground {
        anchors.fill: parent
        z: 0
        vignetteOpacity: 0.5
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        z: 10

        // Header using PageHeader
        Core.PageHeader {
            Layout.fillWidth: true
            title: "General"
            subtitle: "Settings"
            showBack: true
            onBackClicked: settingsGeneral.backRequested()
        }

        // Scrollable content
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: contentColumn.height + 32
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentColumn
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Core.Theme.spacingMedium

                Item { Layout.preferredHeight: Core.Theme.spacingSmall }

                // Units Section
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingMedium

                        Row {
                            spacing: Core.Theme.spacingSmall
                            Core.MaterialIcon {
                                name: "ruler"
                                size: 16
                                iconColor: Core.Theme.warning
                            }
                            Text {
                                text: "UNITS"
                                color: Core.Theme.warning
                                font.pixelSize: Core.Theme.labelSize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: Core.Theme.spacingSmall
                            rowSpacing: Core.Theme.spacingSmall

                            // Temperature
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text {
                                    text: "TEMPERATURE"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Core.TacticalComboBox {
                                    Layout.fillWidth: true
                                    model: ["Celsius (°C)", "Fahrenheit (°F)"]
                                    currentIndex: appSettings.temperatureUnit === "C" ? 0 : 1
                                    onActivated: {
                                        appSettings.temperatureUnit = currentIndex === 0 ? "C" : "F"
                                    }
                                }
                            }

                            // Distance
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text {
                                    text: "DISTANCE"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Core.TacticalComboBox {
                                    Layout.fillWidth: true
                                    model: ["Metric (m/km)", "Imperial (ft/mi)"]
                                    currentIndex: appSettings.distanceUnit === "km" ? 0 : 1
                                    onActivated: appSettings.distanceUnit = currentIndex === 0 ? "km" : "mi"
                                }
                            }

                            // Weight
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text {
                                    text: "WEIGHT"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Core.TacticalComboBox {
                                    Layout.fillWidth: true
                                    model: ["Kilograms (kg)", "Pounds (lbs)"]
                                    currentIndex: appSettings.weightUnit === "kg" ? 0 : 1
                                    onActivated: appSettings.weightUnit = currentIndex === 0 ? "kg" : "lb"
                                }
                            }

                            // Time Format
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text {
                                    text: "TIME FORMAT"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Core.TacticalComboBox {
                                    Layout.fillWidth: true
                                    model: ["24 Hour (ISO)", "12 Hour (AM/PM)"]
                                    currentIndex: appSettings.use24Hour ? 0 : 1
                                    onActivated: appSettings.use24Hour = currentIndex === 0
                                }
                            }
                        }
                    }
                }

                // Display Section
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingMedium

                        Row {
                            spacing: Core.Theme.spacingSmall
                            Core.MaterialIcon {
                                name: "brightness-6"
                                size: 16
                                iconColor: Core.Theme.warning
                            }
                            Text {
                                text: "DISPLAY"
                                color: Core.Theme.warning
                                font.pixelSize: Core.Theme.labelSize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                        }

                        // Brightness
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "BRIGHTNESS"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: appSettings.brightness + "%"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.smallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Core.Theme.spacingSmall

                                Core.MaterialIcon {
                                    name: "brightness-5"
                                    size: 14
                                    iconColor: Core.Theme.textSecondary
                                }

                                Core.Slider {
                                    Layout.fillWidth: true
                                    from: 0
                                    to: 100
                                    value: appSettings.brightness
                                    onValueChanged: appSettings.brightness = Math.round(value)
                                }

                                Core.MaterialIcon {
                                    name: "brightness-7"
                                    size: 16
                                    iconColor: Core.Theme.textPrimary
                                }
                            }
                        }

                        // Screen Timeout
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "SCREEN TIMEOUT"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.tinySize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: 1
                            }
                            Core.TacticalComboBox {
                                Layout.fillWidth: true
                                model: ["1 Minute", "5 Minutes", "15 Minutes", "Never"]
                                currentIndex: {
                                    switch(appSettings.screenTimeout) {
                                        case 60: return 0
                                        case 300: return 1
                                        case 900: return 2
                                        default: return 3
                                    }
                                }
                                onActivated: {
                                    var timeouts = [60, 300, 900, 0]
                                    appSettings.screenTimeout = timeouts[currentIndex]
                                }
                            }
                        }
                    }
                }

                // Developer Section
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingMedium

                        Row {
                            spacing: Core.Theme.spacingSmall
                            Core.MaterialIcon {
                                name: "console"
                                size: 16
                                iconColor: Core.Theme.warning
                            }
                            Text {
                                text: "DEVELOPER"
                                color: Core.Theme.warning
                                font.pixelSize: Core.Theme.labelSize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                        }

                        Core.Divider { Layout.fillWidth: true }

                        // Debug Mode Toggle
                        RowLayout {
                            Layout.fillWidth: true

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "Debug Mode"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.weight: Core.Theme.fontWeightBold
                                }
                                Text {
                                    text: "Enable verbose logging"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }

                            Core.Switch {
                                checked: appSettings.debug
                                onToggled: appSettings.debug = checked
                            }
                        }

                        // Theme
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "UI THEME"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.tinySize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: 1
                            }
                            Core.TacticalComboBox {
                                Layout.fillWidth: true
                                model: ["Tactical Dark (Default)", "Night Vision (Red)", "High Contrast"]
                                currentIndex: 0
                            }
                        }
                    }
                }

                // Storage Section
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    Component.onCompleted: {
                        if (SensorBridge) SensorBridge.refreshStorage()
                    }

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingMedium

                        Row {
                            spacing: Core.Theme.spacingSmall
                            Core.MaterialIcon {
                                name: "harddisk"
                                size: 16
                                iconColor: Core.Theme.warning
                            }
                            Text {
                                text: "STORAGE"
                                color: Core.Theme.warning
                                font.pixelSize: Core.Theme.labelSize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                        }

                        // Usage bar
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: SensorBridge ? SensorBridge.storageUsedGb.toFixed(1) + " GB Used" : "14.2 GB Used"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.family: Core.Theme.fontFamilyMono
                                    font.weight: Core.Theme.fontWeightBold
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: SensorBridge ? SensorBridge.storageTotalGb.toFixed(0) + " GB Total" : "64 GB Total"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.smallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }

                            Core.ProgressBar {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 12
                                value: SensorBridge ? SensorBridge.storageUsedPercent / 100 : 0.22
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "SYSTEM: 4GB"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "MAPS: 8GB"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "LOGS: 2.2GB"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.weight: Core.Theme.fontWeightBold
                                    font.letterSpacing: 1
                                }
                            }
                        }

                        // Refresh button
                        Core.Button {
                            Layout.fillWidth: true
                            text: "Refresh Storage Info"
                            iconName: "refresh"
                            variant: "tacticalSecondary"
                            onClicked: {
                                if (SensorBridge) SensorBridge.refreshStorage()
                            }
                        }
                    }
                }

                // Danger Zone Section
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium
                    Layout.topMargin: Core.Theme.spacingSmall
                    accentBorder: true
                    accentColor: Core.Theme.warning

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingMedium

                        Row {
                            spacing: Core.Theme.spacingSmall
                            Core.MaterialIcon {
                                name: "alert"
                                size: 16
                                iconColor: Core.Theme.warning
                            }
                            Text {
                                text: "DANGER ZONE"
                                color: Core.Theme.warning
                                font.pixelSize: Core.Theme.labelSize
                                font.weight: Core.Theme.fontWeightBold
                                font.letterSpacing: Core.Theme.letterSpacingNormal
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Performing a factory reset will erase all local data, maps, and logs. This action cannot be undone."
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.smallSize
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                        }

                        Core.Button {
                            id: resetButton
                            Layout.fillWidth: true
                            text: isResetting ? "Resetting..." : (confirmReset ? "Tap Again to Confirm" : "Factory Reset")
                            iconName: "delete"
                            variant: confirmReset ? "danger" : "tacticalSecondary"
                            enabled: !isResetting

                            property bool isResetting: false
                            property bool confirmReset: false

                            onClicked: {
                                if (confirmReset) {
                                    isResetting = true
                                    confirmReset = false
                                    settingsGeneral.performFactoryReset()
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

                // Bottom spacer for scrolling
                Item { Layout.preferredHeight: 120 }
            }
        }
    }
}
