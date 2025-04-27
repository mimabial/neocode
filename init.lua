-- Set leader key before anything else
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic Neovim settings
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.ignorecase = true -- Case insensitive searching
vim.opt.smartcase = true -- Override ignorecase when search contains uppercase
vim.opt.hlsearch = true -- Highlight search
vim.opt.wrap = false -- Don't wrap lines
vim.opt.breakindent = true -- Enable break indent
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.undofile = true -- Save undo history
vim.opt.updatetime = 250 -- Decrease update time
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.cursorline = true -- Highlight current line
vim.opt.scrolloff = 8 -- Keep 8 lines above/below cursor when scrolling
vim.opt.termguicolors = true -- True color support
vim.opt.laststatus = 3 -- Global status line
vim.opt.showcmd = false -- Hide command line
vim.opt.showmode = false -- Hide mode text ('-- INSERT --')
vim.opt.cmdheight = 1 -- Command line height
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard

-- Diagnostics customization
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
  },
  update_in_insert = true,
  float = {
    focused = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
  severity_sort = true,
})

-- Configure icons for diagnostics
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  -- Import all configs from lua/plugins directory
  { import = "plugins" },

  -- Default config for lazy.nvim itself
  {
    "folke/lazy.nvim",
    version = false,
  },
}, {
  install = {
    colorscheme = { "gruvbox-material" },
  },
  ui = {
    border = "rounded",
  },
  checker = { enabled = true },
  change_detection = { notify = false },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
