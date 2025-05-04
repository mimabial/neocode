-- lua/config/lazy.lua – Enhanced error reporting for plugin loading

-- Helper for safe loads (avoid dependency on config.utils.safe_require)
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Lazy] Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

-- Bootstrap Lazy.nvim if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.fn.isdirectory(lazypath) == 0 then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Safely load Lazy
local lazy_ok, lazy = pcall(require, "lazy")
if not lazy_ok then
  vim.notify("[ERROR] Failed to load lazy.nvim: " .. lazy, vim.log.levels.ERROR)
  return
end

-- Setup Lazy with enhanced error reporting
lazy.setup({
  spec = {
    { import = "plugins" },
    -- Core dependencies with high priority to ensure they load first
    {
      "nvim-lua/plenary.nvim",
      lazy = false,
      priority = 1001,
    },
    {
      "kevinhwang91/promise-async",
      lazy = true,
      priority = 1000,
    },
    -- Core theme plugins with high priority
    { "sainnhe/gruvbox-material", lazy = false, priority = 999 },
    { "nvim-tree/nvim-web-devicons", lazy = false, priority = 950 },

    -- Stack-specific plugins with more robust conditional loading
    {
      import = "plugins.goth",
      cond = function()
        return not vim.g.current_stack or vim.g.current_stack == "goth" or vim.g.current_stack == "goth+nextjs"
      end,
    },
    {
      import = "plugins.nextjs",
      cond = function()
        return not vim.g.current_stack or vim.g.current_stack == "nextjs" or vim.g.current_stack == "goth+nextjs"
      end,
    },
  },
  defaults = { lazy = true, version = false },
  install = {
    colorscheme = { "gruvbox-material" },
    missing = true,
  },
  checker = { enabled = false }, -- Disable checker for stability
  performance = {
    rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
    cache = { enabled = true },
    reset_packpath = true,
    reset_rtp = false,
  },
  -- Enable logging and debugging
  debug = true,
})

-- Stack focusing command with improved error handling
vim.api.nvim_create_user_command("StackFocus", function(opts)
  local stack_module = safe_require("config.stacks")
  if stack_module then
    local ok, err = pcall(stack_module.configure_stack, opts.args)
    if not ok then
      vim.notify("[ERROR] Failed to configure stack: " .. err, vim.log.levels.ERROR)
    end
  else
    vim.notify("[ERROR] Stack module not available", vim.log.levels.ERROR)
  end
end, {
  nargs = "?",
  desc = "Focus on a specific tech stack",
  complete = function()
    return { "goth", "nextjs", "both" }
  end,
})

-- Plugin diagnosis command
vim.api.nvim_create_user_command("PluginCheck", function()
  local stats = lazy.stats()
  local loaded = stats.loaded
  local count = stats.count

  vim.notify(string.format("Plugins: %d/%d loaded", loaded, count), vim.log.levels.INFO)

  -- Show specific plugin errors
  local plugins = require("lazy.core.config").plugins
  local errors = {}

  for name, plugin in pairs(plugins) do
    if plugin._ and plugin._.loaded == false and plugin._.err then
      table.insert(errors, { name = name, error = plugin._.err })
    end
  end

  if #errors > 0 then
    vim.notify("Plugins with errors:", vim.log.levels.ERROR)
    for _, err in ipairs(errors) do
      vim.notify(err.name .. ": " .. err.error, vim.log.levels.ERROR)
    end
  end
end, { desc = "Check plugin status and errors" })
