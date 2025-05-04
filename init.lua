-- init.lua - Improved error handling and diagnostics

-- Basic setup
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Default settings that won't break things
vim.g.default_explorer = "oil"

-- Version check
if vim.fn.has("nvim-0.8") == 0 then
  vim.notify("⚠️ Neovim 0.8+ required", vim.log.levels.ERROR)
  return
end

-- Improved safe_require with better diagnostics
local function safe_require(mod)
  local ok, result = pcall(require, mod)
  if not ok then
    vim.notify("[ERROR] Failed to load " .. mod .. ": " .. result, vim.log.levels.ERROR)
    return nil
  end
  return result
end

-- Enhanced module loading with proper error handling
local function load_module(name, setup_fn)
  local start_time = vim.loop.hrtime()
  vim.notify("Loading " .. name .. "...", vim.log.levels.DEBUG)

  local mod = safe_require(name)
  if not mod then
    return nil
  end

  -- Check if module has the setup function
  if type(mod) == "table" and type(mod[setup_fn]) == "function" then
    local ok, err = pcall(mod[setup_fn])
    if not ok then
      vim.notify("[ERROR] " .. name .. "." .. setup_fn .. "() failed: " .. tostring(err), vim.log.levels.ERROR)
      return nil
    end
  else
    if type(mod) ~= "table" then
      vim.notify("[WARNING] " .. name .. " is not a table", vim.log.levels.WARN)
    elseif type(mod[setup_fn]) ~= "function" then
      vim.notify("[WARNING] " .. name .. "." .. setup_fn .. "() not found", vim.log.levels.WARN)
    end
  end

  local duration = (vim.loop.hrtime() - start_time) / 1000000
  vim.notify(string.format("Loaded %s in %.2fms", name, duration), vim.log.levels.DEBUG)
  return mod
end

-- Load core options
load_module("config.options", "setup")

-- Bootstrap Lazy.nvim with error handling
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.fn.isdirectory(lazypath) == 0 then
  vim.notify("Installing lazy.nvim...", vim.log.levels.INFO)
  local ok, err = pcall(vim.fn.system, {
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if not ok then
    vim.notify("[ERROR] Failed to install lazy.nvim: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load lazy.nvim with error handling
local ok, _ = pcall(require, "lazy")
if not ok then
  vim.notify("[ERROR] Failed to load lazy.nvim", vim.log.levels.ERROR)
  return
end

-- Load configuration modules in order with proper error handling
load_module("config.lazy", "setup")
load_module("config.stacks", "setup")
load_module("config.keymaps", "setup")
load_module("config.autocmds", "setup")
load_module("config.commands", "setup")
load_module("config.lsp", "setup")

-- Set default colorscheme with error handling
if not vim.g.colors_name then
  local cs_ok, _ = pcall(vim.cmd, "colorscheme gruvbox-material")
  if not cs_ok then
    pcall(vim.cmd, "colorscheme default")
  end
end

-- Add a diagnostic command to help troubleshoot
vim.api.nvim_create_user_command("DiagnosticCheck", function()
  -- Check plugin status
  if package.loaded["lazy"] then
    local stats = require("lazy").stats()
    vim.notify(
      string.format("Plugins: %d/%d loaded in %.2fms", stats.loaded, stats.count, stats.startuptime),
      vim.log.levels.INFO
    )
  else
    vim.notify("Lazy.nvim not loaded", vim.log.levels.ERROR)
  end

  -- Check stack status
  vim.notify("Current stack: " .. (vim.g.current_stack or "not set"), vim.log.levels.INFO)

  -- Check key modules
  local modules = {
    "config.options",
    "config.lazy",
    "config.stacks",
    "config.keymaps",
    "config.autocmds",
    "config.lsp",
  }

  for _, mod in ipairs(modules) do
    if package.loaded[mod] then
      vim.notify(mod .. ": Loaded", vim.log.levels.INFO)
    else
      vim.notify(mod .. ": Not loaded", vim.log.levels.WARN)
    end
  end
end, { desc = "Check diagnostics for Neovim setup" })
