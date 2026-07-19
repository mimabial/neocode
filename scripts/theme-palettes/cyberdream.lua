-- Curated hex -> name map for cyberdream (default dark + light). Names reference
-- the shared vocabulary (V.*, typo-checked). The scheme inverts between variants,
-- so the two near-mono extremes are named neutrally (black/white) and the same
-- role name is reused for each variant's hue (they never share a capture).
local V = require("theme-palettes._vocabulary")

return {
  -- Neutrals shared across variants (dark/light invert)
  ["#16181a"] = V.black,   -- dark bg / light fg
  ["#ffffff"] = V.white,   -- dark fg / light bg
  ["#7b8496"] = V.comment, -- grey (both)

  -- Surfaces
  ["#1e2124"] = V.bg_alt,  -- default bg_alt
  ["#3c4048"] = V.surface, -- default bg_highlight
  ["#eaeaea"] = V.bg_alt,  -- light bg_alt
  ["#acacac"] = V.surface, -- light bg_highlight

  -- Hues (default / dark)
  ["#5ea1ff"] = V.blue,
  ["#5eff6c"] = V.green,
  ["#5ef1ff"] = V.cyan,
  ["#ff6e5e"] = V.red,
  ["#f1ff5e"] = V.yellow,
  ["#ff5ef1"] = V.magenta,
  ["#ff5ea0"] = V.pink,
  ["#ffbd5e"] = V.orange,
  ["#bd5eff"] = V.purple,

  -- Hues (light)
  ["#0057d1"] = V.blue,
  ["#008b0c"] = V.green,
  ["#008c99"] = V.cyan,
  ["#d11500"] = V.red,
  ["#997b00"] = V.yellow,
  ["#d100bf"] = V.magenta,
  ["#f40064"] = V.pink,
  ["#d17c00"] = V.orange,
  ["#a018ff"] = V.purple,

  -- Semantic leakage (shared roles)
  ["#8cf8f7"] = V.aqua,
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
  ["#4f5258"] = V.shadow,
  ["#9b9ea4"] = V.gray_muted,
}
