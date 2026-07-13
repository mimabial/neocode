-- Curated hex -> name map for decay ("green" = its signature default palette).
-- Names reference the shared vocabulary (V.*, typo-checked): decay's blue/green/
-- purple accents over a cool blue-charcoal surface ramp.
local V = require("theme-palettes._vocabulary")

return {
  -- Accents
  ["#70a5eb"] = V.blue,
  ["#75aaf0"] = V.blue_bright,
  ["#485263"] = V.blue_muted,
  ["#4d5768"] = V.comment,
  ["#74bee9"] = V.cyan,
  ["#8cf8f7"] = V.aqua,
  ["#78dba9"] = V.green,
  ["#94f7c5"] = V.mint,
  ["#73c0c9"] = V.teal_dark,
  ["#007373"] = V.teal,
  ["#c68aee"] = V.purple,
  ["#a9acdb"] = V.purple_light,
  ["#e05f65"] = V.red,
  ["#e5646a"] = V.red_muted,
  ["#e89777"] = V.coral_light,
  ["#f1cf8a"] = V.yellow,
  ["#fce094"] = V.yellow_light,

  -- Neutrals / foregrounds
  ["#eef1f8"] = V.white_bright,
  ["#b6beca"] = V.fg,
  ["#9b9ea4"] = V.gray_muted,

  -- Surfaces
  ["#171b20"] = V.bg,
  ["#15191d"] = V.bg_dark,
  ["#07080d"] = V.bg_darkest,
  ["#000000"] = V.black,
  ["#21262d"] = V.cursorline,
  ["#21262e"] = V.overlay,
  ["#242931"] = V.surface,
  ["#262d35"] = V.float,
  ["#4f5258"] = V.shadow,

  -- Diagnostic tints
  ["#160a0a"] = V.red_dim,
  ["#18150e"] = V.yellow_dim,
  ["#0b1118"] = V.info_dim,
  ["#111d23"] = V.hint_dim,

  -- Semantic / leakage
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
}
