import QtQuick
import QtQuick.Layouts

Rectangle {
    id: delegateRoot
    
    property var devData
    property string connectingMac: ""
    property color walColor5
    property color walColor8
    property color walForeground
    
    signal pairDevice(string mac)

    width: parent ? parent.width : 0
    height: 44
    radius: 10
    color: btAvailMa.containsMouse ? Qt.rgba(walColor5.r, walColor5.g, walColor5.b, 0.12) : "transparent"
    
    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutQuad } }
    
    // Vertical Accent Bar on hover
    Rectangle {
        id: hoverIndicator
        width: 3
        height: parent.height - 16
        radius: 1.5
        color: walColor5
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        opacity: btAvailMa.containsMouse ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12
        
        Text {
            id: btIcon
            text: "󰂲"
            color: delegateRoot.connectingMac === devData.mac ? walColor5 : walColor8
            font.pixelSize: 15
            font.family: "JetBrainsMono Nerd Font"
            
            SequentialAnimation {
                running: delegateRoot.connectingMac === devData.mac
                loops: Animation.Infinite
                OpacityAnimator { target: btIcon; from: 0.3; to: 1.0; duration: 600 }
                OpacityAnimator { target: btIcon; from: 1.0; to: 0.3; duration: 600 }
            }
        }
        
        Text {
            text: devData.name
            color: walForeground
            font.pixelSize: 12
            font.bold: btAvailMa.containsMouse
            font.family: "JetBrainsMono Nerd Font"
            elide: Text.ElideRight
            Layout.fillWidth: true
            
            Behavior on font.bold { PropertyAnimation { duration: 100 } }
        }
        
        Text {
            visible: delegateRoot.connectingMac === devData.mac
            text: "Connecting..."
            color: walColor8
            font.pixelSize: 10
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