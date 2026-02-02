local M = {}

function M.setup()
  -- Note: Bootstrap is handled in init.lua to ensure lazy.nvim is available early

  -- Load Lazy with error handling
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then
    vim.notify("Failed to load lazy.nvim. Check installation.", vim.log.levels.ERROR)
    return
  end

  -- Configure Lazy with improved setup
  lazy.setup({
    spec = {
      -- Import all plugin specs from the plugins directory
      { import = "plugins.ai" },
      { import = "plugins.coding" },
      { import = "plugins.debug" },
      { import = "plugins.editor" },
      { import = "plugins.git" },
      { import = "plugins.lsp" },
      { import = "plugins.search" },
      { import = "plugins.themes" },
      { import = "plugins.ui" },
    },
    defaults = {
      lazy = true, -- Don't load plugins until needed
      version = false, -- Use latest plugin versions
    },
    install = {
      -- Set colorscheme with fallbacks
      colorscheme = {
        "kanagawa",
      },
      missing = true, -- Install missing plugins on startup
    },
    pkg = {
      enabled = false,
    },
    checker = {
      enabled = true, -- Check for plugin updates
      notify = false, -- Don't notify about updates
      frequency = 3600, -- Check hourly for updates
    },
    change_detection = {
      enabled = true, -- Auto-reload when plugins change
      notify = false, -- Don't notify about changes
    },
    ui = {
      border = "single", -- Consistent border style
      size = { width = 0.8, height = 0.8 },
      icons = {
        cmd = " ",
        config = " ",
        event = " ",
        ft = " ",
        init = " ",
        keys = " ",
        plugin = " ",
        runtime = " ",
        source = " ",
        start = " ",
        task = " ",
      },
    },
    performance = {
      -- Disable unnecessary plugins
      rtp = {
        disabled_plugins = {
          "gzip",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
      -- Enable caching for faster startup
      cache = {
        enabled = true,
      },
      reset_packpath = true,
      reset_rtp = false,
    },
    -- Enhanced debugging for troubleshooting
    debug = false,
  })

  -- Note: default_picker is set in init.lua

  -- Register helper command to reload plugins
  vim.api.nvim_create_user_command("PluginSync", function()
    -- Clear module cache for plugins
    for name, _ in pairs(package.loaded) do
      if name:match("^plugins%.") then
        package.loaded[name] = nil
      end
    end

    -- Update and sync
    vim.cmd("Lazy sync")

    -- Notify completion
    vim.notify("Plugins synchronized", vim.log.levels.INFO)
  end, { desc = "Synchronize plugins and reload configurations" })
end

return M
