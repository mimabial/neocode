-- zenbones — frozen snapshot (no plugin dependency).
-- Data in definitions/data/zenbones.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.zenbones")
return snapshot.definition("zenbones", "", data)
