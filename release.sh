#!/usr/bin/env bash
# Tag the current commit so GitHub Actions builds and publishes a release.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

pkgver=$(sed -n 's/^pkgver=//p' PKGBUILD)
pkgrel=$(sed -n 's/^pkgrel=//p' PKGBUILD)
tag="v${pkgver}-${pkgrel}"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: working tree has uncommitted changes" >&2
  exit 1
fi

if ! makepkg --printsrcinfo | diff -q .SRCINFO - >/dev/null; then
  echo "error: .SRCINFO is out of date (run: makepkg --printsrcinfo > .SRCINFO)" >&2
  exit 1
fi

if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
  echo "error: tag ${tag} already exists" >&2
  exit 1
fi

git tag -a "$tag" -m "onexray-bin ${pkgver}-${pkgrel}"
git push origin master
git push origin "$tag"

echo "pushed ${tag}: GitHub Actions will build and publish the release"
