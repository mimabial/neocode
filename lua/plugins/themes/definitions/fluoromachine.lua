-- fluoromachine — frozen snapshot. Refresh: SNAPSHOT_SCHEME=fluoromachine \
--   SNAPSHOT_VARIANTS="default glow" nvim --headless -c "luafile scripts/snapshot_theme.lua" -c "qa"
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.fluoromachine")
return snapshot.definition("fluoromachine", "", data)
