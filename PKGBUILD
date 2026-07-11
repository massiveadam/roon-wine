# Maintainer: roon-wine contributors
pkgname=roon-wine
pkgver=0.1.0
pkgrel=3
pkgdesc='Run the Roon desktop controller and audio output on Arch Linux using Wine'
arch=('x86_64')
url='https://github.com/massiveadam/roon-wine'
license=('MIT')
depends=('bash' 'curl' 'umu-launcher')
optdepends=(
  'wine: system Wine fallback runner'
  'winetricks: runtime setup for the system Wine fallback'
  'pipewire-pulse: recommended audio backend for PipeWire desktops'
  'pulseaudio: PulseAudio backend'
  'xorg-xwayland: XWayland display fallback'
  'vulkan-icd-loader: accelerated rendering'
)
source=('roon-wine' 'roon-wine.desktop' 'LICENSE')
sha256sums=(
  '9658888396e95ec78b5d6c9509dc84efda175b567ea8e57590be797e84fda6fb'
  '300b9418ac741675a91fda59670456738f4d6d5693a4cc7899138b94425acd26'
  'bcecb636801e3d141e250e5d457229661aaf57138f03899c172ce2446dcd22ad'
)

package() {
  install -Dm755 "$srcdir/roon-wine" "$pkgdir/usr/bin/roon-wine"
  install -Dm644 "$srcdir/roon-wine.desktop" \
    "$pkgdir/usr/share/applications/roon-wine.desktop"
  install -Dm644 "$srcdir/LICENSE" \
    "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
