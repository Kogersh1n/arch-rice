import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service

    // --- Публичные свойства ---
    property var appList: []
    property var appUsage: ({})
    property string searchTerm: ""
    property int selectedIndex: 0
    property int wallSelectedIndex: 0
    
    property var filteredApps: []

    // Временный массив для быстрой загрузки
    property var _tempList: []

    // --- Сигналы ---
    signal appLaunched()

    // --- Функция ручного обновления фильтра ---
    function updateFilters() {
        var term = service.searchTerm.toLowerCase().trim();
        var allApps = service.appList; 
        var usage = service.appUsage;

        if (allApps.length === 0) {
            service.filteredApps = [];
            return;
        }

        var result = [];

        // 1. Фильтрация
        if (term !== "") {
            for (var i = 0; i < allApps.length; i++) {
                var app = allApps[i];
                if (app.name.toLowerCase().includes(term) || app.exec.toLowerCase().includes(term)) {
                    result.push(app);
                }
            }
        } else {
            result = allApps.slice();
        }

        // 2. Сортировка по частоте
        result.sort(function(a, b) {
            var countA = usage[a.name] || 0;
            var countB = usage[b.name] || 0;
            if (countB !== countA) return countB - countA;
            return a.name.localeCompare(b.name);
        });

        // 3. Отдаем готовый результат в UI
        service.filteredApps = result;
    }

    // ЗАСТАВЛЯЕМ QML обновлять список при любом изменении:
    onAppListChanged: updateFilters()
    onSearchTermChanged: updateFilters()
    onAppUsageChanged: updateFilters()

    // --- Публичные функции ---

    function load() {
        // Очищаем и подготавливаем временный массив
        _tempList = []
        loadUsageProc.running = true
        appListProc.running = true
    }

    function launch(app) {
        if (!app || !app.exec) return

        // Надежный запуск через hyprctl без конфликта кавычек
        launchProc.command = ["bash", "-c", `hyprctl dispatch exec -- ${app.exec}`]
        launchProc.running = true

        // Обновление статистики использования
        var updated = Object.assign({}, service.appUsage)
        updated[app.name] = (updated[app.name] || 0) + 1
        service.appUsage = updated

        // Сохранение статистики на диск
        saveUsageProc.command = ["bash", "-c", `echo '${JSON.stringify(updated)}' > '${root.configPath}/app_usage.json'`]
        saveUsageProc.running = true

        // Оповещаем UI, что запуск произошел
        service.appLaunched()
    }

    // --- Логика процессов ---

    // 1. Загрузка статистики использования
    Process {
        id: loadUsageProc
        command: ["bash", "-c", `cat '${root.configPath}/app_usage.json' 2>/dev/null || echo '{}'`]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try { 
                    appUsage = JSON.parse(data.trim()) 
                } catch(e) { 
                    appUsage = {} 
                }
            }
        }
    }

    // 2. Парсинг .desktop файлов
    Process {
        id: appListProc
        command: ["bash", "-c", `
            awk -F= '
            /^\\[Desktop Entry\\]/ {
                if (name != "" && exec != "" && !skip) {
                    gsub(/ %[a-zA-Z]/, "", exec);
                    print name "\\t" exec "\\t" icon;
                }
                name=""; exec=""; icon=""; skip=0; in_desktop=1; next
            }
            /^\\[/ && !/^\\[Desktop Entry\\]/ { in_desktop=0 }
            in_desktop {
                if ($1=="NoDisplay" && tolower($2)=="true") skip=1;
                if ($1=="Hidden" && tolower($2)=="true") skip=1;
                if ($1=="Name" && name=="") name=$2;
                if ($1=="Exec" && exec=="") exec=$2;
                if ($1=="Icon" && icon=="") icon=$2;
            }
            END {
                if (name != "" && exec != "" && !skip) {
                    gsub(/ %[a-zA-Z]/, "", exec);
                    print name "\\t" exec "\\t" icon;
                }
            }' /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop 2>/dev/null | sort -t$'\\t' -k1,1 -u
        `]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length === 0) return
                
                var parts = line.split("\t")
                if (parts.length < 2) return
                
                // ТИХО добавляем во временный массив (без обновления UI)
                service._tempList.push({ 
                    name: parts[0], 
                    exec: parts[1], 
                    icon: parts.length > 2 ? parts[2] : "" 
                })
            }
        }
        onExited: {
            // КОРОННЫЙ УДАР: Отдаем готовый список в UI ОДИН раз
            service.appList = service._tempList
        }
    }

    Process { id: launchProc }
    Process { id: saveUsageProc }
}