import QtQuick
import Quickshell

PanelWindow {
    id: root

    property var targetScreen
    property string query: ""

    function toggle() {
        visible ? close() : open()
    }

    function open() {
        query = ""
        appList.currentIndex = 0
        visible = true
        Qt.callLater(() => searchInput.forceActiveFocus())
    }

    function close() {
        visible = false
    }

    function launch(entry) {
        if (entry) {
            entry.execute()
            close()
        }
    }

    screen: targetScreen
    color: Theme.overlay
    visible: false
    focusable: visible
    exclusiveZone: 0
    aboveWindows: true

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    ScriptModel {
        id: filteredApps
        values: [...DesktopEntries.applications.values]
            .filter(entry => {
                const needle = root.query.trim().toLowerCase()
                return needle.length === 0
                    || entry.name.toLowerCase().includes(needle)
                    || entry.genericName.toLowerCase().includes(needle)
                    || entry.keywords.some(keyword => keyword.toLowerCase().includes(needle))
            })
            .sort((a, b) => {
                const needle = root.query.trim().toLowerCase()
                const aStarts = needle.length > 0 && a.name.toLowerCase().startsWith(needle)
                const bStarts = needle.length > 0 && b.name.toLowerCase().startsWith(needle)
                if (aStarts !== bStarts)
                    return aStarts ? -1 : 1
                return a.name.localeCompare(b.name)
            })
            .slice(0, 60)
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 76
        width: Math.min(520, parent.width - 40)
        height: Math.min(560, parent.height - 116)
        radius: 16
        color: Theme.bg
        border.width: 1
        border.color: Theme.border

        MouseArea {
            anchors.fill: parent
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "APPLICATIONS"
                color: Theme.accent
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.6
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: 11
                color: Theme.surface
                border.width: searchInput.activeFocus ? 1 : 0
                border.color: Theme.accent

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    text: root.query
                    color: Theme.textBright
                    selectionColor: Theme.accentDeep
                    selectedTextColor: Theme.selectedText
                    font.family: "Inter"
                    font.pixelSize: 14
                    clip: true

                    onTextChanged: {
                        root.query = text
                        appList.currentIndex = 0
                    }
                    onAccepted: root.launch(filteredApps.values[appList.currentIndex])
                    Keys.onDownPressed: appList.currentIndex = Math.min(appList.count - 1, appList.currentIndex + 1)
                    Keys.onUpPressed: appList.currentIndex = Math.max(0, appList.currentIndex - 1)
                    Keys.onEscapePressed: root.close()

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Type to search…"
                        color: Theme.textDim
                        font: parent.font
                        visible: parent.text.length === 0
                    }
                }
            }

            ListView {
                id: appList
                width: parent.width
                height: parent.height - 92
                model: filteredApps
                clip: true
                spacing: 4
                currentIndex: 0

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: appList.width
                    height: 54
                    radius: 10
                    color: index === appList.currentIndex ? Theme.accentFill : appMouse.containsMouse ? Theme.surface : "transparent"

                    Image {
                        id: appIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 30
                        height: 30
                        source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                        fillMode: Image.PreserveAspectFit
                    }

                    Rectangle {
                        anchors.fill: appIcon
                        visible: appIcon.status === Image.Error || appIcon.source.toString().length === 0
                        radius: 8
                        color: Theme.active

                        Text {
                            anchors.centerIn: parent
                            text: modelData.name.length > 0 ? modelData.name[0].toUpperCase() : "·"
                            color: Theme.focusText
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }
                    }

                    Column {
                        anchors.left: appIcon.right
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            width: parent.width
                            text: modelData.name
                            color: Theme.textBright
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: modelData.comment || modelData.genericName
                            color: Theme.textDim
                            font.family: "Inter"
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: appMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: appList.currentIndex = index
                        onClicked: root.launch(modelData)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: appList.count === 0
                    text: "No matching applications"
                    color: Theme.textDim
                    font.family: "Inter"
                    font.pixelSize: 13
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.close()
    }
}
