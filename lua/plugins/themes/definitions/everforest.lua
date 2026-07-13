-- everforest — frozen snapshot (no plugin dependency).
-- Data in definitions/data/everforest.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.everforest")
return snapshot.definition("everforest", "", data)
