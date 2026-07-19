-- dracula — frozen snapshot. Refresh: SNAPSHOT_SCHEME=dracula \
--   SNAPSHOT_VARIANTS="default" nvim --headless -c "luafile scripts/snapshot_theme.lua" -c "qa"
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.dracula")
return snapshot.definition("dracula", "", data)
