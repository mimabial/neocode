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

-- 3) Load lazy.nvim via config.lazy instead of bootstrapping twice
local lazy_ok = safe_require("config.lazy")
if not lazy_ok then
  vim.notify("Failed to load lazy.nvim. Some features may not work.", vim.log.levels.ERROR)
end

-- 4) Load core settings
local opts = safe_require("config.options")
if opts and type(opts.setup) == "function" then
  opts.setup()
end

-- 5) Initialize Lazy and load plugins
local lazy = safe_require("lazy")
if lazy then
  lazy.setup("plugins", {
    lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
    defaults = { lazy = true, version = false },
  })
end

-- 6) Load key mappings
local keys = safe_require("config.keymaps")
if keys and type(keys.setup) == "function" then
  keys.setup()
end

-- 7) Load autocommands
local autocmds = safe_require("config.autocmds")
if autocmds and type(autocmds.setup) == "function" then
  autocmds.setup()
end

-- 8) Load custom commands
local cmds = safe_require("config.commands")
if cmds and type(cmds.setup) == "function" then
  cmds.setup()
end

-- 9) Load diagnostics
local diag = safe_require("config.diagnostics")
if diag and type(diag.setup) == "function" then
  diag.setup()
end

-- 10) Load LSP
local lsp = safe_require("config.lsp")
if lsp and type(lsp.setup) == "function" then
  lsp.setup()
end

safe_require("utils.extras")
safe_require("utils.format")
safe_require("utils.goth")
safe_require("utils.utils")

-- End of init.lua
