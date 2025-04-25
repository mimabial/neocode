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
local set = vim.opt

--------------------------------------------------------------------------------
-- UI and Appearance
--------------------------------------------------------------------------------

-- Line numbers
set.number = true -- Show line numbers
set.relativenumber = true -- Use relative line numbers
set.numberwidth = 4 -- Width of line number column
set.signcolumn = "yes" -- Always show the sign column

-- Visual elements
set.termguicolors = true -- Use GUI colors in terminal
set.cursorline = true -- Highlight current line
set.showmode = false -- Don't show mode in command line (statusline shows it)
set.showcmd = true -- Show command in status line
set.cmdheight = 1 -- Height of command line
set.laststatus = 3 -- Global statusline
set.title = true -- Set window title
set.titlestring = "%<%F%=%l/%L - NeoCode" -- Title format

-- Window splitting
set.splitbelow = true -- New horizontal splits below
set.splitright = true -- New vertical splits to the right
set.equalalways = false -- Don't resize windows on split/close

-- Scroll and view
set.scrolloff = 8 -- Minimum lines to keep above/below cursor
set.sidescrolloff = 8 -- Minimum columns to keep left/right of cursor
set.wrap = false -- Don't wrap long lines
set.linebreak = true -- Break lines at word boundaries
set.breakindent = true -- Preserve indentation in wrapped text
set.display:append("lastline") -- Show as much as possible of the last line

-- Visual whitespace
set.list = true -- Show invisible characters
set.listchars = {
	tab = "→ ",
	lead = "·",
	trail = "·",
	extends = "⟩",
	precedes = "⟨",
	nbsp = "␣",
}

-- Interface behavior
set.mouse = "a" -- Enable mouse in all modes
set.mousemoveevent = true -- Enable mouse movement events
set.pumheight = 10 -- Maximum height of popup menu
set.pumblend = 10 -- Transparency of popup menu
set.winblend = 10 -- Transparency of floating windows

-- Appearance tweaks
set.fillchars:append({
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
set.updatetime = 300 -- Faster updates (CursorHold)
set.timeout = true -- Enable timeout for mappings
set.timeoutlen = 500 -- Timeout length in ms
set.ttimeout = true -- Terminal key code timeout
set.ttimeoutlen = 10 -- Terminal timeout length

-- Editing
set.undofile = true -- Persistent undo history
set.undolevels = 10000 -- Maximum number of undo changes
set.virtualedit = "block" -- Allow cursor beyond end of line in visual block
set.backspace = "indent,eol,start" -- Backspace behavior
set.completeopt = "menu,menuone,noselect" -- Completion options
set.conceallevel = 0 -- No concealing by default

-- Clipboard
set.clipboard = "unnamedplus" -- Use system clipboard

-- Command line
set.wildmode = "longest:full,full" -- Command-line completion mode
set.wildignorecase = true -- Ignore case in command completion
set.history = 1000 -- Command history size

--------------------------------------------------------------------------------
-- Search and Completion
--------------------------------------------------------------------------------

-- Search behavior
set.hlsearch = true -- Highlight search results
set.incsearch = true -- Incremental search
set.ignorecase = true -- Case insensitive search
set.smartcase = true -- Smart case search (override ignorecase)

-- Pattern matching
set.magic = true -- Use 'magic' patterns (extended regular expressions)
set.gdefault = true -- Substitute all matches in a line by default
set.inccommand = "split" -- Show preview of substitution

--------------------------------------------------------------------------------
-- Indentation and Formatting
--------------------------------------------------------------------------------

-- Indentation
set.expandtab = true -- Use spaces instead of tabs
set.smarttab = true -- Insert tabs according to shiftwidth
set.tabstop = 2 -- Width of a tab character
set.softtabstop = 2 -- Number of spaces for a tab
set.shiftwidth = 2 -- Width of an indent
set.autoindent = true -- Copy indent from current line
set.smartindent = true -- Auto-indent new lines

-- Formatting
set.formatoptions = "jcroqlnt" -- Automatic formatting options
set.textwidth = 0 -- No hard text wrapping
set.joinspaces = false -- No double spaces after punctuation on join

-- Folding
set.foldenable = false -- Disable folding on startup
set.foldlevelstart = 99 -- Start with all folds open
set.foldmethod = "expr" -- Use expression for folding
set.foldexpr = "nvim_treesitter#foldexpr()" -- Use treesitter for folding

--------------------------------------------------------------------------------
-- File Handling
--------------------------------------------------------------------------------

-- File operations
set.autoread = true -- Auto-reload changed files
set.autowrite = true -- Auto-save before commands
set.confirm = true -- Confirm before operations
set.fileformats = "unix,dos,mac" -- File format preference

-- Backup and swap
set.backup = false -- No backup files
set.writebackup = false -- No backup while editing
set.swapfile = false -- No swap files
set.undofile = true -- Persistent undo history
set.undodir = vim.fn.stdpath("data") .. "/undo" -- Undo directory

-- Session and view
set.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize"
set.viewoptions = "folds,cursor,curdir,slash,unix"

--------------------------------------------------------------------------------
-- Performance
--------------------------------------------------------------------------------

-- Redraw and rendering
set.lazyredraw = true -- Don't redraw while executing macros
set.redrawtime = 1500 -- Time limit for highlighting in ms
set.ttyfast = true -- Faster terminal connection

-- Buffer management
set.hidden = true -- Allow switching from unsaved buffers

-- Syntax and highlighting
set.synmaxcol = 240 -- Max column for syntax highlighting
set.regexpengine = 0 -- Automatically select regex engine

-- Memory usage
set.maxmempattern = 2000 -- Maximum memory for pattern matching

--------------------------------------------------------------------------------
-- Miscellaneous
--------------------------------------------------------------------------------

-- Neovim specific
set.shortmess:append("c") -- Don't show completion messages
set.shortmess:append("I") -- Don't show intro message
set.shortmess:append("W") -- Don't show "written" message
set.shortmess:append("A") -- Don't show "ATTENTION" message
set.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Error bells
set.errorbells = false -- No error bells
set.visualbell = false -- No visual bell

-- Directories
set.directory = vim.fn.stdpath("data") .. "/swap"
vim.fn.mkdir(vim.fn.stdpath("data") .. "/swap", "p")

-- Spelling
set.spell = false -- Disable spell checking by default
set.spelllang = "en_us" -- Default language for spell checking

-- Debug
if vim.fn.has("nvim-0.9.0") == 1 then
	set.splitkeep = "screen" -- Keep cursor position on split
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
	set.termguicolors = true
end
