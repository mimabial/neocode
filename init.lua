-- Set leader key early to ensure keymaps work correctly
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Default tool preferences
vim.g.default_explorer = "oil"      -- Reserved for future explorer switching logic
vim.g.default_picker = "telescope"  -- Used by plugins to determine picker preference

-- Disable legacy plugins
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bigfile detection: register before lazy bootstrap so the filetype matcher
-- catches files opened on startup (e.g. `nvim huge.log`).
pcall(function() require("lib.bigfile").setup() end)

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

-- Load and call .setup() on a module, reporting failures at the given level.
local function safe_setup(name, level)
  level = level or vim.log.levels.ERROR
  local ok, mod = pcall(require, name)
  if not ok then
    vim.notify("Failed to load " .. name .. ": " .. tostring(mod), level)
    return
  end
  if type(mod) == "table" and mod.setup then
    local setup_ok, err = pcall(mod.setup)
    if not setup_ok then
      vim.notify("Failed to setup " .. name .. ": " .. tostring(err), level)
    end
  end
end

-- Load core configuration (order matters)
for _, module in ipairs({
  "config.options",
  "config.ui",
  "config.terminal_sync",
  "config.lazy",
  "config.keymaps",
  "config.commands",
  "config.autocmds",
  "config.django",
}) do
  safe_setup(module)
end

-- Smart auto-close for special windows
safe_setup("lib.autoclose", vim.log.levels.WARN)

-- Load health check module (provides :ConfigHealth command)
pcall(require, "config.health")
