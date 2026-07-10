import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Qt.rgba(0, 0, 0, 0.3)
    radius: 15
    
    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        Text {
            id: timeDisplay
            anchors.horizontalCenter: parent.horizontalCenter
            text: "12:00:00 AM"
            color: root.walColor5
            font.pixelSize: 30
            font.family: "JetBrainsMono Nerd Font"
        }
        
        Text {
            id: dateDisplay
            anchors.horizontalCenter: parent.horizontalCenter
            text: "01.01.2026, Friday"
            color: root.walForeground
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            var hours = now.getHours()
            var minutes = now.getMinutes()
            var seconds = now.getSeconds()
            var ampm = hours >= 12 ? 'PM' : 'AM'
            hours = hours % 12
            hours = hours ? hours : 12
            var h = hours < 10 ? '0' + hours : hours
            var m = minutes < 10 ? '0' + minutes : minutes
            var s = seconds < 10 ? '0' + seconds : seconds
            timeDisplay.text = h + ':' + m + ':' + s + ' ' + ampm
            dateDisplay.text = Qt.formatDate(now, "dd.MM.yyyy, dddd")
        }
    }
}