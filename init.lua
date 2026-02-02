-- Set leader key early to ensure keymaps work correctly
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Default tool preferences
vim.g.default_explorer = "oil"      -- Reserved for future explorer switching logic
vim.g.default_picker = "telescope"  -- Used by plugins to determine picker preference

-- Disable legacy plugins
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Version check
if vim.fn.has("nvim-0.8") == 0 then
  error("Neovim 0.8+ required for this configuration")
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.fn.isdirectory(lazypath) == 0 then
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to install lazy.nvim: " .. result)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load core configuration (order matters)
local core_modules = {
  "config.options",
  "config.ui",
  "config.terminal_sync",
  "config.lazy",
  "config.keymaps",
  "config.commands",
  "config.autocmds",
  "config.django",
}

for _, module in ipairs(core_modules) do
  local ok, mod = pcall(require, module)
  if ok and type(mod) == "table" and mod.setup then
    local setup_ok, err = pcall(mod.setup)
    if not setup_ok then
      vim.notify("Failed to setup " .. module .. ": " .. tostring(err), vim.log.levels.ERROR)
    end
  elseif not ok then
    vim.notify("Failed to load " .. module .. ": " .. tostring(mod), vim.log.levels.ERROR)
  end
end

-- Setup smart auto-close for special windows
local autoclose_ok, autoclose = pcall(require, "lib.autoclose")
if autoclose_ok and autoclose.setup then
  local setup_ok, err = pcall(autoclose.setup)
  if not setup_ok then
    vim.notify("Failed to setup autoclose: " .. tostring(err), vim.log.levels.WARN)
  end
else
  vim.notify("Failed to load autoclose library", vim.log.levels.WARN)
end

-- Load health check module (provides :ConfigHealth command)
pcall(require, "config.health")
