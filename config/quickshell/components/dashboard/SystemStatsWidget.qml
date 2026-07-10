import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import Quickshell.Io
import "../core"

Rectangle {
    id: statsWidget
    Layout.fillWidth: true
    Layout.preferredHeight: 140
    color: Qt.rgba(0, 0, 0, 0.3)
    radius: 15
    
    property int cpuVal: 0
    property int ramVal: 0
    property int diskVal: 0

    Row {
        anchors.centerIn: parent
        spacing: 30
        CircularStat { label: "CPU"; icon: ""; barColor: root.walColor1; value: statsWidget.cpuVal }
        CircularStat { label: "RAM"; icon: ""; barColor: root.walColor5; value: statsWidget.ramVal }
        CircularStat { label: "DISK"; icon: ""; barColor: root.walColor4; value: statsWidget.diskVal }
    }


    Process {
        id: rustMonitorProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/sys_monitor"]

        running: true 
        
        stdout: SplitParser { 
            onRead: data => {
                var parts = data.trim().split("|")
                if (parts.length >= 3) {
                    statsWidget.cpuVal = parseInt(parts[0]) || 0
                    statsWidget.ramVal = parseInt(parts[1]) || 0
                    statsWidget.diskVal = parseInt(parts[2]) || 0
                }
            } 
        }
    }
}