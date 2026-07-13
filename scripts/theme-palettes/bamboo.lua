-- Curated hex -> name map for bamboo (vulgaris). Names reference the shared
-- vocabulary (V.*, typo-checked): bamboo's warm green/yellow/red/blue/purple
-- accents over a warm green-charcoal surface ramp.
local V = require("theme-palettes._vocabulary")

return {
  -- Greens
  ["#8fb573"] = V.green,
  ["#abc896"] = V.green_light,
  ["#80bc99"] = V.green_muted,
  ["#ccd6ae"] = V.green_pale,

  -- Yellows / gold
  ["#dbb651"] = V.yellow,
  ["#e4c87d"] = V.yellow_light,
  ["#e2c792"] = V.gold,

  -- Oranges / coral
  ["#ff9966"] = V.orange,
  ["#ffb38c"] = V.orange_light,
  ["#e78a4e"] = V.orange_bright,
  ["#f88d73"] = V.coral,
  ["#f08080"] = V.coral_light,

  -- Reds / pinks
  ["#e75a7c"] = V.red,
  ["#ed839d"] = V.red_light,
  ["#b94863"] = V.red_dark,
  ["#e28899"] = V.pink,
  ["#f098ad"] = V.pink_light,

  -- Blues
  ["#57a5e5"] = V.blue,
  ["#96c7ef"] = V.blue_light,
  ["#81bcec"] = V.blue_pale,
  ["#68aee8"] = V.blue_bright,
  ["#8888cc"] = V.blue_muted,
  ["#3d73a0"] = V.blue_dark,

  -- Purples / magenta / teals
  ["#aaaaff"] = V.purple,
  ["#bfbfff"] = V.purple_light,
  ["#c5c2ee"] = V.purple_pale,
  ["#df73ff"] = V.magenta,
  ["#70c2be"] = V.teal,
  ["#94d1ce"] = V.teal_light,
  ["#8cf8f7"] = V.aqua,

  -- Neutrals
  ["#f1e9d2"] = V.fg,
  ["#838781"] = V.gray,
  ["#5b5e5a"] = V.comment,

  -- Surfaces
  ["#252623"] = V.bg,
  ["#1c1e1b"] = V.bg_dark,
  ["#111210"] = V.bg_darkest,
  ["#2f312c"] = V.bg_alt,
  ["#3a3d37"] = V.selection,
  ["#383b35"] = V.surface,
  ["#3b4235"] = V.overlay,
  ["#5c4334"] = V.orange_dark,   -- gitcommit comment tint
  ["#4f5258"] = V.shadow,

  -- Diffs
  ["#40531b"] = V.diff_add,
  ["#893f45"] = V.diff_delete,
  ["#2a3a57"] = V.diff_change,
  ["#3a4a67"] = V.diff_text,

  -- Diagnostic tints
  ["#373428"] = V.yellow_dim,
  ["#2d3633"] = V.info_dim,
  ["#323339"] = V.hint_dim,
  ["#382b2c"] = V.red_dim,

  -- Semantic / leakage
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
}
