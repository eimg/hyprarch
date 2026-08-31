# Agent entry

This repo is the HyprArch kickstart: Arch + Hyprland (Lua) + Quickshell + greetd/UWSM.

1. Read [docs/STACK.md](docs/STACK.md) (locked stack, bans).
2. Read [docs/AGENT.md](docs/AGENT.md) (handover, install, traps).
3. Read [docs/CURRENT.md](docs/CURRENT.md) (what the desktop already is).
4. Confirm the track with the user: `metal` or `parallels`.
5. Verify the machine, then run `scripts/install-desktop.sh --track …` if the desktop is not installed yet.

Do not invent a different compositor, greeter, or file manager. Do not install Omarchy, DMS, GNOME, or GDM.

If the user later wants **niri** or **mango** beside Hyprland, read [docs/OPTIONAL-SESSIONS.md](docs/OPTIONAL-SESSIONS.md). This repo does not ship those configs. Hyprland stays daily.

VirtualBox + Windows is documented as **untested** in [docs/tracks/virtualbox-windows.md](docs/tracks/virtualbox-windows.md). Do not claim it works.
