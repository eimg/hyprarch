import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: root

    property Item anchorItem
    property var panelWindow
    property string pendingAction: ""
    property bool grabReady: false

    function toggle() {
        visible ? close() : open()
    }

    function open() {
        pendingAction = ""
        grabReady = false
        visible = true
        grabDelay.restart()
    }

    function close() {
        grabDelay.stop()
        grabReady = false
        pendingAction = ""
        visible = false
    }

    function runAction() {
        if (pendingAction === "logout")
            Quickshell.execDetached(["uwsm", "stop"])
        else if (pendingAction === "reboot")
            Quickshell.execDetached(["systemctl", "reboot"])
        else if (pendingAction === "poweroff")
            Quickshell.execDetached(["systemctl", "poweroff"])
        close()
    }

    readonly property int chrome: 16
    readonly property int confirmGap: pendingAction.length > 0 ? 8 : 0

    implicitWidth: 280
    implicitHeight: sessionColumn.implicitHeight + chrome * 2 + confirmGap
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
            id: sessionColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: root.chrome
            spacing: 10

            Text {
                text: "SESSION"
                color: Theme.accent
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.5
            }

            Repeater {
                model: [
                    { label: "LOG OUT", action: "logout", detail: "Return to the login screen" },
                    { label: "RESTART", action: "reboot", detail: "Restart the machine" },
                    { label: "SHUT DOWN", action: "poweroff", detail: "Power off the virtual machine" }
                ]

                Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 42
                    radius: 10
                    color: actionMouse.containsMouse ? Theme.hover : Theme.surface

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12

                        Text {
                            text: modelData.label
                            color: Theme.text
                            font.family: "Inter"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: modelData.detail
                            color: Theme.textDim
                            font.family: "Inter"
                            font.pixelSize: 9
                        }
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.pendingAction = modelData.action
                    }
                }
            }

            Rectangle {
                visible: root.pendingAction.length > 0
                width: parent.width
                height: 50
                radius: 10
                color: "#301923"
                border.width: 1
                border.color: "#7f1d1d"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8

                    Text {
                        text: "Confirm " + root.pendingAction + "?"
                        color: "#fecdd3"
                        font.family: "Inter"
                        font.pixelSize: 10
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 66
                        height: 30
                        radius: 8
                        color: confirmMouse.containsMouse ? "#be123c" : "#881337"

                        Text {
                            anchors.centerIn: parent
                            text: "CONFIRM"
                            color: "#fff1f2"
                            font.family: "Inter"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: confirmMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.runAction()
                        }
                    }
                }
            }
        }
    }
}
