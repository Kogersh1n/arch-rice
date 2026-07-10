import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "../components/music" 

PanelWindow {
    id: musicPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; left: true; right: true }
    margins { top: root.musicVisible ? 50 : -350; left: 0; right: 0 }
    implicitWidth: 400
    implicitHeight: musicPanel.gifSelectorOpen ? 460 : 188
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.musicVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.top { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    property string configPath: root.configPath
    property string gifPath: configPath + "/assets/gifs"
    
    // Свойства плеера (теперь они обновляются из Rust!)
    property string playerStatus: "Stopped"
    property string trackTitle: ""
    property string trackArtist: ""
    property real position: 0
    property real lastPosition: 0
    property real length: 0
    property bool hasTrack: playerStatus === "Playing" || playerStatus === "Paused"
    
    // Свойства гифок
    property var gifFiles: []
    property int currentGifIndex: root.savedGifIndex
    property int previewGifIndex: 0
    property bool gifSelectorOpen: false
    property bool gifsLoaded: false
    property int gifReloadCounter: 0
    property bool isApplyingGif: false
    property string currentGifSource: "file://" + gifPath + "/current.gif"
    property int pendingGifIndex: -1

    // --- Функции управления гифками ---
    function nextGif() { if (gifFiles.length > 0) previewGifIndex = (previewGifIndex + 1) % gifFiles.length }
    function prevGif() { if (gifFiles.length > 0) previewGifIndex = (previewGifIndex - 1 + gifFiles.length) % gifFiles.length }

    function applyGif() {
        if (isApplyingGif) return
        if (gifFiles.length > 0 && previewGifIndex < gifFiles.length) {
            isApplyingGif = true
            pendingGifIndex = previewGifIndex
            setGifProc.selFile = gifFiles[previewGifIndex]
            setGifProc.running = true
        }
    }

    function loadGifs() {
        if (gifListProc.running) return
        musicPanel.gifFiles = []
        musicPanel.gifsLoaded = false
        musicPanel.previewGifIndex = 0
        gifListProc.running = true
    }

    function reloadMainGif() {
        // 1. Жестко очищаем источник, чтобы сломать зависший кэш QML
        musicPanel.currentGifSource = "" 
        musicPanel.isApplyingGif = false
        musicPanel.pendingGifIndex = -1
        
        // 2. Даем движку 50 миллисекунд, чтобы понять, что гифки нет, и запускаем её заново
        gifKickstartTimer.start()
    }

    Timer {
        id: gifKickstartTimer
        interval: 50
        repeat: false
        onTriggered: {
            musicPanel.gifReloadCounter++
            musicPanel.currentGifSource = "file://" + gifPath + "/current.gif?v=" + musicPanel.gifReloadCounter + "&t=" + Date.now()
        }
    }


    function saveGifIndex() {
        stateService.save("gif-index", currentGifIndex.toString())
        stateService.savedGifIndex = currentGifIndex
    }
    

    onGifSelectorOpenChanged: { if (!gifSelectorOpen) previewGifIndex = currentGifIndex }

    // Timer { 
    //     id: gifReloadTimer
    //     interval: 250
    //     repeat: false
    //     onTriggered: musicPanel.reloadMainGif() 
    // }

    // --- ИНТЕРФЕЙС ---
    Item {
        anchors.fill: parent
        focus: root.musicVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (musicPanel.gifSelectorOpen) musicPanel.gifSelectorOpen = false
                else root.musicVisible = false
                event.accepted = true
            } else if (event.key === Qt.Key_Space && !musicPanel.gifSelectorOpen) {
                if (!playPauseProc.running) playPauseProc.running = true
                event.accepted = true
            } else if (event.key === Qt.Key_N && !musicPanel.gifSelectorOpen) {
                if (!nextProc.running) nextProc.running = true
                event.accepted = true
            } else if (event.key === Qt.Key_P && !musicPanel.gifSelectorOpen) {
                if (!prevProc.running) prevProc.running = true
                event.accepted = true
            } else if (event.key === Qt.Key_Left && musicPanel.gifSelectorOpen) {
                musicPanel.prevGif()
                event.accepted = true
            } else if (event.key === Qt.Key_Right && musicPanel.gifSelectorOpen) {
                musicPanel.nextGif()
                event.accepted = true
            } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && musicPanel.gifSelectorOpen) {
                if (musicPanel.previewGifIndex !== musicPanel.currentGifIndex) musicPanel.applyGif()
                event.accepted = true
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Rectangle {
                width: 400
                height: 180
                color: {
                    let c = root.walBackground;
                    if (!c || typeof c.r === 'undefined') return Qt.rgba(0.1, 0.1, 0.1, 0.7);
                    return Qt.rgba(c.r, c.g, c.b, 0.7);
                }
                radius: 15
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    PlaybackControls {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: musicPanel.trackTitle
                        artist: musicPanel.trackArtist
                        position: musicPanel.position
                        length: musicPanel.length
                        status: musicPanel.playerStatus
                        hasTrack: musicPanel.hasTrack
                        
                        onSeekRequested: (pos) => { 
                            seekProc.command = ["playerctl", "position", pos.toString()]
                            seekProc.running = true 
                        }
                        onPrevClicked: if (!prevProc.running) prevProc.running = true
                        onNextClicked: if (!nextProc.running) nextProc.running = true
                        onPlayPauseClicked: if (!playPauseProc.running) playPauseProc.running = true
                    }

                    ActiveGif {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 160
                        Layout.alignment: Qt.AlignBottom
                        gifSource: musicPanel.currentGifSource
                        status: musicPanel.playerStatus
                        isActive: !musicPanel.isApplyingGif 
                        onToggleSelector: {
                            if (!musicPanel.gifSelectorOpen) { 
                                musicPanel.loadGifs()
                                musicPanel.gifSelectorOpen = true 
                            } else {
                                musicPanel.gifSelectorOpen = false
                            }
                        }
                    }
                }

                MouseArea { anchors.fill: parent; visible: musicPanel.gifSelectorOpen; onClicked: musicPanel.gifSelectorOpen = false; z: -1 }
            }

            GifSelectorDropdown {
                anchors.horizontalCenter: parent.horizontalCenter
                isOpen: musicPanel.gifSelectorOpen
                gifFiles: musicPanel.gifFiles
                previewIndex: musicPanel.previewGifIndex
                currentIndex: musicPanel.currentGifIndex
                isLoaded: musicPanel.gifsLoaded
                isApplying: musicPanel.isApplyingGif

                onCloseClicked: musicPanel.gifSelectorOpen = false
                onPrevClicked: musicPanel.prevGif()
                onNextClicked: musicPanel.nextGif()
                onApplyClicked: musicPanel.applyGif()
            }
        }
    }

    // --- Управление фокусом ---
    Connections { target: root; function onMusicVisibleChanged() { if (root.musicVisible) focusTimer.start() } }
    Timer { id: focusTimer; interval: 50; repeat: false; onTriggered: { musicPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive; releaseTimer.start() } }
    Timer { id: releaseTimer; interval: 100; repeat: false; onTriggered: { musicPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand } }

    // --- ФОНОВЫЕ ПРОЦЕССЫ ---
    
    // Процессы для смены гифок
    Process {
        id: gifListProc
        command: ["sh", "-c", "find '" + musicPanel.gifPath + "' -maxdepth 1 -name '*.gif' ! -name 'current.gif' -type f 2>/dev/null | sort"]
        stdout: SplitParser { onRead: data => { var f = data.trim(); if (f) { var c = musicPanel.gifFiles.slice(); c.push(f); musicPanel.gifFiles = c } } }
        onExited: { musicPanel.gifsLoaded = true; if (musicPanel.gifFiles.length > 0) musicPanel.previewGifIndex = Math.min(musicPanel.currentGifIndex, musicPanel.gifFiles.length - 1) }
    }

    Process {
        id: setGifProc
        property string selFile: ""
        command: ["cp", selFile, musicPanel.gifPath + "/current.gif"]
        onExited: code => {
            if (code === 0 && musicPanel.pendingGifIndex >= 0) {
                musicPanel.currentGifIndex = musicPanel.pendingGifIndex; musicPanel.gifSelectorOpen = false; musicPanel.saveGifIndex(); musicPanel.reloadMainGif()
            } else { musicPanel.isApplyingGif = false; musicPanel.pendingGifIndex = -1 }
        }
    }

    // =========================================================
    // НАШ НОВЫЙ МАГИЧЕСКИЙ ДЕМОН НА RUST
    // =========================================================
    Process {
        id: rustMusicMonitorProc
        command: [musicPanel.configPath + "/scripts/music_monitor"]
        running: true // Запускаем его навсегда, он почти не жрет ресурсов
        
        stdout: SplitParser { 
            onRead: data => {
                var parts = data.trim().split("|")
                if (parts.length >= 5) {
                    var newStatus = parts[0]
                    var newTitle = parts[1]

                    // ФИКС: Сравниваем иначе! Если пришло НОВОЕ валидное название, которого у нас не было.
                    var isNewTrack = (musicPanel.trackTitle !== newTitle && newTitle !== "")

                    musicPanel.playerStatus = newStatus
                    musicPanel.trackTitle = newTitle
                    musicPanel.trackArtist = parts[2]
                    musicPanel.length = parseFloat(parts[4]) || 0
                    
                    if (isNewTrack) {
                        musicPanel.position = 0 
                        musicPanel.reloadMainGif() 
                    } else {
                        musicPanel.position = parseFloat(parts[3]) || 0
                    }
                    
                } else if (parts[0] === "Stopped" || parts[0] === "") {
                    musicPanel.playerStatus = "Stopped"
                    musicPanel.trackTitle = ""
                    musicPanel.trackArtist = ""
                    musicPanel.position = 0
                    musicPanel.length = 0
                }
            } 
        }
    }

    // --- УПРАВЛЕНИЕ ПЛЕЕРОМ (КЛИКИ) ---
    // Обрати внимание: мы убрали из них onExited! Нам больше не нужно 
    // заставлять QML перепроверять статус. Rust сам моментально заметит 
    // переключение по D-Bus и обновит интерфейс!
    
    Process { id: playPauseProc; command: ["playerctl", "play-pause"] }
    Process { id: nextProc; command: ["playerctl", "next"] }
    Process { id: prevProc; command: ["playerctl", "previous"] }
    Process { id: seekProc; command: ["playerctl", "position", "0"] }
}