#!/usr/bin/env bash
# Update the HiGHS submodule to a HiGHS release, bump the crate version and
# open a pull request.
#
# Usage: scripts/update-highs.sh [TAG]    (default: latest HiGHS release)
# Needs: git, gh (logged in with push access to rust-or/highs-sys)
set -euo pipefail
cd "$(dirname "$0")/.."

[ -z "$(git status --porcelain)" ] || { echo "error: working tree is not clean" >&2; exit 1; }

tag=${1:-$(gh release view --repo ERGO-Code/HiGHS --json tagName --jq .tagName)}
version=${tag#v}
crate=$(sed -n 's/^version = "\(.*\)"/\1/p' Cargo.toml | head -n1)
if [ "$(printf '%s\n' "$crate" "$version" | sort -V | tail -n1)" = "$crate" ]; then
  echo "highs-sys $crate is up to date with HiGHS $tag"
  exit 0
fi

git fetch origin master
git switch -c "update-highs/$tag" origin/master
git submodule update --init
git -C HiGHS fetch --depth=1 origin tag "$tag"
git -C HiGHS checkout "$tag"
sed -i.bak "0,/^version = \".*\"/s//version = \"$version\"/" Cargo.toml && rm Cargo.toml.bak
git add HiGHS Cargo.toml
scripts/check-highs-version.sh

git commit -m "Update HiGHS to $tag"
git push -u origin "update-highs/$tag"
gh pr create --repo rust-or/highs-sys --base master \
  --title "Update HiGHS to $tag" \
  --body "Updates the HiGHS submodule and crate version to [$tag](https://github.com/ERGO-Code/HiGHS/releases/tag/$tag)."
