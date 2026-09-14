-- Theme bootstrap: initialize the manager and apply the active live, snapshot,
-- or palette-driven definition. Loaded after config.lazy so live themes can
-- load their colorscheme plugin on demand.
local M = {}

function M.setup()
  local manager = require("lib.theme_manager")
  local themes = manager.load_themes()

  manager.register_commands(themes)
  manager.setup_focus_sync()
  vim.g.neocode_theme_sync = true

  if not manager.sync(true) then
    local settings = manager.load_settings()
    if settings.background then
      require("lib.background").set(settings.background)
    end
    manager.apply_theme(settings.theme, settings.variant, themes, {
      background = settings.background,
      transparency = settings.transparency,
    })
  end

end

return M
