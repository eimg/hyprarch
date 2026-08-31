# Parallels extras

Applied only by `scripts/install-desktop.sh --track parallels`.

| File | Role |
|---|---|
| `hyprarch-fix-monitor` | If the session maps at 1024×768, push 3024×1898@60 scale 2 |
| `hyprarch-fix-monitor.service` | Hyprland-gated oneshot after the graphical session |
| `console-font.conf` | greetd `ExecStartPre` setfont on VT1 |
| `vconsole.conf` | optional boot font; not installed automatically |
| `ptiagent.desktop` | Parallels Tools tray if Tools are present |
| `install-parallels-tools.sh` | run from the guest with the Tools ISO mounted |
| `hyprarch-prlcc.service` | optional Tools helper; enable only if it exists on disk |
