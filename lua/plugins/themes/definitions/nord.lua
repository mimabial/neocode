-- nord — frozen snapshot (no plugin dependency).
-- Data in definitions/data/nord.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.nord")
return snapshot.definition("nord", "", data)
