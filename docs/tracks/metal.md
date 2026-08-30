# Track: full install

Bare-metal Arch, or a generic KVM/QEMU/cloud VM. The desktop config is the same as the development machine; the **monitor** uses `preferred` at scale 1.

This track was **not** dogfooded on a physical PC. It is the portable expression of a desktop that *was* built in Parallels. Expect to adjust scale, GPU packages, and Wi-Fi.

## You do

1. Install minimal Arch ([Installation guide](https://wiki.archlinux.org/title/Installation_guide)).
2. User + `wheel` + `sudo`, NetworkManager, optional SSH.
3. `pacman -Syu`, then `base-devel git`.
4. Clone this repo on that machine.

On a laptop you will also want firmware (`linux-firmware`) and usually `iwd` or NM Wi-Fi. This repo does not pick a wireless stack for you.

## GPU

The installer asks for `mesa`. Add the extra driver your hardware needs (Intel/AMD/NVIDIA) yourself. Hyprland must run on the real DRM device, not a 1024×768 fallback.

## Installer

```bash
cd ~/hyprarch
bash scripts/install-desktop.sh --track metal
```

Reboot, log in at tuigreet. If the bar is huge or tiny, change `scale` in `~/.config/hypr/hyprland.lua` and `hyprctl reload`.

## Do not apply Parallels extras

Skip `--track parallels`. That forces a Retina mode and Tools hooks that do not belong on metal.
