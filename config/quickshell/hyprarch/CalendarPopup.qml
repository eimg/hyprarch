import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: root

    property var panelWindow
    property date now: new Date()
    property int viewYear: now.getFullYear()
    property int viewMonth: now.getMonth()
    property bool grabReady: false

    readonly property var dayCells: buildCells(viewYear, viewMonth, now)
    readonly property bool viewingCurrentMonth: Qt.formatDateTime(new Date(viewYear, viewMonth, 1), "yyyy-MM")
        === Qt.formatDateTime(now, "yyyy-MM")

    function toggle() {
        visible ? close() : open()
    }

    function open() {
        const d = new Date(now)
        viewYear = d.getFullYear()
        viewMonth = d.getMonth()
        grabReady = false
        visible = true
        grabDelay.restart()
    }

    function close() {
        grabDelay.stop()
        grabReady = false
        visible = false
    }

    function shiftMonth(delta) {
        const d = new Date(viewYear, viewMonth + delta, 1)
        viewYear = d.getFullYear()
        viewMonth = d.getMonth()
    }

    function buildCells(year, month, today) {
        const first = new Date(year, month, 1)
        const offset = (first.getDay() + 6) % 7
        const todayStr = Qt.formatDateTime(today, "yyyy-MM-dd")
        const cells = []
        for (let i = 0; i < 42; i++) {
            const d = new Date(year, month, 1 - offset + i)
            cells.push({
                day: d.getDate(),
                inMonth: d.getMonth() === month,
                isToday: Qt.formatDateTime(d, "yyyy-MM-dd") === todayStr
            })
        }
        return cells
    }

    implicitWidth: 308
    implicitHeight: viewingCurrentMonth ? 336 : 372
    color: "transparent"
    visible: false
    grabFocus: false

    anchor.window: panelWindow
    anchor.rect.x: panelWindow ? Math.round((panelWindow.width - implicitWidth) / 2) : 0
    anchor.rect.y: panelWindow ? panelWindow.height : 0
    anchor.rect.width: 1
    anchor.rect.height: 1
    anchor.edges: Edges.Top | Edges.Left
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
            spacing: 12

            RowLayout {
                width: parent.width

                Rectangle {
                    width: 28
                    height: 28
                    radius: 8
                    color: prevMouse.containsMouse ? Theme.hover : Theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: Theme.accentSoft
                        font.family: "Inter"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.shiftMonth(-1)
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDateTime(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
                    color: Theme.textBright
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    width: 28
                    height: 28
                    radius: 8
                    color: nextMouse.containsMouse ? Theme.hover : Theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        color: Theme.accentSoft
                        font.family: "Inter"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.shiftMonth(1)
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 0

                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                    Text {
                        required property string modelData
                        width: parent.width / 7
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Theme.textDim
                        font.family: "Inter"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }
            }

            Grid {
                width: parent.width
                columns: 7
                rowSpacing: 2
                columnSpacing: 0

                Repeater {
                    model: root.dayCells

                    Rectangle {
                        required property var modelData
                        width: parent.width / 7
                        height: 32
                        radius: 8
                        color: modelData.isToday ? Theme.accentDeep : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.day
                            color: modelData.isToday ? Theme.focusText
                                : modelData.inMonth ? Theme.text : Theme.textFaint
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: modelData.isToday ? Font.DemiBold : Font.Normal
                        }
                    }
                }
            }

            Rectangle {
                visible: !root.viewingCurrentMonth
                width: parent.width
                height: 32
                radius: 8
                color: todayMouse.containsMouse ? Theme.active : Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: "TODAY"
                    color: Theme.accentSoft
                    font.family: "Inter"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: todayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const d = new Date(root.now)
                        root.viewYear = d.getFullYear()
                        root.viewMonth = d.getMonth()
                    }
                }
            }
        }
    }
}
