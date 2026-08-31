# User first steps

Do this yourself. An agent should not download the ISO, create the VM, partition disks, or run the Arch installer unless you later ask.

“Reproducible” here means **a repeatable kickstart**, not bit-identical packages.

## 1. Pick a track

- **Full install** — real machine or any Linux VM: [tracks/metal.md](tracks/metal.md)
- **Parallels on a Mac** — the path this desktop was developed on: [tracks/parallels.md](tracks/parallels.md)
- **Windows in VirtualBox** — extra machine only, untested: [tracks/virtualbox-windows.md](tracks/virtualbox-windows.md)

## 2. Install Arch

Minimal Arch. No GNOME, KDE, EndeavourOS, or `gnome` group.

You need:

1. A user in `wheel` with working `sudo` (your password, not passwordless).
2. **NetworkManager** owning the NIC, DNS after reboot.
3. `openssh` / `sshd` if you want an agent over SSH. Key-only login is better.
4. One successful `pacman -Syu`.
5. `base-devel git sudo` installed.

Do **not** install `hyprland`, `greetd`, `quickshell`, `gdm`, or `gnome` yet.

ArchWiki: [Installation guide](https://wiki.archlinux.org/title/Installation_guide).

## 3. Snapshot

If this is a VM, take a snapshot after the upgrade and before desktop packages.

## 4. Clone this repo on the Arch machine

```bash
git clone https://github.com/eimg/hyprarch.git ~/hyprarch
```

Or copy the tree in. Live files will be ordinary copies under `$HOME` and `/etc`, not bind mounts.

## 5. Either install yourself or hand off

### Yourself

```bash
cd ~/hyprarch
bash scripts/install-desktop.sh --track metal      # or --track parallels
```

Sudo will ask for your password. Reboot when it prints `INSTALL_OK`. Log in at the HyprArch text greeter on VT1. If the graphical session fails: Ctrl+Alt+F2, SSH still works if you set it up.

### Hand off to an agent

Give the agent:

- This repo (or its URL)
- [AGENT.md](AGENT.md) and [STACK.md](STACK.md)
- Track: `metal` or `parallels`
- Hostname, username, SSH alias/IP if remote
- Whether NetworkManager is already the renderer
- Whether sudo needs a visible terminal (usually yes)
- For Parallels: Tools installed or not, guest IP

The agent starts by **verifying**, not by installing.

## 6. After first graphical login

- Super+Enter — terminal
- Super+Space — launcher
- Super+E — files
- Super+N — notepad
- Super+/ — keybinds
- Bar gear — wallpaper and color theme

VS Code is not part of this kickstart. Neovim is in the terminal; Mousepad is the GUI notepad.

## 7. Extra compositors (optional)

The installer is Hyprland only. If you later want **niri** or **mango** as another F3 login choice, say so to an agent and point them at [OPTIONAL-SESSIONS.md](OPTIONAL-SESSIONS.md). That file is a guide, not an installer. Hyprland stays the daily session.
