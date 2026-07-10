import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    anchors.fill: parent

    // Сигналы для связи с основным окном
    signal switchToWalls()
    signal closeLauncher()

    // API компонента
    function focusSearch() { searchInput.forceActiveFocus() }
    function clearSearch() { searchInput.text = "" }
    function removeFocus() { searchInput.focus = false }
    function resetScroll() { appListView.contentY = 0 }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            color: Qt.rgba(0, 0, 0, 0.3)
            radius: 12
            border.width: searchInput.activeFocus ? 1 : 0
            border.color: root.walColor5
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10
                
                Text { text: "󰍉"; color: root.walColor8; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }
                
                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.walForeground
                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    clip: true
                    
                    Text {
                        text: "Search apps..."
                        color: root.walColor8
                        visible: !parent.text
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font: parent.font
                        opacity: 0.6
                    }
                    
                    onTextChanged: {
                        appService.searchTerm = text.toLowerCase()
                        // ИСПРАВЛЕНО: Теперь обращаемся к root
                        root.selectedIndex = 0
                        appListView.contentY = 0
                    }

                    // --- УМНАЯ ОБРАБОТКА КЛАВИШ ---
                    Keys.onPressed: (event) => {
                        var total = appService.filteredApps.length
                        
                        if (event.key === Qt.Key_Up) {
                            root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
                            appListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            event.accepted = true
                        }
                        else if (event.key === Qt.Key_Down) {
                            root.selectedIndex = Math.min(root.selectedIndex + 1, total - 1)
                            appListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            event.accepted = true
                        }
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (total > 0 && root.selectedIndex >= 0 && root.selectedIndex < total) {
                                appService.launch(appService.filteredApps[root.selectedIndex])
                            }
                            event.accepted = true
                        }
                        else if (event.key === Qt.Key_Escape) {
                            closeLauncher()
                            searchInput.text = ""
                            event.accepted = true
                        }
                        else if (event.key === Qt.Key_Tab) {
                            switchToWalls()
                            event.accepted = true
                        }
                    }
                }
                
                Text {
                    visible: searchInput.text.length > 0
                    text: "󰅖"
                    color: root.walColor8
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                    opacity: clearAppMouse.containsMouse ? 1.0 : 0.7
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                    MouseArea {
                        id: clearAppMouse
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { searchInput.text = ""; searchInput.forceActiveFocus() }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.rgba(0, 0, 0, 0.3)
            radius: 15
            clip: true

            ListView {
                id: appListView
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds
                
                // ИСПРАВЛЕНО: Теперь обращаемся к root
                currentIndex: root.selectedIndex
                
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 100
                model: appService.filteredApps

                property real targetContentY: 0
                property bool animatingScroll: false

                NumberAnimation { id: appScrollAnim; target: appListView; property: "contentY"; duration: 300; easing.type: Easing.OutCubic; onFinished: appListView.animatingScroll = false }

                function smoothScrollTo(newY) {
                    var maxY = Math.max(0, contentHeight - height)
                    newY = Math.max(0, Math.min(newY, maxY))
                    if (animatingScroll) appScrollAnim.stop()
                    animatingScroll = true
                    appScrollAnim.from = contentY
                    appScrollAnim.to = newY
                    targetContentY = newY
                    appScrollAnim.start()
                }

                function smoothScrollBy(delta) { smoothScrollTo((animatingScroll ? targetContentY : contentY) + delta) }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onWheel: function(wheel) { appListView.smoothScrollBy(-wheel.angleDelta.y / 120.0 * 60) }
                    onClicked: function(mouse) { mouse.accepted = false }
                    onPressed: function(mouse) { mouse.accepted = false }
                    onReleased: function(mouse) { mouse.accepted = false }
                }

                delegate: Rectangle {
                    width: appListView.width; height: 48; radius: 12
                    color: {
                        let c = root.walColor5;
                        if (!c || typeof c.r === 'undefined') {
                            return index === root.selectedIndex ? Qt.rgba(1, 1, 1, 0.2) : (appItemMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent");
                        }
                        if (index === root.selectedIndex) return Qt.rgba(c.r, c.g, c.b, 0.2)
                        if (appItemMouse.containsMouse) return Qt.rgba(1, 1, 1, 0.05)
                        return "transparent"
                    }
                    Behavior on color { ColorAnimation { duration: 120 } }
                    
                    Rectangle {
                        visible: index === root.selectedIndex
                        width: 3; height: 22; radius: 2; color: root.walColor5
                        anchors.left: parent.left; anchors.leftMargin: 4; anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14; anchors.rightMargin: 14; anchors.topMargin: 6; anchors.bottomMargin: 6
                        spacing: 12
                        Rectangle {
                            width: 32; height: 32; radius: 8; color: Qt.rgba(0, 0, 0, 0.2)
                            Image {
                                anchors.centerIn: parent
                                width: 22; height: 22
                                source: {
                                    var icon = modelData.icon
                                    if (!icon || icon === "") return "image://icon/application-x-executable"
                                    if (icon.indexOf("/") === 0) return "file://" + icon
                                    return "image://icon/" + icon
                                }
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true; cache: true
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 1
                            Text {
                                Layout.fillWidth: true; text: modelData.name
                                color: index === root.selectedIndex ? root.walColor5 : root.walForeground
                                font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"; font.bold: index === root.selectedIndex
                                elide: Text.ElideRight
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }
                            Text {
                                Layout.fillWidth: true; text: modelData.exec
                                color: root.walColor8; font.pixelSize: 9; font.family: "JetBrainsMono Nerd Font"
                                elide: Text.ElideRight; opacity: 0.7
                            }
                        }
                        Text {
                            visible: index === root.selectedIndex
                            text: "↵"; color: root.walColor5; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; font.bold: true
                        }
                    }
                    MouseArea {
                        id: appItemMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        // ИСПРАВЛЕНО: обновляем индекс при наведении
                        onContainsMouseChanged: { if (containsMouse) root.selectedIndex = index }
                        onClicked: appService.launch(modelData)
                    }
                }
                ScrollBar.vertical: ScrollBar { active: true; width: 4; policy: ScrollBar.AsNeeded }
            }
            Text {
                anchors.centerIn: parent; visible: appService.filteredApps.length === 0
                text: "No apps found"; color: root.walColor8; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
            }
        }

        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 28; color: Qt.rgba(0, 0, 0, 0.3); radius: 10
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                Text { text: "↑↓ nav"; color: root.walColor8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; opacity: 0.7 }
                Item { Layout.fillWidth: true }
                Text { text: "↵ launch"; color: root.walColor8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; opacity: 0.7 }
                Item { Layout.fillWidth: true }
                Text { text: "tab walls"; color: root.walColor8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; opacity: 0.7 }
                Item { Layout.fillWidth: true }
                Text { text: "esc close"; color: root.walColor8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; opacity: 0.7 }
            }
        }
    }
}