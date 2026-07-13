-- Ayu (mirage) — frozen snapshot (no plugin dependency).
-- Data in definitions/data/ayu.lua by scripts/snapshot_theme.lua.
-- Only mirage is snapshotted; dark/light remain in the source's all_variants.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.ayu")
return snapshot.definition("ayu", "", data)
