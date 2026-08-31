#!/usr/bin/env bash
set -euo pipefail

# HyprArch desktop bring-up. Run as the desktop user, with a visible sudo
# prompt. Do not install gnome, gdm, or hyprland-git.

REPO=$(cd "$(dirname "$0")/.." && pwd)
CFG=$REPO/config
SCRIPTS=$REPO/scripts
TRACK=metal
REBOOT=0

usage() {
    cat <<EOF
usage: install-desktop.sh [--track metal|parallels] [--reboot]

metal      portable full install / generic VM (default)
parallels  Apple Silicon Parallels extras (Retina monitor, Tools hooks)
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --track)
            TRACK=${2:?}
            shift 2
            ;;
        --reboot)
            REBOOT=1
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            echo "unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

case $TRACK in
    metal | parallels) ;;
    *)
        echo "track must be metal or parallels" >&2
        exit 2
        ;;
esac

LOG=$HOME/hyprarch-desktop-install.log
USER_NAME=$(id -un)

echo "=== $(date -Is) start track=$TRACK user=$USER_NAME ==="
echo "Enter the sudo password if asked."
sudo -v

exec > >(tee -a "$LOG") 2>&1
echo "=== $(date -Is) privileged ==="
echo "repo=$REPO"
uname -m
uname -r
df -h /

sudo pacman -Syu --noconfirm

CANDIDATES=(
    base-devel git
    hyprland uwsm hyprland-guiutils
    xorg-xwayland mesa
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    hyprpolkitagent polkit
    pipewire pipewire-pulse pipewire-alsa wireplumber
    foot
    quickshell
    greetd greetd-tuigreet
    terminus-font
    upower udisks2 gvfs
    gnome-keyring
    wl-clipboard cliphist
    qt6-wayland qt6-gtk-platformtheme
    xdg-utils shared-mime-info xdg-user-dirs xdg-user-dirs-gtk
    inter-font ttf-jetbrains-mono ttf-nerd-fonts-symbols noto-fonts ttf-liberation
    papirus-icon-theme adwaita-icon-theme
    imv
    nsxiv
    thunar tumbler thunar-volman
    mousepad neovim
    chromium
    swaybg
    dconf
)

install=()
for pkg in "${CANDIDATES[@]}"; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then
        install+=("$pkg")
    else
        echo "SKIP missing package: $pkg"
    fi
done

echo "=== installing: ${install[*]} ==="
sudo pacman -S --needed --noconfirm "${install[@]}"

if pacman -Q gdm gnome-shell gnome-session 2>/dev/null | grep -q .; then
    echo "ERROR: GNOME session packages appeared; removing them."
    sudo pacman -Rns --noconfirm gdm gnome-shell gnome-session || true
fi

sudo usermod -aG video,render,audio,input,storage "$USER_NAME" || true

install -d \
    "$HOME/.config/hypr" \
    "$HOME/.config/uwsm" \
    "$HOME/.config/quickshell/hyprarch" \
    "$HOME/.config/systemd/user" \
    "$HOME/.config/systemd/user/at-spi-dbus-bus.service.d" \
    "$HOME/.config/foot" \
    "$HOME/.config/gtk-3.0" \
    "$HOME/.config/gtk-4.0" \
    "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml" \
    "$HOME/.config/environment.d" \
    "$HOME/.config/nsxiv" \
    "$HOME/.config/hyprarch" \
    "$HOME/.config/autostart" \
    "$HOME/.local/bin" \
    "$HOME/.local/share/applications" \
    "$HOME/.local/share/backgrounds/hyprarch" \
    "$HOME/.local/share/gtksourceview-4/styles"

install -m 644 "$CFG/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
rm -f "$HOME/.config/hypr/hyprland.conf"
if [[ $TRACK == parallels ]]; then
    python3 - <<'PY'
from pathlib import Path
p = Path.home() / ".config/hypr/hyprland.lua"
t = p.read_text()
old = '''hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})'''
new = '''hl.monitor({
    output = "",
    mode = "3024x1898@60",
    position = "auto",
    scale = 2,
})'''
if old not in t:
    raise SystemExit("portable monitor block not found; not rewriting")
p.write_text(t.replace(old, new, 1))
print("PARALLELS_MONITOR: 3024x1898@60 scale 2")
PY
fi

