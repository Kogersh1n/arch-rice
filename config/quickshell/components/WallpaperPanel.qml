import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "../components/launcher"

PanelWindow {
    id: wallpaperPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { bottom: true; left: true }
    margins { bottom: root.wallpaperVisible ? 12 : -800; left: 70 }
    implicitWidth: 420
    implicitHeight: 600
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.wallpaperVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.bottom { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        color: {
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

            WallsTab {
                id: wallsTab
                Layout.fillWidth: true
                Layout.fillHeight: true
                onSwitchToApps: {
                    root.wallpaperVisible = false
                    root.toggleLauncher()
                }
                onCloseLauncher: root.wallpaperVisible = false
            }
        }
    }

    // --- Логика Wayland-фокуса и обновления состояний ---
    Connections {
        target: root
        function onWallpaperVisibleChanged() {
            if (root.wallpaperVisible) {
                if (!wallService.wallsLoaded) wallService.load()
                root.wallSelectedIndex = 0
                focusDelayTimer.start()
            } else {
                wallsTab.clearSearch()
                wallsTab.removeFocus()
            }
        }
        function onWallSelectedIndexChanged() {
            if (root.wallpaperVisible) wallsTab.positionView(root.wallSelectedIndex)
        }
    }

    Timer {
        id: focusDelayTimer
        interval: 50
        repeat: false
        onTriggered: { 
            wallpaperPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            exclusiveReleaseTimer.start() 
        }
    }

    Timer {
        id: exclusiveReleaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            wallsTab.focusSearch()
            wallpaperPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }
}
