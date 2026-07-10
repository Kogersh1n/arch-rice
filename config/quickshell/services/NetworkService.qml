import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service

    // ==========================================
    //                 WIFI
    // ==========================================
    property bool wifiEnabled: true
    property string wifiCurrentSSID: ""
    property int wifiSignal: 0
    property var wifiNetworks: []
    property bool wifiScanning: false
    property bool wifiConnecting: false

    function refreshWifi() {
        service.wifiNetworks = []
        service.wifiScanning = true
        if (!wifiStatusProc.running) wifiStatusProc.running = true
        if (!wifiCurrentProc.running) wifiCurrentProc.running = true
        
        if (!wifiScanProc.running) {
            wifiScanProc.running = true
        } else {
            service.wifiScanning = true 
        }
    }

    

    function toggleWifiAdapter() {
        if (wifiToggleProc.running) return // Защита от спама кликами
        wifiToggleProc.command = ["bash", "-c", wifiEnabled ? "nmcli radio wifi off" : "nmcli radio wifi on"]
        wifiToggleProc.running = true
    }

    function connectWifi(ssid, password) {
        wifiConnecting = true
        if (password !== "") {
            wifiConnectProc.command = ["bash", "-c", `nmcli dev wifi connect '${ssid}' password '${password}' 2>&1`]
        } else {
            wifiConnectProc.command = ["bash", "-c", `nmcli dev wifi connect '${ssid}' 2>&1`]
        }
        wifiConnectProc.running = true
    }

    function connectEnterpriseWifi(ssid, login, password) {
        wifiConnecting = true
        let cmd = `
            nmcli connection delete '${ssid}' 2/dev/null;
            nmcli con add type wifi con-name '${ssid}' ifname $(nmcli -t -f device,type dev | grep ':wifi$' | cut -d: -f1 | head -1) ssid '${ssid}' -- wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 802-1x.identity '${login}' 802-1x.password '${password}' 802-1x.system-ca-certs no && nmcli con up '${ssid}'
        `
        wifiConnectProc.command = ['bash', '-c', cmd]
        wifiConnectProc.running = true

    }


    function disconnectWifi() {
        wifiDisconnectProc.command = ["bash", "-c", `
            nmcli dev disconnect wlan0 2>/dev/null
            nmcli dev disconnect wlp0s20f3 2>/dev/null
            nmcli dev disconnect $(nmcli -t -f device,type dev | grep ':wifi$' | cut -d: -f1 | head -1) 2>/dev/null
        `]
        wifiDisconnectProc.running = true
    }

    // --- Процессы WiFi ---

    Process {
        id: wifiStatusProc
        command: ["bash", "-c", "nmcli radio wifi 2>/dev/null || echo 'disabled'"]
        stdout: SplitParser { onRead: data => wifiEnabled = (data.trim() === "enabled") }
    }

    Process {
        id: wifiCurrentProc
        command: ["bash", "-c", "nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes' | head -1"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(":")
                if (parts.length >= 3) {
                    wifiCurrentSSID = parts[1]
                    wifiSignal = parseInt(parts[2]) || 0
                } else {
                    wifiCurrentSSID = ""
                    wifiSignal = 0
                }
            }
        }
    }

    Process {
        id: wifiScanProc
        command: [
            "bash", "-c", `
            export LC_ALL=C
            
            # 1. Ищем сохраненные сети. На Arch тип = 'wifi'
            known=$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wifi" || $2=="802-11-wireless" {print $1}')
            
            # 2. Выводим IN-USE (звездочка для активной), SSID, SIGNAL, SECURITY
            nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan no 2>/dev/null | head -30 | while IFS=: read -r inuse ssid signal security; do
                # Пропускаем пустые скрытые сети
                if [ -z "$ssid" ] || [ "$ssid" = "--" ]; then continue; fi
                
                # 3. ФИЛЬТРАЦИЯ: Если сеть текущая (отмечена *), просто пропускаем ее
                if echo "$inuse" | grep -q "*"; then continue; fi
                
                # 4. Проверка на Saved
                saved="false"
                if echo "$known" | grep -Fqx "$ssid"; then saved="true"; fi
                
                echo "$ssid|$signal|$security|$saved"
            done
            
            nmcli dev wifi rescan >/dev/null 2>&1 &
        `]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line === "") return
                var parts = line.split("|")
                if (parts.length < 2) return
                
                var ssid = parts[0]
                // Явно обращаемся к service, чтобы не потерять контекст
                if (ssid === "" || ssid === service.wifiCurrentSSID) return
                
                var signal = parseInt(parts[1]) || 0
                var security = parts.length >= 3 ? parts[2] : ""
                var saved = (parts[3] == "true")
                
                // Классическая проверка на дубликаты вместо .some()
                var exists = false
                var currentNetworks = service.wifiNetworks
                for (var i = 0; i < currentNetworks.length; i++) {
                    if (currentNetworks[i].ssid === ssid) {
                        exists = true
                        break
                    }
                }
                
                if (!exists) {
                    var current = currentNetworks.slice() 
                    current.push({ ssid: ssid, signal: signal, security: security, saved: saved })
                    service.wifiNetworks = current 
                }
            }
        }
        onExited: service.wifiScanning = false
    }

    Process {
        id: wifiToggleProc
        onExited: {
            wifiStatusProc.running = true
            if (!wifiEnabled) wifiScanDelayTimer.start()
        }
    }

    Process {
        id: wifiConnectProc
        onExited: {
            wifiConnecting = false
            wifiCurrentProc.running = true
        }
    }

    Process {
        id: wifiDisconnectProc
        onExited: {
            wifiCurrentSSID = ""
            wifiSignal = 0
        }
    }

    Timer {
        id: wifiScanDelayTimer
        interval: 2000
        repeat: false
        onTriggered: refreshWifi()
    }

    // ==========================================
    //               BLUETOOTH
    // ==========================================
    property bool btEnabled: true
    property var btPairedDevices: []
    property var btAvailableDevices: []
    property bool btScanning: false
    property string btConnectingMAC: ""


    function startBluetoothScan() {
        if (!btScanProc.running) {
            btScanProc.running = true
        }
    }

    function refreshBluetooth() {
        service.btPairedDevices = []
        service.btAvailableDevices = []
        service.btScanning = false
        service.btConnectingMAC = ""
        if (!btStatusProc.running) btStatusProc.running = true
    }

    function toggleBtAdapter() {
        if (btToggleOnProc.running || btToggleOffProc.running) return
        if (btEnabled) {
            btToggleOffProc.running = true
        } else {
            btToggleOnProc.running = true
        }
    }

    function connectBt(mac) {
        btConnectingMAC = mac
        btActionProc.command = ["bash", "-c", `(echo 'trust ${mac}'; echo 'connect ${mac}'; sleep 2; echo 'quit') | bluetoothctl 2>/dev/null`]
        btActionProc.running = true
    }

    function disconnectBt(mac) {
        btActionProc.command = ["bash", "-c", `echo -e 'disconnect ${mac}\\nquit' | bluetoothctl 2>/dev/null`]
        btActionProc.running = true
    }

    function pairBt(mac) {
        btConnectingMAC = mac
        btActionProc.command = ["bash", "-c", `
            echo -e 'pair ${mac}\\nquit' | bluetoothctl 2>/dev/null
            sleep 2
            echo -e 'trust ${mac}\\nquit' | bluetoothctl 2>/dev/null
            sleep 1
            echo -e 'connect ${mac}\\nquit' | bluetoothctl 2>/dev/null
        `]
        btActionProc.running = true
    }

    function forgetBt(mac) {
        btActionProc.command = ["bash", "-c", `echo -e 'remove ${mac}\\nquit' | bluetoothctl 2>/dev/null`]
        btActionProc.running = true
    }

    // --- Процессы Bluetooth ---

    Process {
        id: btStatusProc
        command: ["bash", "-c", "echo -e 'show\\nquit' | bluetoothctl 2>/dev/null | grep -q 'Powered: yes' && echo 'true' || echo 'false'"]
        stdout: SplitParser { onRead: data => btEnabled = (data.trim() === "true") }
        onExited: {
            if (btEnabled) btDevicesProc.running = true
        }
    }

    Process {
        id: btToggleOnProc
        command: ["bash", "-c", "echo -e 'power on\\nquit' | bluetoothctl 2>/dev/null"]
        onExited: btToggleDelayTimer.start()
    }

    Process {
        id: btToggleOffProc
        command: ["bash", "-c", "echo -e 'power off\\nquit' | bluetoothctl 2>/dev/null"]
        onExited: {
            btEnabled = false
            btPairedDevices = []
            btAvailableDevices = []
        }
    }

    Process {
        id: btDevicesProc
        command: ["bash", "-c", `
            echo -e 'devices\\nquit' | bluetoothctl 2>/dev/null | grep '^Device' | while read -r line; do
                mac=$(echo "$line" | awk '{print $2}')
                name=$(echo "$line" | cut -d' ' -f3-)
                info=$(echo -e "info $mac\\nquit" | bluetoothctl 2>/dev/null)
                paired=$(echo "$info" | grep -oP 'Paired: \K\w+')
                connected=$(echo "$info" | grep -oP 'Connected: \K\w+')
                if [ "$paired" = "yes" ]; then
                    echo "$mac|$name|$connected"
                fi
            done
        `]
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim()
                if (line === "") return
                let parts = line.split("|")
                if (parts.length < 3) return
                
                let mac = parts[0]
                let name = parts[1]
                let connected = (parts[2] === "yes")
                
                if (!btPairedDevices.some(dev => dev.mac === mac)) {
                    let current = btPairedDevices.slice()
                    current.push({ mac: mac, name: name, connected: connected })
                    btPairedDevices = current
                }
            }
        }
    }

    Process {
        id: btScanProc
        command: ["bash", "-c", `
            echo -e 'scan on\\nquit' | bluetoothctl 2>/dev/null
            sleep 5
            echo -e 'scan off\\nquit' | bluetoothctl 2>/dev/null
            sleep 1
            echo -e 'devices\\nquit' | bluetoothctl 2>/dev/null | grep '^Device' | while read -r line; do
                mac=$(echo "$line" | awk '{print $2}')
                name=$(echo "$line" | cut -d' ' -f3-)
                info=$(echo -e "info $mac\\nquit" | bluetoothctl 2>/dev/null)
                paired=$(echo "$info" | grep -oP 'Paired: \K\w+')
                if [ "$paired" != "yes" ] && [ -n "$name" ] && [ "$name" != "$mac" ]; then
                    echo "$mac|$name"
                fi
            done
        `]
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim()
                if (line === "") return
                let parts = line.split("|")
                if (parts.length < 2) return
                
                let mac = parts[0]
                let name = parts[1]
                if (mac.length !== 17) return // Базовая проверка валидности MAC-адреса
                
                if (!btAvailableDevices.some(dev => dev.mac === mac)) {
                    let current = btAvailableDevices.slice()
                    current.push({ mac: mac, name: name })
                    btAvailableDevices = current
                }
            }
        }
        onExited: btScanning = false
    }

    Process {
        id: btActionProc
        onExited: {
            btConnectingMAC = ""
            btActionDelayTimer.start()
        }
    }

    Timer { id: btToggleDelayTimer; interval: 1000; repeat: false; onTriggered: refreshBluetooth() }
    Timer { id: btActionDelayTimer; interval: 1500; repeat: false; onTriggered: refreshBluetooth() }
}