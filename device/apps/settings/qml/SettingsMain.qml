import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Core as Core

/**
 * SettingsMain - Entry point for the Settings app
 *
 * Manages navigation between settings categories.
 */
Rectangle {
    id: root
    color: Core.Theme.background

    // Standard app interface
    signal closeRequested()
    property string appId: "com.waycore.settings"
    property string appTitle: "Settings"

    StackView {
        id: settingsStack
        anchors.fill: parent
        initialItem: categoriesComponent
    }

    Component {
        id: categoriesComponent
        SettingsCategories {
            onBackRequested: root.closeRequested()
            onCategorySelected: function(category) {
                openCategory(category)
            }
        }
    }

    Component {
        id: generalComponent
        SettingsGeneral {
            onBackRequested: settingsStack.pop()
            onNavigateHome: {
                settingsStack.pop(null)
                root.closeRequested()
            }
        }
    }

    Component {
        id: controlsComponent
        SettingsControls {
            onBackRequested: settingsStack.pop()
        }
    }

    Component {
        id: sensorsComponent
        SettingsSensors {
            onBackRequested: settingsStack.pop()
        }
    }

    Component {
        id: infoComponent
        SettingsInfo {
            onBackRequested: settingsStack.pop()
        }
    }

    function openCategory(category) {
        switch(category) {
            case "general":
                settingsStack.push(generalComponent)
                break
            case "controls":
                settingsStack.push(controlsComponent)
                break
            case "sensors":
                settingsStack.push(sensorsComponent)
                break
            case "info":
                settingsStack.push(infoComponent)
                break
        }
    }
}
