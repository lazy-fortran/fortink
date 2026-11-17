#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
if [ -n "${FORTSYM_PREFIX:-}" ]; then
    "${FC:-gfortran}" -I "$FORTSYM_PREFIX/include" "$root/gen/generate.f90" \
        -L "$FORTSYM_PREFIX/lib" -Wl,-rpath,"$FORTSYM_PREFIX/lib" \
        -lfortsym -lfortgen -o "$tmp/generate"
    "$tmp/generate" > "$tmp/kernel.f90"
else
    fpm run --directory "$root/gen" --quiet generate > "$tmp/kernel.f90"
fi
if [ "${1:-}" = --check ]; then
    cmp "$tmp/kernel.f90" "$root/src/generated/ink_filter_leaf.f90"
else
    cp "$tmp/kernel.f90" "$root/src/generated/ink_filter_leaf.f90"
fi
