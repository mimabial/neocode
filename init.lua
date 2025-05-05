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

load_module("config.options", "setup")
load_module("config.autocmds", "setup")
load_module("config.keymaps", "setup")

load_module("config.stacks", "setup")
load_module("config.commands", "setup")
load_module("config.diagnostics", "setup")
load_module("config.lsp", "setup")

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
local lazy_ok, _ = pcall(require, "lazy")
if not lazy_ok then
  vim.notify("❌ Failed to load lazy.nvim", vim.log.levels.ERROR)
  return
end

-- Load plugin configuration
load_module("config.lazy", "setup")

-- Set default colorscheme if not already set
if not vim.g.colors_name then
  pcall(vim.api.nvim_command, "colorscheme gruvbox-material")
end
