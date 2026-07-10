import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// Подключаем наши папки с компонентами
import "../components/dashboard"

PanelWindow {
    id: dashboard
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { bottom: true; left: true }
    margins { bottom: root.dashboardVisible ? 12 : -800; left: 70 }
    implicitWidth: 420
    implicitHeight: 600
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.dashboardVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    Behavior on margins.bottom { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Item {
        anchors.fill: parent
        focus: root.dashboardVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                // Вызываем сигнал из нашего виджета профиля, чтобы закрыть галерею
                profileWidget.closePicker() 
                if (!profileWidget.pfpPickerOpen) {
                    root.dashboardVisible = false
                }
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 0

            // Если открыта галерея аватарок - клик мимо неё закроет её
            MouseArea {
                anchors.fill: parent
                visible: profileWidget.pfpPickerOpen
                onClicked: profileWidget.closePicker()
                z: 50
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 18
                z: 100

                // 1. Профиль, Имя, Аватарка
                ProfileWidget {
                    id: profileWidget
                }

                // 2. Кнопки выключения
                PowerMenuWidget {}

                // 3. Батарея
                BatteryWidget {}

                // 4. Загрузка ЦП, ОЗУ, Диска
                SystemStatsWidget {}

                // 5. Часы и Дата
                DashboardClockWidget {}
            }
        }
    }

    // --- Фокус Wayland (Без изменений) ---
    Connections {
        target: root
        function onDashboardVisibleChanged() {
            if (root.dashboardVisible) focusTimer.start()
        }
    }

    Timer {
        id: focusTimer; interval: 50; repeat: false
        onTriggered: { dashboard.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive; releaseTimer.start() }
    }

    Timer {
        id: releaseTimer; interval: 100; repeat: false
        onTriggered: { dashboard.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand }
    }
}