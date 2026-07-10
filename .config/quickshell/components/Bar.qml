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
    // exclusionMode: Quickshell.Exclusive
    WlrLayershell.layer: WlrLayershell.Top // Было WlrLayer.Top
    WlrLayershell.namespace: "quickshell"
    anchors { top: true; left: true; right: true }
    margins { top: 0; left: 0; right: 0 }
    implicitHeight: 32
    color: "transparent"

    Item {
        anchors.fill: parent

        // ЛЕВАЯ ЧАСТЬ (Меню, Часы, Воркспейсы)
        Row {
            id: leftSection
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 8
            height: 32 // notchHeight
            spacing: 6

            LauncherWidget {}
            ClockWidget {}
            WorkspacesWidget {}
        }

        // ЦЕНТРАЛЬНАЯ ЧАСТЬ (Медиа)
        MediaWidget {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
        }

        // ПРАВАЯ ЧАСТЬ (Система)
        Row {
            id: rightSection
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 8
            height: 32 // notchHeight
            spacing: 6

            SystemWidget {}
        }
    }
}