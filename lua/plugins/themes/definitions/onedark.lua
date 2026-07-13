-- Onedark — frozen snapshot (dark style, no plugin dependency).
-- Data captured in definitions/data/onedark.lua by scripts/snapshot_theme.lua.
-- Refresh/add a style: ensure onedark.nvim is installed, then
--   SNAPSHOT_SCHEME=onedark SNAPSHOT_VARIANTS="dark" \
--     nvim --headless -c "luafile scripts/snapshot_theme.lua" -c "qa"
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.onedark")
return snapshot.definition("onedark", "", data)
