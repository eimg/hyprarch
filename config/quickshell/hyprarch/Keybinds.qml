import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: root

    property Item anchorItem
    property var panelWindow
    property bool grabReady: false

    readonly property var sections: [
        {
            title: "APPS & WINDOWS",
            rows: [
                { keys: "Super + Enter", action: "Open terminal" },
                { keys: "Super + Space", action: "App launcher" },
                { keys: "Super + E", action: "Files" },
                { keys: "Super + N", action: "Notepad" },
                { keys: "Super + Q", action: "Close window" },
                { keys: "Super + F", action: "Fullscreen" },
                { keys: "Super + V", action: "Float / tile" },
                { keys: "Super + arrows", action: "Move focus" },
                { keys: "Super + Shift + E", action: "Log out" }
            ]
        },
        {
            title: "WORKSPACES",
            rows: [
                { keys: "Super + 1…5", action: "Switch workspace" },
                { keys: "Super + Shift + 1…5", action: "Move window there" }
            ]
        },
        {
            title: "MOUSE",
            rows: [
                { keys: "Super + left-drag", action: "Move window" },
                { keys: "Super + right-drag", action: "Resize window" }
            ]
        },
        {
            title: "HELP",
            rows: [
                { keys: "Super + /", action: "This cheatsheet" },
                { keys: "Bar gear", action: "Wallpaper & settings" }
            ]
        }
    ]

    function toggle() {
        visible ? close() : open()
    }

    function open() {
        grabReady = false
        visible = true
        grabDelay.restart()
    }

    function close() {
        grabDelay.stop()
        grabReady = false
        visible = false
    }

    implicitWidth: 400
    implicitHeight: 400
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
                text: "KEYBINDS"
                color: Theme.accent
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.5
            }

            Text {
                width: parent.width
                text: "Super is the Windows key in this VM."
                color: Theme.textDim
                font.family: "Inter"
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }

            Flickable {
                width: parent.width
                height: parent.height - 52
                contentHeight: sectionsColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: sectionsColumn
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: root.sections

                        Column {
                            required property var modelData
                            width: parent.width
                            spacing: 6

                            Text {
                                text: modelData.title
                                color: Theme.textMuted
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                font.letterSpacing: 1.1
                            }

                            Repeater {
                                model: modelData.rows

                                Rectangle {
                                    required property var modelData
                                    width: parent.width
                                    height: 28
                                    radius: 8
                                    color: Theme.surface

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10

                                        Text {
                                            text: modelData.keys
                                            color: Theme.accentSoft
                                            font.family: "JetBrains Mono"
                                            font.pixelSize: 11
                                        }

                                        Item { Layout.fillWidth: true }

                                        Text {
                                            text: modelData.action
                                            color: Theme.text
                                            font.family: "Inter"
                                            font.pixelSize: 11
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
