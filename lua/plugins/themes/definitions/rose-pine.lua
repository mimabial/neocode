-- Rosé Pine — frozen snapshot (no plugin dependency).
-- Data in definitions/data/rose-pine.lua by scripts/snapshot_theme.lua.
-- main = dark, moon dropped (not snapshotted), dawn = light.
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.rose-pine")
return snapshot.definition("rose-pine", "", data)
