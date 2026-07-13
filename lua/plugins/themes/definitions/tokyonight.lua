-- Tokyonight (storm) — frozen snapshot (no plugin dependency).
-- Data in definitions/data/tokyonight.lua by scripts/snapshot_theme.lua.
-- Only the storm variant is snapshotted; night/moon/day remain in the source's
-- all_variants for regeneration.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.tokyonight")
return snapshot.definition("tokyonight", "", data)
