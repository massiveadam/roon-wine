# Publishing `roon-proton` to the AUR

The AUR package name `roon-proton` was available when checked on 2026-07-13.
The AUR accepts package metadata through its SSH Git service, not through the
website upload form.

## One-time account setup

1. Create an AUR account and add the public SSH key from `~/.ssh/id_ed25519.pub`.
2. Verify authentication:

   ```sh
   ssh aur@aur.archlinux.org help
   ```

## First publication

Use a separate AUR checkout so the GitHub project history and AUR package
history stay clean:

```sh
git -c init.defaultbranch=master clone \
  ssh://aur@aur.archlinux.org/roon-proton.git ~/aur/roon-proton
cd ~/aur/roon-proton
cp ~/roon-wine/{PKGBUILD,.SRCINFO,roon-proton.install,roon-wine,roon-wine.desktop,roon-umu-run,roon-system-output.service,90-roon-loopback.conf,roon-proton.modules-load.conf,roon-proton.modprobe.conf,LICENSE} .
cp ~/roon-wine/roon-proton.{niri.kdl,hyprland.conf,hyprland.lua} .
git add PKGBUILD .SRCINFO roon-proton.install roon-wine roon-wine.desktop roon-umu-run roon-system-output.service \
  90-roon-loopback.conf roon-proton.modules-load.conf roon-proton.modprobe.conf \
  roon-proton.* LICENSE
git commit -m 'Initial import: roon-proton 0.2.0-4'
git push origin master
```

The initial push must include both `PKGBUILD` and `.SRCINFO`. Do not include
built packages, downloaded Roon/Proton archives, prefixes, caches, or user data.

## Updating

After changing package metadata, increment `pkgver` or `pkgrel`, regenerate
`.SRCINFO` on Arch, copy the five package files to the AUR checkout, commit, and
push:

```sh
makepkg --printsrcinfo > .SRCINFO
```

The GitHub repository remains the upstream project and issue tracker. The AUR
repository contains only the packaging recipe and its small local source files.
