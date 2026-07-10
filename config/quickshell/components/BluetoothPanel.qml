import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../components/bluetooth" 

PanelWindow {
    id: btPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: 40; right: root.btVisible ? 6 : -350 }
    implicitHeight: 460
    implicitWidth: 320
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.btVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    Item {
        anchors.fill: parent
        focus: root.btVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.btVisible = false
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            // Безопасный вызов цвета
            color: {
                let c = root.walBackground;
                if (!c || typeof c.r === 'undefined') return Qt.rgba(0.1, 0.1, 0.1, 0.7);
                return Qt.rgba(c.r, c.g, c.b, 0.7);
            }
            radius: 20

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // --- ШАПКА BLUETOOTH ---
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "󰂯"
                        color: root.walColor5
                        font.pixelSize: 22
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: "Bluetooth"
                        color: root.walColor5
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 44
                        height: 24
                        radius: 12
                        // ИСПРАВЛЕНО: Берем состояние из сервиса
                        color: netService.btEnabled ? root.walColor5 : Qt.rgba(0.3, 0.3, 0.3, 0.5)
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            y: 2
                            // ИСПРАВЛЕНО: Берем состояние из сервиса
                            x: netService.btEnabled ? 22 : 2
                            color: root.walBackground
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // ИСПРАВЛЕНО: Вызываем функцию сервиса
                                netService.toggleBtAdapter()
                            }
                        }
                    }
                }

                // --- СПИСОК СОПРЯЖЕННЫХ УСТРОЙСТВ ---
                Text {
                    text: "Paired Devices"
                    color: root.walColor8
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                    visible: netService.btEnabled
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 12
                    clip: true
                    visible: netService.btEnabled
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4
                        boundsBehavior: Flickable.StopAtBounds
                        // ИСПРАВЛЕНО: Модель из сервиса
                        model: netService.btPairedDevices
                        
                        delegate: PairedDeviceDelegate {
                            devData: modelData
                            // ИСПРАВЛЕНО
                            connectingMac: netService.btConnectingMAC
                            walColor1: root.walColor1
                            walColor2: root.walColor2
                            walColor5: root.walColor5
                            walColor8: root.walColor8
                            walForeground: root.walForeground
                            
                            onToggleConnection: (mac, isConnected) => {
                                // ИСПРАВЛЕНО
                                if (isConnected) netService.disconnectBt(mac)
                                else netService.connectBt(mac)
                            }
                            
                            onForgetDevice: (mac) => {
                                // ИСПРАВЛЕНО
                                netService.forgetBt(mac)
                            }
                        }
                        ScrollBar.vertical: ScrollBar { active: true; width: 4 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        // ИСПРАВЛЕНО
                        visible: netService.btPairedDevices.length === 0
                        text: "No paired devices"
                        color: root.walColor8
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                // --- КНОПКА СКАНИРОВАНИЯ ---
                RowLayout {
                    Layout.fillWidth: true
                    visible: netService.btEnabled
                    Text {
                        text: "Available Devices"
                        color: root.walColor8
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 60
                        height: 24
                        radius: 6
                        color: btScanBtnMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.2) : Qt.rgba(0, 0, 0, 0.3)
                        Text {
                            anchors.centerIn: parent
                            // ИСПРАВЛЕНО
                            text: netService.btScanning ? "Scanning" : "Scan"
                            color: root.walColor5
                            font.pixelSize: 10
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea {
                            id: btScanBtnMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // ИСПРАВЛЕНО: Вызов сканирования теперь через сервис
                                if (!netService.btScanning) {
                                    netService.btScanning = true
                                    netService.btAvailableDevices = []
                                    // Чтобы это сработало, нам нужно добавить функцию startScan в сервис
                                    netService.startBluetoothScan() 
                                }
                            }
                        }
                    }
                }

                // --- СПИСОК ДОСТУПНЫХ УСТРОЙСТВ ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 12
                    clip: true
                    visible: netService.btEnabled
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4
                        boundsBehavior: Flickable.StopAtBounds
                        // ИСПРАВЛЕНО: Модель из сервиса
                        model: netService.btAvailableDevices
                        
                        delegate: AvailableDeviceDelegate {
                            devData: modelData
                            // ИСПРАВЛЕНО
                            connectingMac: netService.btConnectingMAC
                            walColor8: root.walColor8
                            walForeground: root.walForeground
                            
                            onPairDevice: (mac) => {
                                // ИСПРАВЛЕНО
                                netService.pairBt(mac)
                            }
                        }
                        ScrollBar.vertical: ScrollBar { active: true; width: 4 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        // ИСПРАВЛЕНО
                        visible: netService.btAvailableDevices.length === 0 && !netService.btScanning
                        text: "Press Scan to find devices"
                        color: root.walColor8
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        anchors.centerIn: parent
                        // ИСПРАВЛЕНО
                        visible: netService.btScanning
                        text: "Scanning..."
                        color: root.walColor8
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                // --- ЭКРАН ВЫКЛЮЧЕННОГО BLUETOOTH ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    // ИСПРАВЛЕНО
                    visible: !netService.btEnabled
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "Bluetooth is off"
                        color: root.walColor8
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onBtVisibleChanged() {
            if (root.btVisible) {
                focusTimer.start()
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            btPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            btPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }
}