-- Curated hex -> name map for dracula (dark). Names reference the shared
-- vocabulary (V.*, typo-checked) and follow Dracula's official palette:
-- bg/fg/selection/comment surfaces plus the eight hues and their bright pair.
local V = require("theme-palettes._vocabulary")

return {
  -- Surfaces & neutrals
  ["#282a36"] = V.bg,           -- bg
  ["#21222c"] = V.bg_dark,      -- menu
  ["#191a21"] = V.bg_darker,    -- black
  ["#07080d"] = V.bg_darkest,
  ["#3b4048"] = V.overlay,      -- nontext
  ["#3e4452"] = V.surface,      -- visual
  ["#44475a"] = V.selection,    -- selection
  ["#4f5258"] = V.shadow,
  ["#6272a4"] = V.comment,      -- comment
  ["#f8f8f2"] = V.fg,           -- fg
  ["#e0e2ea"] = V.white_dim,
  ["#abb2bf"] = V.white,        -- white
  ["#ffffff"] = V.white_bright, -- bright_white
  ["#9b9ea4"] = V.gray_muted,
  ["#969696"] = V.gray_light,
  ["#8b8b8b"] = V.gray,

  -- Hues
  ["#ff5555"] = V.red,            -- red
  ["#ff6e6e"] = V.red_bright,     -- bright_red
  ["#ffb86c"] = V.orange,         -- orange
  ["#f1fa8c"] = V.yellow,         -- yellow
  ["#ffffa5"] = V.yellow_bright,  -- bright_yellow
  ["#fce094"] = V.yellow_light,
  ["#50fa7b"] = V.green,          -- green
  ["#69ff94"] = V.green_bright,   -- bright_green
  ["#8be9fd"] = V.cyan,           -- cyan
  ["#a4ffff"] = V.cyan_bright,    -- bright_cyan
  ["#8cf8f7"] = V.aqua,
  ["#bd93f9"] = V.purple,         -- purple
  ["#d484ff"] = V.purple_bright,
  ["#d6acff"] = V.blue_bright,    -- bright_blue
  ["#ff79c6"] = V.pink,           -- pink
  ["#ff92df"] = V.magenta_bright, -- bright_magenta

  -- Semantic leakage (shared roles)
  ["#ff0000"] = V.error,
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
}
