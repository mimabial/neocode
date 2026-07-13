-- bamboo — frozen snapshot (no plugin dependency).
-- Data in definitions/data/bamboo.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.bamboo")
return snapshot.definition("bamboo", "", data)
