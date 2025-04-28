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
vim.opt.list = true -- Show some invisible characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- Define which invisibles to show
vim.opt.splitright = true -- Split windows right
vim.opt.splitbelow = true -- Split windows below
vim.opt.swapfile = false -- Don't use swapfile
vim.opt.backup = false -- Don't create backup files
vim.opt.confirm = true -- Confirm before exiting if unsaved changes
vim.opt.autowrite = true -- Auto save before commands like :next and :make
vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.timeoutlen = 300 -- Time in milliseconds to wait for a mapped sequence to complete
vim.opt.completeopt = "menu,menuone,noselect" -- Better completion experience
vim.opt.smartindent = true -- Smart indentation
vim.opt.showmatch = true -- Show matching brackets
vim.opt.conceallevel = 0 -- Don't hide markdown syntax

-- Folding (using nvim-ufo)
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Diagnostics customization
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    severity = {
      min = vim.diagnostic.severity.HINT,
    },
    source = true,
    spacing = 4,
  },
  float = {
    border = "rounded",
    severity_sort = true,
    source = "always",
    header = "",
    prefix = function(diagnostic)
      local signs = {
        [vim.diagnostic.severity.ERROR] = "✗",  -- Error symbol
        [vim.diagnostic.severity.WARN] = "⚠",   -- Warning symbol
        [vim.diagnostic.severity.INFO] = "ℹ",   -- Information symbol
        [vim.diagnostic.severity.HINT] = "",   -- Hint symbol
      }
      return signs[diagnostic.severity] .. " "
    end,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Configure signs for diagnostics
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Set up global utility functions
_G.utils = {
  -- Check if a plugin is installed
  has_plugin = function(plugin)
    return require("lazy.core.config").spec.plugins[plugin] ~= nil
  end,
  
  -- Check if a command exists
  has_command = function(cmd)
    return vim.fn.exists(":" .. cmd) == 2
  end,
  
  -- Get the current buffer's working directory
  get_buf_dir = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    return vim.fn.fnamemodify(bufname, ":p:h")
  end,
  
  -- Create a new scratch buffer
  scratch_buffer = function()
    vim.cmd([[
      enew
      setlocal buftype=nofile
      setlocal bufhidden=hide
      setlocal noswapfile
      setlocal nobuflisted
    ]])
    return vim.api.nvim_get_current_buf()
  end,
  
  -- Center the current buffer content
  center_buffer = function()
    local win_height = vim.api.nvim_win_get_height(0)
    local buf_height = vim.api.nvim_buf_line_count(0)
    local padding = math.floor((win_height - buf_height) / 2)
    if padding > 0 then
      local lines = {}
      for _ = 1, padding do
        table.insert(lines, "")
      end
      vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
      vim.api.nvim_buf_set_lines(0, buf_height + padding, buf_height + padding, false, lines)
      vim.api.nvim_win_set_cursor(0, {padding + 1, 0})
    end
  end,
}

-- Basic autocommands
local autocmd_group = vim.api.nvim_create_augroup("CustomAutocmds", { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = autocmd_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remember last position in file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = autocmd_group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-format files on save if formatter is available
vim.api.nvim_create_autocmd("BufWritePre", {
  group = autocmd_group,
  callback = function()
    if _G.utils.has_plugin("conform.nvim") and not vim.g.disable_autoformat and not vim.b.disable_autoformat then
      local conform = require("conform")
      conform.format({ async = false, lsp_fallback = true })
    end
  end,
})

-- Automatically toggle relative line numbers when in insert mode
vim.api.nvim_create_autocmd({"InsertEnter"}, {
  group = autocmd_group,
  callback = function()
    vim.opt.relativenumber = false
  end
})

vim.api.nvim_create_autocmd({"InsertLeave"}, {
  group = autocmd_group,
  callback = function()
    vim.opt.relativenumber = true
  end
})

-- Auto resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = autocmd_group,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Automatically set indent settings based on file type
vim.api.nvim_create_autocmd("FileType", {
  group = autocmd_group,
  pattern = {"javascript", "typescript", "typescriptreact", "javascriptreact", "json", "html", "css", "scss", "templ"},
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = autocmd_group,
  pattern = {"python", "rust", "go"},
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end,
})

-- Special filetype settings
vim.api.nvim_create_autocmd("FileType", {
  group = autocmd_group,
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

-- Prevent Vim from automatically commenting on a new line after pressing Start, Enter, or "o" 
vim.api.nvim_create_autocmd("FileType", {
  group = autocmd_group,
  pattern = "*",
  callback = function()
    vim.bo.formatoptions = vim.bo.formatoptions
      :gsub("c", "")
      :gsub("r", "")
      :gsub("o", "")
  end,
})

-- Load lazy.nvim configuration
require("config.lazy")

-- Set common keyboard mappings
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
vim.keymap.set(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

-- Save file
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Paste over currently selected text without yanking it
vim.keymap.set("v", "p", '"_dP', { desc = "Better paste" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>xq", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Maintain cursor position when joining lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and maintain cursor position" })

-- Better navigation
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half a page and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half a page and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Print a startup message
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    local stats = require("lazy").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    local version = vim.version()
    local nvim_version_info = "v" .. version.major .. "." .. version.minor .. "." .. version.patch
    local plugins_count = stats.count
    local plugins_loaded = stats.loaded
    local startup_time = ms
    
    vim.notify(string.format(
      "Neovim %s loaded %s/%s plugins in %sms",
      nvim_version_info, plugins_loaded, plugins_count, startup_time
    ), vim.log.levels.INFO, { title = "Neovim Loaded" })
  end,
})

-- Add custom commands
vim.api.nvim_create_user_command("ReloadConfig", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^config") or name:match("^plugins") then
      package.loaded[name] = nil
    end
  end
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO, { title = "Config" })
end, { desc = "Reload Neovim configuration" })
