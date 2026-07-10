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
    
    property string passwordSSID: ""
    property bool isEnterprise: false
    
    WlrLayershell.keyboardFocus: passwordSSID !== "" ? WlrKeyboardFocus.Exclusive : (root.wifiVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None)
    
    Behavior on margins.right { NumberAnimation { duration: 320; easing.type: Easing.OutExpo } }

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

        // Main glassmorphic container
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.75)
            radius: 18
            border.width: 1
            border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.25)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // --- HEADER WI-FI ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: "󰤨"
                        color: root.walColor5
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: "Wi-Fi"
                        color: root.walColor5
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Custom Material Toggle Switch
                    Rectangle {
                        id: toggleTrack
                        width: 42
                        height: 22
                        radius: 11
                        color: netService.wifiEnabled ? root.walColor5 : Qt.rgba(1, 1, 1, 0.15)
                        border.width: 1
                        border.color: netService.wifiEnabled ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.1)
                        
                        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutQuad } }
                        
                        Rectangle {
                            id: toggleThumb
                            width: toggleMouseArea.pressed ? 20 : 16
                            height: 16
                            radius: 8
                            y: 2
                            x: netService.wifiEnabled ? (parent.width - width - 3) : 3
                            color: netService.wifiEnabled ? root.walBackground : root.walForeground
                            
                            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                            Behavior on width { NumberAnimation { duration: 150 } }
                        }
                        
                        MouseArea {
                            id: toggleMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: netService.toggleWifiAdapter()
                        }
                    }
                }

                // --- ACTIVE CONNECTION ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: 12
                    color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.1)
                    border.width: 1
                    border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.25)
                    visible: netService.wifiCurrentSSID !== ""
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        Text {
                            text: {
                                if (netService.wifiSignal > 75) return "󰤨"
                                if (netService.wifiSignal > 50) return "󰤥"
                                if (netService.wifiSignal > 25) return "󰤢"
                                return "󰤟"
                            }
                            color: root.walColor2
                            font.pixelSize: 17
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            
                            Text {
                                text: netService.wifiCurrentSSID
                                color: root.walColor2
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "Connected · " + netService.wifiSignal + "%"
                                color: root.walColor8
                                font.pixelSize: 9
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                        
                        // Disconnect Button
                        Rectangle {
                            width: 26
                            height: 26
                            radius: 8
                            color: wifiDiscMa.containsMouse ? Qt.rgba(root.walColor1.r, root.walColor1.g, root.walColor1.b, 0.2) : "transparent"
                            
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: wifiDiscMa.containsMouse ? root.walColor1 : root.walColor8
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                                
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            MouseArea {
                                id: wifiDiscMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: netService.disconnectWifi()
                            }
                        }
                    }
                }

                // --- PASSWORD ENTRY FIELD ---
                WifiPasswordInput {
                    id: passwordField
                    targetSSID: wifiPanel.passwordSSID
                    isEnterprise: wifiPanel.isEnterprise
                    walColor5: root.walColor5
                    walColor8: root.walColor8
                    walForeground: root.walForeground
                    walBackground: root.walBackground
                    
                    onSubmitCredentials: (login, password) => {
                        if (wifiPanel.isEnterprise) {
                            netService.connectEnterpriseWifi(wifiPanel.passwordSSID, login, password)
                        } else {
                            netService.connectWifi(wifiPanel.passwordSSID, password)
                        }
                        wifiPanel.passwordSSID = ""
                        wifiPanel.forceActiveFocus()
                    }
                }

                // --- LIST HEADER & REFRESH BUTTON ---
                RowLayout {
                    Layout.fillWidth: true
                    visible: netService.wifiEnabled
                    
                    Text {
                        text: "Available Networks"
                        color: root.walColor8
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 6
                        color: wifiRefreshMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                        
                        Text {
                            id: refreshIcon
                            anchors.centerIn: parent
                            text: "󰑐"
                            color: root.walColor8
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                            transformOrigin: Item.Center
                            
                            RotationAnimation on rotation {
                                from: 0; to: 360
                                duration: 1000
                                loops: Animation.Infinite
                                running: netService.wifiScanning
                            }
                        }
                        
                        MouseArea {
                            id: wifiRefreshMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!netService.wifiScanning) netService.refreshWifi()
                            }
                        }
                    }
                }

                // --- NETWORKS CONTAINER ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(0, 0, 0, 0.25)
                    radius: 12
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.05)
                    clip: true
                    
                    ListView {
                        id: networkList
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds
                        model: netService.wifiNetworks
                        
                        opacity: netService.wifiConnecting ? 0.0 : 1.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        visible: opacity > 0
                        
                        delegate: NetworkDelegate {
                            netData: modelData
                            walColor5: root.walColor5
                            walColor8: root.walColor8
                            walForeground: root.walForeground
                            
                            onRequirePassword: (ssid, isEnterprise) => {
                                wifiPanel.isEnterprise = isEnterprise
                                wifiPanel.passwordSSID = ssid
                                focusTimer.start()
                            }
                            
                            onConnectDirectly: (ssid) => {
                                netService.connectWifi(ssid, "")
                            }
                        }
                        ScrollBar.vertical: ScrollBar { 
                            active: networkList.moving || networkList.fllicking
                            width: 4
                        }
                    }

                    // --- CONNECTING / LOADING STATE ---
                    Item {
                        anchors.fill: parent
                        visible: netService.wifiConnecting
                        opacity: netService.wifiConnecting ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        MouseArea { anchors.fill: parent; hoverEnabled: true }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                id: connectingIcon
                                text: "󰑓" 
                                color: root.walColor5
                                font.pixelSize: 32
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.alignment: Qt.AlignHCenter
                                transformOrigin: Item.Center 

                                RotationAnimation on rotation {
                                    from: 0; to: 360
                                    duration: 1200
                                    loops: Animation.Infinite
                                    running: netService.wifiConnecting 
                                }
                            }

                            Text {
                                text: "Connecting..."
                                color: root.walForeground
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Please wait"
                                color: root.walColor8
                                font.pixelSize: 10
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // --- EMPTY STATE / SCANNED STATES ---
                    Text {
                        anchors.centerIn: parent
                        visible: netService.wifiNetworks.length === 0 && !netService.wifiScanning && !netService.wifiConnecting
                        text: netService.wifiEnabled ? "No networks found" : "Wi-Fi is off"
                        color: root.walColor8
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        visible: netService.wifiScanning && netService.wifiNetworks.length === 0 && !netService.wifiConnecting 
                        text: "Scanning..."
                        color: root.walColor8
                        font.pixelSize: 11
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