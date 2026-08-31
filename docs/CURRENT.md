# Current desktop

This is the working HyprArch desktop as of 2026-08-31. The development guest was Arch Linux ARM in Parallels on Apple Silicon. The same widgets and apps are what `--track metal` should produce, except the monitor block and Parallels extras.

## Session

| Piece | Reality |
|---|---|
| Hyprland | 0.56.x Lua from extra |
| UWSM | starts `hyprland.desktop` |
| greetd | VT1, tuigreet greeting `HyprArch` |
| Recovery | Ctrl+Alt+F2 |
| Shell | Quickshell 0.3.x, config `hyprarch` |
| Wallpaper | `swaybg` via `hyprarch-wallpaper.service` |
| Clipboard history | text/image `wl-paste` watchers via `cliphist-*.service` |

## Apps

| Role | App |
|---|---|
| Terminal | Foot |
| Files | Thunar (CSD, no menu/status bar, 24px sidebar icons) |
| Notepad | Mousepad (Hyprarch GtkSourceView scheme) |
| Editor (TTY) | Neovim |
| Browser | Chromium (`--password-store=basic`) |
| Images | `hyprarch-imv` → nsxiv (imv draws black on this Parallels GPU) |
| Icons | Papirus-Dark via user overlay `Hyprarch` (folder color follows palette) |

## Keybinds

| Keys | Action |
|---|---|
| Super+Enter | Foot |
| Super+Space | Launcher |
| Super+E | Thunar |
| Super+N | Mousepad |
| Super+Q | Close (force-kill for nsxiv/imv) |
| Super+F | Fullscreen |
| Super+V | Float/tile |
| Super+1…5 | Workspace |
| Super+Shift+1…5 | Move window |
| Super+/ | Cheatsheet |
| Super+Shift+E | `uwsm stop` |

## Theme

Settings popup: Teal, Dusk, Pine, Slate, Rose, Amber. Choosing a palette updates Hyprland borders, nsxiv chrome, Papirus folder color, and Mousepad selection. Sidebar/editor **page** background stays ordinary Adwaita charcoal.

## Parallels-only facts (development guest)

- Forced mode `3024x1898@60` scale 2. virtio-gpu often advertises `1024x768` as preferred.
- `prl_fs` shared folders usually absent on ARM. Clipboard is incomplete.
- `imv` is unusable on that GPU; nsxiv is the real viewer.
- Root disk was grown after a small installer `/`. Not part of the public installer.
- Kernel package can be newer than the running image until `/boot` is updated.

## Deliberate non-goals

- No GNOME/KDE session
- No VS Code in the kickstart
- No grim-based screenshot tool in the kickstart
- No CJK fonts unless disk allows (`noto-fonts-cjk`)
- No niri or mango in this kickstart (optional later: [OPTIONAL-SESSIONS.md](OPTIONAL-SESSIONS.md))
