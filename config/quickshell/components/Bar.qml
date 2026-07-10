import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// Подключаем наши папки с компонентами
import "../components/core"
import "../components/bar"

PanelWindow {
    id: bar
    visible: true
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.namespace: "quickshell"
    
    // Left Anchors for Vertical Bar
    anchors { left: true; top: true; bottom: true }
    margins { top: 12; bottom: 12; left: 12 }
    implicitWidth: 46
    color: "transparent"

    Item {
        anchors.fill: parent

        // Floating Vertical Slab Background
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, root.theme.panelOpacity)
            radius: root.theme.panelRadius
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, root.theme.borderOpacity)
        }

        // Vertical Layout Stacking
        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            spacing: 12

            // Top section: Launcher & Workspaces
            Column {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8
                LauncherWidget {}
                WallpaperWidget {}
                WorkspacesWidget {}
            }

            // Center Spacer/Media section
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                
                MediaWidget {
                    anchors.centerIn: parent
                }
            }

            // Bottom section: System Status & Clock
            Column {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8
                
                SystemWidget {}
                ClockWidget {}
            }
        }
    }
}