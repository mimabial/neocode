-- Set leader key early to ensure keymaps work correctly
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable default explorer
vim.g.default_explorer = "oil" -- Options: "oil", "nvim-tree", or "netrw"
vim.g.default_picker = "telescope" -- Prefer telescope over snacks

-- Disable legacy plugins
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Version check with clear error message
if vim.fn.has("nvim-0.8") == 0 then
  vim.notify("⚠️ Neovim 0.8 or higher is required for this configuration.", vim.log.levels.ERROR)
  return
end

-- Enhanced module loading with useful error messages
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    local err_msg = tostring(m):gsub("module '.*' not found:", "Module not found:")
    vim.notify(string.format("⚠️ Could not load '%s': %s", mod, err_msg), vim.log.levels.WARN)
    return nil
  end
  return m
end

-- Robust module loading with optional fallbacks
local function load_module(name, setup_fn, fallback_fn)
  local mod = safe_require(name)
  if mod and type(mod[setup_fn]) == "function" then
    local ok, err = pcall(mod[setup_fn])
    if not ok then
      vim.notify(string.format("❌ Failed to run %s.%s: %s", name, setup_fn, err), vim.log.levels.ERROR)
      -- Try fallback if provided
      if fallback_fn and type(fallback_fn) == "function" then
        fallback_fn()
      end
    end
    return mod
  end
  -- Try fallback if provided
  if fallback_fn and type(fallback_fn) == "function" then
    fallback_fn()
  end
  return nil
end

-- Core system settings that should be loaded first
load_module("config.options", "setup")

-- Bootstrap and load Lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.fn.isdirectory(lazypath) == 0 then
  -- Attempt to install lazy.nvim if missing
  vim.notify("Installing lazy.nvim plugin manager...", vim.log.levels.INFO)
  local success = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  -- Check if installation succeeded
  if vim.v.shell_error ~= 0 then
    vim.notify(
      "Failed to install lazy.nvim. Check your internet connection and git installation.",
      vim.log.levels.ERROR
    )
    -- Continue anyway to allow basic editor functionality
  else
    vim.notify("lazy.nvim installed successfully", vim.log.levels.INFO)
  end
end

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- Load plugin system with error handling
load_module("config.lazy", "setup")

-- Load UI before keymaps so colors are set
load_module("config.ui", "setup")

-- Load keymaps - critical for usability
load_module("config.keymaps", "setup")

-- Load additional modules that enhance functionality
load_module("config.autocmds", "setup")
load_module("autocmds.diagnostics", "setup")

-- Load commands
load_module("config.commands", "setup")
load_module("commands.lazy", "setup")

-- Utilities and specialized features
load_module("utils.core", "setup")

-- Stack detection and configuration - should be loaded last
load_module("utils.stacks", "setup")

-- Set default colorscheme with error handling
if not vim.g.colors_name then
  local colorscheme_ok, _ = pcall(vim.api.nvim_command, "colorscheme gruvbox-material")
  if not colorscheme_ok then
    -- Try alternate colorschemes if the primary one fails
    for _, scheme in ipairs({ "tokyonight", "nord", "habamax", "desert" }) do
      local ok, _ = pcall(vim.api.nvim_command, "colorscheme " .. scheme)
      if ok then
        break
      end
    end
  end
end

-- Open alpha dashboard if available
if vim.fn.argc() == 0 then
  vim.defer_fn(function()
    -- Only open Alpha if we're still in the startup buffer
    local current_buf = vim.api.nvim_get_current_buf()
    local current_buftype = vim.bo[current_buf].buftype
    local current_name = vim.api.nvim_buf_get_name(current_buf)
    if package.loaded["alpha"] and current_name == "" and current_buftype == "" then
      vim.cmd("Alpha")
    end
  end, 100)
end
