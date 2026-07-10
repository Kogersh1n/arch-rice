// import QtQuick 2.15
// import QtQuick.Controls 2.15
// import QtQuick.Layouts 1.15
// import "../components"

// Item {
//     id: libraryRoot
//     anchors.fill: parent

//     Rectangle {
//         id: header
//         anchors.top: parent.top
//         anchors.left: parent.left
//         anchors.right: parent.right
//         height: 50
//         color: "transparent"

//         Text {
//             anchors.centerIn: parent
//             text: 'My Library'
//             color: 'white'
//             font.pixelSize: 22
//             font.bold: true
//         }
//     }


//     GridView {
//         id: mangaGrid
//         anchors.top: header.bottom
//         anchors.bottom: parent.bottom
//         anchors.left: parent.left
//         anchors.right: parent.right
//         anchors.margins: 20 

//         model: Backend.mangaList
//         cellWidth: 110
//         cellHeight: 180
//         clip: true

//         delegate: Rectangle {
//             width: 105
//             height: 160
//             color: model && model.coverColor ? model.coverColor : "#1e1e2e" // Твой любимый Catppuccin Mocha
//             radius: 10

//             Rectangle {
//                 id: cardRect
//                 anchors.fill: parent
//                 radius: 8
//                 color: "#313244"
//                 clip: true
//             }
            
//             Image {
//                 anchors.fill: parent
//                 source: modelData.coverUrl
//                 fillMode: Image.PreserveAspectCrop
//                 asynchronous: true
//             }

//             Rectangle {
//                 anchors.left: parent.left
//                 anchors.right: parent.right
//                 anchors.bottom: parent.bottom
//                 height: 50
//                 color: "#313244"
//             }

//             Text {
//                     anchors.left: parent.left
//                     anchors.right: parent.right
//                     anchors.bottom: parent.bottom
//                     anchors.margins: 8
                    
//                     text: modelData.title
//                     color: "#cdd6f4" // Catppuccin Text
//                     font.bold: true
//                     font.pixelSize: 13
//                     horizontalAlignment: Text.AlignHCenter
//                     wrapMode: Text.WordWrap
//                     maximumLineCount: 2 // Максимум 2 строки
//                     elide: Text.ElideRight // Добавит троеточие, если название слишком длинное
//                 }


//         MouseArea {
//             anchors.fill: parent
//             cursorShape: Qt.PointingHandCursor
//             hoverEnabled: true

//             onEntered: parent.scale = 1.05
//             onExited: parent.scale = 1.0
//             Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } } // I have to explore this more

//             onClicked: {
//                 reader.currentView = 'reader'
//             }
//         }



//     }

//     }
//     Component.onCompleted: Backend.loadMockData()

// }