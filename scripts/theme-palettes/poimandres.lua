-- Curated hex -> name map for poimandres (dark). Names reference the shared
-- vocabulary (V.*, typo-checked): poimandres' teal/blue/pink/yellow accents on
-- a deep blue-charcoal surface ramp.
local V = require("theme-palettes._vocabulary")

return {
  -- Accents
  ["#5de4c7"] = V.teal,        -- primary (functions)
  ["#5fb3a1"] = V.teal_dark,
  ["#add7ff"] = V.blue,
  ["#91b4d5"] = V.blue_muted,
  ["#7390aa"] = V.blue_dim,
  ["#89ddff"] = V.sky_light,
  ["#8cf8f7"] = V.aqua,
  ["#d0679d"] = V.pink,
  ["#fcc5e9"] = V.pink_light,
  ["#fffac2"] = V.yellow,
  ["#42675a"] = V.green,       -- git renamed

  -- Neutrals / foregrounds
  ["#a6accd"] = V.fg,
  ["#e4f0fb"] = V.fg_alt,
  ["#ffffff"] = V.white,
  ["#767c9d"] = V.comment,
  ["#506477"] = V.gray,
  ["#9b9ea4"] = V.gray_muted,

  -- Surfaces
  ["#1b1e28"] = V.bg,
  ["#171922"] = V.bg_dark,
  ["#07080d"] = V.bg_darkest,
  ["#303340"] = V.selection,
  ["#4f5258"] = V.shadow,

  -- Diffs
  ["#3c8178"] = V.diff_add,
  ["#3d6965"] = V.diff_text,
  ["#764363"] = V.diff_delete,

  -- Semantic / leakage
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
}
