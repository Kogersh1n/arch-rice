import QtQuick 2.15
import "../core" // Подтягиваем наш Notch

Notch {
    id: clockNotch
    width: clockLabel.implicitWidth + 24
    hovered: clockMA.containsMouse
    
    // Тултип обновляется через таймер ниже
    tooltip: Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")

    Item {
        anchors.fill: parent

        Text {
            id: clockLabel
            anchors.centerIn: parent
            text: Qt.formatDateTime(new Date(), "hh:mm AP")
            color: root.walColor5 
            font.pixelSize: 11
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        id: clockMA
        anchors.fill: parent
        hoverEnabled: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            clockLabel.text = Qt.formatDateTime(new Date(), "hh:mm AP")
            // Обновляем и тултип, чтобы дата менялась в полночь
            clockNotch.tooltip = Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
        }
    }
}