-- Curated hex -> name map for everforest (soft-dark + hard-light). The two
-- variants are different contrast/background poles, so their hex sets are
-- disjoint and named independently by role. Names reference the shared
-- vocabulary (V.*, typo-checked): everforest's warm green/red/orange/yellow/
-- aqua/blue/purple accents over its muted forest surface ramp.
local V = require("theme-palettes._vocabulary")

return {
  -- ---- soft-dark ----
  ["#a7c080"] = V.green,
  ["#83c092"] = V.green_light,
  ["#e67e80"] = V.red,
  ["#e69875"] = V.orange,
  ["#dbbc7f"] = V.yellow,
  ["#fce094"] = V.yellow_light,
  ["#7fbbb3"] = V.teal,       -- aqua
  ["#d699b6"] = V.purple,
  ["#8cf8f7"] = V.aqua,
  ["#d3c6aa"] = V.fg,
  ["#e0e2ea"] = V.white,
  ["#859289"] = V.comment,
  ["#9da9a0"] = V.gray,
  ["#7a8478"] = V.gray_dim,
  ["#5d6b66"] = V.gray_dark,
  ["#333c43"] = V.bg,
  ["#293136"] = V.bg_dark,
  ["#07080d"] = V.bg_darkest,
  ["#3a464c"] = V.bg_alt,
  ["#434f55"] = V.surface,
  ["#4d5960"] = V.overlay,
  ["#555f66"] = V.selection,
  ["#5c3f4f"] = V.purple_dark, -- visual/purple-tint surface
  ["#4f5258"] = V.shadow,
  ["#48584e"] = V.diff_add,
  ["#59464c"] = V.diff_delete,
  ["#3f5865"] = V.diff_change,

  -- ---- hard-light ----
  ["#8da101"] = V.green,
  ["#93b259"] = V.green_light,
  ["#f85552"] = V.red,
  ["#e66868"] = V.red_light,
  ["#f57d26"] = V.orange,
  ["#dfa000"] = V.yellow,
  ["#6b5300"] = V.yellow_dark,
  ["#35a77c"] = V.teal,       -- aqua
  ["#007373"] = V.teal_dark,
  ["#3a94c5"] = V.blue,
  ["#df69ba"] = V.purple,
  ["#14161b"] = V.fg,
  ["#5c6a72"] = V.comment,
  ["#939f91"] = V.gray,
  ["#a6b0a0"] = V.gray_light,
  ["#bec5b2"] = V.gray_muted,
  ["#829181"] = V.gray_dim,
  ["#708089"] = V.gray_dark,
  ["#9b9ea4"] = V.shadow,
  ["#fffbef"] = V.bg,
  ["#f2efdf"] = V.bg_dark,
  ["#f8f5e4"] = V.bg_alt,
  ["#edeada"] = V.surface,
  ["#e8e5d5"] = V.overlay,
  ["#eef1f8"] = V.cursorline,
  ["#f0f2d4"] = V.selection,
  ["#f3f5d9"] = V.diff_add,
  ["#ffe7de"] = V.diff_delete,
  ["#ecf5ed"] = V.diff_change,
  ["#005523"] = V.success,
  ["#590008"] = V.git_removed,

  -- shared leakage
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
}
