-- Theme bootstrap: initialize the theme manager and apply the active theme at
-- startup. Decoupled from any colorscheme plugin so themes are snapshot-driven
-- and no plugin needs to load eagerly just to host this. Loaded from init.lua
-- right after config.lazy (so lazy.load is available for any plugin-backed theme).
local M = {}

function M.setup()
  local manager = require("lib.theme_manager")
  local themes = manager.load_themes()

  manager.register_commands(themes)

  if not manager.apply_system_theme(themes) then
    local settings = manager.load_settings()
    if settings.background then
      vim.o.background = settings.background
    end
    manager.apply_theme(settings.theme, settings.variant, themes, {
      background = settings.background,
      transparency = settings.transparency,
    })
  end

  manager.setup_focus_sync(themes)
end

return M
