-- Ashen — frozen snapshot (no plugin dependency).
-- Data in definitions/data/ashen.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.ashen")
return snapshot.definition("ashen", "", data)