install -m 644 "$CFG/uwsm/env" "$HOME/.config/uwsm/env"
install -m 644 "$CFG/quickshell/hyprarch/"*.qml "$HOME/.config/quickshell/hyprarch/"
install -m 644 "$CFG/systemd/user/hyprarch-shell.service" "$HOME/.config/systemd/user/"
install -m 644 "$CFG/systemd/user/hyprarch-wallpaper.service" "$HOME/.config/systemd/user/"
install -m 644 "$CFG/systemd/user/cliphist-text.service" "$HOME/.config/systemd/user/"
install -m 644 "$CFG/systemd/user/cliphist-image.service" "$HOME/.config/systemd/user/"
install -m 644 "$CFG/systemd/user/at-spi-dbus-bus.service.d/session-cleanup.conf" \
    "$HOME/.config/systemd/user/at-spi-dbus-bus.service.d/"
install -m 644 "$CFG/foot/foot.ini" "$HOME/.config/foot/foot.ini"
install -m 644 "$CFG/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
install -m 644 "$CFG/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
install -m 644 "$CFG/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
install -m 644 "$CFG/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
install -m 644 "$CFG/xfce4/xfconf/xfce-perchannel-xml/thunar.xml" \
    "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
install -m 644 "$CFG/environment.d/90-hyprarch.conf" "$HOME/.config/environment.d/"
install -m 644 "$CFG/mimeapps.list" "$HOME/.config/mimeapps.list"
install -m 644 "$CFG/nsxiv/Xresources" "$HOME/.config/nsxiv/Xresources"
install -m 644 "$CFG/gtksourceview-4/styles/hyprarch.xml" \
    "$HOME/.local/share/gtksourceview-4/styles/hyprarch.xml"
install -m 644 "$CFG/applications/"*.desktop "$HOME/.local/share/applications/"

install -m 755 "$SCRIPTS/hyprarch-set-wallpaper" "$HOME/.local/bin/"
install -m 755 "$SCRIPTS/hyprarch-imv" "$HOME/.local/bin/"
install -m 755 "$SCRIPTS/hyprarch-icon-theme" "$HOME/.local/bin/"
install -m 755 "$SCRIPTS/hyprarch-apply-theme" "$HOME/.local/bin/"
if [[ -x $SCRIPTS/chromium ]]; then
    install -m 755 "$SCRIPTS/chromium" "$HOME/.local/bin/chromium"
fi
sed -i "s|^Exec=hyprarch-imv|Exec=$HOME/.local/bin/hyprarch-imv|" \
    "$HOME/.local/share/applications/imv.desktop"

if [[ -x $SCRIPTS/make-packed-wallpapers.sh ]]; then
    bash "$SCRIPTS/make-packed-wallpapers.sh" "$HOME/.local/share/backgrounds/hyprarch" || true
fi
if [[ -f $HOME/.local/share/backgrounds/hyprarch/hyper-teal-waves.jpg ]]; then
    ln -sfn "$HOME/.local/share/backgrounds/hyprarch/hyper-teal-waves.jpg" \
        "$HOME/.local/share/backgrounds/hyprarch/current"
    printf '%s\n' "$HOME/.local/share/backgrounds/hyprarch/hyper-teal-waves.jpg" \
        >"$HOME/.config/hyprarch/wallpaper"
fi

bash "$HOME/.local/bin/hyprarch-icon-theme" || true

if command -v xfconf-query >/dev/null; then
    xfconf-query -c thunar -p /misc-use-csd -n -t bool -s true || true
    xfconf-query -c thunar -p /last-menubar-visible -n -t bool -s false || true
    xfconf-query -c thunar -p /last-statusbar-visible -n -t bool -s false || true
    xfconf-query -c thunar -p /shortcuts-icon-size -n -t string -s THUNAR_ICON_SIZE_24 || true
fi

if command -v mousepad >/dev/null && gsettings list-schemas 2>/dev/null | grep -qx org.xfce.mousepad.preferences.view; then
    gsettings set org.xfce.mousepad.preferences.window client-side-decorations true || true
    gsettings set org.xfce.mousepad.preferences.window toolbar-visible false || true
    gsettings set org.xfce.mousepad.preferences.window statusbar-visible false || true
    gsettings set org.xfce.mousepad.preferences.window menubar-visible false || true
    gsettings set org.xfce.mousepad.preferences.view color-scheme 'hyprarch' || true
    gsettings set org.xfce.mousepad.preferences.view use-default-monospace-font false || true
    gsettings set org.xfce.mousepad.preferences.view font-name 'JetBrains Mono 12' || true
    gsettings set org.xfce.mousepad.preferences.view show-line-numbers true || true
    gsettings set org.xfce.mousepad.preferences.view highlight-current-line true || true
    gsettings set org.xfce.mousepad.preferences.view word-wrap true || true
    gsettings set org.xfce.mousepad.preferences.view insert-spaces true || true
