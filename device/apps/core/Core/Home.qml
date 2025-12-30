import QtQuick 2.15
import QtQuick.Layouts 1.15
import "." as Core
import "./components" as Components

/**
 * Home - Tactical app launcher with grid background
 *
 * Features:
 * - Tactical grid background pattern
 * - Scanline overlay effect
 * - 3-column app grid with tactical styling
 * - System info panel at bottom
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
            var allApps = AppBridge.allApps
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

    // === BACKGROUND LAYERS ===

    // Tactical grid pattern background
    Canvas {
        id: gridPattern
        anchors.fill: parent
        z: 0
        opacity: 0.15

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = Core.Theme.divider
            ctx.lineWidth = 1

            var gridSize = Core.Theme.gridSize

            // Vertical lines
            for (var x = 0; x <= width; x += gridSize) {
                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.stroke()
            }

            // Horizontal lines
            for (var y = 0; y <= height; y += gridSize) {
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
        }

        // Repaint when size changes
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    // Scanline overlay effect
    Rectangle {
        id: scanlineOverlay
        anchors.fill: parent
        z: 50
        opacity: 0.15

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0.2) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.2) }
        }

        // Repeat pattern effect using a second overlay
        Canvas {
            anchors.fill: parent
            opacity: 0.5

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                // Create scanline pattern every 4 pixels
                for (var y = 0; y < height; y += 4) {
                    ctx.fillStyle = Qt.rgba(0, 0, 0, 0.15)
                    ctx.fillRect(0, y + 2, width, 2)
                }
            }

            onHeightChanged: requestPaint()
            onWidthChanged: requestPaint()
        }
    }

    // === MAIN CONTENT ===
    Item {
        id: mainContent
        anchors.fill: parent
        z: 10

        // App grid
        GridView {
            id: appGrid
            anchors.top: parent.top
            anchors.topMargin: Core.Theme.spacingMedium
            anchors.bottom: systemInfoPanel.top
            anchors.bottomMargin: Core.Theme.spacingMedium
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Core.Theme.spacingSmall
            anchors.rightMargin: Core.Theme.spacingSmall

            cellWidth: width / 3
            cellHeight: cellWidth  // Square tiles

            model: appList
            clip: true

            delegate: Item {
                width: appGrid.cellWidth
                height: appGrid.cellHeight

                Core.AppTile {
                    anchors.fill: parent
                    anchors.margins: Core.Theme.spacingXS + 2

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

        // System info panel at bottom
        Components.SystemInfoPanel {
            id: systemInfoPanel
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Core.Theme.spacingMedium
        }
    }

    // Empty state when no apps
    Core.EmptyState {
        anchors.centerIn: parent
        visible: appList.length === 0
        icon: "📱"
        title: "No Apps"
        description: "No apps installed"
        z: 20
    }
}
