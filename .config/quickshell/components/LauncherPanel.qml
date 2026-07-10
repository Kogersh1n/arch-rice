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
    anchors { top: true; bottom: true; left: true }
    margins { top: 40; bottom: 10; left: root.launcherVisible ? 6 : -450 }
    implicitWidth: 420
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.launcherVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.left { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        color:{
            let c = wallService.walBackground;
            if (!c || typeof c.r === 'undefined') return Qt.rgba(0.1, 0.1, 0.1, 0.7); // Темный дефолт
            return Qt.rgba(c.r, c.g, c.b, 0.7);
        }
        radius: 20

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // --- 1. Кнопки вкладок ---
            TabButtons {
                onFocusApps: if (appsLoader.item) appsLoader.item.focusSearch()
                onFocusWalls: if (wallsLoader.item) wallsLoader.item.focusSearch()
            }

            // --- 2. Контент ---
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Loader {
                    id: appsLoader
                    anchors.fill: parent
                    active: root.activeTab === 0
                    asynchronous: true

                    onLoaded: if (root.activeTab === 0 && root.launcherVisible) item.focusSearch()
                    
                    sourceComponent: Component {
                        AppsTab {
                            onSwitchToWalls: {
                                root.activeTab = 1
                                if (!wallService.wallsLoaded) wallService.load()
                            }
                            onCloseLauncher: root.launcherVisible = false
                        }
                    }
                }

                Loader {
                    id: wallsLoader
                    anchors.fill: parent
                    active: root.activeTab === 1
                    asynchronous: true
                    
                    onLoaded: if (root.activeTab === 0 && root.launcherVisible) item.focusSearch()

                    sourceComponent: Component {
                        WallsTab {
                            onSwitchToApps: {
                                root.activeTab = 0
                            }
                            onCloseLauncher: root.launcherVisible = false
                        }
                    }
                }
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
                root.wallSelectedIndex = 0
                
                focusDelayTimer.start()
            } else {
                if (appsLoader.item) {
                    appsLoader.item.clearSearch()
                    appsLoader.item.removeFocus()
                }
                if (wallsLoader.item) {
                    wallsLoader.item.clearSearch()
                    wallsLoader.item.removeFocus()
                }
            }
        }
        function onWallSelectedIndexChanged() {
            if (root.activeTab === 1 && wallsLoader.item) wallsLoader.item.positionView(root.wallSelectedIndex)
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
            if (root.activeTab === 0 && appsLoader.item) {
                appsLoader.item.focusSearch()
            } else if (root.activeTab === 1) {
                // ИСПРАВЛЕНО: вызываем сервис вместо root
                if (!wallService.wallsLoaded) wallService.load() 
                if (wallsLoader.item) wallsLoader.item.focusSearch()
            }
            launcherPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }
}