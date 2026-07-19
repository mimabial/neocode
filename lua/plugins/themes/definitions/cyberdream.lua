-- cyberdream — frozen snapshot. Refresh: SNAPSHOT_SCHEME=cyberdream \
--   SNAPSHOT_VARIANTS="default light" nvim --headless -c "luafile scripts/snapshot_theme.lua" -c "qa"
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.cyberdream")
return snapshot.definition("cyberdream", "", data)
