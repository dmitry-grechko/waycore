import QtQuick 2.15
import ".." as Core

/**
 * MaterialIcon - Material Design Icons component
 *
 * Uses Material Design Icons (MDI) font with Unicode codepoints.
 * Icons are rendered in white by default, respecting the tactical theme.
 *
 * Usage:
 *   MaterialIcon {
 *       name: "flashlight"
 *       size: 32
 *       iconColor: Core.Theme.textPrimary
 *   }
 */
Text {
    id: icon

    property string name: ""
    property int size: Core.Theme.iconSizeMedium
    property color iconColor: Core.Theme.textPrimary

    // MDI icon codepoint mapping (hex values for String.fromCodePoint)
    readonly property var iconCodes: ({
        // Time & Schedule
        "schedule": 0xF0954,
        "clock": 0xF0954,
        "clock-outline": 0xF0150,

        // Battery
        "battery": 0xF0079,
        "battery_5_bar": 0xF0079,
        "battery-high": 0xF0079,
        "battery-medium": 0xF007A,
        "battery-low": 0xF007B,
        "battery-outline": 0xF007C,
        "battery-charging": 0xF0084,

        // Signal & Connectivity
        "signal": 0xF04A2,
        "signal_cellular_alt": 0xF04A2,
        "wifi": 0xF05A9,
        "wifi-off": 0xF05AA,
        "radio": 0xF043F,
        "radio-tower": 0xF1051,
        "access-point": 0xF0003,
        "broadcast": 0xF1720,
        "wifi_tethering": 0xF1051,

        // Navigation
        "map": 0xF034D,
        "map-marker": 0xF034E,
        "near_me": 0xF0176,
        "navigation": 0xF0390,
        "compass": 0xF018B,
        "explore": 0xF018B,
        "crosshairs-gps": 0xF0196,

        // Communication
        "message": 0xF035F,
        "chat": 0xF0368,
        "chat-bubble": 0xF0368,
        "forum": 0xF028E,
        "phone": 0xF03F2,

        // Medical
        "medical-bag": 0xF06EF,
        "first-aid": 0xF06EF,

        // Power & System
        "flashlight": 0xF0244,
        "flashlight_on": 0xF0244,
        "flashlight-off": 0xF0245,
        "torch": 0xF1606,
        "lightbulb": 0xF0335,
        "lightbulb-on": 0xF06E8,
        "lock": 0xF033E,
        "lock-open": 0xF033F,
        "lock-outline": 0xF0341,
        "power": 0xF0425,
        "power-off": 0xF0902,
        "power-standby": 0xF0906,
        "sleep": 0xF0904,
        "restart": 0xF0709,
        "shutdown": 0xF0425,

        // Settings & Config
        "settings": 0xF0493,
        "cog": 0xF0493,
        "cog-outline": 0xF08BB,
        "tune": 0xF062E,
        "wrench": 0xF0599,

        // Media
        "camera": 0xF0100,
        "photo_camera": 0xF0100,
        "camera-iris": 0xF0104,
        "shutter-speed": 0xF04A4,
        "image": 0xF02E9,
        "image-multiple": 0xF02EB,
        "image-broken": 0xF02ED,
        "image-broken-variant": 0xF02EE,
        "video": 0xF0568,
        "microphone": 0xF036C,

        // Files & Documents
        "file": 0xF0214,
        "folder": 0xF024B,
        "folder-open": 0xF0770,
        "note": 0xF039A,
        "edit_note": 0xF03EB,
        "text": 0xF09A8,

        // Text Formatting
        "format-bold": 0xF0264,
        "format-italic": 0xF0277,
        "format-underline": 0xF0287,
        "format-list-bulleted": 0xF0279,
        "format-list-numbered": 0xF027B,
        "format-quote-close": 0xF027E,
        "format-header-1": 0xF0270,
        "format-header-2": 0xF0271,
        "code-tags": 0xF0174,
        "link": 0xF0337,

        // AI & Smart
        "robot": 0xF06A9,
        "smart_toy": 0xF06A9,
        "brain": 0xF09F5,
        "chip": 0xF061A,

        // Messaging
        "message": 0xF0361,
        "message-text": 0xF0368,
        "message-text-outline": 0xF0369,
        "chat": 0xF0B79,
        "comment": 0xF017A,

        // Charts & Analytics
        "chart": 0xF0128,
        "analytics": 0xF0127,
        "chart-line": 0xF012C,
        "gauge": 0xF029A,

        // Actions
        "close": 0xF0156,
        "check": 0xF012C,
        "plus": 0xF0415,
        "minus": 0xF0374,
        "refresh": 0xF0450,
        "search": 0xF0349,
        "delete": 0xF01B4,
        "edit": 0xF03EB,
        "save": 0xF0193,
        "share": 0xF0496,
        "send": 0xF048A,
        "download": 0xF01DA,
        "upload": 0xF0552,
        "copy": 0xF018F,
        "menu": 0xF035C,
        "more-vert": 0xF01D9,
        "arrow-back": 0xF004D,
        "arrow-left": 0xF004D,
        "chevron-left": 0xF0141,
        "chevron-right": 0xF0142,

        // Status
        "information": 0xF02FC,
        "info": 0xF02FC,
        "alert": 0xF0026,
        "warning": 0xF0026,
        "error": 0xF0159,
        "help": 0xF02D6,
        "check-circle": 0xF05E0,

        // Misc
        "thermometer": 0xF050F,
        "device_thermostat": 0xF050F,
        "memory": 0xF035B,
        "cpu": 0xF0622,
        "satellite": 0xF0D4A,
        "satellite-variant": 0xF0470,
        "earth": 0xF01E7,
        "home": 0xF02DC,
        "account": 0xF0004,
        "star": 0xF04CE,
        "heart": 0xF02D1,
        "bookmark": 0xF00C0,
        "tag": 0xF04D3,
        "calendar": 0xF00ED,
        "timer": 0xF13AB,
        "alarm": 0xF0020,
        "history": 0xF02DA,
        "fingerprint": 0xF0237,

        // Compass & Navigation extras
        "flag": 0xF0229,
        "flag-outline": 0xF022A,
        "arrow-up": 0xF005D,
        "arrow-down": 0xF0045,
        "crosshairs": 0xF0195,
        "target": 0xF1720,
        "axis-arrow": 0xF0B21,
        "angle-acute": 0xF0937,
        "north": 0xF173F,
        "altitude": 0xF1DA0,

        // Brightness & Display
        "brightness-1": 0xF0D6A,
        "brightness-2": 0xF0D6B,
        "brightness-3": 0xF0D6C,
        "brightness-4": 0xF0D6D,
        "brightness-5": 0xF0D6E,
        "brightness-6": 0xF0D6F,
        "brightness-7": 0xF0D70,
        "brightness-low": 0xF0D6A,
        "brightness-high": 0xF0D70,
        "weather-sunny": 0xF0599,
        "weather-sunny-off": 0xF14E4,
        "white-balance-sunny": 0xF05A8,
        "circle-outline": 0xF0766,

        // Gaming & Controls
        "gamepad": 0xF0296,
        "gamepad-variant": 0xF0297,
        "controller": 0xF0296,

        // Audio & Devices
        "headphones": 0xF02CB,
        "headset": 0xF02CE,
        "speaker": 0xF04C3,
        "volume-high": 0xF057E,

        // Connectivity
        "bluetooth": 0xF00AF,
        "bluetooth-connect": 0xF00B1,
        "cellphone": 0xF011C,
        "phone-cellular": 0xF011C,

        // Wearables
        "watch": 0xF0589,
        "watch-variant": 0xF0588,

        // Storage & Hardware
        "harddisk": 0xF02CA,
        "sd": 0xF047F,
        "usb": 0xF0553,
        "ruler": 0xF141C,

        // Development & Console
        "console": 0xF018D,
        "terminal": 0xF0582,
        "code-braces": 0xF0170,

        // Health & Status
        "heart-pulse": 0xF05F6,
        "pulse": 0xF0412,
        "lightning-bolt": 0xF0357,
        "flash": 0xF0241,

        // Arrows & Direction
        "arrow-top-right": 0xF0054,
        "arrow-expand": 0xF0616,
        "chevron-up": 0xF0143,
        "chevron-down": 0xF0140,
        "arrow-up-bold": 0xF0053,

        // Mesh & Network
        "account-group": 0xF0849,
        "hub": 0xF0316,
        "sync": 0xF04E6,
        "check-all": 0xF012E,
        "alert-circle": 0xF0028,
        "clock-alert-outline": 0xF05CF,
        "pencil": 0xF03EB,
        "share-variant": 0xF0497,

        // Signal bars
        "signal-cellular-outline": 0xF08BE,
        "signal-cellular-1": 0xF08BC,
        "signal-cellular-2": 0xF08BD,
        "signal-cellular-3": 0xF08BE,

        // Stars
        "star-outline": 0xF04D2
    })

    // Convert codepoint to character using String.fromCodePoint
    function getIconChar(iconName) {
        var code = iconCodes[iconName]
        if (code !== undefined) {
            return String.fromCodePoint(code)
        }
        // Return question mark as fallback
        return String.fromCodePoint(0xF02D6)
    }

    text: getIconChar(name)
    color: iconColor
    font.family: materialFont.status === FontLoader.Ready ? materialFont.name : "sans-serif"
    font.pixelSize: size

    // Load Material Design Icons font
    FontLoader {
        id: materialFont
        source: typeof MaterialFontPath !== "undefined" && MaterialFontPath ? MaterialFontPath : ""

        onStatusChanged: {
            if (status === FontLoader.Ready) {
                console.log("MaterialIcon: MDI font loaded successfully")
            } else if (status === FontLoader.Error) {
                console.log("MaterialIcon: Font load error:", source)
            }
        }
    }

    // Fallback: show a placeholder box if font not loaded
    Rectangle {
        visible: materialFont.status !== FontLoader.Ready && icon.name !== ""
        anchors.centerIn: parent
        width: icon.size * 0.7
        height: icon.size * 0.7
        color: "transparent"
        border.color: icon.iconColor
        border.width: 1
        radius: 2
        opacity: 0.3
    }

    // Hide the raw codepoint character when font not loaded
    opacity: materialFont.status === FontLoader.Ready ? 1.0 : 0.0
}
