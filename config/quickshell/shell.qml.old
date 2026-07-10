import Quickshell
import Quickshell.Io
import QtQuick
import "./services"
import "./components"
// import "./components/mangareader"

ShellRoot {
    id: root

    // --- Глобальные пути ---
    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell"
    readonly property string homePath: Quickshell.env("HOME")
    readonly property string cachePath: homePath + "/.cache"
    readonly property string wallpaperPath: homePath + "/wallpapers"

    // --- Флаги видимости UI ---
    property bool dashboardVisible: false
    property bool musicVisible: false
    property bool launcherVisible: false
    property bool wallpaperVisible: false
    property bool wifiVisible: false
    property bool btVisible: false
    property bool readerVisible: false
    property alias savedGifIndex: stateService.savedGifIndex

    property int selectedIndex: 0
    property int wallSelectedIndex: 0

    // --- Centralized Theme System ---
    property alias theme: themeSystem
    QtObject {
        id: themeSystem
        // Panel settings
        readonly property int panelRadius: 16
        readonly property real panelOpacity: 0.92
        readonly property real borderOpacity: 0.08
        
        // Card / Container settings
        readonly property int cardRadius: 12
        readonly property color cardBackground: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.45)
        readonly property color cardBorder: Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.12)
        
        // Font families
        readonly property string textFont: "Inter"
        readonly property string iconFont: "JetBrainsMono Nerd Font"
    }

    // --- Подключение модулей (Сервисов) ---
    StateService { id: stateService }
    WallpaperService { id: wallService }
    AppService { 
        id: appService 
        onAppLaunched: root.launcherVisible = false 
    }
    NetworkService { id: netService }

    // МАГИЧЕСКИЙ МОСТ (Прокидываем свойства для старых компонентов)
    // Цвета
    property color walBackground: wallService.walBackground
    property color walForeground: wallService.walForeground
    property color walColor1: wallService.walColor1
    property color walColor2: wallService.walColor2
    property color walColor4: wallService.walColor4
    property color walColor5: wallService.walColor5
    property color walColor8: wallService.walColor8
    property color walColor13: wallService.walColor13

    // Сеть
    property bool wifiEnabled: netService.wifiEnabled
    property string wifiCurrentSSID: netService.wifiCurrentSSID
    property int wifiSignal: netService.wifiSignal
    property var wifiNetworks: netService.wifiNetworks
    property bool btEnabled: netService.btEnabled
    property var btPairedDevices: netService.btPairedDevices

    // Приложения
    property var filteredApps: appService.filteredApps
    property string searchTerm: appService.searchTerm


    // --- Инициализация при запуске ---
    Component.onCompleted: {
        stateService.init() // Создаст папки и подтянет GifIndex
        wallService.load()  // Подгрузит список обоев и цвета Pywal
        appService.load()   // Спасит .desktop файлы
    }

    // --- Функции управления UI ---
    function closeAllPanels() {
        dashboardVisible = false
        musicVisible = false
        launcherVisible = false
        wallpaperVisible = false
        wifiVisible = false
        btVisible = false
        readerVisible = false
    }

    function toggleLauncher() {
        launcherVisible = !launcherVisible
        if (launcherVisible) {
            wallpaperVisible = false
            dashboardVisible = false
            wifiVisible = false
            btVisible = false
        }
    }

    function toggleWallpaper() {
        wallpaperVisible = !wallpaperVisible
        if (wallpaperVisible) {
            launcherVisible = false
            dashboardVisible = false
            wifiVisible = false
            btVisible = false
        }
    }

    function toggleMusic() { musicVisible = !musicVisible }
    
    function toggleDashboard() {
        dashboardVisible = !dashboardVisible
        if (dashboardVisible) { 
            wifiVisible = false
            btVisible = false 
            launcherVisible = false
            wallpaperVisible = false
        }
    }

    // function toggleReader() {
    //     readerVisible = !readerVisible
    //     if (readerVisible) closeAllPanels()
    // }

    function toggleWifi() {
        wifiVisible = !wifiVisible
        if (wifiVisible) { 
            btVisible = false
            dashboardVisible = false
            launcherVisible = false
            wallpaperVisible = false
            netService.refreshWifi() 
        }
    }

    function toggleBluetooth() {
        btVisible = !btVisible
        if (btVisible) { 
            wifiVisible = false
            dashboardVisible = false
            launcherVisible = false
            wallpaperVisible = false
            netService.refreshBluetooth() 
        }
    }

    // --- UI Компоненты (Панели) ---
    Bar {}
    Dashboard { visible: dashboardVisible }
    MusicPanel { visible: musicVisible }
    WifiPanel { visible: wifiVisible }
    BluetoothPanel { visible: btVisible }
    LauncherPanel { visible: launcherVisible }
    WallpaperPanel { visible: wallpaperVisible }
    // Reader { visible: readerVisible }

    // --- IPC (Межпроцессное взаимодействие) ---
    IpcHandler { target: "dashboard"; function toggle() { root.toggleDashboard() } }
    IpcHandler { target: "music"; function toggle() { root.toggleMusic() } }
    IpcHandler { target: "wifi"; function toggle() { root.toggleWifi() } }
    IpcHandler { target: "bluetooth"; function toggle() { root.toggleBluetooth() } }
    // IpcHandler { target: "reader"; function toggle() { root.toggleReader() } }
    
    IpcHandler {
        target: "launcher"
        function toggle() {
            root.toggleLauncher()
        }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle() {
            root.toggleWallpaper()
        }
    }

    IpcHandler {
        target: "randomwallpaper"
        function apply(path: string) {
            wallService.apply({ path: path, name: path.split("/").pop() })
        }
    }
}