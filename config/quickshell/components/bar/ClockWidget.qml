import QtQuick 2.15
import "../core" // Подтягиваем наш Notch

Notch {
    id: clockNotch
    width: 36
    height: clockLabel.implicitHeight + 16
    hovered: clockMA.containsMouse

    property bool showDate: false

    // Tooltip shows full date
    tooltip: Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")

    scale: clockMA.containsMouse ? 1.05 : 1.0
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

    Item {
        anchors.fill: parent

        Text {
            id: clockLabel
            anchors.centerIn: parent
            text: clockNotch.showDate ? Qt.formatDateTime(new Date(), "dd\nMM") : Qt.formatDateTime(new Date(), "HH\nmm")
            color: root.walColor5 
            font.pixelSize: 12
            font.bold: true
            font.family: root.theme.textFont
            lineHeight: 0.85
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        id: clockMA
        anchors.fill: parent
        hoverEnabled: true
        onClicked: clockNotch.showDate = !clockNotch.showDate
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            clockLabel.text = clockNotch.showDate ? Qt.formatDateTime(new Date(), "dd\nMM") : Qt.formatDateTime(new Date(), "HH\nmm")
            clockNotch.tooltip = Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
        }
    }
}