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
    radius: 14
    color: wifiNetMa.containsMouse ? Qt.rgba(walColor5.r, walColor5.g, walColor5.b, 0.12) : "transparent"
    
    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutQuad } }
    
    // Vertical Accent Bar on hover
    Rectangle {
        id: hoverIndicator
        width: 3
        height: parent.height - 16
        radius: 1.5
        color: walColor5
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        opacity: wifiNetMa.containsMouse ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12
        
        Text {
            text: {
                if (netData.signal > 75) return "󰤨"
                if (netData.signal > 50) return "󰤥"
                if (netData.signal > 25) return "󰤢"
                if (netData.signal > 10) return "󰤟"
                return "󰤯"
            }
            color: walColor5
            font.pixelSize: 17
            font.family: "JetBrainsMono Nerd Font"
            
            Behavior on color { ColorAnimation { duration: 200 } }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
                text: netData.ssid
                color: walForeground
                font.pixelSize: 13
                font.bold: wifiNetMa.containsMouse
                font.family: "Inter", "sans-serif"
                elide: Text.ElideRight
                Layout.fillWidth: true
                
                Behavior on font.bold { PropertyAnimation { duration: 100 } }
            }
            
            Text {
                text: (netData.saved ? "󰆓 Saved" : (netData.security && netData.security !== "--" ? "󰌾 " + netData.security : "Open")) + " · " + netData.signal + "%"
                color: walColor8
                font.pixelSize: 11
                font.family: "Inter", "sans-serif"
            }
        }
    }
    
    MouseArea {
        id: wifiNetMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            let isKnownNetwork = netData.saved === true || netData.known === true
            let secString = netData.security ? netData.security.toLowerCase() : ""
            let isEnterprise = secString.includes('802.1x') || secString.includes('enterprise')

            if (netData.security && netData.security !== "--" && !isKnownNetwork) {
                delegateRoot.requirePassword(netData.ssid, isEnterprise)    
            } else {
                delegateRoot.connectDirectly(netData.ssid)
            }
        }
    }
}