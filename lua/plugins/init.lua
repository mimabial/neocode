--------------------------------------------------------------------------------
-- Plugin Configuration
--------------------------------------------------------------------------------
--
-- This is the main entry point for plugin configurations.
-- It imports all plugin modules from their respective directories:
--
-- Structure:
-- 1. Core plugins that are always loaded
-- 2. Import modules from subdirectories:
--    - editor/: Navigation, text objects, etc.
--    - coding/: Completion, LSP, snippets, etc.
--    - langs/: Language-specific plugins
--    - tools/: Git, terminal, etc.
--    - ui/: Themes, statusline, etc.
--    - util/: Telescope, which-key, etc.
--
-- Each plugin is configured with lazy.nvim's declarative syntax.
-- For more info about lazy.nvim, see: https://github.com/folke/lazy.nvim
--------------------------------------------------------------------------------

return {
  -- Core plugins (always loaded)

  -- Package Manager (manages itself)
  {
    "folke/lazy.nvim",
    version = false, -- Using latest version
  },

  -- Icons (dependency for many plugins)
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    config = function()
      require("nvim-web-devicons").setup({
        override = {},  -- Used to override icons
        default = true, -- Use default icons for filetypes
      })
    end,
  },

  -- Plenary (dependency for many plugins)
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  -- Nui.nvim (UI components used by many plugins)
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },

  -- Import all plugin modules
  { import = "plugins.editor" }, -- Editor enhancements
  { import = "plugins.coding" }, -- Coding support (LSP, completion, etc.)
  { import = "plugins.lsp" },    -- LSP configuration
  { import = "plugins.langs" },  -- Language specific plugins
  { import = "plugins.tools" },  -- Development tools (git, terminal, etc.)
  { import = "plugins.ui" },     -- UI components
  { import = "plugins.util" },   -- Utilities (telescope, etc.)
}
