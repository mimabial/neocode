-- Curated hex -> name map for nord (dark). Names reference the shared
-- vocabulary (V.*, typo-checked) and follow Nord's own palette: Polar Night
-- surfaces (nord0-3), Snow Storm foregrounds (nord4-6), Frost blues/teals
-- (nord7-10), and Aurora accents (nord11-15).
local V = require("theme-palettes._vocabulary")

return {
  -- Frost
  ["#8fbcbb"] = V.teal,       -- nord7
  ["#88c0d0"] = V.cyan,       -- nord8
  ["#81a1c1"] = V.blue,       -- nord9
  ["#5e81ac"] = V.blue_dark,  -- nord10
  ["#a6dbff"] = V.blue_light, -- hint underline
  ["#8cf8f7"] = V.aqua,

  -- Aurora
  ["#bf616a"] = V.red,        -- nord11
  ["#ea6962"] = V.red_bright,
  ["#d08770"] = V.orange,     -- nord12
  ["#ebcb8b"] = V.yellow,     -- nord13
  ["#fce094"] = V.yellow_light,
  ["#d8a657"] = V.gold,
  ["#a3be8c"] = V.green,      -- nord14
  ["#b48ead"] = V.purple,     -- nord15

  -- Snow Storm (foregrounds)
  ["#d8dee9"] = V.fg,         -- nord4
  ["#e5e9f0"] = V.fg_alt,     -- nord5
  ["#eceff4"] = V.white,      -- nord6

  -- Polar Night (surfaces) + neutrals
  ["#2e3440"] = V.bg,         -- nord0
  ["#3b4252"] = V.surface,    -- nord1
  ["#434c5e"] = V.overlay,    -- nord2
  ["#4c566a"] = V.comment,    -- nord3
  ["#616e88"] = V.gray,
  ["#9b9ea4"] = V.gray_muted,
  ["#07080d"] = V.bg_darkest,
  ["#000000"] = V.black,
  ["#4f5258"] = V.shadow,

  -- Semantic / leakage
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
}
