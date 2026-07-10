import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../components/wifi" 

PanelWindow {
    id: wifiPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: 40; right: root.wifiVisible ? 6 : -350 }
    implicitHeight: 420
    implicitWidth: 320
    color: "transparent"
    
    // Переменная для хранения SSID, к которому вводим пароль (локальная для панели)
    property string passwordSSID: ""
    property bool isEnterprise: false
    
    WlrLayershell.keyboardFocus: passwordSSID !== "" ? WlrKeyboardFocus.Exclusive : (root.wifiVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None)
    
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    Shortcut {
        sequence: "Escape"
        enabled: root.wifiVisible
        onActivated: {
            if (passwordSSID !== "") {
                passwordSSID = ""
                wifiPanel.forceActiveFocus() 
            } else {
                root.wifiVisible = false
            }
        }
    }

    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.7)
            radius: 20

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // --- ШАПКА WI-FI ---
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "󰤨"
                        color: root.walColor5
                        font.pixelSize: 22
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: "Wi-Fi"
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
                        color: netService.wifiEnabled ? root.walColor5 : Qt.rgba(0.3, 0.3, 0.3, 0.5)
                        Behavior on color { ColorAnimation { duration: 200 } }
                        
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            y: 2
                            // ИСПРАВЛЕНО: Берем состояние из сервиса
                            x: netService.wifiEnabled ? 22 : 2
                            color: root.walBackground
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            // ИСПРАВЛЕНО: Вызываем функцию сервиса
                            onClicked: netService.toggleWifiAdapter()
                        }
                    }
                }

                // --- ТЕКУЩЕЕ ПОДКЛЮЧЕНИЕ ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 12
                    color: Qt.rgba(0, 0, 0, 0.3)
                    // ИСПРАВЛЕНО
                    visible: netService.wifiCurrentSSID !== ""
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        Text {
                            text: netService.wifiSignal > 66 ? "󰤨" : netService.wifiSignal > 33 ? "󰤥" : "󰤟"
                            color: root.walColor2
                            font.pixelSize: 18
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: netService.wifiCurrentSSID
                                color: root.walColor2
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "Connected · " + netService.wifiSignal + "%"
                                color: root.walColor8
                                font.pixelSize: 10
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 8
                            color: wifiDiscMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: root.walColor1
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            MouseArea {
                                id: wifiDiscMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                // ИСПРАВЛЕНО
                                onClicked: netService.disconnectWifi()
                            }
                        }
                    }
                }

                // --- ПОЛЕ ВВОДА ПАРОЛЯ (Компонент) ---
                WifiPasswordInput {
                    id: passwordField
                    targetSSID: wifiPanel.passwordSSID
                    walColor5: root.walColor5
                    walColor8: root.walColor8
                    walForeground: root.walForeground
                    walBackground: root.walBackground
                    
                    onSubmitCredentials: (login, password) => {
                        if (wifiPanel.isEnterprise){
                            netService.connectEnterpriseWifi(wifiPanel.passwordSSID, login, password)
                        }else{
                        netService.connectWifi(wifiPanel.passwordSSID, password)
                        wifiPanel.passwordSSID = ""
                        wifiPanel.forceActiveFocus()
                    }
                    }
                }

                // --- ЗАГОЛОВОК СПИСКА СЕТЕЙ И КНОПКА ОБНОВЛЕНИЯ ---
                RowLayout {
                    Layout.fillWidth: true
                    visible: netService.wifiEnabled
                    Text {
                        text: "Available Networks"
                        color: root.walColor8
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 6
                        color: wifiRefreshMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        Text {
                            anchors.centerIn: parent
                            // ИСПРАВЛЕНО
                            text: netService.wifiScanning ? "󰑓" : "󰑐"
                            color: root.walColor8
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                            transformOrigin: Item.Center
                            
                            RotationAnimation on rotation {
                                from: 0; to: 360
                                duration: 1000
                                loops: Animation.Infinite
                                // ИСПРАВЛЕНО
                                running: netService.wifiScanning
                            }
                        }
                        MouseArea {
                            id: wifiRefreshMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // ИСПРАВЛЕНО
                                if (!netService.wifiScanning) netService.refreshWifi()
                            }
                        }
                    }
                }

                // --- БЛОК СПИСКА СЕТЕЙ И ЭКРАНА ЗАГРУЗКИ ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 12
                    clip: true
                    
                    ListView {
                        id: networkList
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4
                        boundsBehavior: Flickable.StopAtBounds
                        // Модель берется из сервиса
                        model: netService.wifiNetworks
                        
                        opacity: netService.wifiConnecting ? 0.0 : 1.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        visible: opacity > 0
                        
                        delegate: NetworkDelegate {
                            netData: modelData
                            walColor5: root.walColor5
                            walColor8: root.walColor8
                            walForeground: root.walForeground
                            
                            onRequirePassword: (ssid) => {
                                // ИСПРАВЛЕНО: Сохраняем локально, а не в root
                                wifiPanel.passwordSSID = ssid
                                focusTimer.start()
                            }
                            
                            onConnectDirectly: (ssid) => {
                                // ИСПРАВЛЕНО: Вызываем функцию сервиса (пароль пустой)
                                netService.connectWifi(ssid, "")
                            }
                        }
                        ScrollBar.vertical: ScrollBar { active: true; width: 4 }
                    }

                    // --- ЭКРАН ЗАГРУЗКИ ---
                    Item {
                        anchors.fill: parent
                        // ИСПРАВЛЕНО
                        visible: netService.wifiConnecting
                        opacity: netService.wifiConnecting ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        MouseArea { anchors.fill: parent; hoverEnabled: true }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                text: "󰑓" 
                                color: root.walColor5
                                font.pixelSize: 36
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.alignment: Qt.AlignHCenter
                                transformOrigin: Item.Center 

                                RotationAnimation on rotation {
                                    from: 0; to: 360
                                    duration: 1200
                                    loops: Animation.Infinite
                                    // ИСПРАВЛЕНО
                                    running: netService.wifiConnecting 
                                }
                            }

                            Text {
                                text: "Connecting..."
                                color: root.walForeground
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Please wait"
                                color: root.walColor8
                                font.pixelSize: 11
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        // ИСПРАВЛЕНО
                        visible: netService.wifiNetworks.length === 0 && !netService.wifiScanning && !netService.wifiConnecting
                        text: netService.wifiEnabled ? "No networks found" : "Wi-Fi is off"
                        color: root.walColor8
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        // ИСПРАВЛЕНО
                        visible: netService.wifiScanning && !netService.wifiConnecting 
                        text: "Scanning..."
                        color: root.walColor8
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: passwordField.forceInputFocus() 
    }
}