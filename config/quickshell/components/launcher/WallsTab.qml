import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects

ColumnLayout {
    spacing: 15

    signal switchToApps()
    signal closeLauncher()

    function focusSearch() { wallSearchInput.forceActiveFocus() }
    function clearSearch() { wallSearchInput.text = "" }
    function removeFocus() { wallSearchInput.focus = false }
    function resetScroll() { wallGridView.contentY = 0 }
    function positionView(index) { wallGridView.positionViewAtIndex(index, GridView.Contain) }

    Rectangle {
        Layout.fillWidth: true; Layout.preferredHeight: 42; color: Qt.rgba(0, 0, 0, 0.3); radius: 12
        border.width: wallSearchInput.activeFocus ? 1 : 0
        border.color: root.walColor13
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10
            Text { text: ""; color: root.walColor8; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }
            TextInput {
                id: wallSearchInput
                Layout.fillWidth: true; Layout.fillHeight: true
                color: root.walForeground; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: TextInput.AlignVCenter; selectByMouse: true; clip: true
                
                // ВАЖНО: Приоритет клавиш
                Keys.priority: Keys.BeforeItem
                
                Text {
                    text: "Search wallpapers..."
                    color: root.walColor8; visible: !parent.text
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                    font: parent.font; opacity: 0.6
                }
                
                onTextChanged: { 
                    wallService.searchTerm = text.toLowerCase()
                    root.wallSelectedIndex = 0
                    wallGridView.contentY = 0 
                }

               Keys.onPressed: function(event) {
                    var total = wallService.filteredWallpapers.length
                    
                    if (event.key === Qt.Key_Down) {
                        root.wallSelectedIndex = Math.min(root.wallSelectedIndex + 3, total - 1)
                        wallGridView.positionViewAtIndex(root.wallSelectedIndex, GridView.Contain)
                        event.accepted = true
                    }
                    else if (event.key === Qt.Key_Up) {
                        root.wallSelectedIndex = Math.max(root.wallSelectedIndex - 3, 0)
                        wallGridView.positionViewAtIndex(root.wallSelectedIndex, GridView.Contain)
                        event.accepted = true
                    }
                    
                    else if (event.key === Qt.Key_Right) {
                        if (wallSearchInput.text.length === 0) {
                            root.wallSelectedIndex = Math.min(root.wallSelectedIndex + 1, total - 1)
                            wallGridView.positionViewAtIndex(root.wallSelectedIndex, GridView.Contain)
                            event.accepted = true
                        }
                    }
                    else if (event.key === Qt.Key_Left) {
                        if (wallSearchInput.text.length === 0) {
                            root.wallSelectedIndex = Math.max(root.wallSelectedIndex - 1, 0)
                            wallGridView.positionViewAtIndex(root.wallSelectedIndex, GridView.Contain)
                            event.accepted = true
                        }
                    }
                    // --- ОСТАЛЬНЫЕ КНОПКИ ---
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (total > 0 && root.wallSelectedIndex >= 0 && root.wallSelectedIndex < total) {
                            wallService.apply(wallService.filteredWallpapers[root.wallSelectedIndex])
                        }
                        event.accepted = true
                    }
                    else if (event.key === Qt.Key_Escape) {
                        closeLauncher()
                        wallSearchInput.text = ""
                        event.accepted = true
                    }
                    else if (event.key === Qt.Key_Tab) {
                        switchToApps()
                        event.accepted = true
                    }
                }
            }
            Text {
                visible: wallSearchInput.text.length > 0; text: "󰅖"; color: root.walColor8; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"
                opacity: clearWallMouse.containsMouse ? 1.0 : 0.7
                Behavior on opacity { NumberAnimation { duration: 100 } }
                MouseArea {
                    id: clearWallMouse; anchors.fill: parent; anchors.margins: -4; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { wallSearchInput.text = ""; wallSearchInput.forceActiveFocus() }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true; Layout.fillHeight: true; color: Qt.rgba(0, 0, 0, 0.3); radius: 15; clip: true

        GridView {
            id: wallGridView
            anchors.fill: parent; anchors.margins: 10
            cellWidth: Math.floor(width / 3); cellHeight: cellWidth * 0.65 + 30
            boundsBehavior: Flickable.StopAtBounds; clip: true; cacheBuffer: 400
            
            model: wallService.filteredWallpapers

            property real targetContentY: 0
            property bool animatingScroll: false

            NumberAnimation { id: wallScrollAnim; target: wallGridView; property: "contentY"; duration: 300; easing.type: Easing.OutCubic; onFinished: wallGridView.animatingScroll = false }
            function smoothScrollTo(newY) {
                var maxY = Math.max(0, contentHeight - height)
                newY = Math.max(0, Math.min(newY, maxY))
                if (animatingScroll) wallScrollAnim.stop()
                animatingScroll = true; wallScrollAnim.from = contentY; wallScrollAnim.to = newY; targetContentY = newY; wallScrollAnim.start()
            }
            function smoothScrollBy(delta) { smoothScrollTo((animatingScroll ? targetContentY : contentY) + delta) }

            MouseArea {
                anchors.fill: parent; propagateComposedEvents: true
                onWheel: function(wheel) { wallGridView.smoothScrollBy(-wheel.angleDelta.y / 120.0 * (wallGridView.cellHeight * 0.6)) }
                onClicked: function(mouse) { mouse.accepted = false }
                onPressed: function(mouse) { mouse.accepted = false }
                onReleased: function(mouse) { mouse.accepted = false }
            }

            delegate: Item {
                width: wallGridView.cellWidth; height: wallGridView.cellHeight
                Rectangle {
                    anchors.fill: parent; anchors.margins: 4; radius: 10
                    color: {
                        let c = root.walColor13;
                        if (!c || typeof c.r === 'undefined') {
                            return index === root.wallSelectedIndex ? Qt.rgba(1, 1, 1, 0.25) : (wallItemMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.2));
                        }
                        if (index === root.wallSelectedIndex) return Qt.rgba(c.r, c.g, c.b, 0.25)
                        if (wallItemMouse.containsMouse) return Qt.rgba(1, 1, 1, 0.08)
                        return Qt.rgba(0, 0, 0, 0.2)
                    }
                    border.width: { if (modelData.path === wallService.currentWallpaper) return 2; if (index === root.wallSelectedIndex) return 1; return 0 }
                    border.color: modelData.path === wallService.currentWallpaper ? root.walColor2 : root.walColor13
                    Behavior on color { ColorAnimation { duration: 120 } }
                    
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 4; spacing: 2
                        Item {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            Rectangle { anchors.fill: parent; radius: 7; color: Qt.rgba(0.3, 0.3, 0.3, 0.3); visible: wallThumbImage.status !== Image.Ready }
                            
                            Image {
                                id: wallThumbImage
                                anchors.fill: parent
                                source: modelData.path ? "file://" + modelData.path : ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                asynchronous: true
                                cache: true
                                sourceSize.width: 180
                                sourceSize.height: 120
                                visible: false 
                            }
                            
                            Rectangle { id: wallThumbMaskRect; anchors.fill: parent; radius: 7; color: "black"; visible: false }
                            OpacityMask { anchors.fill: parent; source: wallThumbImage; maskSource: wallThumbMaskRect }
                            
                            Rectangle {
                                visible: modelData.path === wallService.currentWallpaper
                                anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 3
                                width: 16; height: 16; radius: 8; color: root.walColor2
                                Text { anchors.centerIn: parent; text: "󰄬"; color: root.walBackground; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font" }
                            }
                        }
                        Text {
                            Layout.fillWidth: true; Layout.preferredHeight: 22; text: modelData.name
                            color: {
                                if (modelData.path === wallService.currentWallpaper) return root.walColor2
                                if (index === root.wallSelectedIndex) return root.walColor13
                                return root.walForeground
                            }
                            font.pixelSize: 8; font.family: "JetBrainsMono Nerd Font"; font.bold: index === root.wallSelectedIndex || modelData.path === wallService.currentWallpaper
                            elide: Text.ElideMiddle; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }
                    MouseArea {
                        id: wallItemMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: wallService.apply(modelData)
                        onContainsMouseChanged: { if (containsMouse) root.wallSelectedIndex = index }
                    }
                }
            }
            ScrollBar.vertical: ScrollBar { active: true; width: 4; policy: ScrollBar.AsNeeded }
        }
        Text {
            anchors.centerIn: parent; visible: wallService.wallsLoaded && wallService.filteredWallpapers.length === 0
            text: "No wallpapers found"; color: root.walColor8; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
        }
        Text {
            anchors.centerIn: parent; visible: !wallService.wallsLoaded
            text: "Loading..."; color: root.walColor8; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.4; to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.0; to: 0.4; duration: 600; easing.type: Easing.InOutSine }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true; Layout.preferredHeight: 28; color: Qt.rgba(0, 0, 0, 0.3); radius: 10
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
            Text { text: "←→↑↓ nav"; color: root.walColor8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; opacity: 0.7 }
            Item { Layout.fillWidth: true }
            Text { text: "↵ apply"; color: root.walColor8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; opacity: 0.7 }
            Item { Layout.fillWidth: true }
            Text { text: "tab apps"; color: root.walColor8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; opacity: 0.7 }
            Item { Layout.fillWidth: true }
            Text { text: "esc close"; color: root.walColor8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; opacity: 0.7 }
        }
    }
}