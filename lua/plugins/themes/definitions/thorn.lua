-- thorn — frozen snapshot (no plugin dependency).
-- Data in definitions/data/thorn.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.thorn")
return snapshot.definition("thorn", "", data)
