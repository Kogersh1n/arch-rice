import QtQuick
import QtQuick.Layouts

Rectangle {
    id: delegateRoot
    
    property var netData 
    property color walColor5
    property color walColor8
    property color walForeground
    
    signal requirePassword(string ssid, bool isEnterprise)
    signal connectDirectly(string ssid)

    width: ListView.view.width
    height: 44
    radius: 10
    color: wifiNetMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
    
    Behavior on color { ColorAnimation { duration: 120 } }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10
        
        Text {
            // ИЗМЕНЕНИЕ: используем netData
            text: netData.signal > 66 ? "󰤨" : netData.signal > 33 ? "󰤥" : "󰤟"
            color: walColor5
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Text {
                text: netData.ssid
                color: walForeground
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: (netData.saved ? "󰆓 Saved" : (netData.security !== "" && netData.security !== "--" ? "󰌾 " + netData.security : "Open")) + " · " + netData.signal + "%"
                color: walColor8
                font.pixelSize: 9
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }
    
    MouseArea {
        id: wifiNetMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            let isKnownNetwork = netData.saved === true || netData.known === true;

            let secString = netData.security.toLowerCase()
            let isEnterprise = secString.includes('802.1x') || secString.includes('enterprise')

            if (netData.security !== "" && netData.security !== "--" && !isKnownNetwork) {
                delegateRoot.requirePassword(netData.ssid, isEnterprise)    
            } else {
                delegateRoot.connectDirectly(netData.ssid)
            }
        }
    }
}