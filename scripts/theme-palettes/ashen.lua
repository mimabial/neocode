-- Curated hex -> name map for ashen (dark). Canonical roles reference the
-- shared vocabulary (V.*, typo-checked), grounded in how each color is used.
local V = require("theme-palettes._vocabulary")

return {
  -- Surfaces (dark ember tiers)
  ["#121212"] = V.bg,
  ["#07080d"] = V.bg_darkest,
  ["#151515"] = V.bg_darker,
  ["#191919"] = V.bg_dark,
  ["#1d1d1d"] = V.bg_alt,
  ["#2c2e33"] = V.bg_dim,
  ["#212121"] = V.cursorline,
  ["#323232"] = V.surface,
  ["#535353"] = V.overlay,
  ["#4f5258"] = V.shadow,

  -- Neutrals / foregrounds
  ["#e5e5e5"] = V.white,
  ["#d5d5d5"] = V.fg,
  ["#e0e2ea"] = V.fg_alt,
  ["#c4c6cd"] = V.fg_dim,
  ["#b4b4b4"] = V.gray_light,
  ["#a7a7a7"] = V.gray,
  ["#9b9ea4"] = V.gray_muted,
  ["#949494"] = V.gray_dim,
  ["#8b8b8b"] = V.gray_dark,
  ["#737373"] = V.comment,

  -- Reds (embers)
  ["#b14242"] = V.red,
  ["#df6464"] = V.red_bright,
  ["#c53030"] = V.red_dark,
  ["#bd4c4c"] = V.red_muted,
  ["#ff0000"] = V.error,

  -- Oranges / yellows
  ["#c4693d"] = V.orange,
  ["#d87c4a"] = V.orange_light,
  ["#e78a4e"] = V.orange_bright,
  ["#e5a72a"] = V.yellow,
  ["#e49a44"] = V.gold,

  -- Teals / greens
  ["#4a8b8b"] = V.teal,
  ["#3a6e6e"] = V.teal_dark,
  ["#629c7d"] = V.green,
  ["#1e6f54"] = V.green_dark,
  ["#b3f6c0"] = V.success,
  ["#8cf8f7"] = V.cyan_pale,

  -- Purples / pinks
  ["#d3869b"] = V.pink,
  ["#7a3d82"] = V.purple,
  ["#d484ff"] = V.purple_bright,
  ["#4f3552"] = V.purple_dark,

  -- Git
  ["#ffc0b9"] = V.git_removed,
}
