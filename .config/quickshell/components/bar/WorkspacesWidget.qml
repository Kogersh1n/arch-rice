import QtQuick 2.15
import Quickshell.Hyprland
import "../core"

Notch {
    id: wsRoot
    width: wsContainer.width + 20
    
    property int activeWsId: 1
    property int targetWsId: 1

    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "workspace") {
                var wsId = parseInt(event.data.trim())
                if (!isNaN(wsId)) { wsRoot.targetWsId = wsId; wsTransition.restart() }
            } else if (event.name === "focusedmon") {
                var parts = event.data.split(",")
                if (parts.length >= 2) {
                    var wsId = parseInt(parts[1])
                    if (!isNaN(wsId)) { wsRoot.targetWsId = wsId; wsTransition.restart() }
                }
            }
        }
    }

    SequentialAnimation {
        id: wsTransition
        PropertyAnimation { target: wsHighlight; property: "highlightOpacity"; to: 0.4; duration: 50; easing.type: Easing.OutQuad }
        ScriptAction { script: wsRoot.activeWsId = wsRoot.targetWsId }
        ParallelAnimation {
            PropertyAnimation { target: wsHighlight; property: "highlightOpacity"; to: 1; duration: 300; easing.type: Easing.OutCubic }
            PropertyAnimation { target: wsHighlight; property: "highlightScale"; from: 0.9; to: 1.0; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
        }
    }

    Component.onCompleted: {
        if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace) {
            wsRoot.activeWsId = Hyprland.focusedMonitor.activeWorkspace.id
            wsRoot.targetWsId = wsRoot.activeWsId
        }
    }

    Item {
        anchors.fill: parent

        Item {
            id: wsContainer
            anchors.centerIn: parent
            width: wsRow.width
            height: 18

            Rectangle {
                id: wsHighlight
                height: 18
                radius: 9
                property real targetX: 0
                property real targetWidth: 26
                property real highlightOpacity: 1.0
                property real highlightScale: 1.0

                x: targetX
                width: targetWidth
                opacity: highlightOpacity
                scale: highlightScale
                transformOrigin: Item.Center
                color: root.walColor13
                antialiasing: true

                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            }

            Row {
                id: wsRow
                anchors.centerIn: parent
                spacing: 4

                Repeater {
                    id: wsRepeater
                    model: Hyprland.workspaces

                    delegate: Item {
                        id: wsDelegate
                        required property var modelData
                        property bool isActive: wsRoot.activeWsId === modelData.id
                        property bool isHovered: wsMA.containsMouse

                        visible: modelData.id > 0
                        width: Math.max(wsText.implicitWidth + 14, 26)
                        height: 18

                        onIsActiveChanged: updateHighlight()
                        onXChanged: if (isActive) updateHighlight()
                        onWidthChanged: if (isActive) updateHighlight()
                        Component.onCompleted: if (isActive) updateHighlight()

                        function updateHighlight() {
                            if (isActive) {
                                wsHighlight.targetX = x
                                wsHighlight.targetWidth = width
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 9
                            color: isHovered && !isActive ? Qt.rgba(root.walColor13.r, root.walColor13.g, root.walColor13.b, 0.3) : "transparent"
                            antialiasing: true
                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }

                        Text {
                            id: wsText
                            anchors.centerIn: parent
                            text: modelData.name || modelData.id.toString()
                            color: isActive ? root.walBackground : (isHovered ? root.walForeground : Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.5))
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }

                        MouseArea {
                            id: wsMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch("workspace " + modelData.id)
                        }
                    }
                }
            }

            Connections {
                target: wsRoot
                function onActiveWsIdChanged() {
                    for (var i = 0; i < wsRepeater.count; i++) {
                        var item = wsRepeater.itemAt(i)
                        if (item && item.isActive) {
                            item.updateHighlight()
                            break
                        }
                    }
                }
            }
        }
    }
}