import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "../components/launcher"

PanelWindow {
    id: launcherPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { bottom: true; left: true }
    margins { bottom: root.launcherVisible ? 12 : -800; left: 70 }
    implicitWidth: 420
    implicitHeight: 600
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.launcherVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.bottom { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        color:{
            let c = wallService.walBackground;
            if (!c || typeof c.r === 'undefined') return Qt.rgba(0.1, 0.1, 0.1, root.theme.panelOpacity);
            return Qt.rgba(c.r, c.g, c.b, root.theme.panelOpacity);
        }
        radius: root.theme.panelRadius
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, root.theme.borderOpacity)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            AppsTab {
                id: appsTab
                Layout.fillWidth: true
                Layout.fillHeight: true
                onSwitchToWalls: {
                    root.launcherVisible = false
                    root.toggleWallpaper()
                }
                onCloseLauncher: root.launcherVisible = false
            }
        }
    }

    // --- Логика Wayland-фокуса и обновления состояний ---
    Connections {
        target: root
        function onLauncherVisibleChanged() {
            if (root.launcherVisible) {
                appService.load()
                root.selectedIndex = 0
                focusDelayTimer.start()
            } else {
                appsTab.clearSearch()
                appsTab.removeFocus()
            }
        }
    }

    Timer {
        id: focusDelayTimer
        interval: 50
        repeat: false
        onTriggered: { 
            launcherPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            exclusiveReleaseTimer.start() 
        }
    }

    Timer {
        id: exclusiveReleaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            appsTab.focusSearch()
            launcherPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }
}