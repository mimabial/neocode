-- Set leader key early to ensure keymaps work correctly
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable default explorer
vim.g.default_explorer = "oil"
vim.g.default_picker = "telescope"

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
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to install lazy.nvim: " .. result)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load core configuration (order matters)
require("config.options").setup()
require("config.lazy").setup()
require("config.ui").setup()
require("config.keymaps").setup()
require("config.autocmds").setup()
require("config.commands").setup()

-- Load additional modules
require("autocmds.diagnostics").setup()
require("commands.lazy").setup()

-- Set colorscheme with fallback
-- if not pcall(vim.cmd.colorscheme, "kanagawa") then
--   vim.cmd.colorscheme("habamax")
-- end
