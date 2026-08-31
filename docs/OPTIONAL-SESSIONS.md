# Optional sessions (niri, mango)

The kickstart installs **Hyprland only**. That is the daily desktop. This file is for a human (or an agent) who wants a **second or third** greetd choice later.

This repo does **not** ship niri/mango configs, session `.desktop` files, or install scripts. Implement from compositor docs plus the rules below. Snapshot the VM first. Do not replace Hyprland. Do not copy a live guest tree into this repo unless the user asks to publish it.

Upstream:

- niri: [YaLTeR/niri](https://github.com/YaLTeR/niri) (usually in Arch `extra`)
- mango: [mangowm/mango](https://github.com/mangowm/mango) (**not** in `extra`; build)

## When to use this

After Hyprland + Quickshell + greetd already work. The user asks for niri and/or mango as an F3 option at tuigreet. Super+Shift+E (`uwsm stop`) returns to the greeter. Recovery stays Ctrl+Alt+F2.

If the user did not ask, do not add compositors.

## Shared rules (paid for)

These apply to **any** extra compositor on this desktop.

### Greeter

The kickstart tuigreet uses `--cmd` and starts Hyprland only. Extra sessions need `--sessions` pointing at a **custom directory** you own (for example `/usr/local/share/wayland-sessions/hyprarch`), plus `--remember-session`.

List **only** UWSM wrappers there. Never list packaged files:

| Packaged file | What goes wrong |
|---|---|
| `hyprland.desktop` | Hyprland **without UWSM** → empty session, no bar |
| `niri.desktop` / `niri-session` | Second session manager fighting UWSM |
| `mango.desktop` | mango **without UWSM** → same empty-bar class of bug |

Typical Exec lines (write the `.desktop` files; do not invent a different session manager):

```text
uwsm start -e -D Hyprland hyprland.desktop
uwsm start -e -D niri -- niri --session
uwsm start -e -D mango -- mango
```

**Do not restart greetd while a compositor is running.** It kills the session. Next logout picks up greeter changes.

Privileged copies (`/usr/local`, pacman, greetd wrapper) need a **visible** `sudo` prompt. SSH keys are not passwordless sudo.

### UWSM environment

Kickstart `config/uwsm/env` hardcodes `XDG_CURRENT_DESKTOP=Hyprland` and `XDG_SESSION_DESKTOP=Hyprland`. That is correct for Hyprland-only. **Remove those two lines** before a second compositor, or Quickshell will treat niri/mango as Hyprland. The `-D` flag on `uwsm start` sets the desktop.

Use compositor-specific `~/.config/uwsm/env-<name>` files:

- niri: wait/finalize `NIRI_SOCKET`
- mango: wait/finalize `MANGO_INSTANCE_SIGNATURE`

Do not `exec` qs, swaybg, or waybar from niri or mango config. systemd `--user` already owns `hyprarch-shell` and `hyprarch-wallpaper`.

User units must **not** have Hyprland-only `After=`. They should start on `graphical-session.target` for every compositor.

### Quickshell (one config, several compositors)

Keep config name `hyprarch`. Detect each compositor **separately**:

- Hyprland: `HYPRLAND_INSTANCE_SIGNATURE`
- niri: `NIRI_SOCKET` or desktop name contains `niri`
- mango: `MANGO_INSTANCE_SIGNATURE` or desktop name contains `mango`

**Never** treat `!onHyprland` as niri. A third WM then gets niri widgets and `niri msg` polls.

Shortcuts: `GlobalShortcut` is Hyprland-only (`hyprland_global_shortcuts_v1`). Instantiate those QML objects only when Hyprland is active; merely leaving them present on niri/mango emits unsupported-protocol warnings. On niri/mango, Super+Space / Super+/ should `qs -c hyprarch ipc call shell …`.

IPC from QML: plain argv (`execDetached(["niri", "msg", …])`). Do **not** wrap in `bash -c` with `"$1"` — the argument can vanish.

Do not hand-write `qmldir`. Quickshell generates it. A file that only lists `Theme` makes every other type fail.

Menus: `HyprlandFocusGrab` on Hyprland only. On niri/mango, let the `PopupWindow` grab focus so clicking elsewhere dismisses it. Do **not** add a fullscreen transparent click-away `PanelWindow` (broke layout and input on niri).

Some compositors ignore clicks on fully transparent layer pixels. Keep clickable bar chrome opaque.

Cheatsheets must be **native** to that WM (not Hyprland with the arrows swapped). Match HyprArch apps (Foot, Thunar, Mousepad, `uwsm stop`) but describe that compositor’s own workspace model.

From SSH, `qs ipc -c hyprarch` often misses the instance. Use `qs ipc --pid` with the `hyprarch-shell.service` MainPID and `XDG_RUNTIME_DIR=/run/user/UID`.

## niri

Scrollable tiling. **Workspaces are not Hyprland rooms.**

- Horizontal: columns on a strip; windows keep width; you scroll.
- Vertical: dynamic stack per monitor; empty middles vanish; indices are positions, not stable “room 3”.

Package from `extra` when it exists (`pacman -Si niri`). Do not add AUR unless extra is missing and the user agrees.

Bar: a **stack** control (up / dots / index / down / overview), not numbered 1/2/3 pills. Super+1–5 as index jumps are a crutch; do not put them on the niri cheatsheet. Overview is a niri action (`toggle-overview`), not a Hyprland thing.

Settled UX from the development guest (keep unless the user asks otherwise):

- Client-side decorations on
- New columns about half width; no preset-width key; resize with Super+right-drag
- Super+F is **true fullscreen** (covers the bar), not column half/full

Output names vary on VMs. A oneshot that applies the Retina mode when `NIRI_SOCKET` exists is safer than assuming `Virtual-1`.

For a Thunar-only desktop, use `xdg-desktop-portal-wlr` for Screenshot and ScreenCast and route FileChooser to GTK in `niri-portals.conf`. This keeps Nautilus and `xdg-desktop-portal-gnome` out of the installation. The tradeoff is less capable screencasting than niri's recommended GNOME portal path, especially for window-specific and dynamic cast targets.

`niri msg` from SSH needs `NIRI_SOCKET` from `systemctl --user show-environment`.

## mango (mangowm)

dwm-style **tags**, not workspaces. Super+1 **views** a tag (a label). Super+Shift+1 **assigns** the window to that tag. A window can have several tags. There is no empty Hyprland-style room waiting.

Not in `extra`. Typical build path on a guest that already has `wlroots0.20` in extra: build [scenefx](https://github.com/wlrfx/scenefx) 0.5 into `/usr/local`, then mango. Pin exact tested commits for both source trees, and use `pacman -Syu` rather than `pacman -Sy` before building. Hyprland uses aquamarine; leave it alone.

Install `xdg-desktop-portal-wlr` and route mango's Screenshot and ScreenCast portals to `wlr`; keep general desktop portals on GTK.

`mmsg` is the IPC (`MANGO_INSTANCE_SIGNATURE`). Commands look like:

```text
mmsg get all-tags
mmsg dispatch view,1,0
```

Do **not** use dwl-msg flags (`mmsg -s -t N`). Bar pills should dispatch `view,N,0` and highlight from `get all-tags`.

Traps:

- Session starts and returns to tuigreet: mango cannot load `libscenefx-0.5.so`. Arch ldconfig does **not** search `/usr/local/lib` unless you add it (`ld.so.conf.d`) and run `ldconfig`. Also put `LD_LIBRARY_PATH=/usr/local/lib` on the mango UWSM unit.
- Pointer missing on virtio-gpu / Parallels: wlroots hardware cursors. Set `WLR_NO_HARDWARE_CURSORS=1` in mango-only env. Hyprland does not need this. Needs a **new login**, not a config reload.
- Super+R on mango reloads *mango* config. Do not teach that as Hyprland.

Inside a tag, tiling is master + stack, not Hyprland dwindle. Cheatsheet should say tags, not rooms.

`mmsg` from SSH needs `MANGO_INSTANCE_SIGNATURE` (and usually `WAYLAND_DISPLAY`).

## Order of work for an agent

1. Confirm Hyprland already works. Snapshot.
2. Ask which extras: niri, mango, or both. Hyprland stays the default.
3. Fix `uwsm/env` (drop hardcoded Hyprland desktop names).
4. Install the compositor (extra vs build). Visible sudo for `/usr/local`.
5. Custom greeter session dir + UWSM Exec lines above. Do not restart greetd yet.
6. Compositor config: keybinds in the HyprArch spirit, **no** bar/wallpaper spawn.
7. Quickshell: detect that WM; native workspace widget; native cheatsheet; no `!hyprland → niri`.
8. Gate compositor-specific monitor helpers with `ExecCondition`; keep shared clipboard-history watchers attached to `graphical-session.target`.
9. Tell the user to log out (Super+Shift+E) and pick the session with F3.

Do not run `scripts/install-desktop.sh` again on a machine that already has the desktop.
