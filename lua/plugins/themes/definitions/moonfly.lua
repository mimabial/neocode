-- moonfly — frozen snapshot (no plugin dependency).
-- Data in definitions/data/moonfly.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.moonfly")
return snapshot.definition("moonfly", "", data)
