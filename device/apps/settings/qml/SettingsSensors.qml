import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * SettingsSensors - Sensor configuration and status
 *
 * Uses standardized Core components:
 * - TacticalBackground for grid + vignette
 * - PageHeader for navigation
 * - Card for content sections
 * - Theme colors for consistency
 * - MaterialIcon for icons
 * - Badge for status
 */
Rectangle {
    id: settingsSensors
    color: Core.Theme.background

    // Navigation signals
    signal backRequested()

    // Sensors from registry
    property var sensorsList: SensorBridge ? SensorBridge.sensors : []
    property int activeSensors: 4

    // Refresh timer
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (SensorBridge) SensorBridge.refreshSensors()
        }
    }

    Component.onCompleted: {
        if (SensorBridge) SensorBridge.refreshSensors()
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

        // Header section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: Qt.rgba(Core.Theme.background.r, Core.Theme.background.g, Core.Theme.background.b, 0.9)

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Title row using PageHeader pattern
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Core.Theme.appBarHeight

                    Core.PageHeader {
                        anchors.fill: parent
                        title: "Sensors"
                        subtitle: "Configuration"
                        showBack: true
                        rightIcon: "refresh"
                        onBackClicked: settingsSensors.backRequested()
                        onRightClicked: {
                            if (SensorBridge) SensorBridge.discoverSensors()
                        }
                    }
                }

                // Status bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.2)

                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: 1
                        color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.1)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Core.Theme.spacingLarge
                        anchors.rightMargin: Core.Theme.spacingLarge

                        Row {
                            spacing: Core.Theme.spacingSmall

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 8
                                height: 8
                                radius: 4
                                color: Core.Theme.warning

                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 1000 }
                                    NumberAnimation { to: 1.0; duration: 1000 }
                                }
                            }

                            Text {
                                text: "LIVE DATA"
                                color: Core.Theme.warning
                                font.pixelSize: Core.Theme.tinySize
                                font.family: Core.Theme.fontFamilyMono
                                font.weight: Font.Medium
                                font.letterSpacing: 1
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "ACTIVE SENSORS: " + (sensorsList.length > 0 ? sensorsList.length : "04").toString().padStart(2, '0')
                            color: Core.Theme.textSecondary
                            font.pixelSize: Core.Theme.tinySize
                            font.family: Core.Theme.fontFamilyMono
                            font.letterSpacing: 1
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
            }
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

                // GPS Sensor Card
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingSmall

                        RowLayout {
                            Layout.fillWidth: true

                            Row {
                                spacing: Core.Theme.spacingSmall

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: Core.Theme.borderRadius
                                    color: Core.Theme.surface
                                    border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)
                                    border.width: 1

                                    Core.MaterialIcon {
                                        anchors.centerIn: parent
                                        name: "satellite-variant"
                                        size: 20
                                        iconColor: Core.Theme.warning
                                    }
                                }

                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: "GLOBAL POS."
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.weight: Core.Theme.fontWeightBold
                                        font.letterSpacing: Core.Theme.letterSpacingNormal
                                    }
                                    Text {
                                        text: "u-blox GNSS"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.family: Core.Theme.fontFamilyMono
                                        opacity: 0.6
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Core.Badge {
                                text: "Online"
                                variant: "success"
                            }
                        }

                        // GPS data
                        ColumnLayout {
                            Layout.leftMargin: 52
                            spacing: 4

                            Text {
                                text: SensorBridge ?
                                    SensorBridge.latitude.toFixed(4) + "°" + (SensorBridge.latitude >= 0 ? "N" : "S") + ", " +
                                    Math.abs(SensorBridge.longitude).toFixed(4) + "°" + (SensorBridge.longitude >= 0 ? "E" : "W") :
                                    "34.0522°N, 118.2437°W"
                                color: Core.Theme.textPrimary
                                font.pixelSize: Core.Theme.bodySize
                                font.family: Core.Theme.fontFamilyMono
                            }

                            RowLayout {
                                spacing: Core.Theme.spacingMedium
                                Text {
                                    text: "Alt: " + (SensorBridge && SensorBridge.hasElevation ? Math.round(SensorBridge.elevationMeters) + "m" : "124m")
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.smallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                                Text {
                                    text: "Sats: 8"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.smallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }
                        }
                    }
                }

                // Compass Sensor Card (Needs Calibration)
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium
                    accentBorder: true
                    accentColor: Core.Theme.warning

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingSmall

                        RowLayout {
                            Layout.fillWidth: true

                            Row {
                                spacing: Core.Theme.spacingSmall

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: Core.Theme.borderRadius
                                    color: Core.Theme.surface
                                    border.color: Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.2)
                                    border.width: 1

                                    Core.MaterialIcon {
                                        anchors.centerIn: parent
                                        name: "compass"
                                        size: 20
                                        iconColor: Core.Theme.warning
                                    }
                                }

                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: "COMPASS"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.weight: Core.Theme.fontWeightBold
                                        font.letterSpacing: Core.Theme.letterSpacingNormal
                                    }
                                    Text {
                                        text: "BMM150"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.family: Core.Theme.fontFamilyMono
                                        opacity: 0.6
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Core.Badge {
                                text: "Calib. Needed"
                                variant: "warning"
                            }
                        }

                        Text {
                            Layout.leftMargin: 52
                            text: (SensorBridge ? Math.round(SensorBridge.compassHeading) : 320) + "° NW"
                            color: Core.Theme.textPrimary
                            font.pixelSize: Core.Theme.bodySize
                            font.family: Core.Theme.fontFamilyMono
                        }
                    }
                }

                // Inertial Sensor Card
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingSmall

                        RowLayout {
                            Layout.fillWidth: true

                            Row {
                                spacing: Core.Theme.spacingSmall

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: Core.Theme.borderRadius
                                    color: Core.Theme.surface
                                    border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)
                                    border.width: 1

                                    Core.MaterialIcon {
                                        anchors.centerIn: parent
                                        name: "axis-arrow"
                                        size: 20
                                        iconColor: Core.Theme.warning
                                    }
                                }

                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: "INERTIAL"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.weight: Core.Theme.fontWeightBold
                                        font.letterSpacing: Core.Theme.letterSpacingNormal
                                    }
                                    Text {
                                        text: "BMI270"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.family: Core.Theme.fontFamilyMono
                                        opacity: 0.6
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Core.Badge {
                                text: "Online"
                                variant: "success"
                            }
                        }

                        GridLayout {
                            Layout.leftMargin: 52
                            columns: 3
                            columnSpacing: Core.Theme.spacingMedium
                            rowSpacing: 4

                            Text { text: "ACCEL X"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.tinySize; font.family: Core.Theme.fontFamilyMono }
                            Text { text: "ACCEL Y"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.tinySize; font.family: Core.Theme.fontFamilyMono }
                            Text { text: "ACCEL Z"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.tinySize; font.family: Core.Theme.fontFamilyMono }

                            Text { text: "0.02"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.bodySmallSize; font.family: Core.Theme.fontFamilyMono }
                            Text { text: "-0.98"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.bodySmallSize; font.family: Core.Theme.fontFamilyMono }
                            Text { text: "0.11"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.bodySmallSize; font.family: Core.Theme.fontFamilyMono }
                        }
                    }
                }

                // Environment Sensor Card (Error State)
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium
                    opacity: 0.8

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingSmall

                        RowLayout {
                            Layout.fillWidth: true

                            Row {
                                spacing: Core.Theme.spacingSmall

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: Core.Theme.borderRadius
                                    color: Core.Theme.surface
                                    border.color: Qt.rgba(Core.Theme.error.r, Core.Theme.error.g, Core.Theme.error.b, 0.2)
                                    border.width: 1

                                    Core.MaterialIcon {
                                        anchors.centerIn: parent
                                        name: "thermometer"
                                        size: 20
                                        iconColor: Core.Theme.error
                                    }
                                }

                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: "ENVIRONMENT"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.weight: Core.Theme.fontWeightBold
                                        font.letterSpacing: Core.Theme.letterSpacingNormal
                                    }
                                    Text {
                                        text: "BME680"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.family: Core.Theme.fontFamilyMono
                                        opacity: 0.6
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Core.Badge {
                                text: "Error"
                                variant: "error"
                            }
                        }

                        ColumnLayout {
                            Layout.leftMargin: 52
                            spacing: 4

                            Text {
                                text: "--"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.bodySize
                                font.family: Core.Theme.fontFamilyMono
                                font.italic: true
                            }

                            Text {
                                text: "I2C Device not found at 0x77"
                                color: Core.Theme.error
                                font.pixelSize: Core.Theme.tinySize
                                font.family: Core.Theme.fontFamilyMono
                            }
                        }
                    }
                }

                // Power Management Card
                Core.Card {
                    Layout.fillWidth: true
                    Layout.leftMargin: Core.Theme.spacingMedium
                    Layout.rightMargin: Core.Theme.spacingMedium

                    ColumnLayout {
                        width: parent.width
                        spacing: Core.Theme.spacingSmall

                        RowLayout {
                            Layout.fillWidth: true

                            Row {
                                spacing: Core.Theme.spacingSmall

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: Core.Theme.borderRadius
                                    color: Core.Theme.surface
                                    border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)
                                    border.width: 1

                                    Core.MaterialIcon {
                                        anchors.centerIn: parent
                                        name: "battery"
                                        size: 20
                                        iconColor: Core.Theme.warning
                                    }
                                }

                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: "POWER MGMT"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.weight: Core.Theme.fontWeightBold
                                        font.letterSpacing: Core.Theme.letterSpacingNormal
                                    }
                                    Text {
                                        text: "MAX17048"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.family: Core.Theme.fontFamilyMono
                                        opacity: 0.6
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Core.Badge {
                                text: "Online"
                                variant: "success"
                            }
                        }

                        RowLayout {
                            Layout.leftMargin: 52
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingMedium

                            ColumnLayout {
                                spacing: 4
                                Text {
                                    text: "VOLTAGE"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                                Row {
                                    spacing: 2
                                    Text {
                                        text: "12.4"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySize
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                    Text {
                                        text: "V"
                                        color: Core.Theme.divider
                                        font.pixelSize: Core.Theme.smallSize
                                        font.family: Core.Theme.fontFamilyMono
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 2
                                    }
                                }
                            }

                            Rectangle {
                                width: 1
                                height: 32
                                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text {
                                    text: "CURRENT"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                                Row {
                                    spacing: 2
                                    Text {
                                        text: "0.8"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: Core.Theme.bodySize
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                    Text {
                                        text: "A"
                                        color: Core.Theme.divider
                                        font.pixelSize: Core.Theme.smallSize
                                        font.family: Core.Theme.fontFamilyMono
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 2
                                    }
                                }
                            }

                            ColumnLayout {
                                spacing: 4
                                Text {
                                    text: "CAPACITY"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                                Text {
                                    text: (SensorBridge ? SensorBridge.batteryLevel : 98) + "%"
                                    color: Core.Theme.warning
                                    font.pixelSize: Core.Theme.bodySize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }
                        }
                    }
                }

                // Bottom spacer
                Item { Layout.preferredHeight: 120 }
            }
        }
    }
}
