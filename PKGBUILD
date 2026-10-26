# Maintainer: Arkady Chelyadnikov <prbrq at ya dot ru>

pkgname=onexray-bin
pkgver=26.10.5
pkgrel=1
pkgdesc='Cross-platform Xray-core client with TUN mode, smart routing and JSON configuration import'
arch=('x86_64' 'aarch64')
url='https://onexray.com/'
license=('GPL-3.0-only')
# gtk3 pulls the whole GTK/Flutter runtime closure (glib2, pango, cairo, libx11,
# wayland, icu, libxml2, sqlite, json-glib, libseccomp, ...).
depends=('gtk3' 'procps-ng' 'libcap')
optdepends=('gnome-shell-extension-appindicator: tray icons in GNOME')
provides=('onexray')
conflicts=('onexray')
options=('!strip' '!debug') # Dart AOT snapshot and Core must stay untouched

_gh="https://github.com/YuanDevTeam/OneXray/releases/download/v${pkgver}"

# The upstream package names (x86_64 / aarch64) match Arch's $CARCH.
source_x86_64=("${_gh}/OneXray-linux-x86_64.deb" "onexray-caps.hook")
source_aarch64=("${_gh}/OneXray-linux-aarch64.deb" "onexray-caps.hook")
sha256sums_x86_64=('ab51b16d8af741c8048cd7d825750d2bd8427d6253432acfcddef686fe9073cb'
                   '7904b4dca61048f21336f604ffa834e2eba0160fde8868cef9bbc3207616a5b9')
sha256sums_aarch64=('5698e3deb6080b09c6b79b41f8cb13e3b5d1bd915bc85644d74104a4e3936f11'
                    '7904b4dca61048f21336f604ffa834e2eba0160fde8868cef9bbc3207616a5b9')

package() {
  # The DEB carries the complete /opt layout, the .desktop file and the icons.
  bsdtar -xf "${srcdir}/OneXray-linux-${CARCH}.deb" -C "${srcdir}" data.tar.zst
  bsdtar -xf "${srcdir}/data.tar.zst" -C "${pkgdir}"

  # Upstream creates this symlink in its Debian postinst; use the Arch-style
  # command name and point the desktop entry at it.
  install -dm755 "${pkgdir}/usr/bin"
  ln -s /opt/OneXray/OneXray "${pkgdir}/usr/bin/onexray"
  sed -i 's|^Exec=OneXray|Exec=onexray|' \
    "${pkgdir}/usr/share/applications/OneXray.desktop"

  # setcap cannot run under fakeroot, and capabilities are lost every time
  # pacman replaces OneXrayCore. Restore them after the transaction instead.
  install -Dm644 "${srcdir}/onexray-caps.hook" \
    "${pkgdir}/usr/share/libalpm/hooks/90-onexray-caps.hook"
}
