-- Curated hex -> name map for zenbones (default, dark). Zenbones is a subtle
-- warm-monochrome "bones" theme: a long warm gray/brown ramp with muted
-- accents. Names reference the shared vocabulary (V.*, typo-checked); the many
-- neutrals map onto the white/fg/gray ramp by lightness.
local V = require("theme-palettes._vocabulary")

return {
  -- Accents (muted)
  ["#819b69"] = V.green,
  ["#8bae68"] = V.green_light,
  ["#6099c0"] = V.blue,
  ["#61abda"] = V.blue_light,
  ["#315167"] = V.blue_dark,
  ["#66a5ad"] = V.teal,
  ["#65b8c1"] = V.teal_light,
  ["#b279a7"] = V.purple,
  ["#cf86c1"] = V.purple_light,
  ["#65435e"] = V.purple_dark,
  ["#d3869b"] = V.pink,
  ["#bf8fb5"] = V.pink_light,
  ["#de6e7c"] = V.red,
  ["#e8838f"] = V.red_light,
  ["#cb7a83"] = V.red_muted,
  ["#ea6962"] = V.red_bright,
  ["#b77e64"] = V.orange,
  ["#d68c67"] = V.orange_light,
  ["#d8a657"] = V.yellow,

  -- Neutrals (warm/cool ramp, light -> dark)
  ["#e0e2ea"] = V.white_bright,
  ["#cad0d4"] = V.white,
  ["#c4cacf"] = V.white_dim,
  ["#b4bdc3"] = V.fg,
  ["#afa099"] = V.fg_bright,
  ["#9fa7ad"] = V.fg_alt,
  ["#979fa4"] = V.fg_muted,
  ["#a1938c"] = V.fg_dim,
  ["#8d9499"] = V.gray_light,
  ["#888f94"] = V.gray,
  ["#868c91"] = V.gray_muted,
  ["#8e817b"] = V.gray_dim,
  ["#867a74"] = V.gray_dark,
  ["#797f84"] = V.gray_darker,
  ["#837771"] = V.black_bright,
  ["#6e6763"] = V.comment,
  ["#64696d"] = V.black,

  -- Surfaces
  ["#1c1917"] = V.bg,
  ["#231f1d"] = V.bg_dark,
  ["#25211f"] = V.bg_darker,
  ["#272321"] = V.bg_dim,
  ["#2b2725"] = V.bg_alt,
  ["#302b29"] = V.surface_dim,
  ["#352f2d"] = V.surface,
  ["#393431"] = V.surface_bright,
  ["#403833"] = V.panel,
  ["#494341"] = V.panel_dim,
  ["#4a433f"] = V.overlay,
  ["#55392c"] = V.indent_scope,
  ["#3d4042"] = V.selection,   -- Visual
  ["#5c534f"] = V.panel_bright,
  ["#615853"] = V.indent,
  ["#685f5a"] = V.cursorline,
  ["#79675e"] = V.float,
  ["#4f5258"] = V.shadow,

  -- Diffs
  ["#232d1a"] = V.diff_add,
  ["#3e2225"] = V.diff_delete,
  ["#1d2c36"] = V.diff_change,
  ["#324757"] = V.diff_text,

  -- Diagnostic tints
  ["#272020"] = V.red_dim,
  ["#242120"] = V.yellow_dim,
  ["#202223"] = V.info_dim,
  ["#252024"] = V.hint_dim,
  ["#212220"] = V.green_dark,

  -- Semantic / leakage
  ["#b3f6c0"] = V.success,
  ["#ff0000"] = V.error,
}
