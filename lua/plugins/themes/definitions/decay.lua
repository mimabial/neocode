-- decay — frozen snapshot (no plugin dependency).
-- Data in definitions/data/decay.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.decay")
return snapshot.definition("decay", "", data)
