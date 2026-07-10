import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: dropdownCard
    
    property bool isOpen: false
    property var gifFiles: []
    property int previewIndex: 0
    property int currentIndex: 0
    property bool isLoaded: false
    property bool isApplying: false

    signal closeClicked()
    signal prevClicked()
    signal nextClicked()
    signal applyClicked()

    function gifFileName(path) {
        var parts = path.split("/")
        return parts[parts.length - 1].replace(".gif", "")
    }

    width: 380
    height: 260
    radius: root.theme.cardRadius
    color: root.theme.cardBackground
    border.color: root.theme.cardBorder
    border.width: 1
    visible: isOpen
    clip: true

    layer.enabled: true
    layer.effect: DropShadow { 
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 4
        radius: 28
        samples: 17
        color: Qt.rgba(0, 0, 0, 0.35) 
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            
            Text { 
                text: "Select Animation"
                color: root.walColor5
                font.pixelSize: 12
                font.bold: true
                font.family: "Inter", "sans-serif"
                Layout.fillWidth: true 
            }
            
            Text { 
                visible: gifFiles.length > 0
                text: (previewIndex + 1) + " / " + gifFiles.length
                color: root.walColor8
                font.pixelSize: 10
                font.family: "Inter", "sans-serif"
                opacity: 0.6 
            }
            
            Item { width: 6 }
            
            Rectangle {
                width: 20
                height: 20
                radius: 14
                color: dropCloseMa.containsMouse ? Qt.rgba(root.walColor1.r, root.walColor1.g, root.walColor1.b, 0.5) : Qt.rgba(1, 1, 1, 0.08)
                Behavior on color { ColorAnimation { duration: 150 } }
                
                Text { 
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: dropCloseMa.containsMouse ? root.walColor1 : root.walForeground
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                    Behavior on color { ColorAnimation { duration: 150 } } 
                }
                
                MouseArea { 
                    id: dropCloseMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: closeClicked() 
                }
            }
        }

        Rectangle { 
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(1, 1, 1, 0.06) 
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Rectangle {
                anchors.fill: parent
                radius: 18
                color: Qt.rgba(0, 0, 0, 0.2)
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1
                clip: true
                
                Item {
                    anchors.fill: parent
                    anchors.margins: 12
                    
                    Loader {
                        anchors.fill: parent
                        active: isOpen && isLoaded && gifFiles.length > 0
                        sourceComponent: AnimatedImage {
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            source: (gifFiles.length > 0 && previewIndex < gifFiles.length) ? "file://" + gifFiles[previewIndex] : ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            playing: isOpen
                            cache: false
                            asynchronous: true
                        }
                    }
                }
                
                Text { 
                    anchors.centerIn: parent
                    visible: gifFiles.length === 0 && isLoaded
                    text: "No gifs found"
                    color: root.walColor8
                    font.pixelSize: 11
                    font.family: "Inter", "sans-serif"
                    opacity: 0.5 
                }
                
                Text { 
                    anchors.centerIn: parent
                    visible: !isLoaded && isOpen
                    text: "Loading..."
                    color: root.walColor8
                    font.pixelSize: 11
                    font.family: "Inter", "sans-serif"
                    opacity: 0.5 
                }
                
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 8
                    visible: gifFiles.length > 0 && isLoaded
                    width: nameLabel.implicitWidth + 16
                    height: 20
                    radius: 14
                    color: Qt.rgba(0, 0, 0, 0.6)
                    
                    Text { 
                        id: nameLabel
                        anchors.centerIn: parent
                        text: (gifFiles.length > 0 && previewIndex < gifFiles.length) ? gifFileName(gifFiles[previewIndex]) : ""
                        color: root.walForeground
                        font.pixelSize: 9
                        font.family: "Inter", "sans-serif"
                        opacity: 0.9 
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 8
            
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 32
                radius: 12
                color: prevGifMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                border.color: prevGifMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.4) : Qt.rgba(1, 1, 1, 0.05)
                border.width: 1
                opacity: gifFiles.length > 1 ? 1.0 : 0.3
                
                Text { 
                    anchors.centerIn: parent
                    text: "󰅁"
                    color: prevGifMa.containsMouse ? root.walColor5 : root.walForeground
                    font.pixelSize: 16
                    font.family: "Inter", "sans-serif" 
                }
                
                MouseArea { 
                    id: prevGifMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: gifFiles.length > 1 && !isApplying
                    onClicked: prevClicked() 
                }
            }
            
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 32
                radius: 12
                color: nextGifMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                border.color: nextGifMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.4) : Qt.rgba(1, 1, 1, 0.05)
                border.width: 1
                opacity: gifFiles.length > 1 ? 1.0 : 0.3
                
                Text { 
                    anchors.centerIn: parent
                    text: "󰅂"
                    color: nextGifMa.containsMouse ? root.walColor5 : root.walForeground
                    font.pixelSize: 16
                    font.family: "Inter", "sans-serif" 
                }
                
                MouseArea { 
                    id: nextGifMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: gifFiles.length > 1 && !isApplying
                    onClicked: nextClicked() 
                }
            }
            
            Item { Layout.fillWidth: true }
            
            Rectangle {
                Layout.preferredWidth: 85
                Layout.preferredHeight: 32
                radius: 12
                color: {
                    if (isApplying) return Qt.rgba(1, 1, 1, 0.03)
                    if (previewIndex === currentIndex) return Qt.rgba(1, 1, 1, 0.05)
                    return applyGifMa.pressed ? root.walColor5 : applyGifMa.containsMouse ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.35) : Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.18)
                }
                border.color: {
                    if (isApplying) return Qt.rgba(1, 1, 1, 0.05)
                    if (previewIndex === currentIndex) return Qt.rgba(1, 1, 1, 0.08)
                    return applyGifMa.containsMouse ? root.walColor5 : Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.4)
                }
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: isApplying ? "Applying..." : (previewIndex === currentIndex ? "󰄬 Current" : "󰸞 Apply")
                    color: {
                        if (isApplying) return Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.4)
                        if (previewIndex === currentIndex) return Qt.rgba(root.walForeground.r, root.walForeground.g, root.walForeground.b, 0.3)
                        return applyGifMa.pressed ? root.walBackground : root.walColor5
                    }
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
                
                MouseArea {
                    id: applyGifMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: (previewIndex !== currentIndex && !isApplying) ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: previewIndex !== currentIndex && !isApplying
                    onClicked: applyClicked()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            color: Qt.rgba(0, 0, 0, 0.2)
            radius: 6
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                
                Text { 
                    text: "←→ nav"
                    color: root.walColor8
                    font.pixelSize: 9
                    font.family: "Inter", "sans-serif"
                    opacity: 0.6 
                }
                Item { Layout.fillWidth: true }
                Text { 
                    text: "↵ apply"
                    color: root.walColor8
                    font.pixelSize: 9
                    font.family: "Inter", "sans-serif"
                    opacity: 0.6 
                }
                Item { Layout.fillWidth: true }
                Text { 
                    text: "esc close"
                    color: root.walColor8
                    font.pixelSize: 9
                    font.family: "Inter", "sans-serif"
                    opacity: 0.6 
                }
            }
        }
    }
}