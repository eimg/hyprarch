# Locked stack

These choices are the product. Do not “simplify” them into another desktop.

```text
UX:          original Quickshell (config name hyprarch)
Compositor:  Hyprland 0.55+ Lua, from extra
Session:     UWSM (`uwsm start -e -D Hyprland hyprland.desktop`)
Login:       greetd + tuigreet on VT1
OS:          Arch, official core/extra
Plumbing:    systemd, pacman, NetworkManager, PipeWire, portals, polkit
```

## Use extra. Ask before anything else

Prefer packages that exist in `extra` on this architecture. If extra is missing a required package, stop and say so.

Ask the user before:

- AUR, Chaotic-AUR, or other unofficial repos
- `hyprland-git` / `quickshell-git`
- Broad removals
- Security-sensitive PAM or sudo changes

Never partial-upgrade (`pacman -S` without a recent `-Syu`).

## Do not install

```text
gnome, gnome-shell, gdm
plasma, sddm
omarchy installer
dms / dankmaterialshell
nautilus          (slow; pulls Tracker)
```

Nemo is acceptable later if someone wants Cinnamon chrome. The kickstart uses **Thunar**.

Omarchy and DMS are **references** for workflow and widget behavior. Implement original Quickshell. Do not copy their Material UI.

## Session rules

- Hyprland config is `~/.config/hypr/hyprland.lua`. Delete leftover `hyprland.conf`.
- Do not `exec` Quickshell from Hyprland. systemd `--user` owns `hyprarch-shell.service`.
- greetd owns the visible VT (usually VT1). Keep SSH. Keep a recovery getty on TTY2.
- Kickstart `uwsm/env` sets `XDG_CURRENT_DESKTOP=Hyprland`. That is correct until a second compositor exists. Then drop the hardcoded desktop names (see [OPTIONAL-SESSIONS.md](OPTIONAL-SESSIONS.md)).
- `ADW_DISABLE_PORTAL=1` so GTK CSS applies.

## Optional compositors

niri and mango are **not** part of the locked stack. Do not install them unless the user asks. When they do, follow [OPTIONAL-SESSIONS.md](OPTIONAL-SESSIONS.md). Do not invent a fourth session manager or ship those configs into this repo by default.

## Privilege

SSH keys ≠ passwordless sudo. Privileged work needs a visible `sudo` prompt. User-level work is copy + `systemctl --user`.
