import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

Rectangle {
    id: profileSection
    Layout.fillWidth: true
    Layout.preferredHeight: pfpPickerOpen ? 280 : 100
    color: Qt.rgba(0, 0, 0, 0.3)
    radius: 15
    clip: true
    
    property bool pfpPickerOpen: false
    property string configPath: Quickshell.env("HOME") + "/.config/quickshell"
    
    // Свойство, которое мы будем передавать из главного окна
    property var pfpFiles: [] 
    
    // Сигнал, чтобы главное окно могло закрыть Picker при клике вне него
    signal closePicker()
    onClosePicker: pfpPickerOpen = false

    Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            
            // БЛОК АВАТАРКИ
            Item {
                id: pfpContainer
                width: 74
                height: 74
                
                Rectangle {
                    id: pfpBorder
                    anchors.fill: parent
                    radius: 37
                    color: "transparent"
                    border.width: 3
                    border.color: root.walColor5
                }
                
                Image {
                    id: pfpImage
                    anchors.centerIn: parent
                    width: 68
                    height: 68
                    source: "file://" + profileSection.configPath + "/assets/pfps/pfp.jpg"
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    cache: false
                    sourceSize.width: 256
                    sourceSize.height: 256
                    visible: false
                    
                    property int reloadTrigger: 0
                    function reload() {
                        reloadTrigger++
                        source = ""
                        source = "file://" + profileSection.configPath + "/assets/pfps/pfp.jpg?" + reloadTrigger
                    }
                }
                
                Rectangle {
                    id: pfpMask
                    anchors.centerIn: parent
                    width: 68
                    height: 68
                    radius: 34
                    visible: false
                }
                
                OpacityMask {
                    anchors.centerIn: parent
                    width: 68
                    height: 68
                    source: pfpImage
                    maskSource: pfpMask
                }
                
                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    width: 22
                    height: 22
                    radius: 11
                    color: root.walColor5
                    border.width: 2
                    border.color: root.walBackground
                    Text {
                        anchors.centerIn: parent
                        text: "󰏫"
                        color: root.walBackground
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        profileSection.pfpPickerOpen = !profileSection.pfpPickerOpen
                        if (profileSection.pfpPickerOpen) {
                            profileSection.pfpFiles = []
                            pfpListProc.running = true
                        }
                    }
                }
            }
            
            // ИМЯ И АПТАЙМ
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                Text {
                    text: Quickshell.env("USER")
                    color: root.walColor5
                    font.pixelSize: 26
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
                Text {
                    id: uptimeText
                    text: "up ..."
                    color: root.walForeground
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }
        
        // ВЫБОР АВАТАРКИ (ГАЛЕРЕЯ)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.rgba(0, 0, 0, 0.3)
            radius: 10
            visible: profileSection.pfpPickerOpen
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                
                Text {
                    text: "Choose Avatar"
                    color: root.walColor5
                    font.pixelSize: 12
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: pfpGrid.height
                    clip: true
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    
                    GridLayout {
                        id: pfpGrid
                        width: parent.width
                        columns: 6
                        rowSpacing: 8
                        columnSpacing: 8
                        
                        Repeater {
                            model: profileSection.pfpFiles
                            Item {
                                width: 48
                                height: 48
                                Layout.alignment: Qt.AlignHCenter
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 24
                                    color: "transparent"
                                    border.width: 2
                                    border.color: thumbMa.containsMouse ? root.walColor13 : root.walColor5
                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                }
                                Image {
                                    id: thumbImg
                                    anchors.centerIn: parent
                                    width: 44
                                    height: 44
                                    source: "file://" + modelData
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    sourceSize.width: 128
                                    sourceSize.height: 128
                                    visible: false
                                }
                                Rectangle {
                                    id: thumbMask
                                    anchors.centerIn: parent
                                    width: 44
                                    height: 44
                                    radius: 22
                                    visible: false
                                }
                                OpacityMask {
                                    anchors.centerIn: parent
                                    width: 44
                                    height: 44
                                    source: thumbImg
                                    maskSource: thumbMask
                                }
                                MouseArea {
                                    id: thumbMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        setPfpProc.selFile = modelData
                                        setPfpProc.running = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- ПРОЦЕССЫ И ТАЙМЕРЫ ---
    
    // Получение аптайма (каждые 60 сек)
    Timer {
        interval: 60000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { if (!uptimeProc.running) uptimeProc.running = true }
    }
    
    Process {
        id: uptimeProc
        command: ["bash", "-c", "uptime -p"]
        stdout: SplitParser { onRead: data => uptimeText.text = data.trim() }
    }

    // Поиск картинок
    Process {
        id: pfpListProc
        command: ["bash", "-c", "find " + profileSection.configPath + "/assets/pfps -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.gif' \\) ! -name 'pfp.jpg' | sort"]
        stdout: SplitParser {
            onRead: data => {
                var file = data.trim()
                if (file.length > 0) {
                    var current = profileSection.pfpFiles.slice()
                    current.push(file)
                    profileSection.pfpFiles = current
                }
            }
        }
    }
    
    // Установка картинки
    Process {
        id: setPfpProc
        property string selFile: ""
        command: ["bash", "-c", "cp '" + selFile + "' " + profileSection.configPath + "/assets/pfps/pfp.jpg"]
        onExited: {
            pfpImage.reload()
            profileSection.pfpPickerOpen = false
        }
    }
}