-- Curated hex -> name map for gruvbox-material (medium contrast, dark). Names
-- reference the shared vocabulary (V.*, typo-checked) and follow gruvbox's warm
-- accents (red/orange/yellow/green/aqua/blue/purple) over its brown-gray ramp.
local V = require("theme-palettes._vocabulary")

return {
  -- Accents
  ["#ea6962"] = V.red,
  ["#e78a4e"] = V.orange,
  ["#d8a657"] = V.yellow,
  ["#fce094"] = V.yellow_light,
  ["#a9b665"] = V.green,
  ["#89b482"] = V.teal,     -- gruvbox "aqua"
  ["#7daea3"] = V.blue,
  ["#d3869b"] = V.purple,
  ["#8cf8f7"] = V.aqua,

  -- Neutrals
  ["#e0e2ea"] = V.white,
  ["#ddc7a1"] = V.fg_alt,
  ["#d4be98"] = V.fg,
  ["#928374"] = V.comment,
  ["#a89984"] = V.gray,
  ["#7c6f64"] = V.gray_dim,
  ["#5a524c"] = V.gray_dark,

  -- Surfaces
  ["#282828"] = V.bg,
  ["#1b1b1b"] = V.bg_dark,
  ["#07080d"] = V.bg_darkest,
  ["#32302f"] = V.bg_alt,
  ["#3a3735"] = V.cursorline,
  ["#3c3836"] = V.surface,
  ["#45403d"] = V.overlay,
  ["#504945"] = V.selection,
  ["#4f5258"] = V.shadow,

  -- Diffs
  ["#34381b"] = V.diff_add,
  ["#402120"] = V.diff_delete,
  ["#0e363e"] = V.diff_change,

  -- Semantic / leakage
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
}
