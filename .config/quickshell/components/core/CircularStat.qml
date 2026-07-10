import QtQuick 2.15

Item {
    id: statRoot
    property string label
    property string icon
    property color barColor
    property int value
    
    width: 90; height: 110
    
    Column {
        anchors.centerIn: parent
        spacing: 8
        Item {
            width: 70; height: 70
            anchors.horizontalCenter: parent.horizontalCenter
            Canvas {
                anchors.fill: parent
                property int statValue: statRoot.value
                onStatValueChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.lineWidth = 5
                    ctx.lineCap = "round"
                    ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.3)
                    ctx.beginPath()
                    ctx.arc(35, 35, 32, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.strokeStyle = statRoot.barColor
                    ctx.beginPath()
                    ctx.arc(35, 35, 32, -Math.PI / 2, -Math.PI / 2 + (statValue / 100) * 2 * Math.PI)
                    ctx.stroke()
                }
            }
            Column {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: statRoot.icon
                    color: statRoot.barColor
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                    visible: statRoot.icon !== ""
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: statRoot.value + "%"
                    color: root.walForeground
                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: statRoot.label
            color: root.walColor8
            font.pixelSize: 11
            font.family: "JetBrainsMono Nerd Font"
        }
    }
}