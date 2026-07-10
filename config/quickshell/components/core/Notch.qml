import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: notchRoot
    property bool hovered: false
    property string tooltip: ""
    
    // Дефолтные настройки внешнего вида
    property color notchColor: Qt.rgba(0, 0, 0, 0.50)
    property color notchHoverColor: Qt.rgba(0, 0, 0, 0.62)
    property int notchRadius: 12
    property int notchHeight: 32

    default property alias content: contentItem.data
    height: notchHeight

    property bool isActive: notchRoot.hovered || notchRoot.activeFocus

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: -notchRadius
        width: parent.width
        height: parent.height + notchRadius
        radius: notchRadius
        antialiasing: true
        layer.enabled: true
        layer.samples: 4

        gradient: Gradient {
            GradientStop { position: 0.0; color: notchRoot.isActive ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0, 0, 0, 0.30) }
            GradientStop { position: 1.0; color: notchRoot.isActive ? notchHoverColor : notchColor }
        }
    }

    Rectangle {
        id: tooltipBg
        visible: notchRoot.isActive && notchRoot.tooltip !== ""
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 4
        width: tooltipText.implicitWidth + 16
        height: tooltipText.implicitHeight + 8
        radius: 6
        color: Qt.rgba(0, 0, 0, 0.85)
        opacity: visible ? 1 : 0
        z: 1000
        antialiasing: true

        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: notchRoot.tooltip
            color: root.walForeground
            font.pixelSize: 10
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.bottomMargin: 4
    }
}