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

    // Signal when login and password are submitted
    signal submitCredentials(string login, string password)

    // Visibility state of password
    property bool showPassword: false

    function forceInputFocus() {
        if (isEnterprise) {
            wifiLoginInput.forceActiveFocus()
        } else {
            wifiPassInput.forceActiveFocus()
        }
    }

    function triggerSubmit() {
        if (isEnterprise) {
            if (wifiLoginInput.text.length > 0 && wifiPassInput.text.length > 0) {
                passInputRoot.submitCredentials(wifiLoginInput.text, wifiPassInput.text)
                wifiLoginInput.text = ''
                wifiPassInput.text = ''
            }
        } else {
            if (wifiPassInput.text.length > 0) {
                passInputRoot.submitCredentials('', wifiPassInput.text)
                wifiPassInput.text = ''
            }
        }
    }

    Layout.fillWidth: true
    visible: targetSSID !== ""
    width: parent ? parent.width : 300
    spacing: 8

    // --- Enterprise Identity Field ---
    Rectangle {
        width: parent.width  
        height: 36           
        radius: 14
        color: Qt.rgba(0, 0, 0, 0.3)
        border.width: 1
        border.color: wifiLoginInput.activeFocus ? walColor5 : Qt.rgba(1, 1, 1, 0.08)
        visible: passInputRoot.isEnterprise

        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8
            
            Text {
                text: "󰧱"
                color: wifiLoginInput.activeFocus ? walColor5 : walColor8
                font.pixelSize: 14
                font.family: "Inter", "sans-serif"
            }
            
            TextInput {
                id: wifiLoginInput
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: walForeground
                font.pixelSize: 13
                font.family: "Inter", "sans-serif"
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                activeFocusOnPress: true
                
                Text {
                    text: "Username for " + targetSSID
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

    // --- Password Field ---
    Rectangle {
        width: parent.width  
        height: 36
        radius: 14
        color: Qt.rgba(0, 0, 0, 0.3)
        border.width: 1
        border.color: wifiPassInput.activeFocus ? walColor5 : Qt.rgba(1, 1, 1, 0.08)

        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 8
            
            Text {
                text: "󰌾"
                color: wifiPassInput.activeFocus ? walColor5 : walColor8
                font.pixelSize: 14
                font.family: "Inter", "sans-serif"
            } 

            TextInput {
                id: wifiPassInput
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: walForeground
                font.pixelSize: 13
                font.family: "Inter", "sans-serif"
                verticalAlignment: TextInput.AlignVCenter
                echoMode: passInputRoot.showPassword ? TextInput.Normal : TextInput.Password
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

            // Eye Toggle to Show/Hide Password
            Rectangle {
                width: 24
                height: 24
                radius: 6
                color: eyeMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: passInputRoot.showPassword ? "󰈈" : "󰈉"
                    color: passInputRoot.showPassword ? walColor5 : walColor8
                    font.pixelSize: 15
                    font.family: "Inter", "sans-serif"
                }
                
                MouseArea {
                    id: eyeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: passInputRoot.showPassword = !passInputRoot.showPassword
                }
            }
        
            // Submit Button
            Rectangle {
                width: 24
                height: 24
                radius: 6
                color: submitMa.containsMouse ? Qt.rgba(walColor5.r, walColor5.g, walColor5.b, 0.8) : walColor5
                
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "󰄬"
                    color: walBackground
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "Inter", "sans-serif"
                }
                
                MouseArea {
                    id: submitMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: passInputRoot.triggerSubmit()
                }
            }
        }
    }
}