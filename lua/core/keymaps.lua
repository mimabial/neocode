--------------------------------------------------------------------------------
-- Key Mappings
--------------------------------------------------------------------------------
--
-- This file defines global key mappings for Neovim.
--
-- The mappings are organized by:
-- 1. General editor commands
-- 2. Navigation (files, buffers, windows)
-- 3. Editing operations
-- 4. UI toggles and operations
-- 5. Plugin-specific mappings
--
-- Most plugin-specific mappings are defined in their respective plugin files.
--------------------------------------------------------------------------------

-- Shorthand for mapping
local map = vim.keymap.set

-- Set leader key (defined in init.lua and options.lua, but here for clarity)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--------------------------------------------------------------------------------
-- General Mappings
--------------------------------------------------------------------------------

-- Save and quit
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Save and quit" })
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

-- Better escape
map("i", "jk", "<Esc>", { desc = "Escape insert mode" })
map("i", "kj", "<Esc>", { desc = "Escape insert mode" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>noh<cr>", { desc = "Clear highlights" })

-- Better indenting - stay in visual mode
map("v", "<", "<gv", { desc = "Indent left and stay in visual" })
map("v", ">", ">gv", { desc = "Indent right and stay in visual" })

-- Move selected lines up and down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search result and center" })
map("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Join lines but keep cursor position
map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Paste over selection without yanking
map("x", "p", [["_dP]], { desc = "Paste without yanking selection" })

-- Delete without yanking
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- Yank to system clipboard
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

--------------------------------------------------------------------------------
-- Navigation Mappings
--------------------------------------------------------------------------------

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to other buffer" })

-- Split windows
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split window horizontally" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split window vertically" })

-- Close current buffer
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Delete buffer (force)" })

-- Tab navigation
map("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader>tl", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader>th", "<cmd>tabprevious<cr>", { desc = "Previous tab" })

-- Set working directory to current file
map("n", "<leader>cd", "<cmd>cd %:p:h<cr><cmd>pwd<cr>", { desc = "Change CWD to current file" })

--------------------------------------------------------------------------------
-- Editing Mappings
--------------------------------------------------------------------------------

-- Insert blank lines without entering insert mode
map("n", "<leader>o", "o<Esc>", { desc = "Insert line below" })
map("n", "<leader>O", "O<Esc>", { desc = "Insert line above" })

-- Quick substitute current word
map("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute current word" })

-- Make file executable
map("n", "<leader>x", "<cmd>!chmod +x %<cr>", { desc = "Make file executable", silent = true })

-- Format document
map("n", "<leader>cf", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format document" })

-- Duplicate line or selection
map("n", "<leader>dl", "yyp", { desc = "Duplicate line" })
map("v", "<leader>dl", "y'>p", { desc = "Duplicate selection" })

--------------------------------------------------------------------------------
-- UI Mappings
--------------------------------------------------------------------------------

-- Toggle common options
map("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "Toggle word wrap" })
map("n", "<leader>ul", "<cmd>set list!<cr>", { desc = "Toggle show invisible chars" })
map("n", "<leader>uL", "<cmd>set relativenumber!<cr>", { desc = "Toggle relative line numbers" })
map("n", "<leader>us", "<cmd>set spell!<cr>", { desc = "Toggle spell check" })
map("n", "<leader>up", "<cmd>set paste!<cr>", { desc = "Toggle paste mode" })

-- Toggle autoformatting
map("n", "<leader>uf", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
	vim.notify("Autoformatting " .. (vim.g.disable_autoformat and "disabled" or "enabled"), vim.log.levels.INFO)
end, { desc = "Toggle autoformatting" })

-- Help for word under cursor
map("n", "gh", "<cmd>help <C-r><C-w><cr>", { desc = "Help for word under cursor" })

--------------------------------------------------------------------------------
-- Plugin-Specific Mappings
--------------------------------------------------------------------------------

-- Notes: Most plugin-specific mappings are defined in their respective plugin configuration files,
-- However, here are some common ones that might be useful:

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Find text" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })

-- NeoTree
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })

-- Terminal
map({ "n", "t" }, "<F7>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })

-- LSP (Basic; more defined in lsp/keymaps.lua)
map("n", "K", function()
	vim.lsp.buf.hover()
end, { desc = "Show hover documentation" })
map("n", "gd", function()
	vim.lsp.buf.definition()
end, { desc = "Go to definition" })
map("n", "<leader>ca", function()
	vim.lsp.buf.code_action()
end, { desc = "Code actions" })
map("n", "<leader>rn", function()
	vim.lsp.buf.rename()
end, { desc = "Rename symbol" })

-- Diagnostics
map("n", "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", { desc = "Document diagnostics" })
map("n", "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", { desc = "Workspace diagnostics" })
map("n", "[d", function()
	vim.diagnostic.goto_prev()
end, { desc = "Previous diagnostic" })
map("n", "]d", function()
	vim.diagnostic.goto_next()
end, { desc = "Next diagnostic" })

-- Comments (these will be overridden by Comment.nvim if installed)
map("n", "<leader>/", function()
	require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment" })
map(
	"v",
	"<leader>/",
	"<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
	{ desc = "Toggle comment" }
)
