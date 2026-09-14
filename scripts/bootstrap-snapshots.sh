#!/usr/bin/env bash
# Regenerate Aether's committed custom palette snapshots.
# Ordinary themes load lockfile-pinned plugins directly and need no generated
# highlight data. Requires the capture plugins installed (:Lazy install).
#
#   scripts/bootstrap-snapshots.sh
#
# Each capture source declares its complete bootstrap variant set and resolves
# the correct background when no explicit polarity is supplied.
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"

for src in "$here"/scripts/theme-sources/*.lua; do
  [[ -e "$src" ]] || continue
  scheme="$(basename "$src" .lua)"
  variants="$(nvim --headless \
    -c "lua local s = dofile([[$src]]); io.write(table.concat(s.bootstrap_variants or {}, ' '))" \
    -c 'qa' 2>/dev/null)"
  [[ -n $variants ]] || { echo "missing bootstrap_variants in $src" >&2; exit 1; }

  echo ">> ${scheme}: ${variants}"
  SNAPSHOT_SCHEME="$scheme" SNAPSHOT_VARIANTS="$variants" \
    nvim --headless -c "luafile $here/scripts/snapshot_theme.lua" -c 'qa'
done

echo "bootstrap complete."
