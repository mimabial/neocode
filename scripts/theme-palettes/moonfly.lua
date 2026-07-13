-- Curated hex -> name map for moonfly (dark). Names reference the shared
-- vocabulary (V.*, typo-checked): moonfly's vivid accents (red/coral/emerald/
-- turquoise/sky/purple) over a near-black surface ramp with many neutral grays.
local V = require("theme-palettes._vocabulary")

return {
  -- Reds / pinks / coral
  ["#ff5d5d"] = V.red,
  ["#ea6962"] = V.red_bright,
  ["#ff5189"] = V.magenta,
  ["#e196a2"] = V.pink,
  ["#d3869b"] = V.pink_muted,
  ["#f09479"] = V.coral,

  -- Oranges / yellows
  ["#de935f"] = V.orange,
  ["#e78a4e"] = V.orange_bright,
  ["#e3c78a"] = V.yellow,
  ["#d8a657"] = V.gold,
  ["#c6c684"] = V.yellow_muted,

  -- Greens / teals
  ["#8cc85f"] = V.green,
  ["#85dc85"] = V.green_light,
  ["#36c692"] = V.green_bright,
  ["#89b482"] = V.green_muted,
  ["#79dac8"] = V.teal,
  ["#7daea3"] = V.teal_dark,

  -- Blues / purples
  ["#74b2ff"] = V.blue,
  ["#80a0ff"] = V.blue_light,
  ["#4d5d8d"] = V.blue_dark,
  ["#88a2b7"] = V.blue_muted,
  ["#748999"] = V.blue_dim,
  ["#cf87e8"] = V.purple,
  ["#ae81ff"] = V.purple_bright,
  ["#8cf8f7"] = V.aqua,

  -- Neutrals / foregrounds
  ["#e4e4e4"] = V.white,
  ["#c6c6c6"] = V.fg,
  ["#b2b2b2"] = V.fg_alt,
  ["#9e9e9e"] = V.fg_dim,
  ["#949494"] = V.comment,
  ["#808080"] = V.gray,
  ["#7f7f7f"] = V.gray_light,
  ["#626262"] = V.gray_muted,
  ["#585858"] = V.gray_dim,
  ["#4e4e4e"] = V.gray_dark,
  ["#3a3a3a"] = V.black_bright,

  -- Surfaces
  ["#080808"] = V.bg,
  ["#121212"] = V.cursorline,
  ["#1c1c1c"] = V.bg_alt,
  ["#212121"] = V.bg_dim,
  ["#262626"] = V.surface,
  ["#292929"] = V.overlay,
  ["#2e2e2e"] = V.float,
  ["#323437"] = V.selection,
  ["#373c4d"] = V.indent_scope,
  ["#444444"] = V.indent,
  ["#4f5258"] = V.shadow,

  -- Diffs / semantic / leakage
  ["#314940"] = V.diff_add,
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
}
