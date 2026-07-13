-- catppuccin — frozen snapshot (no plugin dependency).
-- Data in definitions/data/catppuccin.lua by scripts/snapshot_theme.lua.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.catppuccin")
return snapshot.definition("catppuccin", "", data)
