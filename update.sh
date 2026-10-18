#!/usr/bin/env bash
# Bump pkgver and checksums to the latest GitHub release.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

api=https://api.github.com/repos/YuanDevTeam/OneXray/releases/latest
json=$(curl -fsSL "$api")

read -r ver x86 aarch64 < <(python3 - "$json" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assets = {a["name"]: a["digest"] for a in d["assets"]}
ver = d["tag_name"].lstrip("v")
x86 = assets["OneXray-linux-x86_64.deb"].removeprefix("sha256:")
arm = assets["OneXray-linux-aarch64.deb"].removeprefix("sha256:")
print(ver, x86, arm)
PY
)

echo "latest upstream release: v$ver ($x86 / $aarch64)"

sed -i -E "s/^pkgver=.*/pkgver=$ver/; s/^pkgrel=.*/pkgrel=1/" PKGBUILD
sed -i -E "s|^sha256sums_x86_64=\('.*'|sha256sums_x86_64=('$x86'|" PKGBUILD
sed -i -E "s|^sha256sums_aarch64=\('.*'|sha256sums_aarch64=('$aarch64'|" PKGBUILD

makepkg --printsrcinfo > .SRCINFO
echo "PKGBUILD and .SRCINFO updated; run ./install.sh to build and install"
