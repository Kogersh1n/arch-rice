import QtQuick 2.15
import Quickshell.Io
import "../core"

Notch {
    id: sysNotch
    property bool wifiConnected: false
    property string wifiSSID: ""
    property int wifiStrength: 0
    property bool btConnected: false

    width: networkRow.width + 24
    hovered: networkMA.containsMouse
    tooltip: {
        var t = ""
        if (wifiConnected) t += wifiSSID + " (" + wifiStrength + "%)"
        else t += "Not connected"
        t += "\nBluetooth: " + (btConnected ? "Connected" : "Off")
        return t
    }

    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { if (!networkProc.running) networkProc.running = true }
    }

    Process {
        id: networkProc
        command: ["bash", "-c", "wifi=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes' | head -1); if [ -n \"$wifi\" ]; then ssid=$(echo \"$wifi\" | cut -d: -f2); sig=$(echo \"$wifi\" | cut -d: -f3); echo \"1|$ssid|$sig\"; else echo '0||0'; fi; bt='0'; devices=$(echo -e 'devices\\nquit' | bluetoothctl 2>/dev/null | grep '^Device' | awk '{print $2}'); for mac in $devices; do if echo -e \"info $mac\\nquit\" | bluetoothctl 2>/dev/null | grep -q 'Connected: yes'; then bt='1'; break; fi; done; echo \"bt:$bt\""]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.startsWith("bt:")) {
                    sysNotch.btConnected = line.endsWith("1")
                } else {
                    var parts = line.split("|")
                    sysNotch.wifiConnected = parts[0] === "1"
                    sysNotch.wifiSSID = parts.length > 1 ? parts[1] : ""
                    sysNotch.wifiStrength = parts.length > 2 ? parseInt(parts[2]) : 0
                }
            }
        }
    }

    Item {
        anchors.fill: parent

        Row {
            id: networkRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (!sysNotch.wifiConnected) return "󰤭"
                    if (sysNotch.wifiStrength > 75) return "󰤨"
                    if (sysNotch.wifiStrength > 50) return "󰤥"
                    if (sysNotch.wifiStrength > 25) return "󰤢"
                    return "󰤟"
                }
                color: sysNotch.wifiConnected ? root.walColor2 : root.walColor8
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: sysNotch.btConnected ? "󰂱" : "󰂲"
                color: sysNotch.btConnected ? root.walColor5 : root.walColor8
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font"
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