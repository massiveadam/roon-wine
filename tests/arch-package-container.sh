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

COPYFILE_DISABLE=1 tar -C "$root" --exclude=.git --exclude='*.pkg.tar.*' \
  --exclude='*.src.tar.*' -cf - . | \
docker run --rm --interactive --platform linux/amd64 \
  --security-opt seccomp=unconfined \
  -v roon-arch-pacman-cache:/var/cache/pacman/pkg \
  archlinux:latest bash -Eeuo pipefail -c '
    sed -i "/^\[options\]/a DisableSandbox" /etc/pacman.conf
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
      printf "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf
    else
      sed -i "/^#\[multilib\]/{s/^#//;n;s/^#//}" /etc/pacman.conf
    fi
    pacman-key --init
    pacman-key --populate archlinux
    pacman -Syu --noconfirm --needed base-devel namcap shellcheck sudo lib32-vulkan-swrast ttf-dejavu
    useradd --create-home builder
    printf "builder ALL=(ALL) NOPASSWD: ALL\n" > /etc/sudoers.d/builder
    install -d -o builder -g builder /build
    tar -C /build -xf -
    chown -R builder:builder /build
    su builder -c "cd /build && make check"
    su builder -c "cd /build && makepkg --syncdeps --clean --cleanbuild --noconfirm"
    cd /build
    namcap PKGBUILD
    namcap roon-proton-*.pkg.tar.zst
    pacman -Qlp roon-proton-*.pkg.tar.zst
    pacman -U --noconfirm roon-proton-*.pkg.tar.zst
    roon-proton help >/dev/null
  '
