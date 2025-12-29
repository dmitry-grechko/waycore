import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

Rectangle {
    id: camera
    color: "#000000"

    // Standard app interface
    property string appId: "com.waycore.camera"
    property string appTitle: "Camera"
    signal closeRequested()

    // Camera state from CameraBridge
    property bool isReady: CameraBridge ? CameraBridge.isReady : false
    property bool isCapturing: CameraBridge ? CameraBridge.isCapturing : false
    property bool connected: CameraBridge ? CameraBridge.connected : false
    property string lastPhotoUrl: ""
    property string toastMessage: ""

    // Viewfinder Area
    Rectangle {
        id: viewfinder
        anchors.fill: parent
        color: "#1a1a1a"

        // Mock viewfinder gradient (simulates camera feed)
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#2a3d33" }
                GradientStop { position: 0.5; color: "#1a2d23" }
                GradientStop { position: 1.0; color: "#2a3d33" }
            }

            // Animated scanline effect for "live" feel
            Rectangle {
                id: scanline
                width: parent.width
                height: 2
                color: Qt.rgba(1, 1, 1, 0.1)
                y: 0

                SequentialAnimation on y {
                    running: camera.visible && connected
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 0
                        to: viewfinder.height
                        duration: 3000
                        easing.type: Easing.Linear
                    }
                }
            }
        }

        // Mock camera label
        Column {
            anchors.centerIn: parent
            spacing: Core.Theme.spacingSmall
            visible: connected

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "📷"
                font.pixelSize: 48
                opacity: 0.5
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "MOCK CAMERA"
                color: "#666"
                font.pixelSize: 18
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: CameraBridge ? (CameraBridge.resolutionWidth + " × " + CameraBridge.resolutionHeight) : ""
                color: "#555"
                font.pixelSize: 14
            }
        }

        // Disconnected state
        Column {
            anchors.centerIn: parent
            spacing: Core.Theme.spacingMedium
            visible: !connected

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "📷"
                font.pixelSize: 48
                opacity: 0.3
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Camera Unavailable"
                color: Core.Theme.warning
                font.pixelSize: 18
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Check camera service connection"
                color: Core.Theme.textSecondary
                font.pixelSize: 14
            }

            // Retry button
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 100
                height: 40
                color: retryButtonMouse.pressed ? Core.Theme.primaryDark : Core.Theme.primary
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: "Retry"
                    color: "white"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: retryButtonMouse
                    anchors.fill: parent
                    onClicked: {
                        if (CameraBridge) {
                            CameraBridge.refreshStatus()
                        }
                    }
                }
            }
        }
    }

    // White flash overlay for capture effect
    Rectangle {
        id: flashOverlay
        anchors.fill: parent
        color: "white"
        opacity: 0
        z: 100

        SequentialAnimation {
            id: captureAnimation
            PropertyAnimation {
                target: flashOverlay
                property: "opacity"
                to: 0.9
                duration: 50
            }
            PropertyAnimation {
                target: flashOverlay
                property: "opacity"
                to: 0
                duration: 200
            }
        }
    }

    // Top control bar
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: Qt.rgba(0, 0, 0, 0.5)
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.margins: Core.Theme.spacingSmall

            // Back button
            Rectangle {
                width: 70
                height: 36
                color: backButtonMouse.pressed ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.2)
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: "← Back"
                    color: "white"
                }

                MouseArea {
                    id: backButtonMouse
                    anchors.fill: parent
                    onClicked: closeRequested()
                }
            }

            Item { Layout.fillWidth: true }

            // Camera switch button (front/back)
            Rectangle {
                width: 80
                height: 36
                color: switchButtonMouse.pressed ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.2)
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: CameraBridge && CameraBridge.isFrontCamera ? "📱 Front" : "📷 Back"
                    color: "white"
                }

                MouseArea {
                    id: switchButtonMouse
                    anchors.fill: parent
                    onClicked: {
                        if (CameraBridge) {
                            CameraBridge.switchCamera(!CameraBridge.isFrontCamera)
                        }
                    }
                }
            }
        }
    }

    // Bottom control bar
    Rectangle {
        id: bottomBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 120
        color: Qt.rgba(0, 0, 0, 0.6)
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.margins: Core.Theme.spacingMedium

            // Gallery thumbnail (last photo)
            Rectangle {
                width: 60
                height: 60
                radius: 8
                color: Core.Theme.surface
                border.color: Core.Theme.divider
                border.width: 1

                Image {
                    id: lastPhotoThumbnail
                    anchors.fill: parent
                    anchors.margins: 2
                    fillMode: Image.PreserveAspectCrop
                    source: lastPhotoUrl
                    visible: lastPhotoUrl !== ""
                }

                Text {
                    anchors.centerIn: parent
                    text: "🖼️"
                    font.pixelSize: 24
                    visible: lastPhotoUrl === ""
                    opacity: 0.5
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Navigate to Gallery
                        var shell = camera.parent
                        while (shell && !shell.hasOwnProperty("navigateTo")) {
                            shell = shell.parent
                        }
                        if (shell && shell.navigateTo) {
                            shell.navigateTo("Gallery")
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Shutter button
            Rectangle {
                id: shutterButton
                width: 80
                height: 80
                radius: 40
                color: isCapturing ? Core.Theme.disabled : "white"
                border.color: Core.Theme.primary
                border.width: 4

                // Inner circle
                Rectangle {
                    anchors.centerIn: parent
                    width: 60
                    height: 60
                    radius: 30
                    color: parent.color
                    border.color: "#ccc"
                    border.width: 2
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: isReady && !isCapturing
                    onClicked: {
                        capturePhoto()
                    }
                }

                // Capturing indicator
                BusyIndicator {
                    anchors.centerIn: parent
                    running: isCapturing
                    visible: isCapturing
                    width: 40
                    height: 40
                }

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }

            Item { Layout.fillWidth: true }

            // Placeholder for symmetry (settings button future)
            Rectangle {
                width: 60
                height: 60
                color: "transparent"
            }
        }
    }

    // Toast notification
    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: bottomBar.top
        anchors.bottomMargin: Core.Theme.spacingMedium
        width: toastText.implicitWidth + Core.Theme.spacingLarge
        height: 40
        radius: 20
        color: Qt.rgba(0, 0, 0, 0.8)
        visible: opacity > 0
        opacity: 0
        z: 20

        Text {
            id: toastText
            anchors.centerIn: parent
            text: toastMessage
            color: "white"
            font.pixelSize: 14
        }

        SequentialAnimation {
            id: toastAnimation
            PropertyAnimation {
                target: toast
                property: "opacity"
                to: 1
                duration: 200
            }
            PauseAnimation { duration: 2000 }
            PropertyAnimation {
                target: toast
                property: "opacity"
                to: 0
                duration: 300
            }
        }
    }

    // Capture handlers
    function capturePhoto() {
        if (CameraBridge && isReady && !isCapturing) {
            captureAnimation.start()
            CameraBridge.capture()
        }
    }

    function showToast(message) {
        toastMessage = message
        toastAnimation.restart()
    }

    // Connect to CameraBridge signals
    Connections {
        target: CameraBridge

        function onCaptureCompleted(photoId) {
            showToast("✓ Photo saved")
            updateLastPhotoUrl()
        }

        function onCaptureFailed(error) {
            showToast("✗ " + error)
        }

        function onPhotosChanged() {
            updateLastPhotoUrl()
        }
    }

    function updateLastPhotoUrl() {
        if (CameraBridge) {
            lastPhotoUrl = CameraBridge.getLastPhotoUrl()
        }
    }

    // Refresh on visible
    Component.onCompleted: {
        if (CameraBridge) {
            CameraBridge.refreshStatus()
            CameraBridge.refreshPhotos()
            updateLastPhotoUrl()
        }
    }

    // Periodic status refresh
    Timer {
        interval: 5000
        running: camera.visible
        repeat: true
        onTriggered: {
            if (CameraBridge) {
                CameraBridge.refreshStatus()
            }
        }
    }
}
