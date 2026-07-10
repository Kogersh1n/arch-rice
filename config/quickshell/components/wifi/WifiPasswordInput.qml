import QtQuick
import QtQuick.Layouts

Column {
    id: passInputRoot
    
    property string targetSSID: ""
    property bool isEnterprise: false
    property color walColor5
    property color walColor8
    property color walForeground
    property color walBackground

    // Сигнал, который передаст введенный пароль и логин
    signal submitCredentials(string login, string password)

    // Позволяем вызывать фокус извне
    function forceInputFocus() {
        if (isEnterprise) {
            wifiLoginInput.forceActiveFocus()
        }else{
            wifiPassInput.forceActiveFocus()
        }

    }

    function triggerSubmit(){
        if (isEnterprise){
            if (wifiLoginInput.text.length > 0 && wifiPassInput.text.length > 0){
                passInputRoot.submitCredentials(wifiLoginInput.text, wifiPassInput.text)
                wifiLoginInput.text = ''
                wifiPassInput.text = ''

            }
        }else{
            if (wifiPassInput.text.length > 0){
                passInputRoot.submitCredentials('', wifiPassInput.text)
                wifiPassInput.text = ''

            }
        }
    }
 

    Layout.fillWidth: true
    visible: targetSSID !== ""
    width: parent ? parent.width : 300
    spacing: 8

    Rectangle{
        width: parent.width  
        height: 36           
        radius: 10
        color: Qt.rgba(0,0,0,0.3)
        visible: passInputRoot.isEnterprise

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8
            
            Text {
                text: "󰌾"
                color: walColor8
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }
            
            TextInput {
                id: wifiLoginInput
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: walForeground
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                clip: true
                activeFocusOnPress: true
                
                Text {
                    text: "Password for " + targetSSID
                    color: walColor8
                    visible: !parent.text && !parent.activeFocus
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font: parent.font
                }
                
                Keys.onReturnPressed: wifiPassInput.forceActiveFocus()
                Keys.onTabPressed: wifiPassInput.forceActiveFocus()
            }
        }
    }

    Rectangle{
        width: parent.width  
        height: 36
        radius: 10
        color: Qt.rgba(0,0,0,0.3)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8
            
            Text {
                text: "󰌾"
                color: walColor8
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            } 

            TextInput {
                id: wifiPassInput
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: walForeground
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                clip: true
                activeFocusOnPress: true
            
                Text {
                    text: "Password for " + targetSSID
                    color: walColor8
                    visible: !parent.text && !parent.activeFocus
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font: parent.font
                }
                Keys.onReturnPressed: passInputRoot.triggerSubmit()
            }

        
    

        
        Rectangle {
            width: 24
            height: 24
            radius: 6
            color: walColor5
            Text {
                anchors.centerIn: parent
                text: "→"
                color: walBackground
                font.pixelSize: 11
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (wifiPassInput.text.length > 0) {
                        passInputRoot.triggerSubmit(wifiPassInput.text)
                        wifiPassInput.text = ""
                    }
                }
            }
        }
    }
    }
}