-- Curated hex -> name map for thorn (forest). Names reference the shared
-- vocabulary (V.*, typo-checked): thorn's teal/green forest accents with a
-- coral keyword, over a deep green-charcoal surface ramp.
local V = require("theme-palettes._vocabulary")

return {
  -- Teals / greens (thorn's core)
  ["#91c4c0"] = V.teal,
  ["#568270"] = V.teal_dark,
  ["#6fa791"] = V.teal_muted,
  ["#87cbb1"] = V.mint,
  ["#88b497"] = V.green,
  ["#9ec59b"] = V.green_light,
  ["#9ebb9c"] = V.green_muted,
  ["#b8cdb6"] = V.green_pale,
  ["#94c68b"] = V.green_bright,
  ["#1f3329"] = V.green_dark,   -- diff-add surface

  -- Warm accents
  ["#d2696c"] = V.red,
  ["#d8464b"] = V.red_dark,
  ["#f2a597"] = V.coral,
  ["#f9ada0"] = V.coral_light,
  ["#ffd7aa"] = V.orange_light,
  ["#e78a4e"] = V.orange_bright,
  ["#6daae3"] = V.blue,

  -- Neutrals
  ["#dbd2c7"] = V.fg,
  ["#9b9a8c"] = V.gray,

  -- Surfaces
  ["#172526"] = V.bg,
  ["#131f20"] = V.bg_dark,
  ["#0b1213"] = V.bg_darkest,
  ["#1d3334"] = V.cursorline,
  ["#1c3d3c"] = V.surface,
  ["#26403e"] = V.selection,
  ["#233935"] = V.overlay,
  ["#4f5258"] = V.shadow,

  -- Diffs
  ["#33232a"] = V.diff_delete,
  ["#1e2d39"] = V.diff_change,

  -- Semantic / leakage
  ["#b3f6c0"] = V.success,
  ["#8cf8f7"] = V.aqua,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
}
