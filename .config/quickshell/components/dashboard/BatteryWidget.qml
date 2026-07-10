import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell.Io

Rectangle {
    id: batWidget
    Layout.fillWidth: true
    Layout.preferredHeight: 70
    color: Qt.rgba(0, 0, 0, 0.3)
    radius: 15
    
    property int batVal: 100
    property string batState: "Unknown"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15
        
        Text {
            id: batIcon
            text: "󰁹"
            color: root.walColor2
            font.pixelSize: 32
            font.family: "JetBrainsMono Nerd Font"
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3
            Text {
                text: "Battery " + batWidget.batVal + "%"
                color: root.walForeground
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                id: batStatus
                text: "Checking..."
                color: root.walColor8
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }
    
    function updateBatteryUI() {
        var cap = batWidget.batVal
        var status = batWidget.batState

        if (status === "Charging") {
            batStatus.text = "Charging"; batIcon.text = "󰂄"
        } else if (status === "Full" || status === "Not charging") {
            batStatus.text = "Fully charged"; batIcon.text = "󰁹"
        } else {
            batStatus.text = "Discharging"
            if (cap >= 90) batIcon.text = "󰁹"
            else if (cap >= 80) batIcon.text = "󰂂"
            else if (cap >= 70) batIcon.text = "󰂁"
            else if (cap >= 60) batIcon.text = "󰂀"
            else if (cap >= 50) batIcon.text = "󰁿"
            else if (cap >= 40) batIcon.text = "󰁾"
            else if (cap >= 30) batIcon.text = "󰁽"
            else if (cap >= 20) batIcon.text = "󰁼"
            else if (cap >= 10) batIcon.text = "󰁻"
            else batIcon.text = "󰁺"
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (!batProc.running) batProc.running = true
            if (!batStatusProc.running) batStatusProc.running = true
        }
    }

    Process {
        id: batProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo 100"]
        stdout: SplitParser { onRead: data => { batWidget.batVal = parseInt(data) || 100; batWidget.updateBatteryUI() } }
    }

    Process {
        id: batStatusProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1 || echo Unknown"]
        stdout: SplitParser { onRead: data => { batWidget.batState = data.trim(); batWidget.updateBatteryUI() } }
    }
}