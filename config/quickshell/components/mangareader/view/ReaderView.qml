// import QtQuick 2.15
// import QtQuick.Controls 2.15


// Item {
//     id: readerRoot
//     anchors.fill: parent

//     Rectangle {
//         anchors.fill: parent
//         color: "#11111b" // Делаем фон чуть темнее, чтобы глаза не уставали при чтении

//         Text {
//             anchors.centerIn: parent
//             text: "Тут будут страницы манги!\n(Мы загрузим их через Rust)"
//             color: "white"
//             font.pixelSize: 18
//             horizontalAlignment: Text.AlignHCenter
//         }

//         // Кнопка "Назад"
//         Rectangle {
//             anchors.top: parent.top
//             anchors.left: parent.left
//             anchors.margins: 20
//             width: 100; height: 40
//             color: "#313244"
//             radius: 8

//             Text {
//                 anchors.centerIn: parent
//                 text: "<- Назад"
//                 color: "white"
//                 font.bold: true
//             }

//             MouseArea {
//                 anchors.fill: parent
//                 cursorShape: Qt.PointingHandCursor
//                 onClicked: {
//                     // Возвращаемся в библиотеку!
//                     reader.currentView = "library"
//                 }
//             }
//         }
//     }
// }