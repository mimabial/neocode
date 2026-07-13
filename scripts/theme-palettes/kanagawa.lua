-- Curated hex -> name map for kanagawa (wave). Canonical roles reference the
-- shared vocabulary (V.*, typo-checked), grounded in how each color is used.
local V = require("theme-palettes._vocabulary")

return {
  -- Surfaces & neutrals (sumiInk tiers)
  ["#1f1f28"] = V.bg,
  ["#16161d"] = V.bg_dark,
  ["#1a1a22"] = V.bg_darker,
  ["#181820"] = V.bg_darkest,
  ["#2a2a37"] = V.surface,
  ["#363646"] = V.cursorline,
  ["#54546d"] = V.overlay,
  ["#223249"] = V.selection,
  ["#2d4f67"] = V.blue_dark,
  ["#4f5258"] = V.shadow,
  ["#dcd7ba"] = V.fg,
  ["#c8c093"] = V.fg_dim,
  ["#727169"] = V.comment,
  ["#938aa9"] = V.gray,
  ["#717c7c"] = V.gray_dim,

  -- Accents
  ["#7e9cd8"] = V.blue,
  ["#9cabca"] = V.blue_pale,
  ["#7fb4ca"] = V.cyan,
  ["#8cf8f7"] = V.cyan_pale,
  ["#658594"] = V.teal,
  ["#7aa89f"] = V.teal_light,
  ["#6a9589"] = V.aqua,
  ["#957fb8"] = V.purple,
  ["#b8b4d0"] = V.purple_pale,
  ["#98bb6c"] = V.green,
  ["#76946a"] = V.green_muted,
  ["#b3f6c0"] = V.green_light,
  ["#e6c384"] = V.yellow,
  ["#c0a36e"] = V.yellow_muted,
  ["#dca561"] = V.gold,
  ["#ff9e3b"] = V.orange,
  ["#ffa066"] = V.orange_light,
  ["#d27e99"] = V.pink,
  ["#e46876"] = V.rose,
  ["#e82424"] = V.red,
  ["#ff5d62"] = V.red_bright,
  ["#c34043"] = V.red_muted,
  ["#ff0000"] = V.error,

  -- Diff & git
  ["#2b3328"] = V.diff_add,
  ["#43242b"] = V.diff_delete,
  ["#252535"] = V.diff_change,
  ["#49443c"] = V.diff_text,
  ["#ffc0b9"] = V.git_removed,
}
