-- Curated hex -> name map for darkvoid (glow). Names reference the shared
-- vocabulary (V.*, typo-checked). Darkvoid is largely monochrome (a deep gray
-- ramp) with a neon-green signature and a moonfly-style terminal palette; the
-- grays map onto the white/fg/gray neutral ramp by lightness.
local V = require("theme-palettes._vocabulary")

return {
  -- Signature greens
  ["#1bfd9c"] = V.green_bright,
  ["#baffc9"] = V.green_light,
  ["#d6efd8"] = V.green_pale,
  ["#005523"] = V.green_dark,
  ["#8cc85f"] = V.green,
  ["#85dc85"] = V.green_muted,
  ["#36c692"] = V.mint,
  ["#bedc74"] = V.lime,
  ["#bdfe58"] = V.lime_bright,

  -- Teals / cyan
  ["#66b2b2"] = V.teal,
  ["#b2d8d8"] = V.teal_light,
  ["#007373"] = V.teal_dark,
  ["#79dac8"] = V.teal_muted,
  ["#8cf8f7"] = V.aqua,

  -- Blues / purples
  ["#7fa1c3"] = V.blue,
  ["#6a7a8a"] = V.blue_dim,
  ["#74b2ff"] = V.blue_light,
  ["#80a0ff"] = V.blue_pale,
  ["#cf87e8"] = V.purple,
  ["#ae81ff"] = V.purple_bright,

  -- Warm accents
  ["#dea6a0"] = V.coral,
  ["#ffb3ba"] = V.red_light,
  ["#590008"] = V.red_dark,
  ["#ff5d5d"] = V.red_bright,
  ["#ff5189"] = V.magenta,
  ["#fce094"] = V.yellow,
  ["#ffffba"] = V.yellow_light,
  ["#e3c78a"] = V.gold,
  ["#c6c684"] = V.yellow_muted,
  ["#e78a4e"] = V.orange_bright,

  -- Neutral ramp (monochrome, light -> dark)
  ["#f1f1f1"] = V.white_bright,
  ["#e6e6e6"] = V.white,
  ["#e4e4e4"] = V.white_dim,
  ["#e1e1e1"] = V.fg_bright,
  ["#e0e2ea"] = V.fg_alt,
  ["#d1d1d1"] = V.fg,
  ["#c6c6c6"] = V.fg_muted,
  ["#c5c5c5"] = V.fg_dim,
  ["#c4c6cd"] = V.gray_light,
  ["#c0c0c0"] = V.gray,
  ["#b1b1b1"] = V.gray_muted,
  ["#a1a1a1"] = V.gray_dim,
  ["#9b9ea4"] = V.gray_dark,
  ["#949494"] = V.comment,

  -- Surfaces
  ["#1c1c1c"] = V.bg,
  ["#07080d"] = V.bg_darkest,
  ["#2c2e33"] = V.bg_alt,
  ["#303030"] = V.surface,
  ["#3c3c3c"] = V.overlay,
  ["#404040"] = V.selection,
  ["#45403d"] = V.cursorline,
  ["#585858"] = V.float,
  ["#323437"] = V.indent_scope,
  ["#4f5258"] = V.shadow,

  -- Diffs / semantic / leakage
  ["#eef1f8"] = V.diff_change,
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
}
