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
    anchors { bottom: true; left: true }
    margins { bottom: root.btVisible ? 12 : -600; left: 70 }
    implicitHeight: 460
    implicitWidth: 320
    color: "transparent"
    focusable: true
    
    WlrLayershell.keyboardFocus: root.btVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    Behavior on margins.bottom { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Item {
        anchors.fill: parent
        focus: root.btVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.btVisible = false
                event.accepted = true
            }
        }

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

                // --- HEADER BLUETOOTH ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: "󰂯"
                        color: root.walColor5
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "Bluetooth"
                            color: root.walColor5
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            text: !netService.btEnabled ? "Adapter is disabled" : 
                                  (netService.btScanning ? "Scanning for devices..." : 
                                  (netService.btConnectingMAC !== "" ? "Connecting device..." : "Adapter active"))
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
                        color: netService.btEnabled ? root.walColor5 : Qt.rgba(1, 1, 1, 0.15)
                        border.width: 1
                        border.color: netService.btEnabled ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.05)
                        
                        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutQuad } }
                        
                        Rectangle {
                            id: toggleThumb
                            width: toggleMouseArea.pressed ? 20 : 16
                            height: 16
                            radius: 12
                            y: 2
                            x: netService.btEnabled ? (parent.width - width - 3) : 3
                            color: netService.btEnabled ? root.walBackground : root.walForeground
                            
                            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                            Behavior on width { NumberAnimation { duration: 150 } }
                        }
                        
                        MouseArea {
                            id: toggleMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: netService.toggleBtAdapter()
                        }
                    }
                }

                // --- PAIRED DEVICES LIST ---
                Text {
                    text: {
                        let len = netService.btPairedDevices.length
                        if (len === 0) return "Paired Devices"
                        return "Paired Devices (" + len + ")"
                    }
                    color: root.walColor8
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    font.family: "Inter", "sans-serif"
                    visible: netService.btEnabled
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    color: Qt.rgba(0, 0, 0, 0.15)
                    radius: 16
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.06)
                    clip: true
                    visible: netService.btEnabled
                    
                    ListView {
                        id: pairedList
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds
                        model: netService.btPairedDevices
                        
                        delegate: PairedDeviceDelegate {
                            devData: modelData
                            connectingMac: netService.btConnectingMAC
                            walColor1: root.walColor1
                            walColor2: root.walColor2
                            walColor5: root.walColor5
                            walColor8: root.walColor8
                            walForeground: root.walForeground
                            
                            onToggleConnection: (mac, isConnected) => {
                                if (isConnected) netService.disconnectBt(mac)
                                else netService.connectBt(mac)
                            }
                            
                            onForgetDevice: (mac) => {
                                netService.forgetBt(mac)
                            }
                        }
                        ScrollBar.vertical: ScrollBar { 
                            active: pairedList.moving || pairedList.flicking
                            width: 4 
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        visible: netService.btPairedDevices.length === 0
                        text: "No paired devices"
                        color: root.walColor8
                        font.pixelSize: 14
                        font.family: "Inter", "sans-serif"
                    }
                }

                // --- AVAILABLE DEVICES SECTION & SCAN BUTTON ---
                RowLayout {
                    Layout.fillWidth: true
                    visible: netService.btEnabled
                    
                    Text {
                        text: {
                            let len = netService.btAvailableDevices.length
                            if (len === 0) return "Available Devices"
                            return "Available Devices (" + len + ")"
                        }
                        color: root.walColor8
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        font.family: "Inter", "sans-serif"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Pill Styled Scan Button
                    Rectangle {
                        width: 70
                        height: 24
                        radius: 12
                        color: btScanBtnMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.2) : Qt.rgba(1, 1, 1, 0.06)
                        border.width: 1
                        border.color: btScanBtnMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.3) : "transparent"
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                text: netService.btScanning ? "󰑓" : "󰂰"
                                color: root.walColor5
                                font.pixelSize: 13
                                font.family: "JetBrainsMono Nerd Font"
                                transformOrigin: Item.Center
                                
                                RotationAnimation on rotation {
                                    from: 0; to: 360
                                    duration: 1000
                                    loops: Animation.Infinite
                                    running: netService.btScanning
                                }
                            }

                            Text {
                                text: netService.btScanning ? "Scan..." : "Scan"
                                color: root.walColor5
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "Inter", "sans-serif"
                            }
                        }

                        MouseArea {
                            id: btScanBtnMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!netService.btScanning) {
                                    netService.btScanning = true
                                    netService.btAvailableDevices = []
                                    netService.startBluetoothScan() 
                                }
                            }
                        }
                    }
                }

                // --- AVAILABLE DEVICES LIST ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(0, 0, 0, 0.15)
                    radius: 16
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.06)
                    clip: true
                    visible: netService.btEnabled
                    
                    ListView {
                        id: availableList
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds
                        model: netService.btAvailableDevices
                        
                        delegate: AvailableDeviceDelegate {
                            devData: modelData
                            connectingMac: netService.btConnectingMAC
                            walColor5: root.walColor5
                            walColor8: root.walColor8
                            walForeground: root.walForeground
                            
                            onPairDevice: (mac) => {
                                netService.pairBt(mac)
                            }
                        }
                        ScrollBar.vertical: ScrollBar { 
                            active: availableList.moving || availableList.flicking
                            width: 4 
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        visible: netService.btAvailableDevices.length === 0 && !netService.btScanning
                        text: "Press Scan to find devices"
                        color: root.walColor8
                        font.pixelSize: 14
                        font.family: "Inter", "sans-serif"
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        visible: netService.btScanning && netService.btAvailableDevices.length === 0
                        text: "Scanning..."
                        color: root.walColor8
                        font.pixelSize: 14
                        font.family: "Inter", "sans-serif"
                    }
                }

                // --- BLUETOOTH OFF STATE ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !netService.btEnabled
                    color: "transparent"
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "󰂲"
                            color: root.walColor8
                            font.pixelSize: 34
                            font.family: "JetBrainsMono Nerd Font"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "Bluetooth is turned off"
                            color: root.walColor8
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                            Layout.alignment: Qt.AlignHCenter
                        }
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