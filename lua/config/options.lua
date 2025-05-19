---@diagnostic disable: missing-fields
local M = {}

function M.setup()
  local opt = vim.opt
  local g = vim.g
  local fn = vim.fn
  -- Leader keys
  g.mapleader = " "
  g.maplocalleader = " "

  -- Basic UI
  opt.number = true         -- Show absolute line numbers
  opt.relativenumber = true -- Show relative line numbers
  opt.cursorline = true     -- Highlight current line
  opt.termguicolors = true  -- True color support
  opt.background = "dark"   -- Dark background
  opt.signcolumn = "yes:1"  -- Always show sign column with fixed width

  -- Scrolling
  opt.scrolloff = 8     -- Keep 8 lines visible when scrolling
  opt.sidescrolloff = 8 -- Keep 8 columns visible when scrolling horizontally

  -- Wrapping
  opt.wrap = false -- Disable line wrap

  -- Command line behavior
  opt.cmdheight = 1         -- Command line height
  opt.showmode = false      -- Mode handled by statusline
  opt.showcmd = false       -- Don't show partial commands
  opt.shortmess:append("c") -- Don't show completion messages
  opt.shortmess:remove("S") -- Allow search count in statusline

  -- Indentation
  opt.expandtab = true   -- Use spaces instead of tabs
  opt.shiftwidth = 2     -- Size of an indent
  opt.tabstop = 2        -- Number of spaces tabs count for
  opt.smartindent = true -- Smart indenting
  opt.breakindent = true -- Wrapped lines maintain indent

  -- Search settings
  opt.ignorecase = true -- Case-insensitive search
  opt.smartcase = true  -- Smart case
  opt.hlsearch = true   -- Highlight search results
  opt.incsearch = true  -- Incremental search

  -- Performance tweaks
  opt.lazyredraw = true -- Don't redraw when executing macros
  opt.updatetime = 300  -- Faster completion
  opt.timeoutlen = 200  -- Faster timeout for mapped sequences

  -- Backup & Swap: keep crash recovery, but avoid slow disk writes

  -- enable traditional backups (e.g. file.txt~), but write them to a cache dir
  opt.backup = true
  opt.writebackup = true
  opt.backupdir = fn.stdpath("data") .. "/backup//"
  -- keep a swapfile for crash recovery, but in RAM (tmpfs) if available
  opt.swapfile = true
  -- e.g. /dev/shm on Linux; adjust to a tmpfs path on your system
  opt.directory = "/dev/shm/nvim/swap//"
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
  opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
  opt.confirm = true                          -- prompt rather than error on unsaved changes

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
