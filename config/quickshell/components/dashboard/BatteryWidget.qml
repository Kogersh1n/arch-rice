import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell.Io

Rectangle {
    id: batWidget
    Layout.fillWidth: true
    Layout.preferredHeight: 70
    color: root.theme.cardBackground
    radius: root.theme.cardRadius
    border.width: 1
    border.color: root.theme.cardBorder
    
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
            font.family: root.theme.iconFont
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3
            Text {
                text: "Battery " + batWidget.batVal + "%"
                color: root.walForeground
                font.pixelSize: 18
                font.family: root.theme.textFont
            }
            Text {
                id: batStatus
                text: "Checking..."
                color: root.walColor8
                font.pixelSize: 12
                font.family: root.theme.textFont
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
        }
    }

    Process {
        id: batProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity /sys/class/power_supply/BAT*/status 2>/dev/null | tr '\\n' '|' || echo '100|Unknown'"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split("|")
                if (parts.length >= 2) {
                    batWidget.batVal = parseInt(parts[0]) || 100
                    batWidget.batState = parts[1].trim()
                    batWidget.updateBatteryUI()
                }
            }
        }
    }
}