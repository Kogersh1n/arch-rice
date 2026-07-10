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
    anchors { bottom: true; left: true }
    margins { bottom: root.wifiVisible ? 12 : -600; left: 70 }
    implicitHeight: 440
    implicitWidth: 320
    color: "transparent"
    
    property string passwordSSID: ""
    property bool isEnterprise: false
    
    WlrLayershell.keyboardFocus: passwordSSID !== "" ? WlrKeyboardFocus.Exclusive : (root.wifiVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None)
    
    Behavior on margins.bottom { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

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

        // Sleek, minimal background
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, root.theme.panelOpacity)
            radius: root.theme.panelRadius
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, root.theme.borderOpacity)
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                // --- HEADER WI-FI ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: "󰤨"
                        color: root.walColor5
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "Wi-Fi Network"
                            color: root.walColor5
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            text: !netService.wifiEnabled ? "Adapter is disabled" : 
                                  (netService.wifiConnecting ? "Connecting..." : 
                                  (netService.wifiCurrentSSID !== "" ? "Connected to " + netService.wifiCurrentSSID : "Ready to connect"))
                            color: root.walColor8
                            font.pixelSize: 13
                            font.family: "Inter", "sans-serif"
                        }
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
                        border.color: netService.wifiEnabled ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.05)
                        
                        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutQuad } }
                        
                        Rectangle {
                            id: toggleThumb
                            width: toggleMouseArea.pressed ? 20 : 16
                            height: 16
                            radius: 12
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

                // --- ACTIVE CONNECTION CARD ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: 16
                    color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.12)
                    border.width: 1
                    border.color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.3)
                    visible: netService.wifiCurrentSSID !== ""
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12
                        
                        // Signal Circle
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: Qt.rgba(root.walColor2.r, root.walColor2.g, root.walColor2.b, 0.15)
                            
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (netService.wifiSignal > 75) return "󰤨"
                                    if (netService.wifiSignal > 50) return "󰤥"
                                    if (netService.wifiSignal > 25) return "󰤢"
                                    return "󰤟"
                                }
                                color: root.walColor2
                                font.pixelSize: 16
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            
                            Text {
                                text: netService.wifiCurrentSSID
                                color: root.walColor2
                                font.pixelSize: 14
                                font.bold: true
                                font.family: "Inter", "sans-serif"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "Signal: " + netService.wifiSignal + "% · Active connection"
                                color: root.walColor8
                                font.pixelSize: 13
                                font.family: "Inter", "sans-serif"
                            }
                        }
                        
                        // Disconnect Button
                        Rectangle {
                            width: 26
                            height: 26
                            radius: 12
                            color: wifiDiscMa.containsMouse ? Qt.rgba(root.walColor1.r, root.walColor1.g, root.walColor1.b, 0.25) : "transparent"
                            
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: wifiDiscMa.containsMouse ? root.walColor1 : root.walColor8
                                font.pixelSize: 14
                                font.family: "JetBrainsMono Nerd Font"
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
                        text: {
                            let len = netService.wifiNetworks.length
                            if (len === 0) return "Available Networks"
                            return "Available Networks (" + len + ")"
                        }
                        color: root.walColor8
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        font.family: "Inter", "sans-serif"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 6
                        color: wifiRefreshMa.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
                        
                        Text {
                            id: refreshIcon
                            anchors.centerIn: parent
                            text: "󰑐"
                            color: root.walColor8
                            font.pixelSize: 14
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
                    color: Qt.rgba(0, 0, 0, 0.15)
                    radius: 16
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.06)
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
                            active: networkList.moving || networkList.flicking
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
                                font.pixelSize: 34
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
                                font.pixelSize: 14
                                font.bold: true
                                font.family: "Inter", "sans-serif"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Please wait"
                                color: root.walColor8
                                font.pixelSize: 13
                                font.family: "Inter", "sans-serif"
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
                        font.pixelSize: 14
                        font.family: "Inter", "sans-serif"
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        visible: netService.wifiScanning && netService.wifiNetworks.length === 0 && !netService.wifiConnecting 
                        text: "Scanning..."
                        color: root.walColor8
                        font.pixelSize: 14
                        font.family: "Inter", "sans-serif"
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