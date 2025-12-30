pragma Singleton
import QtQuick 2.15

QtObject {
    id: theme

    // === MODE TOGGLE ===
    property bool daylightMode: false

    // === TACTICAL COLOR PALETTE ===
    // Inspired by military/tactical HUD interfaces

    // Primary Colors (Tactical Green)
    readonly property color primary: "#2c583c"           // Main green accent
    readonly property color primaryDark: "#1B3D2F"       // Darker tactical card background
    readonly property color primaryLight: "#3D5A4D"      // Lighter green for hover states
    readonly property color primaryAccent: "#5C7A65"     // Muted green accent

    // Background colors (OLED-optimized tactical black)
    readonly property color background: daylightMode ? "#F8FAF9" : "#0A0F0A"
    readonly property color backgroundAlt: daylightMode ? "#E8EFEB" : "#0D120D"

    // Tactical Surface colors
    readonly property color tacticalCard: daylightMode ? "#FFFFFF" : "#121A14"     // Dark card background (tactical-card)
    readonly property color surface: daylightMode ? "#FFFFFF" : "#1B3D2F"          // tactical-card-highlight
    readonly property color surfaceElevated: daylightMode ? "#F0F5F2" : "#243D32"  // Slightly elevated
    readonly property color surfaceHighlight: daylightMode ? "#D4E4DA" : "#2D5A3D" // Active/highlighted

    // Border and divider (tactical-border)
    readonly property color divider: daylightMode ? "#D0DCD4" : "#2D5A3D"
    readonly property color border: daylightMode ? "#C0CCC4" : "#2D5A3D"

    // Semantic Colors (high contrast for outdoor visibility)
    readonly property color success: daylightMode ? "#16A34A" : "#4ADE80"
    readonly property color warning: daylightMode ? "#D97706" : "#D4A574"   // tactical-warning (tan)
    readonly property color error: daylightMode ? "#DC2626" : "#C97064"
    readonly property color emergency: daylightMode ? "#B91C1C" : "#DC2626"
    readonly property color info: daylightMode ? "#2563EB" : "#60A5FA"

    // Accent colors
    readonly property color accent: daylightMode ? "#2D5A3E" : "#2c583c"
    readonly property color accentLight: daylightMode ? "#3D7A54" : "#3D5A4D"

    // Text Colors (tactical style)
    readonly property color textPrimary: daylightMode ? "#0A0F0C" : "#FFFFFF"
    readonly property color textSecondary: daylightMode ? "#3A453E" : "#a5b1a9"    // tactical-text
    readonly property color textTertiary: daylightMode ? "#6A756E" : "#7B8B7F"
    readonly property color textDisabled: daylightMode ? "#8A958E" : "#6B7B6F"
    readonly property color textInverse: daylightMode ? "#FFFFFF" : "#0A0F0A"
    readonly property color textMono: daylightMode ? "#4A5A4E" : "#8B9B8F"         // For monospace/coordinates

    // Disabled state
    readonly property color disabled: daylightMode ? "#C5D0C9" : "#4A5A50"

    // Status indicator colors
    readonly property color statusActive: "#2c583c"      // Pulsing green dot
    readonly property color statusInactive: "#2D5A3D"    // Inactive dot

    // === TYPOGRAPHY ===
    // Tactical fonts - Space Grotesk for display, monospace for data
    readonly property string fontFamily: "Space Grotesk, system-ui, -apple-system, sans-serif"
    readonly property string fontFamilyMono: "SF Mono, Monaco, Cascadia Code, Roboto Mono, monospace"
    readonly property int fontWeightNormal: Font.Medium
    readonly property int fontWeightBold: Font.Bold
    readonly property int fontWeightHeavy: Font.ExtraBold

    readonly property int h1Size: 32
    readonly property int h2Size: 24
    readonly property int h3Size: 20
    readonly property int bodySize: 16
    readonly property int bodySmallSize: 14
    readonly property int smallSize: 12
    readonly property int captionSize: 12
    readonly property int labelSize: 11        // ALL CAPS labels
    readonly property int tinySize: 10         // Secure mode badge, etc.

    // Letter spacing for tactical look
    readonly property real letterSpacingWide: 2      // For WAYCORE title
    readonly property real letterSpacingNormal: 1    // For labels
    readonly property real letterSpacingMono: 0.5    // For coordinates

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
    readonly property int touchTarget: 48
    readonly property int touchTargetLarge: 64
    readonly property int touchTargetXL: 80

    readonly property int appBarHeight: 56
    readonly property int statusBarHeight: 80        // Tactical status HUD
    readonly property int quickActionHeight: 88      // Quick action dock
    readonly property int buttonHeight: 56
    readonly property int inputHeight: 56

    readonly property int appTileSize: 120
    readonly property int iconSizeSmall: 20
    readonly property int iconSizeMedium: 24
    readonly property int iconSizeLarge: 32
    readonly property int iconSizeXL: 48

    readonly property int borderRadius: 4            // Tactical - less rounded
    readonly property int borderRadiusLarge: 8

    // Grid pattern (for background)
    readonly property int gridSize: 40

    // === ANIMATION (Minimal for power saving) ===
    readonly property int animationFast: 100
    readonly property int animationNormal: 200
    readonly property int animationSlow: 300

    // === PULSE ANIMATION ===
    readonly property int pulseInterval: 1000

    // === THEME TOGGLE FUNCTION ===
    function toggleDaylightMode() {
        daylightMode = !daylightMode
    }
}
