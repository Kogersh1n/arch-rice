import QtQuick
import QtQuick.Layouts

Rectangle {
    id: delegateRoot
    
    property var devData
    property string connectingMac: ""
    property color walColor8
    property color walForeground
    
    signal pairDevice(string mac)

    width: parent ? parent.width : 0
    height: 44
    radius: 10
    color: btAvailMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
    
    Behavior on color { ColorAnimation { duration: 120 } }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10
        
        Text {
            text: "󰂲"
            color: walColor8
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
        }
        
        Text {
            text: devData.name
            color: walForeground
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
        
        Text {
            visible: delegateRoot.connectingMac === devData.mac
            text: "..."
            color: walColor8
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
        }
    }
    
    MouseArea {
        id: btAvailMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: delegateRoot.pairDevice(devData.mac)
    }
}