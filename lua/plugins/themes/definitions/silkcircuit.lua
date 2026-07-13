-- SilkCircuit — frozen snapshot (no plugin dependency).
-- Highlights captured in definitions/data/silkcircuit.lua by
-- scripts/snapshot_theme.lua. To refresh or add a variant, ensure the
-- silkcircuit plugin is installed and run:
--   SNAPSHOT_SCHEME=silkcircuit nvim --headless -c "luafile scripts/snapshot_theme.lua" -c "qa"
local snapshot = require("lib.snapshot")
local data = require("plugins.themes.definitions.data.silkcircuit")
return snapshot.definition("silkcircuit", "󰘚", data)
