import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * MeshNodeDetails - Node Details screen with tactical design
 */
Rectangle {
    id: meshNodeDetails
    color: Core.Theme.background

    property string nodeId: ""
    property var node: null
    property var contact: null
    property bool isFavorite: false  // Reactive property for star button

    Component.onCompleted: loadNodeDetails()

    function loadNodeDetails() {
        if (!nodeId) return

        if (MeshBridge) {
            var nodesResult = MeshBridge.getNodesWithContacts()
            if (nodesResult && nodesResult.nodes) {
                for (var i = 0; i < nodesResult.nodes.length; i++) {
                    if (nodesResult.nodes[i].node_id === nodeId) {
                        node = nodesResult.nodes[i]
                        break
                    }
                }
            }

            var contactResult = MeshBridge.getContact(nodeId)
            if (contactResult && contactResult.contact) {
                contact = contactResult.contact
                isFavorite = contactResult.contact.is_favorite || false
            }
        } else {
            node = {
                node_id: nodeId || "!f823a109",
                short_name: "ECHO-ONE",
                long_name: "Echo-One-Alpha",
                hardware: "tbeam",
                status: "online",
                battery_level: 88,
                voltage: 4.12,
                snr: 9.5,
                rssi: -85,
                hops_away: 0,
                last_seen: new Date().toISOString(),
                position: { latitude: 34.0522, longitude: -118.2437, altitude: 128 }
            }
            contact = { is_favorite: true, alias: "Team Lead" }
            isFavorite = true
        }
    }

    function toggleFavorite() {
        if (typeof MeshBridge !== "undefined" && MeshBridge) {
            var result = MeshBridge.toggleFavorite(nodeId)
            if (result) {
                isFavorite = result.is_favorite
                if (contact) contact.is_favorite = result.is_favorite
            }
        } else {
            isFavorite = !isFavorite
            if (contact) contact.is_favorite = isFavorite
        }
    }

    Core.TacticalBackground { anchors.fill: parent; z: 0 }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        z: 10

        // Header using PageHeader with star button overlay
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Core.Theme.appBarHeight

            Core.PageHeader {
                anchors.fill: parent
                title: node ? (node.short_name || node.node_id) : "Node Details"
                subtitle: node && node.status === "online" ? "Connected" : "Offline"
                showBack: true
                onBackClicked: {
                    var p = meshNodeDetails.parent
                    while (p && !p.navigateBack) p = p.parent
                    if (p) p.navigateBack()
                }
            }

            // Star button (overlaid on right side)
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: Core.Theme.spacingMedium
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 48
                radius: 24
                color: favMouse.containsMouse ? Qt.rgba(Core.Theme.warning.r, Core.Theme.warning.g, Core.Theme.warning.b, 0.1) : "transparent"
                z: 10

                Core.MaterialIcon {
                    anchors.centerIn: parent
                    name: isFavorite ? "star" : "star-outline"
                    size: 24
                    iconColor: isFavorite ? Core.Theme.warning : (favMouse.containsMouse ? Core.Theme.warning : Core.Theme.textSecondary)

                    Behavior on iconColor {
                        ColorAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    id: favMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: toggleFavorite()
                }
            }
        }

        // Content
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentColumn.height + Core.Theme.spacingLarge * 2
            clip: true

            ColumnLayout {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Core.Theme.spacingMedium
                anchors.topMargin: Core.Theme.spacingMedium
                spacing: Core.Theme.spacingMedium

                // Node ID Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: nodeIdContent.height + Core.Theme.spacingMedium * 2
                    radius: 12
                    color: Core.Theme.tacticalCard
                    border.color: Core.Theme.divider
                    border.width: 1

                    // Background fingerprint icon
                    Core.MaterialIcon {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Core.Theme.spacingMedium
                        name: "fingerprint"
                        size: 64
                        iconColor: Core.Theme.textPrimary
                        opacity: 0.1
                    }

                    ColumnLayout {
                        id: nodeIdContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Core.Theme.spacingMedium
                        spacing: Core.Theme.spacingMedium

                        // Node ID and Status
                        RowLayout {
                            Layout.fillWidth: true

                            Column {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "NODE ID"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                    font.letterSpacing: 2
                                    font.capitalization: Font.AllUppercase
                                }
                                Text {
                                    text: node ? node.node_id : "--"
                                    color: Core.Theme.success
                                    font.pixelSize: 20
                                    font.family: Core.Theme.fontFamilyMono
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                }
                            }

                            // Online badge
                            Rectangle {
                                visible: node && node.status === "online"
                                width: onlineBadgeRow.width + 12
                                height: 24
                                radius: 4
                                color: Qt.rgba(Core.Theme.success.r, Core.Theme.success.g, Core.Theme.success.b, 0.1)
                                border.color: Qt.rgba(Core.Theme.success.r, Core.Theme.success.g, Core.Theme.success.b, 0.3)
                                border.width: 1

                                Row {
                                    id: onlineBadgeRow
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Rectangle {
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: Core.Theme.success
                                        anchors.verticalCenter: parent.verticalCenter

                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite
                                            running: true
                                            NumberAnimation { to: 0.4; duration: 1000 }
                                            NumberAnimation { to: 1.0; duration: 1000 }
                                        }
                                    }
                                    Text {
                                        text: "ONLINE"
                                        color: Core.Theme.success
                                        font.pixelSize: Core.Theme.tinySize
                                        font.weight: Font.Bold
                                        font.letterSpacing: 2
                                    }
                                }
                            }
                        }

                        // Divider
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)
                        }

                        // Short Name and Long Name
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: Core.Theme.spacingLarge
                            rowSpacing: 4

                            Column {
                                spacing: 2
                                Text {
                                    text: "SHORT NAME"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                    font.letterSpacing: 2
                                }
                                Text {
                                    text: node ? node.short_name : "--"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySize
                                    font.weight: Font.Bold
                                }
                            }

                            Column {
                                spacing: 2
                                Text {
                                    text: "LONG NAME"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                    font.letterSpacing: 2
                                }
                                Text {
                                    text: node ? (node.long_name || "--") : "--"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        // Alias section
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: Core.Theme.spacingSmall
                            height: 1
                            color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "YOUR ALIAS"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.tinySize
                                font.family: Core.Theme.fontFamilyMono
                                font.letterSpacing: 2
                            }

                            Rectangle {
                                width: parent.width
                                height: 40
                                radius: 4
                                color: Qt.rgba(0, 0, 0, 0.3)
                                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Text {
                                        Layout.fillWidth: true
                                        text: contact && contact.alias ? contact.alias : "No alias set"
                                        color: contact && contact.alias ? Core.Theme.textSecondary : Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                        font.pixelSize: Core.Theme.bodySmallSize
                                    }
                                    Core.MaterialIcon {
                                        name: "pencil"
                                        size: 14
                                        iconColor: Core.Theme.textSecondary
                                    }
                                }
                            }
                        }
                    }
                }

                // Hardware Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: hardwareContent.height + Core.Theme.spacingMedium * 2
                    radius: 12
                    color: Core.Theme.tacticalCard
                    border.color: Core.Theme.divider
                    border.width: 1

                    ColumnLayout {
                        id: hardwareContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Core.Theme.spacingMedium
                        spacing: Core.Theme.spacingMedium

                        // Header with border
                        Column {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            Row {
                                spacing: Core.Theme.spacingSmall
                                Core.MaterialIcon { name: "memory"; size: 14; iconColor: Core.Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "HARDWARE"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.smallSize
                                    font.weight: Font.Bold
                                    font.letterSpacing: 2
                                }
                            }
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: Core.Theme.spacingLarge
                            rowSpacing: Core.Theme.spacingMedium

                            // Device
                            Column {
                                spacing: 4
                                Text {
                                    text: "DEVICE"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                    font.letterSpacing: 2
                                }
                                Text {
                                    text: node ? formatHardware(node.hardware) : "--"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }

                            // Battery
                            Column {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "BATTERY"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                    font.letterSpacing: 2
                                }

                                RowLayout {
                                    width: parent.width
                                    spacing: Core.Theme.spacingSmall

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 8
                                        radius: 4
                                        color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.5)

                                        Rectangle {
                                            width: parent.width * (node && node.battery_level ? node.battery_level / 100 : 0)
                                            height: parent.height
                                            radius: 4
                                            color: Core.Theme.success
                                        }
                                    }

                                    Text {
                                        text: node && node.battery_level ? node.battery_level + "%" : "--"
                                        color: Core.Theme.success
                                        font.pixelSize: Core.Theme.bodySmallSize
                                        font.family: Core.Theme.fontFamilyMono
                                        font.weight: Font.Bold
                                    }
                                }

                                Text {
                                    anchors.right: parent.right
                                    visible: node !== null && node.voltage !== undefined && node.voltage !== null
                                    text: (node && node.voltage !== undefined && node.voltage !== null) ? node.voltage.toFixed(2) + "V" : ""
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }
                        }
                    }
                }

                // Signal Quality Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: signalContent.height + Core.Theme.spacingMedium * 2
                    radius: 12
                    color: Core.Theme.tacticalCard
                    border.color: Core.Theme.divider
                    border.width: 1

                    ColumnLayout {
                        id: signalContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Core.Theme.spacingMedium
                        spacing: Core.Theme.spacingMedium

                        // Header with border
                        Column {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            Row {
                                spacing: Core.Theme.spacingSmall
                                Core.MaterialIcon { name: "signal-cellular-3"; size: 14; iconColor: Core.Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "SIGNAL QUALITY"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.smallSize
                                    font.weight: Font.Bold
                                    font.letterSpacing: 2
                                }
                            }
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                            }
                        }

                        // Signal stats grid
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            // SNR
                            Rectangle {
                                Layout.fillWidth: true
                                height: 70
                                radius: 4
                                color: Qt.rgba(0, 0, 0, 0.2)
                                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "SNR"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.family: Core.Theme.fontFamilyMono
                                        font.letterSpacing: 2
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: node && node.snr !== undefined ? node.snr.toFixed(1) + "dB" : "--"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: 16
                                        font.family: Core.Theme.fontFamilyMono
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            // RSSI
                            Rectangle {
                                Layout.fillWidth: true
                                height: 70
                                radius: 4
                                color: Qt.rgba(0, 0, 0, 0.2)
                                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "RSSI"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.family: Core.Theme.fontFamilyMono
                                        font.letterSpacing: 2
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: node && node.rssi !== undefined ? node.rssi : "--"
                                        color: Core.Theme.textPrimary
                                        font.pixelSize: 16
                                        font.family: Core.Theme.fontFamilyMono
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        visible: node && node.rssi !== undefined
                                        text: "dBm"
                                        color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                        font.pixelSize: 8
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                }
                            }

                            // Hops
                            Rectangle {
                                Layout.fillWidth: true
                                height: 70
                                radius: 4
                                color: Qt.rgba(0, 0, 0, 0.2)
                                border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "HOPS"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.tinySize
                                        font.family: Core.Theme.fontFamilyMono
                                        font.letterSpacing: 2
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: node && node.hops_away !== undefined ? node.hops_away : "--"
                                        color: Core.Theme.success
                                        font.pixelSize: 16
                                        font.family: Core.Theme.fontFamilyMono
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        visible: node && node.hops_away !== undefined
                                        text: node && node.hops_away === 0 ? "Direct" : ""
                                        color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.5)
                                        font.pixelSize: 8
                                        font.family: Core.Theme.fontFamilyMono
                                    }
                                }
                            }
                        }
                    }
                }

                // Position Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: positionContent.height + Core.Theme.spacingMedium * 2
                    radius: 12
                    color: Core.Theme.tacticalCard
                    border.color: Core.Theme.divider
                    border.width: 1
                    visible: node !== null && node.position !== undefined && node.position !== null

                    ColumnLayout {
                        id: positionContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Core.Theme.spacingMedium
                        spacing: Core.Theme.spacingMedium

                        // Header
                        RowLayout {
                            Layout.fillWidth: true

                            Row {
                                spacing: Core.Theme.spacingSmall
                                Core.MaterialIcon { name: "map-marker"; size: 14; iconColor: Core.Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "POSITION"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.smallSize
                                    font.weight: Font.Bold
                                    font.letterSpacing: 2
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "Last updated: 2m ago"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.tinySize
                                font.family: Core.Theme.fontFamilyMono
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                        }

                        // Coordinates with navigation icon
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingMedium

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 4
                                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                                border.color: Core.Theme.divider

                                Core.MaterialIcon {
                                    anchors.centerIn: parent
                                    name: "navigation"
                                    size: 24
                                    iconColor: Core.Theme.success
                                    rotation: 45
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: node && node.position ? formatCoordinates(node.position.latitude, node.position.longitude) : "--"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                                Text {
                                    text: "DIST: 420m • BRG: 215° SW"
                                    color: Core.Theme.textSecondary
                                    font.pixelSize: Core.Theme.tinySize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }
                        }

                        // Altitude
                        Rectangle {
                            Layout.fillWidth: true
                            height: 36
                            radius: 4
                            color: Qt.rgba(0, 0, 0, 0.2)
                            border.color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.2)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                Row {
                                    spacing: Core.Theme.spacingSmall
                                    Core.MaterialIcon { name: "arrow-up-bold"; size: 12; iconColor: Core.Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter }
                                    Text {
                                        text: "ALTITUDE"
                                        color: Core.Theme.textSecondary
                                        font.pixelSize: Core.Theme.smallSize
                                        font.letterSpacing: 0.5
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: node && node.position && node.position.altitude ? node.position.altitude + "m" : "--"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.bodySmallSize
                                    font.family: Core.Theme.fontFamilyMono
                                }
                            }
                        }
                    }
                }

                // Activity Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: activityContent.height + Core.Theme.spacingMedium * 2
                    radius: 12
                    color: Core.Theme.tacticalCard
                    border.color: Core.Theme.divider
                    border.width: 1

                    ColumnLayout {
                        id: activityContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Core.Theme.spacingMedium
                        spacing: Core.Theme.spacingMedium

                        // Header with border
                        Column {
                            Layout.fillWidth: true
                            spacing: Core.Theme.spacingSmall

                            Row {
                                spacing: Core.Theme.spacingSmall
                                Core.MaterialIcon { name: "history"; size: 14; iconColor: Core.Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "ACTIVITY"
                                    color: Core.Theme.textPrimary
                                    font.pixelSize: Core.Theme.smallSize
                                    font.weight: Font.Bold
                                    font.letterSpacing: 2
                                }
                            }
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Qt.rgba(Core.Theme.divider.r, Core.Theme.divider.g, Core.Theme.divider.b, 0.3)
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "LAST SEEN"
                                color: Core.Theme.textSecondary
                                font.pixelSize: Core.Theme.tinySize
                                font.family: Core.Theme.fontFamilyMono
                                font.letterSpacing: 2
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: formatLastSeenFull(node ? node.last_seen : null)
                                color: Core.Theme.textPrimary
                                font.pixelSize: Core.Theme.bodySmallSize
                                font.family: Core.Theme.fontFamilyMono
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: "Via LoRa (Mesh)"
                            color: Qt.rgba(Core.Theme.textSecondary.r, Core.Theme.textSecondary.g, Core.Theme.textSecondary.b, 0.6)
                            font.pixelSize: Core.Theme.tinySize
                            font.italic: true
                        }
                    }
                }

                // Send Message button
                Core.Button {
                    Layout.fillWidth: true
                    text: "Send Message"
                    variant: "tactical"
                    iconName: "chat"
                    enabled: node && node.status === "online"
                    onClicked: {
                        var p = meshNodeDetails.parent
                        while (p && !p.openConversation) p = p.parent
                        if (p) p.openConversation(nodeId)
                    }
                }

                // Bottom spacing
                Item { Layout.preferredHeight: 40 }
            }
        }
    }

    function formatHardware(hw) {
        if (!hw) return "Unknown"
        var names = {
            "tbeam": "T-Beam v1.1",
            "tlora": "T-LoRa v2",
            "heltec": "Heltec LoRa 32",
            "rak4631": "RAK4631",
            "station_g1": "Station G1",
            "techo": "T-Echo"
        }
        return names[hw.toLowerCase()] || hw
    }

    function formatCoordinates(lat, lon) {
        if (lat === undefined || lon === undefined) return "--"
        var latDir = lat >= 0 ? "N" : "S"
        var lonDir = lon >= 0 ? "E" : "W"
        return Math.abs(lat).toFixed(4) + "° " + latDir + ", " + Math.abs(lon).toFixed(4) + "° " + lonDir
    }

    function formatLastSeenFull(isoString) {
        if (!isoString) return "Unknown"
        var date = new Date(isoString)
        var now = new Date()
        var hours = date.getHours().toString().padStart(2, '0')
        var mins = date.getMinutes().toString().padStart(2, '0')
        var secs = date.getSeconds().toString().padStart(2, '0')

        if (date.toDateString() === now.toDateString()) {
            return "Today, " + hours + ":" + mins + ":" + secs
        }
        return date.toLocaleDateString() + ", " + hours + ":" + mins + ":" + secs
    }
}
