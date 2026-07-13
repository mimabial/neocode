-- Curated hex -> name map for catppuccin (mocha = dark, latte = light). The two
-- variants are parallel; each role has one hex per variant. Names reference the
-- shared vocabulary (V.*, typo-checked) and follow Catppuccin's own roles
-- (rosewater/flamingo/pink/mauve/red/maroon/peach/yellow/green/teal/sky/
-- sapphire/blue/lavender + base/mantle/crust + surface0-2 + overlay0-2).
local V = require("theme-palettes._vocabulary")

return {
  -- Accents (mocha / latte)
  ["#f5e0dd"] = V.rose,      ["#dc8a79"] = V.rose,      -- rosewater
  ["#f2cdce"] = V.coral,     ["#dd7879"] = V.coral,     -- flamingo
  ["#f5c2e8"] = V.pink,      ["#ea76cc"] = V.pink,
  ["#f38ba9"] = V.red,       ["#d20f3a"] = V.red,
  ["#eba0ad"] = V.red_muted, ["#e64554"] = V.red_muted, -- maroon
  ["#fab388"] = V.orange,    ["#fe640c"] = V.orange,    -- peach
  ["#f9e2b0"] = V.yellow,    ["#df8e1e"] = V.yellow,
  ["#a6e3a2"] = V.green,     ["#40a02c"] = V.green,
  ["#94e2d6"] = V.teal,      ["#17929a"] = V.teal,
  ["#89dcec"] = V.sky,       ["#04a5e6"] = V.sky,
  ["#74c7ed"] = V.cyan,      ["#209fb6"] = V.cyan,      -- sapphire
  ["#89b4fb"] = V.blue,      ["#1e66f6"] = V.blue,
  ["#b4beff"] = V.violet,    ["#7287fe"] = V.violet,    -- lavender
  ["#cba6f8"] = V.purple,    ["#8839f0"] = V.purple,    -- mauve

  -- Neutrals / foregrounds
  ["#cdd6f5"] = V.fg,         ["#4c4f6a"] = V.fg,         -- text
  ["#bac2df"] = V.fg_alt,     ["#5c5f78"] = V.fg_alt,     -- subtext1
  ["#a6adc9"] = V.fg_dim,     ["#6c6f86"] = V.fg_dim,     -- subtext0
  ["#9399b3"] = V.gray_light, ["#7c7f94"] = V.gray_light, -- overlay2
  ["#7f849d"] = V.gray,       ["#8c8fa2"] = V.gray,       -- overlay1
  ["#6c7087"] = V.comment,    ["#9ca0b1"] = V.comment,    -- overlay0

  -- Surfaces
  ["#585b71"] = V.selection,   ["#acb0bf"] = V.selection,   -- surface2
  ["#45475b"] = V.overlay,     ["#bcc0cd"] = V.overlay,     -- surface1
  ["#313245"] = V.surface,     ["#ccd0db"] = V.surface,     -- surface0
  ["#1e1e2f"] = V.bg,          ["#eff1f6"] = V.bg,          -- base
  ["#181826"] = V.bg_dark,     ["#e6e9f0"] = V.bg_dark,     -- mantle
  ["#11111c"] = V.bg_darkest,  ["#dce0e9"] = V.bg_darkest,  -- crust
  ["#2a2b3d"] = V.cursorline,  ["#e9ebf2"] = V.cursorline,
  ["#191927"] = V.bg_alt,      ["#e7eaf1"] = V.bg_alt,

  -- Mocha-only extras (git inline, diffs, search, diagnostic tints)
  ["#393b4e"] = V.float,
  ["#3e5768"] = V.surface_bright,
  ["#7ec9d9"] = V.cyan_dark,
  ["#364144"] = V.diff_add,
  ["#25293d"] = V.diff_change,
  ["#443245"] = V.diff_delete,
  ["#3e4b6c"] = V.diff_text,
  ["#4f6558"] = V.green_dark,
  ["#2d334c"] = V.blue_dark,
  ["#6b455b"] = V.red_dark,
  ["#283041"] = V.info_dim,
  ["#29313f"] = V.hint_dim,
  ["#32283b"] = V.red_dim,
  ["#33313b"] = V.yellow_dim,
  ["#ffc0b9"] = V.git_removed,
  ["#b3f6c0"] = V.success,

  -- Latte-only extras
  ["#cbcfd9"] = V.float,
  ["#a8daf1"] = V.surface_bright,
  ["#1bade8"] = V.cyan_dark,
  ["#d0e2d2"] = V.diff_add,
  ["#e0e7f6"] = V.diff_change,
  ["#eac8d4"] = V.diff_delete,
  ["#b0c7f6"] = V.diff_text,
  ["#b0d4ad"] = V.green_dark,
  ["#d2def6"] = V.blue_dark,
  ["#e5a0b2"] = V.red_dark,
  ["#d9eaf4"] = V.info_dim,
  ["#dae8ed"] = V.green_pale,
  ["#ecdce4"] = V.red_dim,
  ["#ede8e1"] = V.yellow_dim,
  ["#590008"] = V.git_removed,
  ["#005523"] = V.success,

  -- Shared leakage
  ["#ff0000"] = V.error,
}
