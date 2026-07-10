import QtQuick 2.15
import Quickshell.Io
import "../core"

Notch {
    id: sysNotch
    property bool wifiConnected: root.wifiCurrentSSID !== ""
    property string wifiSSID: root.wifiCurrentSSID
    property int wifiStrength: root.wifiSignal
    property bool btConnected: {
        if (!root.btEnabled) return false
        var devices = root.btPairedDevices
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].connected) return true
        }
        return false
    }

    width: 36
    height: 52
    hovered: networkMA.containsMouse
    
    scale: networkMA.containsMouse ? 1.05 : 1.0
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

    tooltip: {
        var t = ""
        if (wifiConnected) t += wifiSSID + " (" + wifiStrength + "%)"
        else t += "Not connected"
        t += "\nBluetooth: " + (btConnected ? "Connected" : "Off")
        return t
    }

    Item {
        anchors.fill: parent

        Column {
            id: networkColumn
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    if (!sysNotch.wifiConnected) return "󰤭"
                    if (sysNotch.wifiStrength > 75) return "󰤨"
                    if (sysNotch.wifiStrength > 50) return "󰤥"
                    if (sysNotch.wifiStrength > 25) return "󰤢"
                    return "󰤟"
                }
                color: sysNotch.wifiConnected ? root.walColor2 : root.walColor8
                font.pixelSize: 15
                font.family: root.theme.iconFont
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: sysNotch.btConnected ? "󰂱" : "󰂲"
                color: sysNotch.btConnected ? root.walColor5 : root.walColor8
                font.pixelSize: 14
                font.family: root.theme.iconFont
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }
    }

    MouseArea {
        id: networkMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) root.toggleBluetooth()
            else root.toggleWifi()
        }
    }
}