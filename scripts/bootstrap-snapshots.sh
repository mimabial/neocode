#!/usr/bin/env bash
# Regenerate the (gitignored) snapshot data files for every scheme that has a
# source applier. Run after a fresh clone, or after editing a palette map.
# Requires the source plugins installed (:Lazy install first if needed).
#
#   scripts/bootstrap-snapshots.sh
#
# Each scheme captures the variants its packs reference; if no pack references
# it, the scheme's first declared variant is used.
set -uo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
themes="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/themes"

for src in "$here"/scripts/theme-sources/*.lua; do
  [ -e "$src" ] || continue
  scheme="$(basename "$src" .lua)"

  # 1. Explicit bootstrap_variants in the source applier (authoritative).
  variants="$(nvim --headless \
    -c "lua local s = dofile([[$src]]); io.write(table.concat(s.bootstrap_variants or {}, ' '))" \
    -c 'qa' 2>/dev/null)"

  # 2. Else the variants packs currently reference.
  if [ -z "${variants// /}" ]; then
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      v="$(grep -oP '(?<=NVIM_VARIANT = ).*' "$f" 2>/dev/null)"
      [ -n "$v" ] && variants="${variants} ${v}"
    done < <(grep -lE "^\\\$NVIM_SCHEME[[:space:]]*=[[:space:]]*${scheme}([[:space:]]|\$)" \
      "$themes"/*/hypr.theme 2>/dev/null)
  fi

  # 3. Else the scheme's first declared variant.
  if [ -z "${variants// /}" ]; then
    variants="$(nvim --headless \
      -c "lua local s = dofile([[$src]]); io.write((s.all_variants or { 'dark' })[1])" \
      -c 'qa' 2>/dev/null | tr -dc 'a-z')"
  fi
  variants="$(echo "$variants" | xargs)" # trim whitespace

  echo ">> ${scheme}: ${variants:-dark}"
  SNAPSHOT_SCHEME="$scheme" SNAPSHOT_VARIANTS="${variants:-dark}" \
    nvim --headless -c "luafile $here/scripts/snapshot_theme.lua" -c 'qa'
done

echo "bootstrap complete."
