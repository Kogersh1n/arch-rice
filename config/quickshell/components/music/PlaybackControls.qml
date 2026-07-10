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
        font.family: "Inter", "sans-serif"
        Layout.fillWidth: true
        elide: Text.ElideRight
    }

    Text {
        text: artist || ""
        color: root.walForeground
        font.pixelSize: 12
        font.family: "Inter", "sans-serif"
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
            font.family: "Inter", "sans-serif"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 2
            radius: 1
            color: Qt.rgba(1, 1, 1, 0.08)

            Rectangle {
                width: length > 0 ? parent.width * (position / length) : 0
                height: parent.height
                radius: 1
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
            font.family: "Inter", "sans-serif"
        }
    }

    // Кнопки управления
    Row {
        Layout.alignment: Qt.AlignHCenter
        spacing: 16
        opacity: hasTrack ? 1.0 : 0.5

        // Prev Button
        Rectangle {
            width: 32; height: 32; radius: 16
            color: prevMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
            border.width: prevMa.containsMouse ? 1 : 0
            border.color: Qt.rgba(1, 1, 1, 0.15)
            
            Text {
                anchors.centerIn: parent
                text: "󰒮"
                color: root.walForeground
                font.pixelSize: 16
                font.family: "JetBrainsMono Nerd Font"
                opacity: prevMa.containsMouse ? 1.0 : 0.7
            }
            MouseArea { id: prevMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: prevClicked() }
        }

        // Play / Pause Button
        Rectangle {
            width: 40; height: 40; radius: 20
            color: playMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.25) : Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.12)
            border.width: 1
            border.color: playMa.containsMouse ? root.walColor5 : Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.4)
            
            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: status === "Playing" ? "󰏤" : "󰐊"
                color: root.walColor5
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
            }
            MouseArea { id: playMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: playPauseClicked() }
        }

        // Next Button
        Rectangle {
            width: 32; height: 32; radius: 16
            color: nextMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
            border.width: nextMa.containsMouse ? 1 : 0
            border.color: Qt.rgba(1, 1, 1, 0.15)
            
            Text {
                anchors.centerIn: parent
                text: "󰒭"
                color: root.walForeground
                font.pixelSize: 16
                font.family: "JetBrainsMono Nerd Font"
                opacity: nextMa.containsMouse ? 1.0 : 0.7
            }
            MouseArea { id: nextMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: nextClicked() }
        }
    }
}