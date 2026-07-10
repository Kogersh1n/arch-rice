import QtQuick 2.15
import "../core"

Notch {
    width: 36
    hovered: wallMA.containsMouse
    tooltip: "Wallpapers"

    scale: wallMA.containsMouse ? 1.08 : 1.0
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

    Item {
        anchors.fill: parent
        Text {
            anchors.centerIn: parent
            text: "󰸉" // Wallpaper image icon
            color: root.walColor2
            font.pixelSize: 18
            font.family: root.theme.iconFont
        }
    }

    MouseArea {
        id: wallMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.toggleWallpaper()
        }
    }
}
