-- lua/config/lazy.lua – Enhanced Lazy.nvim configuration with better plugin management
local M = {}

-- Helper for safe loads (avoid dependency on config.utils.safe_require)
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Warning] Could not load '%s'", mod), vim.log.levels.WARN)
    return nil
  end
  return m
end

function M.setup()
  -- Bootstrap Lazy.nvim if missing
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if vim.fn.isdirectory(lazypath) == 0 then
    vim.notify("Installing lazy.nvim plugin manager...", vim.log.levels.INFO)
    local result = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    })
    if vim.v.shell_error ~= 0 then
      vim.notify("Failed to install lazy.nvim: " .. result, vim.log.levels.ERROR)
      return
    end
  end
  vim.opt.rtp:prepend(lazypath)

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
      { import = "plugins" },
    },
    defaults = {
      lazy = true, -- Don't load plugins until needed
      version = false, -- Use latest plugin versions
    },
    install = {
      -- Set colorscheme with fallbacks
      colorscheme = {
        "gruvbox-material",
        "tokyonight",
        "nord",
        "habamax",
      },
      missing = true, -- Install missing plugins on startup
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
    -- Priority overrides for key plugins
    priorities = {
      -- Load UI elements early
      ["nvim-web-devicons"] = 100,
      ["plenary.nvim"] = 100,
      ["nui.nvim"] = 100,

      -- Theme plugins
      ["gruvbox-material"] = 90,
      ["tokyonight.nvim"] = 90,
      ["nord.nvim"] = 90,

      -- Core functionality plugins
      ["telescope.nvim"] = 80, -- Primary picker
      ["which-key.nvim"] = 80,
      ["oil.nvim"] = 80, -- Primary file explorer

      -- Stack-specific plugins
      ["go.nvim"] = 70,
      ["typescript-tools.nvim"] = 70,
    },
    -- Enhanced debugging for troubleshooting
    debug = false,
  })

  -- Set global picker preference
  vim.g.default_picker = "telescope" -- Prefer telescope over snacks

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
