-- Curated hex -> name map for onedark (dark). Canonical roles reference the
-- shared vocabulary (V.*, typo-checked), grounded in how each color is used.
local V = require("theme-palettes._vocabulary")

return {
  -- Core
  ["#282c34"] = V.bg,
  ["#21252b"] = V.bg_dark,
  ["#2d323a"] = V.bg_alt,
  ["#181a1f"] = V.bg_darkest,
  ["#31353f"] = V.cursorline,
  ["#393f4a"] = V.selection,
  ["#3b3f4c"] = V.surface,
  ["#4f5258"] = V.shadow,
  ["#abb2bf"] = V.fg,
  ["#5c6370"] = V.comment,
  ["#848b98"] = V.gray,
  ["#8b8b8b"] = V.gray_light,
  ["#393739"] = V.gray_dim,

  -- Accents
  ["#c678dd"] = V.purple,
  ["#d484ff"] = V.purple_bright,
  ["#8a3fa0"] = V.purple_dim,
  ["#322e3f"] = V.purple_dark,
  ["#4f3552"] = V.purple_muted,
  ["#e86671"] = V.red,
  ["#f70067"] = V.red_bright,
  ["#993939"] = V.red_dim,
  ["#8a1f1f"] = V.red_dark,
  ["#332d35"] = V.red_muted,
  ["#98c379"] = V.green,
  ["#a9ff68"] = V.green_bright,
  ["#b3f6c0"] = V.green_light,
  ["#4f6752"] = V.green_dark,
  ["#333b3b"] = V.green_muted,
  ["#e5c07b"] = V.yellow,
  ["#ebd09c"] = V.yellow_light,
  ["#93691d"] = V.yellow_dim,
  ["#333232"] = V.yellow_dark,
  ["#d19a66"] = V.orange,
  ["#f79000"] = V.orange_bright,
  ["#79491d"] = V.orange_dark,
  ["#61afef"] = V.blue,
  ["#73b8f1"] = V.blue_bright,
  ["#447aa7"] = V.blue_dim,
  ["#56b6c2"] = V.cyan,
  ["#2b6f77"] = V.cyan_dim,
  ["#28333b"] = V.cyan_dark,

  -- Diff & diagnostics
  ["#31392b"] = V.diff_add,
  ["#382b2c"] = V.diff_delete,
  ["#1c3448"] = V.diff_change,
  ["#2c5372"] = V.diff_text,
  ["#ff0000"] = V.error,
}
