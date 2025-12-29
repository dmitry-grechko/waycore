import QtQuick 2.15
import QtQuick.Layouts 1.15
import "." as Core

/**
 * Home - Main home screen with all apps in a grid
 *
 * Shows all apps sorted by tier and name, with Settings always last.
 */
Rectangle {
    id: home
    color: Core.Theme.background

    // Signal to navigate to apps
    signal navigateToApp(string appId)
    signal navigateTo(string viewName)

    // Build the app list from AppBridge
    property var appList: buildAppList()

    function buildAppList() {
        var apps = []

        if (typeof AppBridge !== "undefined" && AppBridge) {
            // Get all apps
            var allApps = AppBridge.allApps

            // Separate settings from other apps
            var settingsApp = null
            var otherApps = []

            for (var i = 0; i < allApps.length; i++) {
                var app = allApps[i]
                if (app.id === "com.waycore.settings") {
                    settingsApp = app
                } else {
                    otherApps.push(app)
                }
            }

            // Sort other apps: tier 1 first, then tier 2, then by name
            otherApps.sort(function(a, b) {
                if (a.tier !== b.tier) {
                    return a.tier - b.tier
                }
                return a.name.localeCompare(b.name)
            })

            // Add all apps, then settings at the end
            for (var j = 0; j < otherApps.length; j++) {
                apps.push({
                    appId: otherApps[j].id,
                    name: otherApps[j].name,
                    icon: otherApps[j].icon || "📱",
                    category: otherApps[j].category || "",
                    isEmergency: otherApps[j].isEmergency || false
                })
            }

            // Add settings at the end
            if (settingsApp) {
                apps.push({
                    appId: settingsApp.id,
                    name: settingsApp.name,
                    icon: settingsApp.icon || "⚙️",
                    category: settingsApp.category || "system",
                    isEmergency: false
                })
            }
        }

        return apps
    }

    // Rebuild model when AppBridge changes
    Connections {
        target: AppBridge || null
        function onAppsChanged() {
            home.appList = buildAppList()
        }
    }

    // Title header
    Text {
        id: title
        text: "WAYCORE"
        color: Core.Theme.textPrimary
        font.pixelSize: Core.Theme.h2Size
        font.weight: Font.Bold
        font.letterSpacing: 2
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Core.Theme.spacingMedium
    }

    // Grid of all apps
    GridView {
        id: appGrid
        anchors.top: title.bottom
        anchors.topMargin: Core.Theme.spacingMedium
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Core.Theme.spacingSmall

        cellWidth: width / 3
        cellHeight: 110

        model: appList

        delegate: Item {
            width: appGrid.cellWidth
            height: appGrid.cellHeight

            Core.AppTile {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingXS

                appId: modelData.appId
                appName: modelData.name
                appIcon: modelData.icon
                isEmergency: modelData.isEmergency
                compact: true

                onClicked: {
                    console.log("Home: Opening", modelData.appId)
                    home.navigateToApp(modelData.appId)
                }
            }
        }
    }

    // Empty state when no apps
    Core.EmptyState {
        anchors.centerIn: parent
        visible: appList.length === 0
        icon: "📱"
        title: "No Apps"
        description: "No apps installed"
    }
}
