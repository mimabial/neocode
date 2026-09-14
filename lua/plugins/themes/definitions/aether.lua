-- aether — frozen snapshot (no plugin dependency).
-- Data in definitions/data/aether.lua by scripts/snapshot_theme.lua.
-- Variants are injected palettes, not plugin variants: aether = stock,
-- while akaito and sakura-mochi are imported palettes.
local snapshot = require("lib.snapshot")
return snapshot.definition("aether", "", function()
  return require("plugins.themes.definitions.data.aether")
end, { "aether", "akaito", "sakura-mochi" })
