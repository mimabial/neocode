-- Curated hex -> name map for citruszest (dark). Names reference the shared
-- vocabulary (V.*, typo-checked) and follow citruszest's palette: high-contrast
-- background/foreground with saturated ANSI hues and a few named extras.
local V = require("theme-palettes._vocabulary")

return {
  -- Surfaces & neutrals
  ["#121212"] = V.bg,           -- background
  ["#232323"] = V.black,        -- black
  ["#383838"] = V.cursorline,   -- cursor
  ["#404040"] = V.selection,    -- visual
  ["#4f5258"] = V.shadow,
  ["#767c77"] = V.comment,      -- bright_black
  ["#8b8b8b"] = V.gray,
  ["#bfbfbf"] = V.fg,           -- foreground / white
  ["#f9f9f9"] = V.white_bright, -- bright_white

  -- Hues
  ["#ff5454"] = V.red,           -- red
  ["#ff1a75"] = V.red_bright,    -- bright_red
  ["#00cc7a"] = V.green,         -- green
  ["#1affa3"] = V.green_bright,  -- bright_green
  ["#ffd700"] = V.yellow,        -- yellow
  ["#ffff00"] = V.yellow_bright, -- bright_yellow
  ["#ff7431"] = V.orange,        -- orange
  ["#ffaa54"] = V.orange_bright, -- bright_orange
  ["#00bfff"] = V.blue,          -- blue
  ["#28c9ff"] = V.blue_bright,   -- bright_blue
  ["#00ffff"] = V.cyan,          -- cyan
  ["#33ffff"] = V.cyan_bright,   -- bright_cyan
  ["#af74ee"] = V.violet,        -- violet

  -- Named extras
  ["#9adcff"] = V.blue_light,    -- baby_blue
  ["#fff2b3"] = V.yellow_pale,   -- lemon_yellow
  ["#b2f3ac"] = V.green_light,   -- aurora
  ["#659b75"] = V.green_muted,   -- oxley

  -- Semantic leakage (shared roles)
  ["#8cf8f7"] = V.aqua,
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
  ["#fce094"] = V.yellow_light,
  ["#d484ff"] = V.purple_bright,
  ["#a6dbff"] = V.blue_pale,
}
