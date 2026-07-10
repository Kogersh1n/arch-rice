import QtQuick 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    spacing: 6

    property string title: ""
    property string artist: ""
    property real position: 0
    property real length: 0
    property string status: "Stopped"
    property bool hasTrack: false

    signal seekRequested(real pos)
    signal prevClicked()
    signal nextClicked()
    signal playPauseClicked()

    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    Text {
        text: title || "Nothing is playing"
        color: root.walColor5
        font.pixelSize: 15
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
        Layout.fillWidth: true
        elide: Text.ElideRight
    }

    Text {
        text: artist || ""
        color: root.walForeground
        font.pixelSize: 12
        font.family: "JetBrainsMono Nerd Font"
        opacity: 0.7
        Layout.fillWidth: true
        elide: Text.ElideRight
        visible: artist !== ""
    }

    Item { Layout.fillHeight: true } // Распорка

    // Полоса прогресса
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        visible: hasTrack

        Text {
            text: formatTime(position)
            color: root.walColor8
            font.pixelSize: 10
            font.family: "JetBrainsMono Nerd Font"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 4
            radius: 2
            color: Qt.rgba(0, 0, 0, 0.3)

            Rectangle {
                width: length > 0 ? parent.width * (position / length) : 0
                height: parent.height
                radius: 2
                color: root.walColor5
                Behavior on width { NumberAnimation { duration: 200 } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: function(mouse) {
                    if (length > 0) {
                        var seekPos = (mouse.x / parent.width) * length
                        seekRequested(seekPos)
                    }
                }
            }
        }

        Text {
            text: formatTime(length)
            color: root.walColor8
            font.pixelSize: 10
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    // Кнопки управления
    Row {
        Layout.alignment: Qt.AlignHCenter
        spacing: 12
        opacity: hasTrack ? 1.0 : 0.5

        Rectangle {
            width: 32; height: 32; radius: 8
            color: prevMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
            Text { anchors.centerIn: parent; text: "󰒮"; color: root.walForeground; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
            MouseArea { id: prevMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: prevClicked() }
        }

        Rectangle {
            width: 40; height: 40; radius: 20; color: root.walColor5
            Text { anchors.centerIn: parent; text: status === "Playing" ? "󰏤" : "󰐊"; color: root.walBackground; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: playPauseClicked() }
        }

        Rectangle {
            width: 32; height: 32; radius: 8
            color: nextMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
            Text { anchors.centerIn: parent; text: "󰒭"; color: root.walForeground; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
            MouseArea { id: nextMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: nextClicked() }
        }
    }
}