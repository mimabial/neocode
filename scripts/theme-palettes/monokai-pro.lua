-- Curated hex -> name map for monokai-pro (ristretto filter). Names reference
-- the shared vocabulary (V.*, typo-checked): monokai's pink/orange/yellow/green/
-- cyan/purple accents over ristretto's warm brown surface ramp.
local V = require("theme-palettes._vocabulary")

return {
  -- Accents
  ["#fd6883"] = V.red,
  ["#f38d70"] = V.orange,
  ["#f9cc6c"] = V.yellow,
  ["#fce094"] = V.yellow_light,
  ["#adda78"] = V.green,
  ["#85dacc"] = V.cyan,
  ["#94e9db"] = V.cyan_light,
  ["#8fe4d6"] = V.cyan_bright,
  ["#a8a9eb"] = V.purple,

  -- Neutrals / foregrounds (warm gray ramp)
  ["#fff1f3"] = V.white,
  ["#c6babb"] = V.fg_alt,
  ["#c3b7b8"] = V.fg,
  ["#b2a8a9"] = V.fg_dim,
  ["#b1a5a7"] = V.gray_light,
  ["#998f90"] = V.gray,
  ["#948a8b"] = V.gray_muted,
  ["#857b7c"] = V.gray_dim,
  ["#72696a"] = V.comment,
  ["#5b5353"] = V.gray_dark,

  -- Surfaces
  ["#2c2525"] = V.bg,
  ["#262121"] = V.bg_alt,
  ["#211c1c"] = V.bg_dark,
  ["#191515"] = V.bg_darker,
  ["#07080d"] = V.bg_darkest,
  ["#222222"] = V.black,
  ["#372f2f"] = V.cursorline,
  ["#3b3434"] = V.bg_dim,
  ["#362e2e"] = V.indent_scope,
  ["#41393a"] = V.surface,
  ["#403838"] = V.float,
  ["#433b3b"] = V.selection,
  ["#4c4444"] = V.overlay,
  ["#4f5258"] = V.shadow,

  -- Diffs
  ["#2f2f25"] = V.diff_add,
  ["#819e5b"] = V.green_dark,
  ["#362724"] = V.diff_change,
  ["#b16955"] = V.orange_dark,
  ["#372426"] = V.diff_delete,
  ["#b85062"] = V.red_dark,

  -- Diagnostic tints
  ["#353736"] = V.diag_dim,
  ["#402f2d"] = V.yellow_dim,
  ["#412c2e"] = V.red_dim,

  -- Semantic / leakage
  ["#b3f6c0"] = V.success,
  ["#8cf8f7"] = V.aqua,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
}
