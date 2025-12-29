pragma Singleton
import QtQuick 2.15

QtObject {
    id: theme

    // === MODE TOGGLE ===
    property bool daylightMode: false

    // === OLED-OPTIMIZED COLOR PALETTE ===
    // Pure black background saves power on OLED displays

    // Primary Colors (Dark Green)
    readonly property color primary: "#2B3D33"
    readonly property color primaryDark: "#1F2D26"
    readonly property color primaryLight: "#3D5447"
    readonly property color primaryAccent: "#5C7A65"

    // Background colors (computed based on mode)
    readonly property color background: daylightMode ? "#F8FAF9" : "#000000"
    readonly property color backgroundAlt: daylightMode ? "#E8EFEB" : "#0A0D0B"

    // Surface colors
    readonly property color surface: daylightMode ? "#FFFFFF" : "#1A1F1C"
    readonly property color surfaceElevated: daylightMode ? "#F0F5F2" : "#252B27"
    readonly property color surfaceHighlight: daylightMode ? "#D4E4DA" : "#2B3D33"

    // Divider and borders
    readonly property color divider: daylightMode ? "#D0DCD4" : "#2A352F"

    // Semantic Colors (high contrast for outdoor visibility)
    readonly property color success: daylightMode ? "#16A34A" : "#4ADE80"
    readonly property color warning: daylightMode ? "#D97706" : "#FBBF24"
    readonly property color error: daylightMode ? "#DC2626" : "#F87171"
    readonly property color emergency: daylightMode ? "#B91C1C" : "#DC2626"
    readonly property color info: daylightMode ? "#2563EB" : "#60A5FA"

    // Accent colors
    readonly property color accent: daylightMode ? "#2D5A3E" : "#7A9984"
    readonly property color accentLight: daylightMode ? "#3D7A54" : "#9CB5A3"

    // Text Colors (high contrast)
    readonly property color textPrimary: daylightMode ? "#0A0F0C" : "#FFFFFF"
    readonly property color textSecondary: daylightMode ? "#3A453E" : "#A3B8A8"
    readonly property color textTertiary: daylightMode ? "#6A756E" : "#7B8B7F"
    readonly property color textDisabled: daylightMode ? "#8A958E" : "#6B7B6F"
    readonly property color textInverse: daylightMode ? "#FFFFFF" : "#000000"

    // Disabled state
    readonly property color disabled: daylightMode ? "#C5D0C9" : "#4A5A50"

    // === TYPOGRAPHY ===
    // Heavy weights for outdoor readability
    readonly property string fontFamily: "system-ui, -apple-system, sans-serif"
    readonly property int fontWeightNormal: Font.Medium
    readonly property int fontWeightBold: Font.Bold
    readonly property int fontWeightHeavy: Font.ExtraBold

    readonly property int h1Size: 32
    readonly property int h2Size: 24
    readonly property int h3Size: 20
    readonly property int bodySize: 16      // Increased from 14 for readability
    readonly property int bodySmallSize: 14
    readonly property int smallSize: 12     // Alias for captionSize
    readonly property int captionSize: 12
    readonly property int labelSize: 11     // ALL CAPS labels

    // === SPACING (8dp grid) ===
    readonly property int spacingXS: 4
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24
    readonly property int spacingXL: 32
    readonly property int spacingXXL: 48

    // Legacy alias for compatibility
    readonly property int spacingExtraSmall: spacingXS

    // === DIMENSIONS ===
    // Touch targets sized for gloved use
    readonly property int touchTargetSmall: 36
    readonly property int touchTargetMin: 48
    readonly property int touchTarget: 48     // Alias for touchTargetMin
    readonly property int touchTargetLarge: 64
    readonly property int touchTargetXL: 80

    readonly property int appBarHeight: 56
    readonly property int statusBarHeight: 64
    readonly property int quickActionHeight: 96
    readonly property int buttonHeight: 56      // Increased for gloves
    readonly property int inputHeight: 56

    readonly property int appTileSize: 120      // Large touch targets for home grid
    readonly property int iconSizeSmall: 20
    readonly property int iconSizeMedium: 24
    readonly property int iconSizeLarge: 32
    readonly property int iconSizeXL: 48

    readonly property int borderRadius: 8
    readonly property int borderRadiusLarge: 12

    // === ANIMATION (Minimal for power saving) ===
    readonly property int animationFast: 100
    readonly property int animationNormal: 200
    readonly property int animationSlow: 300

    // === THEME TOGGLE FUNCTION ===
    function toggleDaylightMode() {
        daylightMode = !daylightMode
    }
}