fi

if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.interface icon-theme 'Hyprarch' || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' || true
    gsettings set org.gnome.desktop.interface font-name 'Inter 11' || true
    gsettings set org.gnome.desktop.interface document-font-name 'Inter 11' || true
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11' || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' || true
    gsettings set org.gnome.desktop.interface cursor-size 24 || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
fi

systemctl --user import-environment GTK_THEME GTK_ICON_THEME ADW_DISABLE_PORTAL 2>/dev/null || true
dbus-update-activation-environment --systemd GTK_THEME GTK_ICON_THEME ADW_DISABLE_PORTAL 2>/dev/null || true

xdg-user-dirs-update || true
mkdir -p "$HOME/Desktop" "$HOME/Downloads" "$HOME/Documents" \
    "$HOME/Pictures" "$HOME/Music" "$HOME/Videos" \
    "$HOME/Templates" "$HOME/Public"
cat >"$HOME/.config/gtk-3.0/bookmarks" <<EOF
file://$HOME/Downloads Downloads
file://$HOME/Documents Documents
file://$HOME/Pictures Pictures
file://$HOME/Music Music
file://$HOME/Videos Videos
file://$HOME/Desktop Desktop
EOF

update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

if [[ -x /usr/bin/imv-wayland && ! -e /usr/bin/imv ]]; then
    ln -sfn /usr/bin/imv-wayland "$HOME/.local/bin/imv"
fi

if [[ $TRACK == parallels ]]; then
    EXTRA=$REPO/extras/parallels
    if [[ -f $EXTRA/ptiagent.desktop ]]; then
        install -m 644 "$EXTRA/ptiagent.desktop" "$HOME/.config/autostart/"
    fi
    if [[ -x $EXTRA/hyprarch-fix-monitor ]]; then
        install -m 755 "$EXTRA/hyprarch-fix-monitor" "$HOME/.local/bin/"
        install -m 644 "$EXTRA/hyprarch-fix-monitor.service" "$HOME/.config/systemd/user/"
        systemctl --user enable hyprarch-fix-monitor.service || true
    fi
    if [[ -f $EXTRA/console-font.conf ]]; then
        sudo install -o root -g root -m 644 "$EXTRA/console-font.conf" \
            /etc/systemd/system/greetd.service.d/console-font.conf
    fi
fi

systemctl --user daemon-reload || true
systemctl --user enable \
    hyprarch-shell.service hyprarch-wallpaper.service \
    cliphist-text.service cliphist-image.service || true
systemctl --user enable hyprpolkitagent.service 2>/dev/null || true
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true

sudo install -m 755 "$CFG/greetd/hyprarch-tuigreet" /usr/local/bin/hyprarch-tuigreet
sudo install -o root -g root -m 644 "$CFG/greetd/config.toml" /etc/greetd/config.toml
sudo install -d -o root -g root -m 755 /etc/systemd/system/greetd.service.d
sudo install -o root -g root -m 644 "$CFG/systemd/system/greetd.service.d/tty-conflict.conf" \
    /etc/systemd/system/greetd.service.d/tty-conflict.conf
sudo systemctl daemon-reload
sudo systemctl disable --now getty@tty1.service || true
sudo systemctl disable --now gdm.service gdm3.service sddm.service 2>/dev/null || true
sudo systemctl mask gdm.service 2>/dev/null || true
sudo systemctl unmask greetd.service || true
sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target

echo "=== versions ==="
hyprland --version 2>/dev/null || true
pacman -Q hyprland uwsm greetd greetd-tuigreet quickshell foot thunar mousepad neovim chromium 2>/dev/null || true
echo "=== gdm check ==="
pacman -Q gdm gnome-shell 2>&1 || true
echo "=== sessions ==="
ls /usr/share/wayland-sessions/ || true

echo "INSTALL_OK track=$TRACK"
if [[ $REBOOT -eq 1 ]]; then
    echo "Rebooting into greetd."
    sudo reboot
else
    echo "Reboot when you are ready. Login on VT1 (HyprArch tuigreet)."
    echo "Recovery TTY: Ctrl+Alt+F2."
fi
