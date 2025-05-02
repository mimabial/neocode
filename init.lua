-- init.lua – Neovim entrypoint with robust module loading and correct load order

-- 0) Leader & feature flags
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.default_explorer = "oil"
vim.g.default_picker = "snacks"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 1) Version check
if vim.fn.has("nvim-0.8") == 0 then
  vim.api.nvim_err_writeln("Error: Neovim 0.8 or higher is required for this config.")
  return
end

-- 2) Helper for safe loads
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Warning] Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

-- 3) Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- 4) Load core settings
local opts = safe_require("config.options")
if opts and type(opts.setup) == "function" then
  opts.setup()
end

-- 5) Initialize Lazy and load plugins
local lazy = safe_require("lazy")
if lazy then
  lazy.setup({
    spec = {
      { import = "plugins" },
      { "sainnhe/gruvbox-material", lazy = false, priority = 1000 },
      { "nvim-tree/nvim-web-devicons", lazy = false, priority = 950 },
      { "rcarriga/nvim-notify", lazy = false, priority = 940 },
      { "stevearc/oil.nvim", lazy = false, priority = 850 },
      { "folke/which-key.nvim", event = "VeryLazy", priority = 820 },
      { "folke/snacks.nvim", event = "VeryLazy", priority = 800 },
      -- Load GOTH when that stack is active or no stack is specified
      {
        import = "plugins.goth",
        cond = function()
          return vim.g.current_stack ~= "nextjs"
        end,
      },
      -- Load Next.js when that stack is active or no stack is specified
      {
        import = "plugins.nextjs",
        cond = function()
          return vim.g.current_stack ~= "goth"
        end,
      },
    },
    defaults = { lazy = true, version = false },
    install = { colorscheme = { "gruvbox-material", "tokyonight" }, missing = true },
    ui = {
      border = "rounded",
      size = { width = 0.8, height = 0.8 },
      icons = { loaded = "●", not_loaded = "○", lazy = "󰒲 " },
    },
    checker = { enabled = true, notify = false, frequency = 3600 },
    performance = {
      rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
      cache = { enabled = true },
      reset_packpath = true,
    },
  })
end

-- 6) Detect and configure stack
local stack = safe_require("config.stack")
if stack and type(stack.setup) == "function" then
  stack.setup()
end

-- 7) Load key mappings
local keys = safe_require("config.keymaps")
if keys and type(keys.setup) == "function" then
  keys.setup()
end

-- 8) Load autocommands
local autocmds = safe_require("config.autocmds")
if autocmds and type(autocmds.setup) == "function" then
  autocmds.setup()
end

-- 9) Load custom commands
local cmds = safe_require("config.commands")
if cmds and type(cmds.setup) == "function" then
  cmds.setup()
end

-- 10) Load stack-specific commands
local stack_cmds = safe_require("config.stack_commands")
if stack_cmds and type(stack_cmds.setup) == "function" then
  stack_cmds.setup()
end

-- 11) Load diagnostics
local diag = safe_require("config.diagnostics")
if diag and type(diag.setup) == "function" then
  diag.setup()
end

-- 12) Load LSP configuration
local lsp = safe_require("config.lsp")
if lsp and type(lsp.setup) == "function" then
  lsp.setup()
end

-- 13) Load which-key
local which_key = safe_require("config.which-key")
if which_key and type(which_key.setup) == "function" then
  which_key.setup()
end

-- 14) Load utilities
safe_require("utils.utils")
safe_require("utils.format")
safe_require("utils.goth")
safe_require("utils.extras")
