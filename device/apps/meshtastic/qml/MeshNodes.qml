import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * MeshNodes - Node List screen with tactical design
 */
Rectangle {
    id: meshNodes
    color: Core.Theme.background

    property var nodes: []

    Component.onCompleted: refreshNodes()

    function refreshNodes() {
        if (typeof MeshBridge !== "undefined" && MeshBridge) {
            var result = MeshBridge.getNodesWithContacts()
            if (result && result.nodes) {
                // Ensure all nodes have is_favorite defined
                var processedNodes = []
                for (var i = 0; i < result.nodes.length; i++) {
                    var n = result.nodes[i]
                    processedNodes.push({
                        node_id: n.node_id || "",
                        short_name: n.short_name || "",
                        long_name: n.long_name || "",
                        status: n.status || "offline",
                        battery_level: n.battery_level !== undefined ? n.battery_level : null,
                        snr: n.snr !== undefined ? n.snr : null,
                        hops_away: n.hops_away !== undefined ? n.hops_away : null,
                        last_seen: n.last_seen || "",
                        is_favorite: n.is_favorite === true  // Ensure boolean
                    })
                }
                nodes = processedNodes
            }
        } else {
            nodes = [
                { node_id: "!f34a9b", short_name: "ALPHA-ONE", long_name: "Base Station", status: "online", battery_level: 94, snr: -82, hops_away: 0, last_seen: new Date().toISOString(), is_favorite: true },
                { node_id: "!a21c44", short_name: "ROVER-2", long_name: "Mobile Unit", status: "online", battery_level: 45, snr: -95, hops_away: 1, last_seen: new Date(Date.now() - 120000).toISOString(), is_favorite: false },
                { node_id: "!99cc11", short_name: "RELAY-NORTH", long_name: "Repeater", status: "offline", battery_level: null, snr: null, hops_away: 2, last_seen: new Date(Date.now() - 15120000).toISOString(), is_favorite: false }
            ]
        }
    }

    function toggleFavorite(nodeId, index) {
        // Save to database via MeshBridge
        if (typeof MeshBridge !== "undefined" && MeshBridge) {
            var result = MeshBridge.toggleFavorite(nodeId)
            if (result) {
                // Refresh to get updated state from DB
                refreshNodes()
            }
        } else {
            // Mock mode - just update local state
            var updatedNodes = nodes.slice()
            updatedNodes[index].is_favorite = !updatedNodes[index].is_favorite
            nodes = updatedNodes
        }
    }

    Timer { interval: 10000; running: true; repeat: true; onTriggered: refreshNodes() }

    Core.TacticalBackground { anchors.fill: parent; z: 0 }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        z: 10

        // Header using PageHeader
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Core.Theme.appBarHeight

            Core.PageHeader {
                anchors.fill: parent
                title: "Mesh Nodes"
                subtitle: getOnlineCount() + "/" + nodes.length + " Online"
                showBack: true
                rightIcon: "refresh"
                onBackClicked: {
                    var p = meshNodes.parent
                    while (p && !p.navigateBack) p = p.parent
                    if (p) p.navigateBack()
                }
                onRightClicked: refreshNodes()
            }
        }

        // Status bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: Qt.rgba(Core.Theme.surface.r, Core.Theme.surface.g, Core.Theme.surface.b, 0.3)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Core.Theme.spacingMedium
                anchors.rightMargin: Core.Theme.spacingMedium

                Text { text: "VISIBILITY"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.tinySize; font.family: Core.Theme.fontFamilyMono; font.letterSpacing: 2 }
                Item { Layout.fillWidth: true }
                Row {
                    spacing: Core.Theme.spacingSmall
                    Rectangle { width: 8; height: 8; radius: 4; color: Core.Theme.success; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: getOnlineCount() + "/" + nodes.length + " ONLINE"; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.tinySize; font.family: Core.Theme.fontFamilyMono; font.weight: Font.Bold }
                }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Core.Theme.divider }
        }

        // Node list
        ListView {
            id: nodeList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Core.Theme.spacingMedium
            clip: true
            spacing: Core.Theme.spacingMedium
            model: nodes

            delegate: Rectangle {
                width: nodeList.width
                height: nodeColumn.height + Core.Theme.spacingMedium * 2
                radius: Core.Theme.borderRadius
                color: Core.Theme.tacticalCard
                border.color: nodeMouse.containsMouse ? Qt.rgba(Core.Theme.primary.r, Core.Theme.primary.g, Core.Theme.primary.b, 0.5) : Core.Theme.divider
                opacity: modelData.status === "offline" ? 0.75 : 1.0

                MouseArea { id: nodeMouse; anchors.fill: parent; hoverEnabled: true
                    onClicked: { var p = meshNodes.parent; while (p && !p.openNodeDetails) p = p.parent; if (p) p.openNodeDetails(modelData.node_id) }
                }

                ColumnLayout {
                    id: nodeColumn
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                    anchors.margins: Core.Theme.spacingMedium
                    spacing: Core.Theme.spacingSmall

                    // Header row with status dot, name, and star button
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(nodeInfo.height, starButton.height)

                        // Status dot
                        Rectangle {
                            id: statusDot
                            width: 12; height: 12; radius: 6
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.topMargin: 4
                            color: modelData.status === "online" ? Core.Theme.success : Core.Theme.textSecondary
                            opacity: modelData.status === "online" ? 1.0 : 0.3
                            // Glow effect for online nodes
                            layer.enabled: modelData.status === "online"
                            layer.effect: null
                        }

                        // Node info (name + type)
                        Column {
                            id: nodeInfo
                            anchors.left: statusDot.right
                            anchors.leftMargin: Core.Theme.spacingMedium
                            anchors.right: starButton.left
                            anchors.rightMargin: Core.Theme.spacingSmall
                            anchors.top: parent.top
                            spacing: 2

                            Row {
                                spacing: Core.Theme.spacingSmall
                                Text {
                                    text: modelData.short_name
                                    color: modelData.status === "offline" ? Core.Theme.textSecondary : Core.Theme.textPrimary
                                    font.pixelSize: 18
                                    font.weight: Core.Theme.fontWeightBold
                                }
                                Text {
                                    text: modelData.node_id
                                    color: modelData.is_favorite ? Core.Theme.warning : Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.6)
                                    font.pixelSize: Core.Theme.smallSize
                                    font.family: Core.Theme.fontFamilyMono
                                    anchors.baseline: parent.children[0].baseline
                                }
                            }
                            Text {
                                text: modelData.long_name || ""
                                color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.7)
                                font.pixelSize: Core.Theme.tinySize
                                font.family: Core.Theme.fontFamilyMono
                                font.capitalization: Font.AllUppercase
                                font.letterSpacing: 1
                            }
                        }

                        // Star button aligned to top-right
                        Rectangle {
                            id: starButton
                            width: 32; height: 32
                            anchors.right: parent.right
                            anchors.top: parent.top
                            color: "transparent"

                            Core.MaterialIcon {
                                anchors.centerIn: parent
                                name: modelData.is_favorite ? "star" : "star-outline"
                                size: 22
                                iconColor: modelData.is_favorite ? Core.Theme.warning : Core.Theme.textSecondary
                                opacity: modelData.is_favorite ? 1.0 : 0.3
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: toggleFavorite(modelData.node_id, index)
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3) }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 4
                        columnSpacing: Core.Theme.spacingSmall
                        opacity: modelData.status === "offline" ? 0.6 : 1.0

                        Repeater {
                            model: [
                                { icon: "signal-cellular-3", iconColor: Core.Theme.success, value: modelData.snr ? modelData.snr + "dB" : "--" },
                                { icon: "battery", iconColor: Core.Theme.textSecondary, value: modelData.battery_level ? modelData.battery_level + "%" : "?" },
                                { icon: "hub", iconColor: Core.Theme.textSecondary, value: modelData.hops_away !== undefined ? modelData.hops_away + " Hops" : "--" },
                                { icon: "clock-outline", iconColor: modelData.status === "online" ? Core.Theme.success : Core.Theme.textSecondary, value: formatLastSeen(modelData) }
                            ]

                            Rectangle {
                                Layout.fillWidth: true; height: 48; radius: Core.Theme.borderRadius; color: Qt.rgba(0, 0, 0, 0.2)
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 4
                                    Core.MaterialIcon { Layout.alignment: Qt.AlignHCenter; name: modelData.icon; size: 16; iconColor: modelData.iconColor }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: modelData.value; color: Core.Theme.textPrimary; font.pixelSize: Core.Theme.tinySize; font.family: Core.Theme.fontFamilyMono }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: Core.Theme.borderRadius
                        color: modelData.status === "online" ? Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2) : "transparent"
                        border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)

                        Row {
                            anchors.centerIn: parent; spacing: Core.Theme.spacingSmall
                            Core.MaterialIcon { name: "chat"; size: 14; iconColor: modelData.status === "online" ? Core.Theme.textSecondary : Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5) }
                            Text { text: modelData.status === "online" ? "DIRECT MESSAGE" : "OFFLINE"; color: modelData.status === "online" ? Core.Theme.textSecondary : Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5); font.pixelSize: Core.Theme.smallSize; font.weight: Core.Theme.fontWeightBold; font.letterSpacing: 1 }
                        }

                        MouseArea {
                            anchors.fill: parent; enabled: modelData.status === "online"
                            onClicked: { var p = meshNodes.parent; while (p && !p.openConversation) p = p.parent; if (p) p.openConversation(modelData.node_id) }
                        }
                    }
                }
            }

            footer: Item {
                width: nodeList.width; height: 80
                Column {
                    anchors.centerIn: parent; spacing: Core.Theme.spacingSmall; opacity: 0.5
                    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 48; height: 1; color: Core.Theme.divider }
                    Text { text: "END OF TRANSMISSION"; color: Core.Theme.divider; font.pixelSize: Core.Theme.tinySize; font.family: Core.Theme.fontFamilyMono; font.letterSpacing: 3 }
                    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 48; height: 1; color: Core.Theme.divider }
                }
            }

            Text { visible: nodes.length === 0; anchors.centerIn: parent; text: "No nodes found"; color: Core.Theme.textSecondary; font.pixelSize: Core.Theme.bodySize }
        }
    }

    function getOnlineCount() { return nodes.filter(function(n) { return n.status === "online"; }).length }
    function formatLastSeen(node) {
        if (node.status === "online") {
            var diff = Date.now() - new Date(node.last_seen).getTime()
            if (diff < 60000) return "NOW"
            return Math.floor(diff / 60000) + "m"
        }
        var diff = Date.now() - new Date(node.last_seen).getTime()
        var hours = Math.floor(diff / 3600000)
        var mins = Math.floor((diff % 3600000) / 60000)
        if (hours > 0) return hours + "h " + mins + "m"
        return mins + "m"
    }
}
