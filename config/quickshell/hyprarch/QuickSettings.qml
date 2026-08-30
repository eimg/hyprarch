import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.Pipewire

PopupWindow {
    id: root

    property Item anchorItem
    property var panelWindow
    property var audioSink
    property var connectedDevice
    property var battery
    property bool grabReady: false
    signal settingsRequested()

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

    function setVolume(position) {
        if (audioSink && audioSink.audio)
            audioSink.audio.volume = Math.max(0, Math.min(1, position / volumeTrack.width))
    }

    implicitWidth: 340
    implicitHeight: battery && battery.ready && battery.isLaptopBattery ? 396 : 338
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
            anchors.margins: 18
            spacing: 16

            Text {
                text: "QUICK SETTINGS"
                color: Theme.accent
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.4
            }

            Rectangle {
                width: parent.width
                height: 86
                radius: 12
                color: Theme.surface

                Column {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 10

                    RowLayout {
                        width: parent.width

                        Text {
                            text: root.audioSink && root.audioSink.audio && root.audioSink.audio.muted ? "AUDIO MUTED" : "OUTPUT VOLUME"
                            color: Theme.text
                            font.family: "Inter"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.audioSink && root.audioSink.audio
                                ? Math.round(root.audioSink.audio.volume * 100) + "%"
                                : "Unavailable"
                            color: Theme.accentSoft
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                        }

                        Rectangle {
                            width: 48
                            height: 24
                            radius: 7
                            color: muteMouse.containsMouse ? Theme.hover : Theme.surface

                            Text {
                                anchors.centerIn: parent
                                text: root.audioSink && root.audioSink.audio && root.audioSink.audio.muted ? "ON" : "MUTE"
                                color: Theme.text
                                font.family: "Inter"
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: muteMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.audioSink && root.audioSink.audio
                                onClicked: root.audioSink.audio.muted = !root.audioSink.audio.muted
                            }
                        }
                    }

                    Rectangle {
                        id: volumeTrack
                        width: parent.width
                        height: 8
                        radius: 4
                        color: Theme.border

                        Rectangle {
                            width: root.audioSink && root.audioSink.audio
                                ? parent.width * Math.min(1, root.audioSink.audio.volume)
                                : 0
                            height: parent.height
                            radius: parent.radius
                            color: Theme.meter
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.audioSink && root.audioSink.audio
                            onPressed: mouse => root.setVolume(mouse.x)
                            onPositionChanged: mouse => {
                                if (pressed)
                                    root.setVolume(mouse.x)
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 70
                radius: 12
                color: Theme.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 13

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: root.connectedDevice ? Theme.ok : Theme.bad
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: root.connectedDevice ? "NETWORK CONNECTED" : "NETWORK OFFLINE"
                            color: Theme.text
                            font.family: "Inter"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: root.connectedDevice
                                ? root.connectedDevice.name + " · NetworkManager"
                                : "No connected interface"
                            color: Theme.textDim
                            font.family: "JetBrains Mono"
                            font.pixelSize: 10
                        }
                    }
                }
            }

            Rectangle {
                visible: root.battery && root.battery.ready && root.battery.isLaptopBattery
                width: parent.width
                height: 42
                radius: 10
                color: Theme.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 13
                    anchors.rightMargin: 13

                    Text {
                        text: "BATTERY"
                        color: Theme.text
                        font.family: "Inter"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: Math.round(root.battery.percentage * 100) + "%"
                        color: Theme.accentSoft
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 8

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 36
                    radius: 9
                    color: terminalMouse.containsMouse ? Theme.active : Theme.accentFill

                    Text {
                        anchors.centerIn: parent
                        text: "OPEN TERMINAL"
                        color: Theme.accentSoft
                        font.family: "Inter"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: terminalMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["foot"])
                            root.close()
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 36
                    radius: 9
                    color: networkMouse.containsMouse ? Theme.hover : Theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: "NETWORK DETAILS"
                        color: Theme.text
                        font.family: "Inter"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: networkMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["foot", "nmtui"])
                            root.close()
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 36
                radius: 9
                color: settingsMouse.containsMouse ? Theme.active : Theme.accentFill

                Text {
                    anchors.centerIn: parent
                    text: "WALLPAPER & SETTINGS"
                    color: Theme.accentSoft
                    font.family: "Inter"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: settingsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.close()
                        root.settingsRequested()
                    }
                }
            }
        }
    }
}
