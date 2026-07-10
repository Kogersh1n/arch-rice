import QtQuick 2.15
import "../core"

Notch {
    width: 36
    hovered: appsMA.containsMouse
    tooltip: "Apps / Wallpapers"

    Item {
        anchors.fill: parent
        Text {
            anchors.centerIn: parent
            text: "󰣇"
            color: root.walColor1
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        id: appsMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                root.activeTab = 1
                if (!root.launcherVisible) root.toggleLauncher()
                else { root.activeTab = 1; if (!root.wallsLoaded) root.loadWallpapers() }
            } else {
                root.activeTab = 0
                root.toggleLauncher()
            }
        }
    }
}