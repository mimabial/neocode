--------------------------------------------------------------------------------
-- Neovim Options
--------------------------------------------------------------------------------
--
-- This file configures core Neovim options for a better editing experience.
--
-- Options are organized by functionality:
-- 1. UI and appearance
-- 2. Editor behavior
-- 3. Search and completion
-- 4. Indentation and formatting
-- 5. File handling
-- 6. Performance
-- 7. Miscellaneous
--
-- Most settings use vim.opt to change options.
--------------------------------------------------------------------------------

-- Local helper function for setting options
local opt = vim.opt

--------------------------------------------------------------------------------
-- UI and Appearance
--------------------------------------------------------------------------------

-- Line numbers
opt.number = true -- Show line numbers
opt.relativenumber = true -- Use relative line numbers
opt.numberwidth = 4 -- Width of line number column
opt.signcolumn = "yes" -- Always show the sign column

-- Visual elements
opt.termguicolors = true -- Use GUI colors in terminal
opt.cursorline = true -- Highlight current line
opt.showmode = false -- Don't show mode in command line (statusline shows it)
opt.showcmd = true -- Show command in status line
opt.cmdheight = 1 -- Height of command line
opt.laststatus = 3 -- Global statusline
opt.title = true -- Set window title
opt.titlestring = "%<%F%=%l/%L - NeoCode" -- Title format

-- Window splitting
opt.splitbelow = true -- New horizontal splits below
opt.splitright = true -- New vertical splits to the right
opt.equalalways = false -- Don't resize windows on split/close

-- Scroll and view
opt.scrolloff = 8 -- Minimum lines to keep above/below cursor
opt.sidescrolloff = 8 -- Minimum columns to keep left/right of cursor
opt.wrap = false -- Don't wrap long lines
opt.linebreak = true -- Break lines at word boundaries
opt.breakindent = true -- Preserve indentation in wrapped text
opt.display:append("lastline") -- Show as much as possible of the last line

-- Visual whitespace
opt.list = true -- Show invisible characters
opt.listchars = {
	tab = "→ ",
	lead = "·",
	trail = "·",
	extends = "⟩",
	precedes = "⟨",
	nbsp = "␣",
}

-- Interface behavior
opt.mouse = "a" -- Enable mouse in all modes
opt.mousemoveevent = true -- Enable mouse movement events
opt.pumheight = 10 -- Maximum height of popup menu
opt.pumblend = 10 -- Transparency of popup menu
opt.winblend = 10 -- Transparency of floating windows

-- Appearance tweaks
opt.fillchars:append({
	horiz = "━",
	horizup = "┻",
	horizdown = "┳",
	vert = "┃",
	vertleft = "┫",
	vertright = "┣",
	verthoriz = "╋",
	eob = " ", -- Empty line at end of buffer
})

--------------------------------------------------------------------------------
-- Editor Behavior
--------------------------------------------------------------------------------

-- Timing
opt.updatetime = 300 -- Faster updates (CursorHold)
opt.timeout = true -- Enable timeout for mappings
opt.timeoutlen = 500 -- Timeout length in ms
opt.ttimeout = true -- Terminal key code timeout
opt.ttimeoutlen = 10 -- Terminal timeout length

-- Editing
opt.undofile = true -- Persistent undo history
opt.undolevels = 10000 -- Maximum number of undo changes
opt.virtualedit = "block" -- Allow cursor beyond end of line in visual block
opt.backspace = "indent,eol,start" -- Backspace behavior
opt.completeopt = "menu,menuone,noselect" -- Completion options
opt.conceallevel = 0 -- No concealing by default

-- Clipboard
-- opt.clipboard = "unnamedplus" -- Use system clipboard

-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard

-- Command line
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.wildignorecase = true -- Ignore case in command completion
opt.history = 1000 -- Command history size

--------------------------------------------------------------------------------
-- Search and Completion
--------------------------------------------------------------------------------

-- Search behavior
opt.hlsearch = true -- Highlight search results
opt.incsearch = true -- Incremental search
opt.ignorecase = true -- Case insensitive search
opt.smartcase = true -- Smart case search (override ignorecase)

