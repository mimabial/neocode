-- Colorscheme Plugin Configuration
-- Theme definitions are in themes/definitions/
-- Theme management logic is in themes/manager.lua

return {
  -- Primary theme - Kanagawa (loaded eagerly)
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local manager = require("lib.theme_manager")
      local themes = manager.load_themes()

      -- Register commands
      manager.register_commands(themes)

      -- Apply theme once: try system theme, fallback to saved theme
      -- Kanagawa is loaded first (priority=1000, lazy=false), so it's available immediately
      if not manager.apply_system_theme(themes) then
        local settings = manager.load_settings()
        manager.apply_theme(settings.theme, settings.variant, settings.transparency, themes)
      end

      -- Setup focus-based theme sync (checks when you alt-tab back to Neovim)
      manager.setup_focus_sync(themes)
    end,
  },

  -- Additional themes (lazy loaded)
  { "ficcdaf/ashen.nvim", lazy = true, priority = 950 },
  { "Shatur/neovim-ayu", lazy = true, priority = 950 },
  { "ribru17/bamboo.nvim", lazy = true, priority = 950 },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, priority = 950 },
  { "aliqyan-21/darkvoid.nvim", lazy = true, priority = 950 },
  { "decaycs/decay.nvim", lazy = true, priority = 950 },
  { "sainnhe/everforest", lazy = true, priority = 950 },
  { "ellisonleao/gruvbox.nvim", lazy = true, priority = 950 },
  { "sainnhe/gruvbox-material", lazy = true, priority = 950 },
  { "loctvl842/monokai-pro.nvim", lazy = true, priority = 950 },
  { "shaunsingh/nord.nvim", lazy = true, priority = 950 },
  { "navarasu/onedark.nvim", lazy = true, priority = 950 },
  { "nyoom-engineering/oxocarbon.nvim", lazy = true, priority = 950 },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, priority = 950 },
  { "maxmx03/solarized.nvim", lazy = true, priority = 950 },
  { "jpwol/thorn.nvim", lazy = true, priority = 950 },
  { "folke/tokyonight.nvim", lazy = true, priority = 950 },
}
