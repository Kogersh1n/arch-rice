import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../core"

Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 50
    color: Qt.rgba(0, 0, 0, 0.3)
    radius: 15
    
    Row {
        anchors.centerIn: parent
        spacing: 25
        PowerBtn { icon: "⏻"; iconColor: root.walColor2; cmd: "systemctl poweroff" }
        PowerBtn { icon: "󰜉"; iconColor: root.walColor13; cmd: "systemctl reboot" }
        PowerBtn { icon: "󰌾"; iconColor: root.walColor5; cmd: "hyprlock" }
        PowerBtn { icon: "󰒲"; iconColor: root.walColor4; cmd: "systemctl suspend" }
        PowerBtn { icon: "󰍃"; iconColor: root.walColor1; cmd: "hyprctl dispatch exit" }
    }
}