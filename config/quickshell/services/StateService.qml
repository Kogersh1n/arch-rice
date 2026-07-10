import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service

    // --- Свойства ---
    property string stateDir: root.configPath + "/state"
    property int savedGifIndex: 0

    // Универсальный коллбэк для одиночных загрузок
    property var currentCallback: null

    // --- Инициализация ---
    function init() {
        initProc.running = true
    }

    Process {
        id: initProc
        command: ["mkdir", "-p", stateDir]
        onExited: {
            // Сразу после создания папки грузим критичные стейты
            loadGifIndexProc.running = true
        }
    }

    // --- Специфичные стейты (Безопасный подход) ---
    Process {
        id: loadGifIndexProc
        command: ["bash", "-c", `cat '${stateDir}/gif-index' 2>/dev/null || echo '0'`]
        stdout: SplitParser {
            onRead: data => {
                let idx = parseInt(data.trim(), 10)
                savedGifIndex = isNaN(idx) ? 0 : idx
            }
        }
    }

    // --- Универсальные функции ---
    
    // Сохранение любого ключа
    function save(key, value) {
        saveStateProc.command = ["bash", "-c", `mkdir -p '${stateDir}' && echo '${value}' > '${stateDir}/${key}'`]
        saveStateProc.running = true
    }

    Process { id: saveStateProc }

    // Загрузка любого ключа (Осторожно: не вызывай дважды подряд без задержки)
    function load(key, callback) {
        currentCallback = callback
        loadStateProc.command = ["cat", `${stateDir}/${key}`]
        loadStateProc.running = true
    }

    Process {
        id: loadStateProc
        stdout: SplitParser {
            onRead: data => {
                if (service.currentCallback) {
                    service.currentCallback(data.trim())
                    service.currentCallback = null // Очищаем после использования
                }
            }
        }
    }
}