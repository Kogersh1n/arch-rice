import QtQuick 2.15
import "../core"

Notch {
    width: 36
    hovered: appsMA.containsMouse
    tooltip: "Applications"

    scale: appsMA.containsMouse ? 1.08 : 1.0
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

    Item {
        anchors.fill: parent
        Text {
            anchors.centerIn: parent
            text: "󰣇"
            color: root.walColor1
            font.pixelSize: 18
            font.family: root.theme.iconFont
        }
    }

    MouseArea {
        id: appsMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.toggleLauncher()
        }
    }
}