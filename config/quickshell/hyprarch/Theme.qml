pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME") || "/home/eimg"
    readonly property var catalog: [
        {
            id: "teal",
            name: "Teal",
            match: "hyper-teal-waves",
            bg: "#0b1220",
            bgBar: "#b80b1220",
            overlay: "#99060b14",
            surface: "#111c2f",
            hover: "#143844",
            active: "#164e63",
            border: "#243247",
            borderMuted: "#334155",
            accent: "#67e8f9",
            accentSoft: "#a5f3fc",
            accentDeep: "#155e75",
            accentFill: "#12343f",
            text: "#e2e8f0",
            textBright: "#f8fafc",
            textMuted: "#94a3b8",
            textDim: "#64748b",
            focusText: "#cffafe",
            textFaint: "#475569",
            selectedText: "#ecfeff",
            tileScrim: "#cc0b1220",
            meter: "#22d3ee",
            ok: "#22c55e",
            bad: "#fb7185",
            hyprActive: "rgba(7dd3fcee)",
            hyprInactive: "rgba(475569aa)"
        },
        {
            id: "dusk",
            name: "Dusk",
            match: "dusk-navy",
            bg: "#0a1628",
            bgBar: "#b80a1628",
            overlay: "#9908141f",
            surface: "#0f1c32",
            hover: "#1e3a5f",
            active: "#1e40af",
            border: "#1e3a5f",
            borderMuted: "#334155",
            accent: "#93c5fd",
            accentSoft: "#bfdbfe",
            accentDeep: "#1d4ed8",
            accentFill: "#172554",
            text: "#e2e8f0",
            textBright: "#f8fafc",
            textMuted: "#94a3b8",
            textDim: "#64748b",
            focusText: "#dbeafe",
            textFaint: "#475569",
            selectedText: "#eff6ff",
            tileScrim: "#cc0a1628",
            meter: "#60a5fa",
            ok: "#22c55e",
            bad: "#fb7185",
            hyprActive: "rgba(93c5fdcc)",
            hyprInactive: "rgba(334155aa)"
        },
        {
            id: "pine",
            name: "Pine",
            match: "deep-teal",
            bg: "#04211f",
            bgBar: "#b804211f",
            overlay: "#99031412",
            surface: "#0f2f2c",
            hover: "#115e59",
            active: "#0f766e",
            border: "#134e4a",
            borderMuted: "#115e59",
            accent: "#5eead4",
            accentSoft: "#99f6e4",
            accentDeep: "#0f766e",
            accentFill: "#134e4a",
            text: "#e2e8f0",
            textBright: "#f8fafc",
            textMuted: "#94a3b8",
            textDim: "#6b9b96",
            focusText: "#ccfbf1",
            textFaint: "#115e59",
            selectedText: "#f0fdfa",
            tileScrim: "#cc04211f",
            meter: "#2dd4bf",
            ok: "#34d399",
            bad: "#fb7185",
            hyprActive: "rgba(5eead4cc)",
            hyprInactive: "rgba(134e4aaa)"
        },
        {
            id: "slate",
            name: "Slate",
            match: "",
            bg: "#0f1419",
            bgBar: "#b80f1419",
            overlay: "#99080b10",
            surface: "#1e293b",
            hover: "#334155",
            active: "#475569",
            border: "#334155",
            borderMuted: "#475569",
            accent: "#cbd5e1",
            accentSoft: "#e2e8f0",
            accentDeep: "#64748b",
            accentFill: "#334155",
            text: "#e2e8f0",
            textBright: "#f8fafc",
            textMuted: "#94a3b8",
            textDim: "#64748b",
            focusText: "#f1f5f9",
            textFaint: "#475569",
            selectedText: "#f8fafc",
            tileScrim: "#cc0f1419",
            meter: "#94a3b8",
            ok: "#22c55e",
            bad: "#fb7185",
            hyprActive: "rgba(cbd5e1cc)",
            hyprInactive: "rgba(334155aa)"
        },
        {
            id: "rose",
            name: "Rose",
            match: "",
            bg: "#1c1418",
            bgBar: "#b81c1418",
            overlay: "#99140e12",
            surface: "#2a1a22",
            hover: "#4c1d36",
            active: "#9f1239",
            border: "#4c1d36",
            borderMuted: "#701a3c",
            accent: "#fda4af",
            accentSoft: "#fecdd3",
            accentDeep: "#be123c",
            accentFill: "#4c0519",
            text: "#f1e5e8",
            textBright: "#fff1f2",
            textMuted: "#e11d48aa",
            textDim: "#9f1239",
            focusText: "#ffe4e6",
            textFaint: "#701a3c",
            selectedText: "#fff1f2",
            tileScrim: "#cc1c1418",
            meter: "#fb7185",
            ok: "#22c55e",
            bad: "#fb7185",
            hyprActive: "rgba(fda4afcc)",
            hyprInactive: "rgba(4c1d36aa)"
        },
        {
            id: "amber",
            name: "Amber",
            match: "",
            bg: "#1a140b",
            bgBar: "#b81a140b",
            overlay: "#99140f08",
            surface: "#292017",
            hover: "#78350f",
            active: "#b45309",
            border: "#78350f",
            borderMuted: "#92400e",
            accent: "#fbbf24",
            accentSoft: "#fde68a",
            accentDeep: "#b45309",
            accentFill: "#451a03",
            text: "#f5e6c8",
            textBright: "#fffbeb",
            textMuted: "#d6b06a",
            textDim: "#92400e",
            focusText: "#fef3c7",
            textFaint: "#78350f",
            selectedText: "#fffbeb",
            tileScrim: "#cc1a140b",
            meter: "#f59e0b",
            ok: "#22c55e",
            bad: "#fb7185",
            hyprActive: "rgba(fbbf24cc)",
            hyprInactive: "rgba(78350faa)"
        }
    ]

    property string themeId: "teal"

    readonly property var current: palette(themeId)
    readonly property string bg: current.bg
    readonly property string bgBar: current.bgBar
    readonly property string overlay: current.overlay
    readonly property string surface: current.surface
    readonly property string hover: current.hover
    readonly property string active: current.active
    readonly property string border: current.border
    readonly property string borderMuted: current.borderMuted
    readonly property string accent: current.accent
    readonly property string accentSoft: current.accentSoft
    readonly property string accentDeep: current.accentDeep
    readonly property string accentFill: current.accentFill
    readonly property string text: current.text
    readonly property string textBright: current.textBright
    readonly property string textMuted: current.textMuted
    readonly property string textDim: current.textDim
    readonly property string focusText: current.focusText
    readonly property string textFaint: current.textFaint
    readonly property string selectedText: current.selectedText
    readonly property string tileScrim: current.tileScrim
    readonly property string meter: current.meter
    readonly property string ok: current.ok
    readonly property string bad: current.bad

    function palette(id) {
        for (let i = 0; i < catalog.length; i++) {
            if (catalog[i].id === id)
                return catalog[i]
        }
        return catalog[0]
    }

    function setTheme(id) {
        const next = palette(id)
        themeId = next.id
        adapter.theme = next.id
        store.writeAdapter()
        applyChrome()
    }

    function themeForWallpaper(path) {
        const name = String(path).split("/").pop().toLowerCase()
        for (let i = 0; i < catalog.length; i++) {
            if (catalog[i].match.length > 0 && name.indexOf(catalog[i].match) !== -1)
                return catalog[i].id
        }
        return ""
    }

    function applyChrome() {
        const p = current
        Quickshell.execDetached([
            root.home + "/.local/bin/hyprarch-apply-theme",
            p.bg, p.accentSoft, p.textMuted, p.accent, p.hyprActive, p.hyprInactive,
            p.id, p.surface, p.hover, p.accentFill
        ])
    }

    FileView {
        id: store
        path: root.home + "/.config/hyprarch/settings.json"
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()

        JsonAdapter {
            id: adapter
            property string theme: "teal"
        }
    }

    Component.onCompleted: {
        if (adapter.theme && adapter.theme !== themeId)
            themeId = adapter.theme
        applyChrome()
    }

    Connections {
        target: adapter
        function onThemeChanged() {
            if (adapter.theme && adapter.theme !== root.themeId)
                root.themeId = adapter.theme
            root.applyChrome()
        }
    }
}
