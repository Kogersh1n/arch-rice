// import Quickshell
// import Quickshell.Wayland
// import QtQuick
// import QtQuick.Layouts



// PanelWindow {
//     id: reader
//     visible: true
//     exclusionMode: ExclusionMode.Ignore
    
//     anchors { top: true; bottom: true; right: true }
    
//     margins { top: 40; bottom: 10; right: root.readerVisible ? 6 : -450 }
    
//     Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    
//     implicitWidth: 400
//     color: "transparent"
//     focusable: true

//     property string currentView: "library"

//     Item {
//         anchors.fill: parent
//         focus: root.readerVisible

//         Rectangle {
//             anchors.fill: parent
//             color: "#1e1e2e"
//             radius: 15
//             border.color: "#cba6f7" 
//             border.width: 2
//             clip: true


//             Loader {
//                 id: readerLoader
//                 anchors.fill: parent
//                 anchors.margins: 10
                
//                 source: reader.currentView === "library" ? "view/LibraryView.qml" : "view/ReaderView.qml"
//             }
//         }
//     }
// }