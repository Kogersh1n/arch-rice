import QtQuick 2.15
import Quickshell
import Quickshell.Io
import "../core"

Notch {
    id: mediaNotch
    property string mediaText: ""
    property string mediaClass: "stopped"
    property real mediaPosition: 0
    property real mediaLength: 0

    width: mediaText !== "" ? 36 : 0
    height: mediaText !== "" ? 36 : 0
    visible: mediaText !== ""
    hovered: mediaMA.containsMouse
    tooltip: mediaText

    scale: mediaMA.containsMouse ? 1.05 : 1.0
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

    Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

    Timer {
        interval: 1500; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { if (!mediaProc.running) mediaProc.running = true }
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

        // Rotating Vinyl / Music Disc
        Rectangle {
            id: disc
            anchors.centerIn: parent
            width: 26
            height: 26
            radius: 13
            color: mediaNotch.mediaClass === "playing" ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.15) : "transparent"
            border.width: 1
            border.color: mediaNotch.mediaClass === "playing" ? root.walColor5 : root.walColor8
            antialiasing: true

            Behavior on color { ColorAnimation { duration: 250 } }
            Behavior on border.color { ColorAnimation { duration: 250 } }

            Text {
                anchors.centerIn: parent
                text: "󰎆"
                color: mediaNotch.mediaClass === "playing" ? root.walColor5 : root.walColor8
                font.pixelSize: 13
                font.family: root.theme.iconFont
                
                // Slow rotation animation when music is playing!
                RotationAnimation on rotation {
                    from: 0; to: 360
                    duration: 8000
                    loops: Animation.Infinite
                    running: mediaNotch.mediaClass === "playing"
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