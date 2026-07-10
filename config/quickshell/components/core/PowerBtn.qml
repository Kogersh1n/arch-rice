import QtQuick 2.15
import Quickshell.Io

Rectangle {
    id: btnRoot
    property string icon
    property color iconColor
    property string cmd
    
    width: 40; height: 40; radius: 12
    color: powerMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
    Behavior on color { ColorAnimation { duration: 150 } }
    
    scale: powerMa.containsMouse ? 1.12 : 1.0
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
    
    Text {
        anchors.centerIn: parent
        text: btnRoot.icon
        color: btnRoot.iconColor
        font.pixelSize: 20
        font.family: root.theme.iconFont
    }
    MouseArea {
        id: powerMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: cmdProc.running = true
    }
    Process {
        id: cmdProc
        command: ["bash", "-c", btnRoot.cmd]
    }
}