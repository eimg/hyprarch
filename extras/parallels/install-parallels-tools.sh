#!/usr/bin/env bash
set -euo pipefail

# Install Parallels Tools from the already-attached prl-tools-lin-arm.iso.
# Copy off the ISO first: it is often mounted noexec/read-only.
# Do not -Syu here; a kernel bump would desync the running uname from headers.

LOG=/home/eimg/prl-tools-install.log
BUILD=/home/eimg/prl-tools-build
MNT=/mnt/cdrom

echo "=== $(date -Is) start ==="
echo "kernel=$(uname -r)"
echo "Enter the guest sudo password if asked."
sudo -v

exec > >(tee -a "$LOG") 2>&1

echo "=== $(date -Is) privileged ==="
pacman -Q linux-aarch64 linux-aarch64-headers dkms 2>/dev/null || true

sudo pacman -S --needed --noconfirm linux-aarch64-headers dkms net-tools libelf

echo "=== versions ==="
uname -r
pacman -Q linux-aarch64 linux-aarch64-headers || true

test -b /dev/sr0
sudo mkdir -p "$MNT"
if ! findmnt "$MNT" >/dev/null 2>&1; then
  sudo mount -o ro,exec /dev/sr0 "$MNT" || sudo mount /dev/sr0 "$MNT"
fi
echo "=== ISO contents ==="
ls -la "$MNT"
test -x "$MNT/install" -o -f "$MNT/install"

rm -rf "$BUILD"
mkdir -p "$BUILD"
sudo cp -a "$MNT"/. "$BUILD"/
sudo chown -R eimg:eimg "$BUILD"
chmod +x "$BUILD/install" || true

cd "$BUILD"
echo "=== installer help ==="
sudo ./install --help 2>&1 || true

echo "=== install (unattended) ==="
set +e
sudo ./install --install-unattended
rc=$?
set -e
echo "unattended rc=$rc"

if [[ $rc -ne 0 ]]; then
  echo "=== install (default; answer yes if prompted) ==="
  sudo ./install
fi

echo "=== post-install ==="
pacman -Q linux-aarch64-headers dkms
ls -d /usr/lib/parallels-tools 2>/dev/null || true
systemctl list-unit-files 'prl*' --no-pager || true
ls /var/log/parallels-tools-install.log >/dev/null 2>&1 && \
  echo "--- vendor log tail ---" && sudo tail -n 40 /var/log/parallels-tools-install.log || true

if [[ ! -d /usr/lib/parallels-tools ]]; then
  echo "INSTALL_FAILED: /usr/lib/parallels-tools missing"
  echo "INSTALL_FAILED" >>"$LOG"
  exit 1
fi

echo "INSTALL_OK: rebooting so prltoolsd can start"
echo "INSTALL_OK" >>"$LOG"
sudo reboot
