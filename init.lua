-- init.lua – Neovim entrypoint with robust module loading, error handling, and stack detection

-- 0) Leader & feature flags
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.default_explorer = "oil"
vim.g.default_picker = "snacks"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 1) Version check
if vim.fn.has("nvim-0.8") == 0 then
  vim.notify("⚠️ Neovim 0.8 or higher is required for this configuration.", vim.log.levels.ERROR)
  return
end

-- 2) Helper for safe module loading with error handling
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("⚠️ Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

-- 3) Load core settings with error handling
local function load_module(name, setup_fn)
  local mod = safe_require(name)
  if mod and type(mod[setup_fn]) == "function" then
    local ok, err = pcall(mod[setup_fn])
    if not ok then
      vim.notify(string.format("❌ Failed to run %s.%s: %s", name, setup_fn, err), vim.log.levels.ERROR)
    end
    return mod
  end
  return nil
end

-- Apply core options
load_module("config.options", "setup")

-- 4) Initialize plugin manager (Lazy.nvim)
-- Bootstrap Lazy.nvim if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.fn.isdirectory(lazypath) == 0 then
  vim.notify("📦 Installing lazy.nvim...", vim.log.levels.INFO)
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  vim.notify("✅ lazy.nvim installed successfully", vim.log.levels.INFO)
end
vim.opt.rtp:prepend(lazypath)

-- Load lazy
local lazy_ok, lazy = pcall(require, "lazy")
if not lazy_ok then
  vim.notify("❌ Failed to load lazy.nvim", vim.log.levels.ERROR)
  return
end

-- Lazy.nvim setup
lazy.setup({
  spec = {
    { import = "plugins" },
    -- Core theme plugins with high priority
    { "sainnhe/gruvbox-material", lazy = false, priority = 1000 },
    { "sainnhe/everforest", lazy = true, priority = 950 },
    { "rebelot/kanagawa.nvim", lazy = true, priority = 950 },

    -- Core UI components
    { "nvim-tree/nvim-web-devicons", lazy = false, priority = 900 },
    { "rcarriga/nvim-notify", lazy = false, priority = 890 },
    { "stevearc/oil.nvim", lazy = false, priority = 880 },
    { "folke/which-key.nvim", event = "VeryLazy", priority = 870 },
    { "folke/snacks.nvim", event = "VeryLazy", priority = 860 },

    -- AI integration
    {
      "zbirenbaum/copilot.lua",
      event = "InsertEnter",
      dependencies = { "zbirenbaum/copilot-cmp" },
      priority = 800,
    },
    {
      "Exafunction/codeium.nvim",
      event = "InsertEnter",
      dependencies = { "nvim-lua/plenary.nvim" },
      priority = 790,
    },

    -- Stack-specific plugins with conditional loading
    {
      import = "plugins.goth",
      cond = function()
        return vim.g.current_stack ~= "nextjs"
      end,
    },
    {
      import = "plugins.nextjs",
      cond = function()
        return vim.g.current_stack ~= "goth"
      end,
    },
  },
  defaults = { lazy = true, version = false },
  install = {
    colorscheme = { "gruvbox-material", "everforest", "kanagawa" },
    missing = true,
  },
  ui = {
    border = "rounded",
    size = { width = 0.8, height = 0.8 },
    icons = {
      loaded = "●",
      not_loaded = "○",
      lazy = "󰒲 ",
      cmd = " ",
      config = "",
      event = "",
      ft = " ",
      init = " ",
      keys = " ",
      plugin = " ",
      runtime = " ",
      require = "󰢱 ",
      source = " ",
      start = "",
      task = "✓",
      list = {
        "●",
        "➜",
        "★",
        "‒",
      },
    },
  },
  checker = { enabled = true, notify = false, frequency = 3600 },
  change_detection = { enabled = true, notify = false },
  performance = {
    rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
    cache = { enabled = true },
    reset_packpath = true,
    reset_rtp = false,
  },
  -- Enhanced debugging for troubleshooting
  debug = false,
})

-- Load ui configuration
load_module("config.ui", "setup")

-- Detect and configure tech stack (Must run before any other modules that depend on stack)
load_module("config.stacks", "setup")

-- Load stack-specific commands
load_module("config.stack_commands", "setup")

-- Load key mappings
load_module("config.keymaps", "setup")

-- Load autocommands
load_module("config.autocmds", "setup")

-- Load custom commands
load_module("config.commands", "setup")

-- Load diagnostics
load_module("config.diagnostics", "setup")

-- Load LSP configuration
load_module("config.lsp", "setup")

-- Set default colorscheme if not already set

if not vim.g.colors_name then
  pcall(vim.api.nvim_command, "colorscheme gruvbox-material")
end

-- 13) Print startup success message
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    local lazy_stats = require("lazy").stats()
    local ms = math.floor(lazy_stats.startuptime * 100 + 0.5) / 100
    local v = vim.version()

    local stack_icon = ""
    if vim.g.current_stack == "goth" then
      stack_icon = "󰟓 "
    elseif vim.g.current_stack == "nextjs" then
      stack_icon = " "
    elseif vim.g.current_stack == "goth+nextjs" then
      stack_icon = "󰡄 "
    end

    local msg = string.format(
      "⚡ Neovim v%d.%d.%d loaded %d/%d plugins in %.2fms %s",
      v.major,
      v.minor,
      v.patch,
      lazy_stats.loaded,
      lazy_stats.count,
      ms,
      stack_icon
    )
    vim.notify(msg, vim.log.levels.INFO, { title = "Neovim Started" })

    -- Open dashboard if enabled
    if package.loaded["snacks.dashboard"] and vim.fn.argc() == 0 then
      vim.cmd("Dashboard")
    end
  end,
})

-- 14) Try to load project-specific configuration if it exists
local project_init = vim.fn.getcwd() .. "/.nvim/init.lua"
if vim.fn.filereadable(project_init) == 1 then
  vim.notify("📝 Loading project-specific configuration", vim.log.levels.INFO)
  local ok, err = pcall(dofile, project_init)
  if not ok then
    vim.notify("❌ Error in project config: " .. err, vim.log.levels.ERROR)
  end
end
