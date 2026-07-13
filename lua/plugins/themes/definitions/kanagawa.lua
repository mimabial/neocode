-- Kanagawa — frozen snapshot (wave, no plugin dependency).
-- Data in definitions/data/kanagawa.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.kanagawa")
return snapshot.definition("kanagawa", "", data)
