import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: activeGifRoot

    property string gifSource: ""
    property string status: "Stopped"
    property bool isActive: true 

    signal toggleSelector()

    // --- 1. ВЫНОСИМ ГИФКУ В НЕЗАВИСИМЫЙ ЧЕРТЕЖ (COMPONENT) ---
    Component {
        id: gifTemplate
        AnimatedImage {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            source: activeGifRoot.gifSource
            fillMode: Image.PreserveAspectCrop
            smooth: true
            paused: activeGifRoot.status !== "Playing"
            cache: false
            asynchronous: true
            
            // Vinyl Mode Rotation Animation
            RotationAnimation on rotation {
                from: 0; to: 360
                duration: 12000
                loops: Animation.Infinite
                running: activeGifRoot.status === "Playing"
            }

            onStatusChanged: {
                if (status === AnimatedImage.Ready && activeGifRoot.status === "Playing") {
                    playing = true
                }
            }
        }
    }

    Rectangle {
        id: gifContainer
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 140
        height: 140
        radius: 70
        color: "transparent"
        clip: true

        Loader {
            id: danceGifLoader
            anchors.fill: parent
            sourceComponent: (activeGifRoot.isActive && activeGifRoot.gifSource !== "") ? gifTemplate : null
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 5
        anchors.rightMargin: 5
        width: 24; height: 24; radius: 12
        color: gifEditMa.containsMouse ? Qt.rgba(1,1,1,0.2) : Qt.rgba(0,0,0,0.3)
        Behavior on color { ColorAnimation { duration: 150 } }

        Text { anchors.centerIn: parent; text: "󰏫"; color: root.walForeground; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }

        MouseArea {
            id: gifEditMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: activeGifRoot.toggleSelector()
        }
    }
}