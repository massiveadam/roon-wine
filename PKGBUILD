# Maintainer: roon-wine contributors
pkgname=roon-wine
pkgver=0.1.0
pkgrel=2
pkgdesc='Run the Roon desktop controller and audio output on Arch Linux using Wine'
arch=('x86_64')
url='https://github.com/massiveadam/roon-wine'
license=('MIT')
depends=('bash' 'curl' 'wine' 'winetricks')
optdepends=(
  'pipewire-pulse: recommended audio backend for PipeWire desktops'
  'pulseaudio: PulseAudio backend'
  'xorg-xwayland: XWayland display fallback'
  'vulkan-icd-loader: accelerated rendering'
)
source=('roon-wine' 'roon-wine.desktop' 'LICENSE')
sha256sums=(
  '6cc40eaf45e2bd7b64df8de3e5c43c4c7213ae27b7d0cba04dd297ab8d0d6e81'
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
