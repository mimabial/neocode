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
-- 5. Diagnostics and LSP (basic)
--
-- Most plugin-specific mappings are defined in their respective plugin files.
--------------------------------------------------------------------------------

-- Shorthand for mapping
local map = vim.keymap.set

-- Set leader key (defined in init.lua, but here for clarity)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--------------------------------------------------------------------------------
-- General Mappings
--------------------------------------------------------------------------------

-- Better up/down for wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down (respect wrap)" })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down (respect wrap)" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up (respect wrap)" })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up (respect wrap)" })

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
map("n", "<A-j>", "<cmd>move .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>move .-2<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>move .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>move .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":move '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":move '<-2<cr>gv=gv", { desc = "Move selection up" })

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

-- Add undo break-points (creates undo points at punctuation)
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

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

-- Split windows
map("n", "<leader>_", "<cmd>split<cr>", { desc = "Split window horizontally" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split window vertically" })

-- Close current buffer
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

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

-- Duplicate line or selection
map("n", "<leader>dl", "yyp", { desc = "Duplicate line" })
map("v", "<leader>dl", "y'>p", { desc = "Duplicate selection" })

-- Save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

--------------------------------------------------------------------------------
-- UI Mappings
--------------------------------------------------------------------------------

-- Toggle common options
map("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "Toggle word wrap" })
map("n", "<leader>ul", "<cmd>set list!<cr>", { desc = "Toggle show invisible chars" })
map("n", "<leader>uL", "<cmd>set relativenumber!<cr>", { desc = "Toggle relative line numbers" })
map("n", "<leader>us", "<cmd>set spell!<cr>", { desc = "Toggle spell check" })

-- Toggle autoformatting (uses global variable checked in autocmds)
map("n", "<leader>uf", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify("Autoformatting " .. (vim.g.disable_autoformat and "disabled" or "enabled"), vim.log.levels.INFO)
end, { desc = "Toggle autoformatting" })

-- Help for word under cursor
map("n", "gh", "<cmd>help <C-r><C-w><cr>", { desc = "Help for word under cursor" })

--------------------------------------------------------------------------------
-- Basic LSP and Diagnostics Mappings
--------------------------------------------------------------------------------

-- Diagnostics navigation
local function diagnostic_goto(next, severity)
  return function()
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return go({ severity = severity })
  end
end

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- Basic LSP mappings (more defined in lsp/keymaps.lua)
map("n", "K", function() vim.lsp.buf.hover() end, { desc = "Show hover documentation" })
map("n", "gd", function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
map("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { desc = "Code actions" })
map("n", "<leader>rn", function() vim.lsp.buf.rename() end, { desc = "Rename symbol" })

--------------------------------------------------------------------------------
-- Search Mappings
--------------------------------------------------------------------------------

-- Clear search and redraw screen
map("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", 
  { desc = "Redraw / Clear hlsearch / Diff Update" })

-- Better search behavior for n/N
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

--------------------------------------------------------------------------------
-- Quickfix List Mappings
--------------------------------------------------------------------------------

-- Toggle quickfix list
map("n", "<leader>xq", function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end, { desc = "Toggle Quickfix List" })

-- Navigation through the quickfix list
map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix Item" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix Item" })

-- Quick definition of common leader groups for which-key
-- (Plugin will flesh these out fully)
if not vim.g.keys_defined then
  vim.g.keys_defined = true
  
  -- Define namespaces for leader key groups
  local leader_groups = {
    b = "Buffer",
    c = "Code",
    d = "Debug/Diagnostics",
    f = "Find/File",
    g = "Git",
    l = "LSP",
    q = "Quit/Session",
    r = "Refactor",
    s = "Search",
    t = "Terminal/Test",
    u = "UI/Toggle",
    w = "Window",
    x = "Diagnostics/Quickfix",
  }
  
  -- Create stub mappings to define the leader groups
  for key, name in pairs(leader_groups) do
    map("n", "<leader>" .. key, "<Nop>", { desc = name })
  end
end
