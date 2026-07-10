import QtQuick
import QtQuick.Layouts

Rectangle {
    id: delegateRoot
    
    property var devData
    property string connectingMac: ""
    
    property color walColor1
    property color walColor2
    property color walColor5
    property color walColor8
    property color walForeground

    signal toggleConnection(string mac, bool isConnected)
    signal forgetDevice(string mac)

    width: parent ? parent.width : 0
    height: 48
    radius: 10
    color: btPairedMa.containsMouse ? Qt.rgba(walColor5.r, walColor5.g, walColor5.b, 0.12) : "transparent"
    
    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutQuad } }
    
    // Vertical Accent Bar on hover
    Rectangle {
        id: hoverIndicator
        width: 3
        height: parent.height - 16
        radius: 1.5
        color: devData.connected ? walColor2 : walColor5
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        opacity: btPairedMa.containsMouse || devData.connected ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 10
        spacing: 12
        
        // Status Icon
        Text {
            id: statusIcon
            text: devData.connected ? "󰂱" : "󰂲"
            color: devData.connected ? walColor2 : walColor8
            font.pixelSize: 17
            font.family: "JetBrainsMono Nerd Font"
            
            SequentialAnimation {
                running: delegateRoot.connectingMac === devData.mac
                loops: Animation.Infinite
                OpacityAnimator { target: statusIcon; from: 0.3; to: 1.0; duration: 600 }
                OpacityAnimator { target: statusIcon; from: 1.0; to: 0.3; duration: 600 }
            }
        }
        
        // Name and Status Description
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text: devData.name
                color: devData.connected ? walColor2 : walForeground
                font.pixelSize: 12
                font.bold: devData.connected || btPairedMa.containsMouse
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
                Layout.fillWidth: true
                
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            Text {
                text: {
                    if (delegateRoot.connectingMac === devData.mac) return "Connecting..."
                    if (devData.connected) return "Connected"
                    return "Paired"
                }
                color: walColor8
                font.pixelSize: 9
                font.family: "JetBrainsMono Nerd Font"
            }
        }
        
        // Button: Connect / Disconnect
        Rectangle {
            width: 28
            height: 28
            radius: 8
            color: {
                if (!btConnBtnMa.containsMouse) return "transparent"
                return devData.connected ? Qt.rgba(walColor1.r, walColor1.g, walColor1.b, 0.2) : Qt.rgba(walColor2.r, walColor2.g, walColor2.b, 0.2)
            }
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: devData.connected ? "󰅖" : "󰐕"
                color: devData.connected ? walColor1 : walColor5
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }
            MouseArea {
                id: btConnBtnMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: delegateRoot.toggleConnection(devData.mac, devData.connected)
            }
        }
        
        // Button: Forget
        Rectangle {
            width: 28
            height: 28
            radius: 8
            color: btForgetMa.containsMouse ? Qt.rgba(walColor1.r, walColor1.g, walColor1.b, 0.2) : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "󰆴"
                color: btForgetMa.containsMouse ? walColor1 : walColor8
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            MouseArea {
                id: btForgetMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: delegateRoot.forgetDevice(devData.mac)
            }
        }
    }
    
    // Main area connect click
    MouseArea {
        id: btPairedMa
        anchors.fill: parent
        hoverEnabled: true
        z: -1
        onClicked: delegateRoot.toggleConnection(devData.mac, devData.connected)
    }
}