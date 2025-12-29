import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

Rectangle {
    id: nodeDetails
    color: Core.Theme.background

    signal closeRequested()

    property string nodeId: ""
    property var node: null
    property var contact: null

    Component.onCompleted: {
        loadNodeDetails()
    }

    function loadNodeDetails() {
        if (!nodeId) return

        console.log("Loading details for node:", nodeId)

        if (MeshBridge) {
            // Get node info from the nodes list
            var nodesResult = MeshBridge.getNodes()
            if (nodesResult && nodesResult.nodes) {
                for (var i = 0; i < nodesResult.nodes.length; i++) {
                    if (nodesResult.nodes[i].node_id === nodeId) {
                        node = nodesResult.nodes[i]
                        break
                    }
                }
            }

            // Get contact info
            var contactResult = MeshBridge.getContact(nodeId)
            if (contactResult && contactResult.contact) {
                contact = contactResult.contact
            }
        } else {
            // Mock data
            node = {
                node_id: nodeId,
                short_name: "ALPH",
                long_name: "Alpha Station",
                hardware: "tbeam",
                status: "online",
                battery_level: 85,
                snr: 8.5,
                rssi: -75,
                hops_away: 1,
                last_seen: new Date().toISOString(),
                position: {
                    latitude: 37.7749,
                    longitude: -122.4194,
                    altitude: 15
                }
            }
            contact = { is_favorite: true, alias: null, notes: null }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: Core.Theme.surface

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.spacingSmall
                spacing: Core.Theme.spacingSmall

                Button {
                    text: "←"
                    font.pixelSize: 20
                    onClicked: closeRequested()
                }

                Text {
                    text: contact && contact.alias ? contact.alias : (node ? node.short_name : "Node")
                    color: Core.Theme.textPrimary
                    font.pixelSize: Core.Theme.h2Size
                    font.bold: true
                    Layout.fillWidth: true
                }

                // Favorite button
                Button {
                    text: (contact && contact.is_favorite) ? "⭐" : "☆"
                    font.pixelSize: 20
                    flat: true
                    onClicked: {
                        if (MeshBridge) {
                            MeshBridge.toggleFavorite(nodeId)
                            // Reload contact to get updated favorite status
                            var contactResult = MeshBridge.getContact(nodeId)
                            if (contactResult && contactResult.contact) {
                                contact = contactResult.contact
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Core.Theme.divider
        }

        // Content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: Core.Theme.spacingSmall
                visible: node !== null

                // Node ID card
                InfoCard {
                    title: "Node ID"
                    value: node ? node.node_id : ""
                    icon: "🔗"
                    monospace: true
                }

                // Status card
                InfoCard {
                    title: "Status"
                    value: node ? (node.status === "online" ? "Online" : "Offline") : ""
                    icon: node && node.status === "online" ? "🟢" : "⚫"
                    valueColor: node && node.status === "online" ? Core.Theme.success : Core.Theme.textSecondary
                }

                // Names section
                SectionHeader { text: "Identity" }

                InfoCard {
                    title: "Short Name"
                    value: node ? node.short_name : ""
                    icon: "📛"
                }

                InfoCard {
                    title: "Long Name"
                    value: node ? (node.long_name || "Not set") : ""
                    icon: "📋"
                }

                InfoCard {
                    visible: contact && contact.alias
                    title: "Your Alias"
                    value: contact ? (contact.alias || "") : ""
                    icon: "✏️"
                }

                // Hardware section
                SectionHeader { text: "Hardware" }

                InfoCard {
                    title: "Device"
                    value: node ? formatHardware(node.hardware) : ""
                    icon: "📟"
                }

                InfoCard {
                    title: "Battery"
                    value: node && node.battery_level !== undefined ? node.battery_level + "%" : "Unknown"
                    icon: getBatteryIcon(node ? node.battery_level : null)
                    valueColor: getBatteryColor(node ? node.battery_level : null)
                }

                // Signal section
                SectionHeader { text: "Signal Quality" }

                InfoCard {
                    title: "SNR (Signal-to-Noise)"
                    value: node && node.snr !== undefined ? node.snr.toFixed(1) + " dB" : "N/A"
                    icon: getSignalIcon(node ? node.snr : null)
                    valueColor: getSnrColor(node ? node.snr : null)
                }

                InfoCard {
                    title: "RSSI (Signal Strength)"
                    value: node && node.rssi !== undefined ? node.rssi + " dBm" : "N/A"
                    icon: "📶"
                }

                InfoCard {
                    title: "Hops Away"
                    value: node && node.hops_away !== undefined
                           ? (node.hops_away === 0 ? "Direct connection" : node.hops_away + " hop" + (node.hops_away > 1 ? "s" : ""))
                           : "Unknown"
                    icon: "🔀"
                }

                // Position section (if available)
                SectionHeader {
                    text: "Position"
                    visible: node && node.position
                }

                InfoCard {
                    visible: node && node.position
                    title: "Coordinates"
                    value: node && node.position
                           ? node.position.latitude.toFixed(6) + ", " + node.position.longitude.toFixed(6)
                           : ""
                    icon: "📍"
                    monospace: true
                }

                InfoCard {
                    visible: node && node.position && node.position.altitude
                    title: "Altitude"
                    value: node && node.position && node.position.altitude
                           ? node.position.altitude + " m"
                           : ""
                    icon: "⛰️"
                }

                // Last seen
                SectionHeader { text: "Activity" }

                InfoCard {
                    title: "Last Seen"
                    value: node ? formatLastSeen(node.last_seen) : ""
                    icon: "🕐"
                }

                // Actions
                SectionHeader { text: "Actions" }

                Button {
                    Layout.fillWidth: true
                    Layout.margins: Core.Theme.spacingMedium
                    text: "💬 Send Message"
                    enabled: node && node.status === "online"
                    onClicked: {
                        // Navigate to chat
                        var shell = nodeDetails.parent
                        while (shell && !shell.hasOwnProperty("navigateTo")) {
                            shell = shell.parent
                        }
                        if (shell && shell.navigateTo) {
                            shell.navigateTo("Meshtastic")
                        }
                    }
                }

                // Bottom spacing
                Item { Layout.preferredHeight: Core.Theme.spacingLarge }
            }
        }

        // Loading state
        Text {
            visible: node === null
            anchors.centerIn: parent
            text: "Loading..."
            color: Core.Theme.textSecondary
            font.pixelSize: Core.Theme.bodySize
        }
    }

    function formatHardware(hw) {
        if (!hw) return "Unknown"
        var names = {
            "tbeam": "LilyGo T-Beam",
            "tlora": "LilyGo T-LoRa",
            "heltec": "Heltec LoRa 32",
            "rak4631": "RAK4631",
            "station_g1": "Station G1",
            "techo": "LilyGo T-Echo",
            "nano_g1": "Nano G1"
        }
        return names[hw.toLowerCase()] || hw
    }

    function getBatteryIcon(level) {
        if (level === undefined || level === null) return "🔋"
        if (level < 20) return "🪫"
        if (level < 50) return "🔋"
        return "🔋"
    }

    function getBatteryColor(level) {
        if (level === undefined || level === null) return Core.Theme.textSecondary
        if (level < 20) return Core.Theme.error
        if (level < 50) return Core.Theme.warning
        return Core.Theme.success
    }

    function getSignalIcon(snr) {
        if (snr === undefined || snr === null) return "📶"
        if (snr > 5) return "📶"
        if (snr > 0) return "📶"
        if (snr > -5) return "📶"
        return "📶"
    }

    function getSnrColor(snr) {
        if (snr === undefined || snr === null) return Core.Theme.textSecondary
        if (snr > 5) return Core.Theme.success
        if (snr > 0) return "#8BC34A"  // Light green
        if (snr > -5) return Core.Theme.warning
        return Core.Theme.error
    }

    function formatLastSeen(isoString) {
        if (!isoString) return "Unknown"
        var date = new Date(isoString)
        var now = new Date()
        var diff = now - date
        var mins = Math.floor(diff / 60000)
        var hours = Math.floor(diff / 3600000)
        var days = Math.floor(diff / 86400000)

        if (mins < 1) return "Just now"
        if (mins < 60) return mins + " minute" + (mins > 1 ? "s" : "") + " ago"
        if (hours < 24) return hours + " hour" + (hours > 1 ? "s" : "") + " ago"
        return days + " day" + (days > 1 ? "s" : "") + " ago"
    }

    // Info Card component
    component InfoCard: Rectangle {
        property string title: ""
        property string value: ""
        property string icon: ""
        property bool monospace: false
        property color valueColor: Core.Theme.textPrimary

        Layout.fillWidth: true
        Layout.margins: Core.Theme.spacingSmall
        Layout.leftMargin: Core.Theme.spacingMedium
        Layout.rightMargin: Core.Theme.spacingMedium
        height: 60
        color: Core.Theme.surface
        radius: 8

        RowLayout {
            anchors.fill: parent
            anchors.margins: Core.Theme.spacingSmall
            spacing: Core.Theme.spacingSmall

            Text {
                text: icon
                font.pixelSize: 24
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignHCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: title
                    color: Core.Theme.textSecondary
                    font.pixelSize: Core.Theme.captionSize
                }

                Text {
                    text: value
                    color: valueColor
                    font.pixelSize: Core.Theme.bodySize
                    font.bold: true
                    font.family: monospace ? "monospace" : undefined
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }

    // Section Header component
    component SectionHeader: Item {
        property string text: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.topMargin: Core.Theme.spacingSmall

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Core.Theme.spacingMedium
            anchors.verticalCenter: parent.verticalCenter
            text: parent.text
            color: Core.Theme.textSecondary
            font.pixelSize: Core.Theme.captionSize
            font.bold: true
            font.capitalization: Font.AllUppercase
        }
    }
}
