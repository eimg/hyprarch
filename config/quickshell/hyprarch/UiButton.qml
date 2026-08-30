import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string label: ""
    property string icon: ""
    property string sublabel: ""
    property bool accent: false
    property bool active: false
    signal clicked()

    implicitWidth: Math.max(36, content.implicitWidth + 16)
    implicitHeight: 30
    radius: 9
    color: active ? Theme.active : mouse.containsMouse ? Theme.hover : Theme.surface
    border.width: 1
    border.color: active ? Theme.accent : accent && !mouse.containsMouse ? Theme.accentDeep : "transparent"

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Text {
            visible: root.icon.length > 0
            text: root.icon
            color: root.accent || root.active ? Theme.accentSoft : Theme.text
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.label.length > 0
            text: root.label
            color: root.accent || root.active ? Theme.accentSoft : Theme.text
            font.family: "Inter"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.sublabel.length > 0
            text: root.sublabel
            color: Theme.textMuted
            font.family: "Inter"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
