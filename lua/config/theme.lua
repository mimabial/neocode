-- Theme bootstrap: initialize the manager and apply the active live, snapshot,
-- or palette-driven definition. Loaded after config.lazy so live themes can
-- load their colorscheme plugin on demand.
local M = {}

function M.setup()
  local manager = require("lib.theme_manager")
  manager.load_catalog()

  manager.register_commands()
  manager.setup_focus_sync()
  vim.g.neocode_theme_sync = true

  if not manager.sync(true) then
    local settings = manager.load_settings()
    if settings.background then
      require("lib.background").set(settings.background)
    end
    manager.apply_theme(settings.theme, settings.variant, {
      background = settings.background,
      transparency = settings.transparency,
    })
  end

end

return M
