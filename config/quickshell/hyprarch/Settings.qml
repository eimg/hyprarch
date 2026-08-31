import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

PopupWindow {
    id: root

    property Item anchorItem
    property var panelWindow
    property bool grabReady: false
    property var wallpapers: []
    property string currentWallpaper: ""
    readonly property string home: Quickshell.env("HOME") || "/home/eimg"

    function toggle() {
        visible ? close() : open()
    }

    function open() {
        grabReady = false
        visible = true
        refresh()
        grabDelay.restart()
    }

    function close() {
        grabDelay.stop()
        grabReady = false
        visible = false
    }

    function refresh() {
        scan.running = false
        scan.running = true
        readCurrent.running = false
        readCurrent.running = true
    }

    function applyWallpaper(path) {
        Quickshell.execDetached([root.home + "/.local/bin/hyprarch-set-wallpaper", path])
        currentWallpaper = path
        const matched = Theme.themeForWallpaper(path)
        if (matched.length > 0)
            Theme.setTheme(matched)
    }

    implicitWidth: 456
    implicitHeight: 562
    color: "transparent"
    visible: false
    grabFocus: false

    anchor.window: panelWindow
    anchor.rect.x: panelWindow ? panelWindow.width - 12 : 0
    anchor.rect.y: panelWindow ? panelWindow.height : 0
    anchor.rect.width: 1
    anchor.rect.height: 1
    anchor.edges: Edges.Top | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Right

    Timer {
        id: grabDelay
        interval: 180
        repeat: false
        onTriggered: root.grabReady = true
    }

    HyprlandFocusGrab {
        active: root.visible && root.grabReady
        windows: [root]
        onCleared: root.close()
    }

    Process {
        id: scan
        command: [
            "bash", "-c",
            "find \"$HOME/.local/share/backgrounds/hyprarch\" \"$HOME/Pictures\" " +
            "-maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o " +
            "-iname '*.png' -o -iname '*.webp' \\) ! -name current -print0 2>/dev/null " +
            "| xargs -0 -r sha256sum | sort -s -k1,1 -u | sed 's/^[0-9a-f]\\{64\\}  //'"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.wallpapers = text.trim().length > 0 ? text.trim().split("\n") : []
        }
    }

    Process {
        id: readCurrent
        command: ["bash", "-c", "readlink -f \"$HOME/.local/share/backgrounds/hyprarch/current\" 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    root.currentWallpaper = text.trim()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Theme.bg
        border.width: 1
        border.color: Theme.border

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            Text {
                text: "SETTINGS"
                color: Theme.accent
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.4
            }

            Text {
                text: "WALLPAPER"
                color: Theme.textMuted
                font.family: "Inter"
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 1.1
            }

            Text {
                width: parent.width
                text: "Packed pictures apply a matching palette. Override below anytime."
                color: Theme.textDim
                font.family: "Inter"
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }

            Flickable {
                width: parent.width
                height: 196
                contentHeight: wallpaperGrid.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Grid {
                    id: wallpaperGrid
                    width: parent.width
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 10

                    Repeater {
                        model: root.wallpapers

                        Rectangle {
                            required property var modelData
                            property bool selected: root.currentWallpaper === modelData

                            width: 202
                            height: 88
                            radius: 10
                            color: Theme.surface
                            border.width: selected || tileMouse.containsMouse ? 1 : 0
                            border.color: selected ? Theme.accent : Theme.borderMuted
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                source: "file://" + modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                sourceSize.width: 404
                                sourceSize.height: 176
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 22
                                color: Theme.tileScrim

                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    text: modelData.split("/").pop()
                                    color: parent.parent.selected ? Theme.accentSoft : Theme.text
                                    font.family: "Inter"
                                    font.pixelSize: 10
                                    elide: Text.ElideMiddle
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            MouseArea {
                                id: tileMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.applyWallpaper(modelData)
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.wallpapers.length === 0
                    text: "No pictures found yet"
                    color: Theme.textDim
                    font.family: "Inter"
                    font.pixelSize: 12
                }
            }

            Text {
                text: "COLOR THEME"
                color: Theme.textMuted
                font.family: "Inter"
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 1.1
            }

            Grid {
                width: parent.width
                columns: 3
                columnSpacing: 8
                rowSpacing: 8

                Repeater {
                    model: Theme.catalog

                    Rectangle {
                        required property var modelData
                        property bool selected: Theme.themeId === modelData.id

                        width: 136
                        height: 52
                        radius: 10
                        color: themeMouse.containsMouse ? Theme.hover : Theme.surface
                        border.width: 1
                        border.color: selected ? Theme.accent : "transparent"

                        Column {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            Text {
                                text: modelData.name
                                color: selected ? Theme.accentSoft : Theme.text
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }

                            Row {
                                spacing: 4

                                Repeater {
                                    model: [modelData.bg, modelData.surface, modelData.accentDeep, modelData.accent]

                                    Rectangle {
                                        required property var modelData
                                        width: 14
                                        height: 14
                                        radius: 4
                                        color: modelData
                                        border.width: 1
                                        border.color: "#33ffffff"
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: themeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Theme.setTheme(modelData.id)
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 36
                radius: 9
                color: picturesMouse.containsMouse ? Theme.hover : Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: "OPEN PICTURES"
                    color: Theme.text
                    font.family: "Inter"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: picturesMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(["thunar", root.home + "/Pictures"])
                        root.close()
                    }
                }
            }
        }
    }
}
