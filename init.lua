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
  vim.notify("Error: Neovim 0.8 or higher is required for this config.")
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

-- 3) Load core settings
local opts = safe_require("config.options")
if opts and type(opts.setup) == "function" then
  opts.setup()
end

-- 4) Initialize plugin manager (Lazy.nvim)
safe_require("config.lazy")
-- config.lazy handles bootstrap and setup

-- 5) Detect and configure tech stack
local stack = safe_require("config.stacks")
if stack and type(stack.setup) == "function" then
  stack.setup()
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

-- 9) Load stack-specific commands
local stack_cmds = safe_require("config.stack_commands")
if stack_cmds and type(stack_cmds.setup) == "function" then
  stack_cmds.setup()
end

-- 10) Load diagnostics
local diag = safe_require("config.diagnostics")
if diag and type(diag.setup) == "function" then
  diag.setup()
end

-- 11) Load LSP configuration
local lsp = safe_require("config.lsp")
if lsp and type(lsp.setup) == "function" then
  lsp.setup()
end

-- 12) Load utility modules
safe_require("utils.init")
safe_require("utils.format")
safe_require("utils.goth")
safe_require("utils.extras")
