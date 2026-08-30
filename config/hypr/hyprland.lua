-- HyprArch desktop (Hyprland 0.55+ Lua).
-- Do not add dwindle.pseudotile. Do not exec Quickshell from here;
-- systemd --user owns the shell under graphical-session.target.
--
-- Default monitor is portable. --track parallels rewrites this block
-- (see extras/parallels and docs/tracks/parallels.md).
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("GTK_ICON_THEME", "Hyprarch")
hl.env("ADW_DISABLE_PORTAL", "1")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        layout = "dwindle",
        allow_tearing = false,
        col = {
            active_border = "rgba(7dd3fcee)",
            inactive_border = "rgba(475569aa)",
        },
    },
    decoration = {
        rounding = 6,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        blur = { enabled = false },
    },
    animations = { enabled = false },
    dwindle = {
        preserve_split = true,
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})

local mod = "SUPER"

hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("foot"))
hl.bind(mod .. " + SPACE", hl.dsp.global("hyprarch:launcher"))
hl.bind(mod .. " + slash", hl.dsp.global("hyprarch:keybinds"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("mousepad"))
hl.bind(mod .. " + Q", function()
    local win = hl.get_active_window()
    if win ~= nil and (win.class == "imv" or win.initial_class == "imv"
        or win.class == "nsxiv" or win.initial_class == "nsxiv"
        or win.class == "Nsxiv" or win.initial_class == "Nsxiv") then
        hl.dispatch(hl.dsp.window.kill())
    else
        hl.dispatch(hl.dsp.window.close())
    end
end)
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

for workspace = 1, 5 do
    hl.bind(mod .. " + " .. workspace, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mod .. " + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.window_rule({
    match = { class = "Nsxiv" },
    float = true,
    center = true,
    size = { "monitor_w * 0.78", "monitor_h * 0.78" },
})

