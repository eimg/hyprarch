# HyprArch

<!-- Agent: this repo is the public kickstart, not the live guest. In Desktop workspace/, live config is ../arch-hypr-config/. -->

![HyprArch desktop](docs/images/hyprarch-screenshot.jpg)

A lean Arch Linux desktop: **Hyprland** (Lua) + original **Quickshell** widgets + conventional plumbing (systemd, pacman, NetworkManager, PipeWire, greetd, UWSM).

This repository is a **kickstart**, not a locked ISO. You install Arch. Then either you or an agent copies this tree and runs the installer. Versions float with Arch `extra`.

```text
You do first:     machine + Arch + user + network + SSH
This repo does:   desktop packages, session, recoverable config
An agent can:     continue from docs/AGENT.md after you hand off
```

Omarchy and DankMaterialShell are references only. Do not run their installers.

## Two tracks

| Track | Who it is for | Status |
|---|---|---|
| [Full install](docs/tracks/metal.md) | Bare metal or a generic Linux VM | Expressed from the working desktop; monitor uses `preferred` |
| [Parallels VM](docs/tracks/parallels.md) | Apple Silicon Mac + Parallels | **This is the path that was actually built** |
| [VirtualBox + Windows](docs/tracks/virtualbox-windows.md) | A Windows guest beside HyprArch | **Not tested.** Written so you can try it without pretending we did. |

Start with **[docs/USER.md](docs/USER.md)**. Agents start with **[AGENTS.md](AGENTS.md)**.

## What you get

- greetd + tuigreet on VT1, Hyprland via UWSM
- Quickshell bar: workspaces, launcher, calendar, settings, power menu
- Thunar, Mousepad, Neovim, Foot, Chromium, nsxiv (via an imv-named wrapper)
- Papirus folders remapped to the color palette (Hyprarch icon overlay)
- Adwaita-dark, Inter, JetBrains Mono

## Quick start (after Arch exists)

```bash
git clone https://github.com/eimg/hyprarch.git
cd hyprarch
# metal:
bash scripts/install-desktop.sh --track metal
# Parallels on Apple Silicon:
bash scripts/install-desktop.sh --track parallels
```

Use a visible terminal for `sudo`. Then reboot and log in at the HyprArch greeter. Recovery: Ctrl+Alt+F2.

## Layout

```text
docs/USER.md              first steps (human)
docs/AGENT.md             full handover (agent)
docs/STACK.md             locked choices and bans
docs/CURRENT.md           desktop as it exists today
docs/OPTIONAL-SESSIONS.md niri / mango beside Hyprland (hints only)
docs/tracks/              metal / parallels / virtualbox-windows
config/                   files that land in $HOME and /etc
scripts/                  installer and user helpers
extras/parallels/         Retina monitor, Tools, greeter font
```

## License

MIT. See [LICENSE](LICENSE).
