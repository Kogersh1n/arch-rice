import QtQuick 2.15
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../core"

Notch {
    id: mediaNotch
    property string mediaText: ""
    property string mediaClass: "stopped"
    property real mediaPosition: 0
    property real mediaLength: 0
    property var cavaValues: [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]

    width: mediaText !== "" ? mediaContent.width + 28 : 0
    visible: mediaText !== ""
    hovered: mediaMA.containsMouse
    tooltip: mediaText

    Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

    Timer {
        interval: 1500; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { if (!mediaProc.running) mediaProc.running = true }
    }

    Process {
        id: cavaProc
        running: mediaNotch.mediaClass === "playing"
        command: ["cava", "-p", Quickshell.env("HOME") + "/.config/cava/config_raw"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(";")
                var vals = []
                for (var i = 0; i < 12 && i < parts.length; i++) {
                    vals.push(parseInt(parts[i]) / 255)
                }
                while (vals.length < 12) vals.push(0.1)
                mediaNotch.cavaValues = vals
            }
        }
    }

    Timer {
        interval: 80; running: mediaNotch.mediaClass !== "playing"; repeat: true
        onTriggered: {
            var newVals = []
            for (var i = 0; i < 12; i++) newVals.push(mediaNotch.cavaValues[i] * 0.85)
            mediaNotch.cavaValues = newVals
        }
    }

    Process {
        id: mediaProc
        command: ["bash", "-c", "status=$(playerctl --player=%any status 2>/dev/null); pos=$(playerctl --player=%any position 2>/dev/null | cut -d. -f1); len=$(playerctl --player=%any metadata mpris:length 2>/dev/null); len=$((len / 1000000)); if [ \"$status\" = \"Playing\" ] || [ \"$status\" = \"Paused\" ]; then artist=$(playerctl --player=%any metadata artist 2>/dev/null); title=$(playerctl --player=%any metadata title 2>/dev/null); if [ -n \"$title\" ]; then text=\"$title\"; [ -n \"$artist\" ] && text=\"$artist - $title\"; if [ ${#text} -gt 35 ]; then text=\"${text:0:32}...\"; fi; echo \"$status|$text|$pos|$len\"; else echo 'stopped||0|0'; fi; else echo 'stopped||0|0'; fi"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split("|")
                if (parts.length >= 4) {
                    mediaNotch.mediaClass = parts[0].toLowerCase()
                    mediaNotch.mediaText = parts[1]
                    mediaNotch.mediaPosition = parseInt(parts[2]) || 0
                    mediaNotch.mediaLength = parseInt(parts[3]) || 0
                }
            }
        }
    }

    Timer {
        interval: 1000; running: mediaNotch.mediaClass === "playing"; repeat: true
        onTriggered: { if (mediaNotch.mediaPosition < mediaNotch.mediaLength) mediaNotch.mediaPosition += 1 }
    }

    Process { id: mediaPlayPauseProc; command: ["playerctl", "play-pause"]; onExited: { if (!mediaProc.running) mediaProc.running = true } }
    Process { id: mediaNextProc; command: ["playerctl", "next"]; onExited: { if (!mediaProc.running) mediaProc.running = true } }
    Process { id: mediaPrevProc; command: ["playerctl", "previous"]; onExited: { if (!mediaProc.running) mediaProc.running = true } }

    Item {
        anchors.fill: parent

        Column {
            id: mediaContent
            anchors.centerIn: parent
            spacing: 2

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Item {
                    width: cavaRow.width
                    height: 14
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        id: cavaRow
                        anchors.centerIn: parent
                        spacing: 2

                        Repeater {
                            model: 12
                            Rectangle {
                                width: 2
                                height: Math.max(3, mediaNotch.cavaValues[index] * 14)
                                radius: 1.5
                                anchors.verticalCenter: parent.verticalCenter
                                color: root.walColor5
                                antialiasing: true
                                Behavior on height { NumberAnimation { duration: 60; easing.type: Easing.OutQuad } }
                            }
                        }
                    }
                }

                Text {
                    id: mediaLabel
                    anchors.verticalCenter: parent.verticalCenter
                    text: mediaNotch.mediaText
                    color: root.walColor2
                    font.pixelSize: 10
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    opacity: mediaNotch.mediaClass === "playing" ? 1.0 : 0.7

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0; verticalOffset: 1; radius: 4; samples: 9; spread: 0.2
                        color: Qt.rgba(0, 0, 0, 0.8)
                        transparentBorder: true
                    }
                    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                }
            }

            Rectangle {
                width: mediaContent.width
                height: 3
                radius: 1.5
                color: Qt.rgba(0, 0, 0, 0.4)
                visible: mediaNotch.mediaLength > 0
                antialiasing: true

                Rectangle {
                    width: mediaNotch.mediaLength > 0 ? parent.width * (mediaNotch.mediaPosition / mediaNotch.mediaLength) : 0
                    height: parent.height
                    radius: 1.5
                    color: root.walColor2

                    layer.enabled: true
                    layer.effect: Glow {
                        radius: 3; samples: 7; color: root.walColor2; transparentBorder: true; antialiasing: true
                    }
                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.Linear } }
                }
            }
        }
    }

    MouseArea {
        id: mediaMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) root.toggleMusic()
            else if (mouse.button === Qt.MiddleButton) { if (!mediaNextProc.running) mediaNextProc.running = true } 
            else { if (!mediaPlayPauseProc.running) mediaPlayPauseProc.running = true }
        }
        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) { if (!mediaNextProc.running) mediaNextProc.running = true } 
            else { if (!mediaPrevProc.running) mediaPrevProc.running = true }
        }
    }
}