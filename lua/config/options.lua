-- lua/config/options.lua
-- Core editor options structured as a setup function
---@diagnostic disable: missing-fields
local M = {}

--- Set Neovim core options and globals
function M.setup()
  local opt = vim.opt
  local g = vim.g

  -- Leader keys
  g.mapleader = " "
  g.maplocalleader = " "

  -- Basic UI
  opt.number = true -- Show absolute line numbers
  opt.relativenumber = true -- Show relative line numbers
  opt.cursorline = true -- Highlight current line
  opt.signcolumn = "yes" -- Always show sign column
  opt.termguicolors = true -- True color support
  opt.background = "dark" -- Dark background

  -- Control relative numbers via global flag
  g.disable_relative_number = false

  -- Scrolling
  opt.scrolloff = 8 -- Keep 8 lines visible when scrolling
  opt.sidescrolloff = 8

  -- Wrapping
  opt.wrap = false -- Disable line wrap

  -- Command line behavior
  opt.cmdheight = 1 -- Command line height
  opt.showmode = false -- Mode handled by statusline
  opt.showcmd = false -- Don't show partial commands
  opt.shortmess:remove("S") -- Allow search count in statusline

  -- Indentation
  opt.expandtab = true -- Use spaces instead of tabs
  opt.shiftwidth = 2 -- Size of an indent
  opt.tabstop = 2 -- Number of spaces tabs count for
  opt.smartindent = true -- Smart indenting
  opt.breakindent = true -- Wrapped lines maintain indent

  -- Search settings
  opt.ignorecase = true -- Case-insensitive search
  opt.smartcase = true -- Smart case
  opt.hlsearch = true -- Highlight search results
  opt.incsearch = true -- Incremental search

  -- File handling
  opt.swapfile = false -- Disable swapfile
  opt.backup = false -- Disable backups
  opt.undofile = true -- Persistent undo
  opt.confirm = true -- Confirm before exiting unsaved
  opt.autowrite = true -- Auto-save before commands

  -- Window splits
  opt.splitright = true -- Splits open to the right
  opt.splitbelow = true -- Splits open below

  -- Completion
  opt.completeopt = { "menu", "menuone", "noselect" }

  -- Invisibles
  opt.list = true
  opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

  -- Clipboard
  opt.clipboard = "unnamedplus" -- System clipboard

  -- Folding
  opt.foldmethod = "expr"
  opt.foldexpr = "nvim_treesitter#foldexpr()"
  opt.foldlevel = 99
  opt.foldlevelstart = 99
  opt.foldenable = true
  opt.fillchars = { eob = " " } -- Hide end-of-buffer tildes

  -- Statusline: append search count
  opt.statusline:append(" %=%{v:lua.require'config.utils'.search_count()}")
end

return M
