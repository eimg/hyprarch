import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower

ShellRoot {
    id: root

    signal toggleLauncherRequested()
    signal toggleKeybindsRequested()

    property var audioSink: Pipewire.defaultAudioSink
    property var connectedDevice: Networking.devices.values.find(device => device.connected) || null
    property var battery: UPower.displayDevice

    readonly property string uiFont: "Inter"
    readonly property string iconFont: "Symbols Nerd Font"

    function volumeIcon() {
        if (!audioSink || !audioSink.audio || audioSink.audio.muted)
            return "\uf6a9"
        const level = audioSink.audio.volume
        if (level < 0.01)
            return "\uf026"
        if (level < 0.34)
            return "\uf027"
        return "\uf028"
    }

    function volumeText() {
        if (!audioSink || !audioSink.audio)
            return "--"
        if (audioSink.audio.muted)
            return "MUTE"
        return Math.round(audioSink.audio.volume * 100) + "%"
    }

    function networkIcon() {
        if (!connectedDevice)
            return "\uf127"
        const name = String(connectedDevice.name || "").toLowerCase()
        if (name.startsWith("wl") || name.indexOf("wlan") !== -1 || name.indexOf("wifi") !== -1)
            return "\uf1eb"
        return "\uf0ac"
    }

    function batteryVisible() {
        return battery && battery.ready && battery.isLaptopBattery
    }

    function batteryCharging() {
        return batteryVisible() && battery.state === UPowerDeviceState.Charging
    }

    function batteryIcon() {
        if (!batteryVisible())
            return ""
        if (batteryCharging())
            return "\uf0e7"
        const pct = battery.percentage
        if (pct >= 0.9)
            return "\uf240"
        if (pct >= 0.7)
            return "\uf241"
        if (pct >= 0.45)
            return "\uf242"
        if (pct >= 0.2)
            return "\uf243"
        return "\uf244"
    }

    function batteryText() {
        if (!batteryVisible())
            return ""
        return Math.round(battery.percentage * 100) + "%"
    }

    PwObjectTracker {
        objects: [root.audioSink]
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    GlobalShortcut {
        appid: "hyprarch"
        name: "launcher"
        description: "Open the HyprArch application launcher"
        onPressed: root.toggleLauncherRequested()
    }

    GlobalShortcut {
        appid: "hyprarch"
        name: "keybinds"
        description: "Open the HyprArch keybind cheatsheet"
        onPressed: root.toggleKeybindsRequested()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData

            property double popupClosedAt: 0

            screen: modelData
            color: Theme.bgBar
            implicitHeight: 44
            exclusiveZone: 44

            anchors {
                top: true
                left: true
                right: true
            }

            function requestLauncher() {
                quickSettings.close()
                powerMenu.close()
                keybinds.close()
                calendar.close()
                settings.close()
                launcher.toggle()
            }

            function requestKeybinds() {
                launcher.close()
                quickSettings.close()
                powerMenu.close()
                calendar.close()
                settings.close()
                keybinds.toggle()
            }

            function requestCalendar() {
                launcher.close()
                quickSettings.close()
                powerMenu.close()
                keybinds.close()
                settings.close()
                calendar.toggle()
            }

            function requestSettings() {
                launcher.close()
                quickSettings.close()
                powerMenu.close()
                keybinds.close()
                calendar.close()
                if (settings.visible)
                    settings.close()
                else
                    settings.open()
            }

            Connections {
                target: root

                function onToggleLauncherRequested() {
                    if (bar.modelData === Quickshell.screens[0])
                        bar.requestLauncher()
                }

                function onToggleKeybindsRequested() {
                    if (bar.modelData === Quickshell.screens[0])
                        bar.requestKeybinds()
                }
            }

            Item {
                id: barBody
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Row {
                    id: leftCluster
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    Rectangle {
                        id: workspaceGroup
                        implicitWidth: workspaceRow.implicitWidth + 8
                        implicitHeight: 30
                        radius: 9
                        color: Theme.surface
                        anchors.verticalCenter: parent.verticalCenter

                        Row {
                            id: workspaceRow
                            anchors.centerIn: parent
                            spacing: 2

                            Repeater {
                                model: 3

                                Rectangle {
                                    required property int index
                                    property int workspaceNumber: index + 1
                                    property bool focused: Hyprland.focusedWorkspace !== null
                                        && Hyprland.focusedWorkspace.id === workspaceNumber
                                    property bool occupied: Hyprland.workspaces.values.some(workspace =>
                                        workspace.id === workspaceNumber && workspace.toplevels.values.length > 0)

                                    width: 28
                                    height: 24
                                    radius: 6
                                    color: focused ? Theme.accentDeep : workspaceMouse.containsMouse ? Theme.hover : "transparent"
                                    border.width: occupied && !focused ? 1 : 0
                                    border.color: Theme.borderMuted

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.workspaceNumber
                                        color: parent.focused ? Theme.focusText : parent.occupied ? Theme.text : Theme.textDim
                                        font.family: root.uiFont
                                        font.pixelSize: 12
                                        font.weight: parent.focused ? Font.DemiBold : Font.Normal
                                    }

                                    MouseArea {
                                        id: workspaceMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + parent.workspaceNumber + " })")
                                    }
                                }
                            }
                        }
                    }

                    UiButton {
                        id: launcherButton
                        icon: "\uf00a"
                        label: "Apps"
                        accent: true
                        active: launcher.visible
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: bar.requestLauncher()
                    }

                    Text {
                        visible: Hyprland.activeToplevel && Hyprland.activeToplevel.title
                        width: Math.min(implicitWidth, 280)
                        anchors.verticalCenter: parent.verticalCenter
                        text: Hyprland.activeToplevel && Hyprland.activeToplevel.title
                            ? Hyprland.activeToplevel.title
                            : ""
                        color: Theme.textMuted
                        font.family: root.uiFont
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Rectangle {
                    id: clockButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1
                    implicitWidth: clockLabel.implicitWidth + 16
                    implicitHeight: 30
                    radius: 9
                    color: calendar.visible ? Theme.active : clockMouse.containsMouse ? Theme.hover : "transparent"
                    border.width: 1
                    border.color: calendar.visible ? Theme.accent : "transparent"

                    Text {
                        id: clockLabel
                        anchors.centerIn: parent
                        text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")
                        color: calendar.visible ? Theme.accentSoft : Theme.textBright
                        font.family: root.uiFont
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        verticalAlignment: Text.AlignVCenter
                    }

                    MouseArea {
                        id: clockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (calendar.visible) {
                                calendar.close()
                            } else if (Date.now() - bar.popupClosedAt >= 250) {
                                bar.requestCalendar()
                            }
                        }
                    }
                }

                Row {
                    id: rightCluster
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    UiButton {
                        id: settingsButton
                        icon: "\uf013"
                        active: settings.visible
                        onClicked: {
                            if (settings.visible) {
                                settings.close()
                            } else if (Date.now() - bar.popupClosedAt >= 250) {
                                bar.requestSettings()
                            }
                        }
                    }

                    UiButton {
                        id: keybindsButton
                        icon: "\uf11c"
                        active: keybinds.visible
                        onClicked: {
                            if (keybinds.visible) {
                                keybinds.close()
                            } else if (Date.now() - bar.popupClosedAt >= 250) {
                                bar.requestKeybinds()
                            }
                        }
                    }

                    Row {
                        spacing: 7
                        visible: SystemTray.items.values.length > 0
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: SystemTray.items

                            Item {
                                required property var modelData
                                width: 24
                                height: 28

                                Image {
                                    anchors.centerIn: parent
                                    width: 17
                                    height: 17
                                    source: modelData.icon
                                    fillMode: Image.PreserveAspectFit
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                                            const point = bar.itemPosition(parent)
                                            modelData.display(bar, point.x, bar.height)
                                        } else {
                                            modelData.activate()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: statusButton
                        implicitWidth: statusRow.implicitWidth + 18
                        implicitHeight: 30
                        radius: 9
                        color: quickSettings.visible ? Theme.active : statusMouse.containsMouse ? Theme.hover : Theme.surface
                        border.width: 1
                        border.color: quickSettings.visible ? Theme.accent : "transparent"

                        Row {
                            id: statusRow
                            anchors.centerIn: parent
                            spacing: 12

                            Row {
                                spacing: 5

                                Text {
                                    text: root.volumeIcon()
                                    color: Theme.text
                                    font.family: root.iconFont
                                    font.pixelSize: 13
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Text {
                                    text: root.volumeText()
                                    color: Theme.text
                                    font.family: root.uiFont
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Text {
                                text: root.networkIcon()
                                color: root.connectedDevice ? Theme.accent : Theme.textMuted
                                font.family: root.iconFont
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }

                            Row {
                                visible: root.batteryVisible()
                                spacing: 5

                                Text {
                                    text: root.batteryIcon()
                                    color: root.batteryCharging() ? Theme.accent : Theme.text
                                    font.family: root.iconFont
                                    font.pixelSize: 13
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Text {
                                    text: root.batteryText()
                                    color: Theme.text
                                    font.family: root.uiFont
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        MouseArea {
                            id: statusMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                launcher.close()
                                powerMenu.close()
                                keybinds.close()
                                calendar.close()
                                settings.close()
                                if (quickSettings.visible) {
                                    quickSettings.close()
                                } else if (Date.now() - bar.popupClosedAt >= 250) {
                                    quickSettings.open()
                                }
                            }
                        }
                    }

                    UiButton {
                        id: powerButton
                        icon: "\uf011"
                        active: powerMenu.visible
                        onClicked: {
                            launcher.close()
                            quickSettings.close()
                            keybinds.close()
                            calendar.close()
                            settings.close()
                            if (powerMenu.visible) {
                                powerMenu.close()
                            } else if (Date.now() - bar.popupClosedAt >= 250) {
                                powerMenu.open()
                            }
                        }
                    }
                }
            }

            AppLauncher {
                id: launcher
                targetScreen: bar.screen
            }

            CalendarPopup {
                id: calendar
                panelWindow: bar
                now: clock.date
                onVisibleChanged: {
                    if (!visible)
                        bar.popupClosedAt = Date.now()
                }
            }

            Keybinds {
                id: keybinds
                anchorItem: keybindsButton
                panelWindow: bar
                onVisibleChanged: {
                    if (!visible)
                        bar.popupClosedAt = Date.now()
                }
            }

            QuickSettings {
                id: quickSettings
                anchorItem: statusButton
                panelWindow: bar
                audioSink: root.audioSink
                connectedDevice: root.connectedDevice
                battery: root.battery
                onSettingsRequested: bar.requestSettings()
                onVisibleChanged: {
                    if (!visible)
                        bar.popupClosedAt = Date.now()
                }
            }

            Settings {
                id: settings
                anchorItem: settingsButton
                panelWindow: bar
                onVisibleChanged: {
                    if (!visible)
                        bar.popupClosedAt = Date.now()
                }
            }

            PowerMenu {
                id: powerMenu
                anchorItem: powerButton
                panelWindow: bar
                onVisibleChanged: {
                    if (!visible)
                        bar.popupClosedAt = Date.now()
                }
            }
        }
    }
}
