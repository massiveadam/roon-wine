# Maintainer: roon-wine contributors
pkgname=roon-proton
pkgver=0.2.0
pkgrel=2
pkgdesc='Roon desktop controller and native audio endpoint for Arch Linux'
arch=('x86_64')
url='https://github.com/massiveadam/roon-wine'
license=('MIT')
depends=('alsa-lib' 'bash' 'curl' 'umu-launcher' 'xorg-xwayland')
provides=('roon-wine')
conflicts=('roon-wine')
replaces=('roon-wine')
optdepends=(
  'wine: system Wine fallback runner'
  'winetricks: runtime setup for the system Wine fallback'
  'pipewire-pulse: recommended audio backend for PipeWire desktops'
  'pulseaudio: PulseAudio backend'
  'vulkan-icd-loader: accelerated rendering'
)
source=(
  'roon-wine'
  'roon-wine.desktop'
  'roon-proton.niri.kdl'
  'roon-proton.hyprland.conf'
  'roon-proton.hyprland.lua'
  'LICENSE'
)
sha256sums=(
  '790a59d4455fd824b55f563fe99e14db28583c7c6e0aa54d5af5a70b883a9ab3'
  '300b9418ac741675a91fda59670456738f4d6d5693a4cc7899138b94425acd26'
  'aab5a24dff98029cbb17a40c27af62b14a114c58d1e398b02a02b4404b8af528'
  'fa0808ac99a1ecb1180c672cd634fd561e4c377029ca7cff0920bddc71e42778'
  'ffb8bd1b1c39ba5274f20b2ef564c50b68ae2c41ea501d96d2f407f9d89ea085'
  'bcecb636801e3d141e250e5d457229661aaf57138f03899c172ce2446dcd22ad'
)

package() {
  install -Dm755 "$srcdir/roon-wine" "$pkgdir/usr/bin/roon-proton"
  ln -s roon-proton "$pkgdir/usr/bin/roon-wine"
  install -Dm644 "$srcdir/roon-wine.desktop" \
    "$pkgdir/usr/share/applications/roon-proton.desktop"
  sed -i 's/^Exec=roon-wine/Exec=roon-proton/' \
    "$pkgdir/usr/share/applications/roon-proton.desktop"
  install -Dm644 "$srcdir/roon-proton.niri.kdl" \
    "$pkgdir/usr/share/roon-proton/wm/roon-proton.niri.kdl"
  install -Dm644 "$srcdir/roon-proton.hyprland.conf" \
    "$pkgdir/usr/share/roon-proton/wm/roon-proton.hyprland.conf"
  install -Dm644 "$srcdir/roon-proton.hyprland.lua" \
    "$pkgdir/usr/share/roon-proton/wm/roon-proton.hyprland.lua"
  install -Dm644 "$srcdir/LICENSE" \
    "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
