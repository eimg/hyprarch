# Agent handover

Read this, [STACK.md](STACK.md), and [CURRENT.md](CURRENT.md) before changing the machine. The human already did (or will do) Arch install, sudo, network, and SSH. See [USER.md](USER.md).

You are continuing a **bespoke desktop**, not inventing a new one.

## First actions

1. Confirm the track: `metal` or `parallels`.
2. Verify instead of assuming:

   ```text
   uname -m
   pacman -Syu (report, then run when appropriate)
   pacman -Si hyprland          # must be 0.55+ Lua
   pacman -Si quickshell
   id / sudo -n true            # sudo may need a visible prompt
   ip / nmcli                   # NetworkManager should own the NIC
   ssh still works if you are remote
   df -h /                      # do not fill a tiny root
   ```

3. If Hyprland in extra is still conf-era (&lt; 0.55), **stop**. Do not switch to `hyprland-git` unless the user approves.
4. Snapshot (ask) before greetd / compositor changes.

## Install

Repo root on the guest (clone or copy):

```bash
bash scripts/install-desktop.sh --track metal
# or
bash scripts/install-desktop.sh --track parallels
```

The script copies `config/` into `$HOME` and `/etc`, enables greetd, does **not** reboot unless `--reboot`.

Privileged steps need a visible Terminal (`ssh -t` is fine). Do not loop on a failed sudo password from a non-interactive SSH.

After reboot: greetd on VT1, Hyprland via UWSM, Quickshell bar. Recovery: Ctrl+Alt+F2.

## Where files live

Live guest files are ordinary copies of this tree:

| Repo | Guest |
|---|---|
| `config/hypr/hyprland.lua` | `~/.config/hypr/hyprland.lua` |
| `config/uwsm/env` | `~/.config/uwsm/env` |
| `config/quickshell/hyprarch/*.qml` | `~/.config/quickshell/hyprarch/` |
| `config/systemd/user/*.service` | `~/.config/systemd/user/` |
| `config/systemd/user/at-spi-dbus-bus.service.d/` | `~/.config/systemd/user/at-spi-dbus-bus.service.d/` |
| `config/greetd/config.toml` | `/etc/greetd/config.toml` |
| `config/greetd/hyprarch-tuigreet` | `/usr/local/bin/hyprarch-tuigreet` |
| `scripts/hyprarch-*` | `~/.local/bin/` |

Do not symlink the guest to a Mac workspace.

## After install, match CURRENT.md

The kickstart should already include the desktop in [CURRENT.md](CURRENT.md). If something is missing, restore it from `config/` and `scripts/` rather than rewriting the shell.

Known follow-through that is **not** in the installer:

- Parallels Tools (user + [tracks/parallels.md](tracks/parallels.md))
- Growing a tiny installer root (one-off; ask)
- VS Code (later, user-requested)
- VirtualBox Windows VM ([tracks/virtualbox-windows.md](tracks/virtualbox-windows.md) — untested)
- Extra compositors: niri and/or mango beside Hyprland ([OPTIONAL-SESSIONS.md](OPTIONAL-SESSIONS.md) — hints only, no configs in this repo)

## Optional niri / mango

Only if the user asks, and only after Hyprland works. Read [OPTIONAL-SESSIONS.md](OPTIONAL-SESSIONS.md) first. Do not add those packages or session files during the kickstart install. Do not treat every non-Hyprland session as niri.

## Hard rules

- No GDM, no `gnome` group, no Omarchy/DMS install.
- No Nautilus. Files = Thunar.
- No grim unless the user asks; image viewer is nsxiv behind `hyprarch-imv`.
- Do not add `qmldir` that lists only `Theme` — Quickshell then fails to load other types.
- Theme apply goes through `hyprarch-apply-theme` (borders, icons, Mousepad scheme, Thunar sidebar CSS).
- Ask before unofficial repos and `-git` packages.

## Traps already paid for

- GDM “Hyprland” starts the compositor **without UWSM** → empty session, no bar.
- Nautilus pulls Tracker and starts slowly.
- Parallels preferred mode is often 1024×768. `--track parallels` forces 3024×1898@60 scale 2.
- `imv` draws black on the development Parallels GPU.
- kmscon or getty on VT1 steals the greeter. greetd must Conflict with `getty@tty1`.
- libadwaita user CSS is flaky; that is why Files is Thunar (GTK3).

## How to work

Inspect, then change. Small reversible steps. Keep SSH while swapping login. Record AUR and unofficial repos if any appear. No secrets in git.

When the user wants a feature, install the **capability**, not a desktop group.
