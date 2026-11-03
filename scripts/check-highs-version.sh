#!/usr/bin/env bash
# Check that the HiGHS submodule is at its committed version and that the
# crate version matches it: same MAJOR.MINOR, crate PATCH >= HiGHS PATCH.
# A stale submodule is how highs-sys 1.14.2 shipped HiGHS 1.13.1 (#51).
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { echo "error: $*" >&2; exit 1; }

case "$(git submodule status HiGHS)" in
  " "*) ;;
  *) fail "HiGHS submodule is not at the committed version; run 'git submodule update --init'" ;;
esac

v() { sed -n "s/^HIGHS_$1=//p" HiGHS/Version.txt; }
highs="$(v MAJOR).$(v MINOR).$(v PATCH)"
crate=$(sed -n 's/^version = "\(.*\)"/\1/p' Cargo.toml | head -n1)
echo "crate $crate, HiGHS $highs"

[ "${crate%.*}" = "${highs%.*}" ] || fail "crate and HiGHS MAJOR.MINOR differ"
[ "${crate##*.}" -ge "${highs##*.}" ] || fail "crate version is older than HiGHS; bump 'version' in Cargo.toml"
