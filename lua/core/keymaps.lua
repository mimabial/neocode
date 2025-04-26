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

-- Better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

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

-- Move lines up and down
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

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

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

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
map("n", "<leader>_", "<cmd>split<cr>", { desc = "Split window horizontally" })
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

-- Save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

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

local diagnostic_goto = function(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

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

--------------------------------------------------------------------------------
-- Search Mappings
--------------------------------------------------------------------------------

-- Clear search and stop snippet on escape
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
	-- Clear persistent search highlighting
	vim.cmd("noh")
	-- Stop snippet expansion if a snippet plugin (like luasnip) is running
	-- This check prevents errors if no snippet engine is active
	if pcall(require, "luasnip") and require("luasnip").running() then
		require("luasnip").jump(0) -- Exit the current snippet
	end
	-- Return <esc> to allow the default escape behavior (e.g., exiting insert mode)
	return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch and stop snippet" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
	"n",
	"<leader>ur",
	"<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
	{ desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

--------------------------------------------------------------------------------
-- List Mappings
--------------------------------------------------------------------------------

-- location list
map("n", "<leader>xl", function()
	local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Location List" })

-- quickfix list
map("n", "<leader>xq", function()
	local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })
