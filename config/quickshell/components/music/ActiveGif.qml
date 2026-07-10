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
            fillMode: Image.PreserveAspectFit
            smooth: true
            
            // Управляем паузой
            paused: activeGifRoot.status !== "Playing"
            cache: false
            asynchronous: true
            
            // Страховка: если гифка прогрузилась, а трек уже играет - принудительно крутим
            onStatusChanged: {
                if (status === AnimatedImage.Ready && activeGifRoot.status === "Playing") {
                    playing = true
                }
            }
        }
    }

    Item {
        id: gifContainer
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 200
        height: 160

        // --- 2. ЯДЕРНАЯ ОПЦИЯ ЛОАДЕРА ---
        Loader {
            id: danceGifLoader
            anchors.fill: parent
            // Если панель активна И ссылка не пустая -> создаем гифку. 
            // В момент переключения трека (наши 50мс) ссылка "", лоадер получает null и УБИВАЕТ старую гифку!
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

        Text { anchors.centerIn: parent; text: "󰏫"; color: root.walForeground; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }

        MouseArea {
            id: gifEditMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: activeGifRoot.toggleSelector()
        }
    }
}