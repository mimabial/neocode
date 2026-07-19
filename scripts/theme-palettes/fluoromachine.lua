-- Curated hex -> name map for fluoromachine (dark, default + glow variants).
-- Names reference the shared vocabulary (V.*, typo-checked) and follow the
-- plugin's palette; glow shifts the bg tiers, so both sets are mapped (each
-- variant is a separate capture, so two hexes may share one role name).
local V = require("theme-palettes._vocabulary")

return {
  -- Surfaces & neutrals (bg tiers differ per variant: default plain / glow bloom)
  ["#262335"] = V.bg,           -- bg (default)
  ["#200933"] = V.bg,           -- bg (glow)
  ["#241b2f"] = V.bg_dark,      -- bgdark (default)
  ["#1c082d"] = V.bg_dark,      -- bgdark (glow)
  ["#1c1a27"] = V.bg_darker,    -- (default)
  ["#180626"] = V.bg_darker,    -- (glow)
  ["#282a36"] = V.bg_alt,       -- cursor surface
  ["#463465"] = V.selection,    -- selection / currentline
  ["#4f5258"] = V.shadow,
  ["#495495"] = V.comment,      -- comment
  ["#8ba7a7"] = V.fg,           -- fg
  ["#ffffff"] = V.white_bright,

  -- Hues
  ["#fe4450"] = V.red,          -- red
  ["#982830"] = V.red_dark,
  ["#ff8b39"] = V.orange,       -- orange
  ["#e78a4e"] = V.orange_muted,
  ["#ffcc00"] = V.yellow,       -- yellow
  ["#997a00"] = V.yellow_dark,
  ["#72f1b8"] = V.green,        -- green
  ["#44906e"] = V.green_muted,
  ["#61e2ff"] = V.cyan,         -- cyan
  ["#4db4cc"] = V.teal,
  ["#8cf8f7"] = V.aqua,
  ["#af6df9"] = V.purple,       -- purple
  ["#57367c"] = V.purple_dark,
  ["#8c57c7"] = V.violet,       -- separator
  ["#fc199a"] = V.pink,         -- pink
  ["#7e0c4d"] = V.pink_dark,

  -- Semantic leakage (shared roles)
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
  ["#ff0000"] = V.error,
}
