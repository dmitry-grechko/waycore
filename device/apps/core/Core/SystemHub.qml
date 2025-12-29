import QtQuick 2.15
import QtQuick.Layouts 1.15
import "." as Core

/**
 * SystemHub - Tier 2 app launcher
 *
 * Shows all secondary apps in a 3-column grid:
 * - Notes, Compass, Camera, Gallery
 * - Sensors, Flashlight, Settings
 * - Any additional installed apps
 */
Rectangle {
    id: systemHub
    color: Core.Theme.background

    signal closeRequested()
    signal navigateToApp(string appId)

    // Get apps from AppBridge
    property var apps: (typeof AppBridge !== "undefined" && AppBridge) ? AppBridge.tier2Apps : []

    // App bar
    Core.AppBar {
        id: appBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        title: "System Hub"
        showBack: true
        onBackClicked: systemHub.closeRequested()
    }

    // 3-column grid for Tier 2 apps
    GridView {
        id: appGrid
        anchors.top: appBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Core.Theme.spacingSmall

        cellWidth: width / 3
        cellHeight: 120

        model: apps

        delegate: Item {
            width: appGrid.cellWidth
            height: appGrid.cellHeight

            Core.AppTile {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingXS

                appId: modelData.id || ""
                appName: modelData.name || "App"
                appIcon: modelData.icon || "📱"
                compact: true

                onClicked: {
                    console.log("SystemHub: Opening app", modelData.id)
                    systemHub.navigateToApp(modelData.id)
                }
            }
        }
    }

    // Empty state when no apps
    Core.EmptyState {
        anchors.centerIn: parent
        visible: apps.length === 0
        icon: "📱"
        title: "No Apps"
        description: "No tier 2 apps installed"
    }
}
