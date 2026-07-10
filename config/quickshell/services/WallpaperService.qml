import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service

    property var wallpaperList: []
    property var filteredWallpapers: []
    property string searchTerm: ""
    property string currentWallpaper: ""
    property bool wallsLoaded: false
    property string wallDir: Quickshell.env("HOME") + "/wallpapers"

    property color walBackground: "#1e1e2e"
    property color walForeground: "#cdd6f4"
    property color walColor1: "#f38ba8"
    property color walColor2: "#a6e3a1"
    property color walColor4: "#89b4fa"
    property color walColor5: "#f5c2e7"
    property color walColor8: "#585b70"
    property color walColor13: "#f5c2e7"
    property int wallSelectedIndex: 0

    // --- Железобетонный фильтр ---
    function updateFilters() {
        var term = service.searchTerm.toLowerCase().trim()
        var source = service.wallpaperList
        
        if (source.length === 0) {
            service.filteredWallpapers = []
            return
        }
        
        if (term === "") {
            service.filteredWallpapers = source.slice()
            return
        }

        var result = []
        for (var i = 0; i < source.length; i++) {
            if (source[i].name.toLowerCase().includes(term)) {
                result.push(source[i])
            }
        }
        service.filteredWallpapers = result
    }

    onWallpaperListChanged: updateFilters()
    onSearchTermChanged: updateFilters()

    // --- Функции обоев ---
    function load() {
        wallsLoaded = false
        wallpaperList = []
        wallListProc.running = true
    }

    function apply(wallpaper) {
        if (!wallpaper || !wallpaper.path) return
        currentWallpaper = wallpaper.path
        
        // Меняем обои и генерируем новые цвета через wal
        applyWallProc.command = ["bash", "-c", `
            ln -sf '${wallpaper.path}' '${service.wallDir}/current'
            awww img '${wallpaper.path}' --transition-type any --transition-duration 2 &
            wal -i '${wallpaper.path}' -n -q
            sleep 0.3
        `]
        applyWallProc.running = true
    }

    // --- Процессы ---
    
    // 1. Поиск обоев
    Process {
        id: wallListProc
        command: ["bash", "-c", "find '" + service.wallDir + "' -maxdepth 1 -not -name 'current' -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \\) 2>/dev/null | sort"]
        stdout: SplitParser {
            onRead: data => {
                var path = data.trim()
                if (path === "") return
                var name = path.substring(path.lastIndexOf("/") + 1)
                
                var current = service.wallpaperList.slice()
                current.push({ name: name, path: path })
                service.wallpaperList = current
            }
        }
        onExited: service.wallsLoaded = true
    }

    // 2. Установка обоев
    Process { 
        id: applyWallProc 
        onExited: {
            // Как только pywal отработал, читаем новые цвета!
            colorReadProc.running = true
        }
    }

    // 3. ЧТЕНИЕ ЦВЕТОВ ИЗ PYWAL (МАГИЯ ЗДЕСЬ)
    Process {
        id: colorReadProc
        command: ["bash", "-c", "cat ~/.cache/wal/colors.json 2>/dev/null"]
        stdout: SplitParser {
            splitMarker: "" // Читаем весь файл целиком, а не по строкам
            onRead: data => {
                try {
                    let wal = JSON.parse(data.trim())
                    service.walBackground = wal.special.background
                    service.walForeground = wal.special.foreground
                    service.walColor1 = wal.colors.color1
                    service.walColor2 = wal.colors.color2
                    service.walColor4 = wal.colors.color4
                    service.walColor5 = wal.colors.color5
                    service.walColor8 = wal.colors.color8
                    service.walColor13 = wal.colors.color13
                } catch(e) {
                    console.log("QML: Не удалось прочитать цвета Pywal!")
                }
            }
        }
    }

    // --- АВТОЗАПУСК ---
    Component.onCompleted: {
        load() // Ищем картинки
        colorReadProc.running = true // Загружаем текущие цвета при старте
    }
}