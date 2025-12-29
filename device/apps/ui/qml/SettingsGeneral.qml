import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCore
import "." as App
import "components" as UI

Rectangle {
	id: settingsGeneral
	color: App.Theme.background

	// Persistent app preferences (defaults: F, mi, lb)
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

	// Factory reset function
	function performFactoryReset() {
		console.log("Factory reset: calling backend...")
		var success = SensorBridge ? SensorBridge.factoryReset() : false

		if (success) {
			resetStatusText.text = "✅ Factory reset complete"
			resetStatusText.color = App.Theme.success
		} else {
			resetStatusText.text = "⚠️ Reset completed (offline mode)"
			resetStatusText.color = App.Theme.warning
		}

		resetButton.isResetting = false
		resetCompleteTimer.start()
	}

	Timer {
		id: resetCompleteTimer
		interval: 1500
		onTriggered: {
			var shell = settingsGeneral.parent
			while (shell && !shell.hasOwnProperty("navigateHome")) {
				shell = shell.parent
			}
			if (shell && shell.navigateHome) {
				shell.navigateHome()
			}
		}
	}

	Flickable {
		anchors.fill: parent
		anchors.margins: App.Theme.spacingLarge
		contentHeight: contentColumn.height
		clip: true

		ColumnLayout {
			id: contentColumn
			width: parent.width
			spacing: App.Theme.spacingLarge

			// Header
			RowLayout {
				Layout.fillWidth: true
				spacing: App.Theme.spacingSmall

				Button {
					text: "← Back"
					onClicked: {
						var parentItem = settingsGeneral.parent
						while (parentItem && !parentItem.hasOwnProperty("navigateBack")) {
							parentItem = parentItem.parent
						}
						if (parentItem && parentItem.navigateBack) {
							parentItem.navigateBack()
						}
					}
				}

				Text {
					text: "⚙️ General"
					color: App.Theme.textPrimary
					font.pixelSize: App.Theme.h1Size
					font.bold: true
					Layout.fillWidth: true
				}
			}

			// Units Card
			UI.Card {
				Layout.fillWidth: true

				Text { text: "Units"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.h2Size }

				RowLayout {
					width: parent.width
					spacing: App.Theme.spacingSmall
					Text { text: "Temperature"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.bodySize; Layout.preferredWidth: 100 }
					ComboBox {
						id: temperatureCombo
						model: ["Celsius (°C)", "Fahrenheit (°F)"]
						currentIndex: appSettings.temperatureUnit === "C" ? 0 : 1
						onActivated: {
							appSettings.temperatureUnit = currentIndex === 0 ? "C" : "F"
							App.SensorData.temperatureUnit = appSettings.temperatureUnit
						}
						Layout.fillWidth: true
					}
				}

				RowLayout {
					width: parent.width
					spacing: App.Theme.spacingSmall
					Text { text: "Distance"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.bodySize; Layout.preferredWidth: 100 }
					ComboBox {
						id: distanceCombo
						model: ["Kilometers (km)", "Miles (mi)"]
						currentIndex: appSettings.distanceUnit === "km" ? 0 : 1
						onActivated: appSettings.distanceUnit = currentIndex === 0 ? "km" : "mi"
						Layout.fillWidth: true
					}
				}

				RowLayout {
					width: parent.width
					spacing: App.Theme.spacingSmall
					Text { text: "Weight"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.bodySize; Layout.preferredWidth: 100 }
					ComboBox {
						id: weightCombo
						model: ["Kilograms (kg)", "Pounds (lb)"]
						currentIndex: appSettings.weightUnit === "kg" ? 0 : 1
						onActivated: appSettings.weightUnit = currentIndex === 0 ? "kg" : "lb"
						Layout.fillWidth: true
					}
				}

				RowLayout {
					width: parent.width
					spacing: App.Theme.spacingSmall
					Text { text: "Pressure"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.bodySize; Layout.preferredWidth: 100 }
					ComboBox {
						model: ["hPa", "inHg", "mmHg"]
						currentIndex: appSettings.pressureUnit === "hPa" ? 0 : (appSettings.pressureUnit === "inHg" ? 1 : 2)
						onActivated: {
							var units = ["hPa", "inHg", "mmHg"]
							appSettings.pressureUnit = units[currentIndex]
						}
						Layout.fillWidth: true
					}
				}

				RowLayout {
					width: parent.width
					spacing: App.Theme.spacingSmall
					Text { text: "Time format"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.bodySize; Layout.preferredWidth: 100 }
					ComboBox {
						model: ["24-hour", "12-hour"]
						currentIndex: appSettings.use24Hour ? 0 : 1
						onActivated: appSettings.use24Hour = currentIndex === 0
						Layout.fillWidth: true
					}
				}
			}

			// Display Card
			UI.Card {
				Layout.fillWidth: true

				Text { text: "Display"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.h2Size }

				RowLayout {
					width: parent.width
					spacing: App.Theme.spacingSmall
					Text { text: "Brightness"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.bodySize }
					Slider {
						from: 0; to: 100; value: appSettings.brightness
						onValueChanged: appSettings.brightness = Math.round(value)
						Layout.fillWidth: true
					}
					Text { text: appSettings.brightness + "%"; color: App.Theme.textPrimary; Layout.preferredWidth: 40 }
				}

				RowLayout {
					width: parent.width
					spacing: App.Theme.spacingSmall
					Text { text: "Screen timeout"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.bodySize; Layout.preferredWidth: 120 }
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

			// Developer Card
			UI.Card {
				Layout.fillWidth: true

				Text { text: "Developer"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.h2Size }

				RowLayout {
					width: parent.width
					Text { text: "Debug mode"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.bodySize; Layout.fillWidth: true }
					Switch { checked: appSettings.debug; onToggled: appSettings.debug = checked }
				}

				RowLayout {
					width: parent.width
					Text { text: "Theme"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.bodySize; Layout.preferredWidth: 100 }
					ComboBox {
						model: ["dark", "light"]
						currentIndex: appSettings.theme === "dark" ? 0 : 1
						onActivated: appSettings.theme = currentText
						Layout.fillWidth: true
					}
				}
			}

			// Storage Card
			UI.Card {
				Layout.fillWidth: true

				// Refresh storage on load
				Component.onCompleted: {
					if (SensorBridge) SensorBridge.refreshStorage()
				}

				Text { text: "Storage"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.h2Size }

				// Storage bar visualization
				Rectangle {
					width: parent.width
					height: 24
					radius: 4
					color: App.Theme.background
					border.color: App.Theme.divider

					Rectangle {
						width: parent.width * (SensorBridge ? SensorBridge.storageUsedPercent / 100 : 0.35)
						height: parent.height
						radius: 4
						color: (SensorBridge && SensorBridge.storageUsedPercent > 90) ? App.Theme.error :
							   (SensorBridge && SensorBridge.storageUsedPercent > 75) ? App.Theme.warning :
							   App.Theme.primary
					}
				}

				GridLayout {
					columns: 2
					width: parent.width
					rowSpacing: App.Theme.spacingExtraSmall

					Text { text: "Total"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.captionSize }
					Text {
						text: SensorBridge ? SensorBridge.storageTotalGb.toFixed(1) + " GB" : "32 GB"
						color: App.Theme.textPrimary
						font.pixelSize: App.Theme.captionSize
					}

					Text { text: "Used"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.captionSize }
					Text {
						text: SensorBridge ?
							SensorBridge.storageUsedGb.toFixed(1) + " GB (" + SensorBridge.storageUsedPercent.toFixed(0) + "%)" :
							"-- GB"
						color: App.Theme.textPrimary
						font.pixelSize: App.Theme.captionSize
					}

					Text { text: "Available"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.captionSize }
					Text {
						text: SensorBridge ? SensorBridge.storageAvailableGb.toFixed(1) + " GB" : "-- GB"
						color: App.Theme.success
						font.pixelSize: App.Theme.captionSize
					}

					// Breakdown section
					Text { text: ""; Layout.columnSpan: 2 }  // Spacer

					Text { text: "System"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.captionSize }
					Text {
						text: SensorBridge && SensorBridge.storageBreakdown.system ?
							SensorBridge.storageBreakdown.system.human : "~2 GB"
						color: App.Theme.textPrimary
						font.pixelSize: App.Theme.captionSize
					}

					Text { text: "Apps"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.captionSize }
					Text {
						text: SensorBridge && SensorBridge.storageBreakdown.apps ?
							SensorBridge.storageBreakdown.apps.human : "~500 MB"
						color: App.Theme.textPrimary
						font.pixelSize: App.Theme.captionSize
					}

					Text { text: "Data"; color: App.Theme.textSecondary; font.pixelSize: App.Theme.captionSize }
					Text {
						text: SensorBridge && SensorBridge.storageBreakdown.data ?
							SensorBridge.storageBreakdown.data.human : "calculating..."
						color: App.Theme.textPrimary
						font.pixelSize: App.Theme.captionSize
					}
				}

				Button {
					text: "Refresh Storage Info"
					width: parent.width
					onClicked: {
						if (SensorBridge) SensorBridge.refreshStorage()
					}
				}
			}

			// Factory Reset Card
			UI.Card {
				Layout.fillWidth: true

				Text { text: "⚠️ Danger Zone"; color: App.Theme.error; font.pixelSize: App.Theme.h2Size }

				Text {
					text: "Factory reset will delete all notes, preferences, and restore default settings."
					color: App.Theme.textSecondary
					font.pixelSize: App.Theme.bodySize
					wrapMode: Text.WordWrap
					width: parent.width
				}

				Button {
					id: resetButton
					text: isResetting ? "Resetting..." : (confirmReset ? "Tap again to confirm" : "Factory Reset")
					width: parent.width
					enabled: !isResetting

					property bool confirmReset: false
					property bool isResetting: false

					onClicked: {
						if (isResetting) return

						if (confirmReset) {
							isResetting = true
							confirmReset = false
							resetStatusText.text = "Resetting..."
							resetStatusText.color = App.Theme.warning
							resetStatusText.visible = true

							// Reset local settings to defaults
							appSettings.temperatureUnit = "F"
							appSettings.distanceUnit = "mi"
							appSettings.weightUnit = "lb"
							appSettings.pressureUnit = "hPa"
							appSettings.use24Hour = true
							appSettings.brightness = 75
							appSettings.debug = false
							appSettings.theme = "dark"
							appSettings.screenTimeout = 60
							App.SensorData.temperatureUnit = "F"

							// Update ComboBox UI
							temperatureCombo.currentIndex = 1
							distanceCombo.currentIndex = 1
							weightCombo.currentIndex = 1

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

				Text {
					id: resetStatusText
					visible: false
					color: App.Theme.warning
					font.pixelSize: App.Theme.bodySize
				}
			}

			Item { Layout.preferredHeight: App.Theme.spacingLarge }
		}
	}
}
