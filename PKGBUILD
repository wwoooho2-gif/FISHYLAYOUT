# Maintainer: Furina
pkgname=omarchy-fishylayout
pkgver=1.0.0
pkgrel=1
pkgdesc='FISHYLAYOUT dashboard plugin suite for Omarchy'
arch=('any')
url='https://github.com/wwoooho2-gif/FISHYLAYOUT'
license=('MIT')
depends=('jq')

package() {
  local dst="$pkgdir/usr/share/omarchy-fishylayout"
  install -dm755 "$dst/plugin"
  cp -a "$startdir"/manifest.json "$startdir"/*.qml "$startdir"/README.md \
    "$startdir"/features "$startdir"/presets "$dst/plugin/"
  find "$dst" -name '__pycache__' -type d -prune -exec rm -rf -- {} +

  install -Dm644 "$startdir/packaging/shell-layout.json" "$dst/shell-layout.json"
  install -Dm755 "$startdir/packaging/install-plugin.sh" "$dst/install-plugin.sh"
  install -Dm755 "$startdir/packaging/apply-layout.sh" "$dst/apply-layout.sh"
  install -Dm755 "$startdir/packaging/hook-plugin.sh" \
    "$pkgdir/etc/skel/.config/omarchy/hooks/post-boot.d/20-fishylayout-plugin"
  install -Dm755 "$startdir/packaging/hook-layout.sh" \
    "$pkgdir/etc/skel/.config/omarchy/hooks/post-boot.d/40-fish-layout"
}
