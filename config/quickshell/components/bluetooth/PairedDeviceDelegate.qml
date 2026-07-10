import QtQuick
import QtQuick.Layouts

Rectangle {
    id: delegateRoot
    
    // Свойства из основной модели
    property var devData
    property string connectingMac: ""
    
    // Цвета из твоей темы (wal)
    property color walColor1
    property color walColor2
    property color walColor5
    property color walColor8
    property color walForeground

    // Сигналы для связи с основным окном
    signal toggleConnection(string mac, bool isConnected)
    signal forgetDevice(string mac)

    width: parent ? parent.width : 0
    height: 48
    radius: 10
    color: btPairedMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
    
    Behavior on color { ColorAnimation { duration: 120 } }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10
        
        // Иконка статуса
        Text {
            text: devData.connected ? "󰂱" : "󰂲"
            color: devData.connected ? walColor2 : walColor8
            font.pixelSize: 18
            font.family: "JetBrainsMono Nerd Font"
        }
        
        // Имя и статус
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Text {
                text: devData.name
                color: devData.connected ? walColor2 : walForeground
                font.pixelSize: 12
                font.bold: devData.connected
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
                Layout.fillWidth: true
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
        
        // Кнопка: Подключить / Отключить
        Rectangle {
            width: 28
            height: 28
            radius: 8
            color: btConnBtnMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
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
        
        // Кнопка: Забыть устройство
        Rectangle {
            width: 28
            height: 28
            radius: 8
            color: btForgetMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
            Text {
                anchors.centerIn: parent
                text: "󰆴"
                color: walColor8
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
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
    
    // Клик по всей плашке тоже переключает соединение
    MouseArea {
        id: btPairedMa
        anchors.fill: parent
        hoverEnabled: true
        z: -1
        onClicked: delegateRoot.toggleConnection(devData.mac, devData.connected)
    }
}