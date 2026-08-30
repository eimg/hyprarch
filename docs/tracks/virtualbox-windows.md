# Track: VirtualBox + Windows VM

**Not tested.** Written so a future attempt is honest, not so you can treat it as a known-good path.

HyprArch is an Arch + Hyprland desktop. Windows is a **sibling machine** for apps that still need Windows. This repo does not install VirtualBox or Windows, and it does not nest a hypervisor for you.

## Two different ideas (do not mix them)

### A. Windows host, Arch guest in VirtualBox

You want HyprArch inside VirtualBox on a PC.

- Use an **x86_64** Arch ISO. Apple Silicon cannot run that guest natively in VirtualBox the way a PC can.
- 3D / Wayland on VirtualBox has a long history of being worse than KVM or Parallels. Hyprland may fail, flicker, or stay at a tiny mode.
- Enable EFI, give it enough RAM, and install Guest Additions only after a TTY works.
- Then run `--track metal` if Hyprland actually starts.
- We have **not** done this. If it fails, that is expected, not a HyprArch bug.

### B. You already have HyprArch, plus a Windows VM

You want Word/Excel/a Windows-only app next to the Linux desktop.

**On a Mac (Apple Silicon), prefer Parallels Windows**, not VirtualBox. Current VirtualBox on ARM does not give you typical x86_64 Windows. ARM64 Windows is a different product.

**On an Intel/AMD PC running HyprArch (`--track metal`):**

1. Install VirtualBox from extra (`virtualbox` + host modules) only after you accept out-of-tree kernel modules.
2. Create a **separate** Windows VM. Do not put Windows on the HyprArch disk.
3. Give the Windows VM its own CPU/RAM. Nested virtualization (HyprArch itself inside Parallels, then VirtualBox inside that) is a bad idea and untested.
4. Shared folders, clipboard, and seamless mode are VirtualBox features. They are unrelated to this repo’s Thunar/Mousepad setup.

We have **not** run VirtualBox on the HyprArch guest.

## What an agent must not do

- Do not install VirtualBox as part of `install-desktop.sh`.
- Do not tell the user this pairing is verified.
- Do not nest VirtualBox inside the Parallels Arch guest unless the user explicitly wants that experiment.
- Do not download Windows ISOs or product keys.

If the user asks to try it, treat it as a new experiment: snapshot first, keep SSH, write down what actually works.
