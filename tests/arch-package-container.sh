#!/usr/bin/env bash
set -Eeuo pipefail

command -v docker >/dev/null 2>&1 || {
  echo 'docker is required for the Arch packaging test' >&2
  exit 1
}

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
nvme_socket=${ROON_ARCH_DOCKER_SOCKET:-/Volumes/NVMe/Roon Arch Linux Test/colima/roon-arch/docker.sock}
if [[ -S $nvme_socket ]]; then
  export DOCKER_HOST="unix://$nvme_socket"
fi

COPYFILE_DISABLE=1 tar -C "$root" --exclude=.git --exclude='*.pkg.tar.*' -cf - . | \
docker run --rm --interactive --platform linux/amd64 \
  --security-opt seccomp=unconfined \
  -v roon-arch-pacman-cache:/var/cache/pacman/pkg \
  archlinux:latest bash -Eeuo pipefail -c '
    sed -i "/^\[options\]/a DisableSandbox" /etc/pacman.conf
    pacman-key --init
    pacman-key --populate archlinux
    pacman -Sy --noconfirm --needed base-devel namcap
    useradd --create-home builder
    install -d -o builder -g builder /build
    tar -C /build -xf -
    chown -R builder:builder /build
    su builder -c "cd /build && bash -n roon-wine"
    su builder -c "cd /build && makepkg --nodeps --clean --cleanbuild --noconfirm"
    cd /build
    namcap PKGBUILD
    namcap roon-wine-*.pkg.tar.zst
    pacman -Qlp roon-wine-*.pkg.tar.zst
  '
