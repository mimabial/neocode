-- lua/config/options.lua
-- Core editor options
---@diagnostic disable: missing-fields
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
opt.termguicolors = true -- Enable true color support
opt.background = "dark" -- Dark background

-- Ensure line numbers are globally enabled as defaults
vim.g.disable_relative_number = false

-- Scrolling
opt.scrolloff = 8 -- Keep 8 lines on screen when scrolling
opt.sidescrolloff = 8

-- Wrapping
opt.wrap = false -- Disable line wrap

-- Command line
opt.cmdheight = 1 -- Command line height
opt.showmode = false -- Don't show mode (handled by statusline)
opt.showcmd = false -- Don't show partial commands
opt.shortmess:remove("S") -- Allow `search_count()` in statusline

-- Indentation
opt.tabstop = 2 -- Number of spaces tabs count for
opt.shiftwidth = 2 -- Size of an indent
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Smart indenting
opt.breakindent = true -- Wrapped lines maintain indent

-- Search
opt.ignorecase = true -- Case-insensitive search
opt.smartcase = true -- Smart case
opt.hlsearch = true -- Highlight search results
opt.incsearch = true -- Incremental search

-- Files
opt.swapfile = false -- Don't use swapfile
opt.backup = false -- Don't create backup files
opt.undofile = true -- Save undo history
opt.confirm = true -- Confirm before exiting with unsaved changes
opt.autowrite = true -- Auto-save before running commands

-- Splits
opt.splitright = true -- Splits open to the right
opt.splitbelow = true -- Splits open below

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Invisible characters
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard

-- Folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.fillchars = { eob = " " } -- Hide end-of-buffer tildes

-- Statusline: append search count
opt.statusline:append(" %=%{v:lua.require'config.utils'.search_count()}")

return {} -- No module export needed
