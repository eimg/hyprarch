# Track: Parallels VM (Apple Silicon)

This is the **tested** path. Development guest: Arch Linux ARM (`aarch64`) in Parallels Desktop on a Mac, Hyprland 0.56, Quickshell 0.3.

## You do on the Mac

1. New VM, **Other Linux**, aarch64. Not an x86_64 ISO.
2. Enough RAM/CPU. Graphics = **More Space**. Startup view = **Full screen**.
3. Install Arch (Archboot aarch64 ISO is the usual media).
4. User + sudo, NetworkManager, SSH from the Mac.
5. Optional: attach `prl-tools-lin-arm.iso` from the Parallels.app bundle and install Tools. Shared folders (`prl_fs`) often **do not exist** on ARM. Clipboard is incomplete.
6. Snapshot after `pacman -Syu`, before desktop packages.

Do not install GNOME, GDM, Hyprland, or greetd yourself.

## Handoff facts

VM name, hostname, username, SSH alias, guest IP (`10.211.55.x` is typical), Tools yes/no, sudo needs a visible Terminal.

## Installer

On the guest:

```bash
cd ~/hyprarch
bash scripts/install-desktop.sh --track parallels
```

That also:

- Forces `3024x1898@60` scale 2 (virtio-gpu prefers 1024×768 at greetd)
- Enables `hyprarch-fix-monitor.service` if the session still comes up small
- Installs a larger tuigreet font drop-in

If your host panel is not 3024×1898, change the monitor block in `hyprland.lua` to your sharp fullscreen mode. `preferred` is the wrong choice on this GPU.

## After login

- Scale 2 is expected on Retina.
- Super+E is Thunar. Super+N is Mousepad.
- Image viewer is nsxiv (`imv` is black on this GPU).
- macOS owns host battery, brightness, and Wi-Fi. Do not add laptop daemons inside the VM without evidence.

## Recovery

Ctrl+Alt+F2. Keep SSH. greetd must own VT1 (`Conflicts=getty@tty1`).
