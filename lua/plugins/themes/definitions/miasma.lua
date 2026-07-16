-- miasma — frozen snapshot (no plugin dependency).
-- Data in definitions/data/miasma.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.miasma")
return snapshot.definition("miasma", "", data)
