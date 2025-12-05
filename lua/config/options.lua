---@diagnostic disable: missing-fields
local M = {}

function M.setup()
  local opt = vim.opt
  local g = vim.g
  local fn = vim.fn

  -- Basic UI
  opt.number = true -- Show absolute line numbers
  opt.relativenumber = true -- Show relative line numbers
  opt.numberwidth = 4 -- Set number column width to 2
  opt.cursorline = true -- Highlight current line
  opt.termguicolors = true -- True color support
  opt.background = "dark" -- Dark background
  opt.signcolumn = "yes:1" -- Always show sign column with fixed width
  opt.showtabline = 2 -- Show tab line if there are at least two tabs
  opt.laststatus = 3 -- Global statusline (single bar at bottom)
  opt.formatoptions:remove({ "c", "r", "o" }) -- Disable comment continuation
  opt.runtimepath:remove("/usr/share/vim/vimfiles") -- Separate Vim plugins from Neovim

  -- Scrolling
  opt.scrolloff = 4 -- Keep 4 lines visible when scrolling
  opt.sidescrolloff = 8 -- Keep 8 columns visible when scrolling horizontally

  -- Wrapping
  opt.wrap = false -- Display lines as one long line
  opt.linebreak = true -- Companion to wrap, don't split words
  opt.whichwrap = "bs<>[]hl" -- Which "horizontal" keys are allowed to wrap

  -- Command line behavior
  opt.cmdheight = 1 -- Command line height
  opt.showmode = false -- Mode handled by statusline
  opt.showcmd = false -- Don't show partial commands
  opt.shortmess:append("c") -- Don't show completion messages
  -- opt.shortmess:remove("S") -- Allow search count in statusline

  -- Indentation
  opt.expandtab = true -- Use spaces instead of tabs
  opt.shiftwidth = 2 -- Size of an indent
  opt.tabstop = 2 -- Number of spaces tabs count for
  opt.softtabstop = 2 -- Number of spaces tabs count for while editing
  opt.autoindent = true -- Copy indent from current line to new one
  opt.smartindent = true -- Smart indenting
  opt.breakindent = true -- Wrapped lines maintain indent

  -- Search settings
  opt.ignorecase = true -- Case-insensitive search
  opt.smartcase = true -- Smart case
  opt.hlsearch = true -- Highlight search results
  opt.incsearch = true -- Incremental search

  -- Winbar settings
  opt.winbar = "" -- Allow winbar to be set by plugins

  -- Performance tweaks
  opt.updatetime = 250 -- Faster completion
  opt.timeoutlen = 300 -- Faster timeout for mapped sequences

  -- Backup & Swap: keep crash recovery, but avoid slow disk writes

  opt.backup = true
  opt.writebackup = true
  -- enable traditional backups (e.g. file.txt~), but write them to a cache dir
  opt.backupdir = fn.stdpath("data") .. "/backup//"

  -- Keep swapfile for crash recovery in persistent storage
  opt.swapfile = true
  local swap_dir = fn.stdpath("data") .. "/swap//"
  if fn.isdirectory(fn.stdpath("data") .. "/swap") == 0 then
    fn.mkdir(fn.stdpath("data") .. "/swap", "p")
  end
  opt.directory = swap_dir

  -- Skip fsync() after write (speed) but keep the above safety nets
  opt.fsync = false

  -- Create backup directory if it doesn't exist
  if fn.isdirectory(fn.stdpath("data") .. "/backup") == 0 then
    fn.mkdir(fn.stdpath("data") .. "/backup", "p")
  end

  -- Persistent undo: keep undo history across sessions
  opt.undofile = true
  opt.undodir = fn.stdpath("data") .. "/undo//"
  opt.undolevels = 1000 -- plenty of undo steps
  opt.undoreload = 10000

  -- Create undo directory if it doesn't exist
  if fn.isdirectory(fn.stdpath("data") .. "/undo") == 0 then
    fn.mkdir(fn.stdpath("data") .. "/undo", "p")
  end

  -- ShaDa (shared data) for registers, marks, etc.:
  -- store everything—registers, marks, command history—in one file
  opt.shada = [[!,'100,<50,s10,h]]
  --   !   = save and load command-line history
  --   '100 = save up to 100 marks per file
  --   <50  = save up to 50 lines of registers
  --   s10  = max item size 10 KB
  --   h    = disable ‘hlsearch’ persistence

  -- Misc safety / UX
  opt.backupskip = { "/tmp/*", "/private/*" } -- skip noisy tmp files
  -- Session options (aligned with persistence.nvim)
  opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" }
  opt.confirm = true -- prompt rather than error on unsaved changes

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
end

return M