-- Pattern matching
opt.magic = true -- Use 'magic' patterns (extended regular expressions)
opt.gdefault = true -- Substitute all matches in a line by default
opt.inccommand = "split" -- Show preview of substitution

--------------------------------------------------------------------------------
-- Indentation and Formatting
--------------------------------------------------------------------------------

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.smarttab = true -- Insert tabs according to shiftwidth
opt.tabstop = 2 -- Width of a tab character
opt.softtabstop = 2 -- Number of spaces for a tab
opt.shiftwidth = 2 -- Width of an indent
opt.autoindent = true -- Copy indent from current line
opt.smartindent = true -- Auto-indent new lines

-- Formatting
opt.formatoptions = "jcroqlnt" -- Automatic formatting options
opt.textwidth = 0 -- No hard text wrapping
opt.joinspaces = false -- No double spaces after punctuation on join

-- Folding
opt.foldenable = false -- Disable folding on startup
opt.foldlevelstart = 99 -- Start with all folds open
opt.foldmethod = "expr" -- Use expression for folding
opt.foldexpr = "nvim_treesitter#foldexpr()" -- Use treesitter for folding

--------------------------------------------------------------------------------
-- File Handling
--------------------------------------------------------------------------------

-- File operations
opt.autoread = true -- Auto-reload changed files
opt.autowrite = true -- Auto-save before commands
opt.confirm = true -- Confirm before operations
opt.fileformats = "unix,dos,mac" -- File format preference

-- Backup and swap
opt.backup = false -- No backup files
opt.writebackup = false -- No backup while editing
opt.swapfile = false -- No swap files
opt.undofile = true -- Persistent undo history
opt.undodir = vim.fn.stdpath("data") .. "/undo" -- Undo directory

-- Session and view
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize"
opt.viewoptions = "folds,cursor,curdir,slash,unix"

--------------------------------------------------------------------------------
-- Performance
--------------------------------------------------------------------------------

-- Redraw and rendering
opt.lazyredraw = true -- Don't redraw while executing macros
opt.redrawtime = 1500 -- Time limit for highlighting in ms
opt.ttyfast = true -- Faster terminal connection

-- Buffer management
opt.hidden = true -- Allow switching from unsaved buffers

-- Syntax and highlighting
opt.synmaxcol = 240 -- Max column for syntax highlighting
opt.regexpengine = 0 -- Automatically select regex engine

-- Memory usage
opt.maxmempattern = 2000 -- Maximum memory for pattern matching

--------------------------------------------------------------------------------
-- Miscellaneous
--------------------------------------------------------------------------------

-- Neovim specific
opt.shortmess:append("c") -- Don't show completion messages
opt.shortmess:append("I") -- Don't show intro message
opt.shortmess:append("W") -- Don't show "written" message
opt.shortmess:append("A") -- Don't show "ATTENTION" message
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Error bells
opt.errorbells = false -- No error bells
opt.visualbell = false -- No visual bell

-- Directories
opt.directory = vim.fn.stdpath("data") .. "/swap"
vim.fn.mkdir(vim.fn.stdpath("data") .. "/swap", "p")

-- Spelling
opt.spell = false -- Disable spell checking by default
opt.spelllang = "en_us" -- Default language for spell checking

-- Debug
if vim.fn.has("nvim-0.9.0") == 1 then
	opt.splitkeep = "screen" -- Keep cursor position on split
end

--------------------------------------------------------------------------------
-- Global Variables
--------------------------------------------------------------------------------

-- Disable unused built-in plugins
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Language providers
vim.g.loaded_python_provider = 0 -- Disable Python 2 provider
vim.g.python3_host_prog = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python3"

-- Other settings
vim.g.mapleader = " " -- Set leader key to space
vim.g.maplocalleader = " " -- Set local leader to space too

-- Enable 24-bit color in TUI
if vim.fn.has("termguicolors") == 1 then
	opt.termguicolors = true
end

-- I don't kwon what it does... yet
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep" -- Assumes ripgrep is installed
