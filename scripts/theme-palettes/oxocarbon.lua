-- Curated hex -> name map for oxocarbon (dark). Canonical roles reference the
-- shared vocabulary (V.*, typo-checked), grounded in how each color is used.
local V = require("theme-palettes._vocabulary")

return {
  -- Surfaces & neutrals
  ["#161616"] = V.bg,
  ["#131313"] = V.bg_dark,
  ["#07080d"] = V.bg_darkest,
  ["#262626"] = V.surface,
  ["#393939"] = V.selection,
  ["#4f5258"] = V.shadow,
  ["#d0d0d0"] = V.fg,
  ["#e0e2ea"] = V.fg_dim,
  ["#f2f2f2"] = V.white,
  ["#ffffff"] = V.white_bright,
  ["#525252"] = V.comment,
  ["#9b9ea4"] = V.gray,
  ["#adadad"] = V.gray_light,

  -- Accents
  ["#78a9ff"] = V.blue,
  ["#82cfff"] = V.blue_light,
  ["#33b1ff"] = V.blue_bright,
  ["#3ddbd9"] = V.cyan,
  ["#8cf8f7"] = V.cyan_pale,
  ["#08bdba"] = V.teal,
  ["#be95ff"] = V.purple,
  ["#ff7eb6"] = V.pink,
  ["#ee5396"] = V.red,
  ["#42be65"] = V.green,
  ["#b3f6c0"] = V.green_light,
  ["#fce094"] = V.yellow,

  -- Diff & git
  ["#122f2f"] = V.diff_add,
  ["#361c28"] = V.diff_delete,
  ["#222a39"] = V.diff_change,
  ["#2f3f5c"] = V.diff_text,
  ["#ffc0b9"] = V.git_removed,
}
