import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 42
    color: Qt.rgba(0, 0, 0, 0.3)
    radius: 18
    
    signal focusApps()
    signal focusWalls()

    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4
        
        // Кнопка Apps
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: root.activeTab === 0 ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.2) : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text { text: "󰀻"; color: root.activeTab === 0 ? root.walColor5 : root.walColor8; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                Text { text: "Apps"; color: root.activeTab === 0 ? root.walColor5 : root.walColor8; font.pixelSize: 15; font.bold: root.activeTab === 0; font.family: "JetBrainsMono Nerd Font" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.activeTab = 0
                    focusApps()
                }
            }
        }
        
        // Кнопка Walls
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: root.activeTab === 1 ? Qt.rgba(root.walColor13.r, root.walColor13.g, root.walColor13.b, 0.2) : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text { text: "󰸉"; color: root.activeTab === 1 ? root.walColor13 : root.walColor8; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                Text { text: "Walls"; color: root.activeTab === 1 ? root.walColor13 : root.walColor8; font.pixelSize: 15; font.bold: root.activeTab === 1; font.family: "JetBrainsMono Nerd Font" }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.activeTab = 1
                    if (!wallService.wallsLoaded) wallService.load()
                    focusWalls()
                }
            }
        }
    }
}