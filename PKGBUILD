# Maintainer: roon-wine contributors
pkgname=roon-wine
pkgver=0.1.0
pkgrel=1
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
  'f985dc7f89cb5b56f2f5af7d3631e631e9e6484f9ec00664490fce48637a02a5'
  'd7c6ba558d3b49dbd5cf59ae60a5367e8c8d38439460dd9e49ca9a5f0da99529'
  'bcecb636801e3d141e250e5d457229661aaf57138f03899c172ce2446dcd22ad'
)

package() {
  install -Dm755 "$srcdir/roon-wine" "$pkgdir/usr/bin/roon-wine"
  install -Dm644 "$srcdir/roon-wine.desktop" \
    "$pkgdir/usr/share/applications/roon-wine.desktop"
  install -Dm644 "$srcdir/LICENSE" \
    "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
