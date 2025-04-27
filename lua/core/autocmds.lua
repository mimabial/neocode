--------------------------------------------------------------------------------
-- Auto Commands
--------------------------------------------------------------------------------
--
-- This file defines auto commands - actions triggered automatically on events.
--
-- Auto commands are organized by:
-- 1. File type settings
-- 2. Buffer behaviors
-- 3. UI customizations 
-- 4. Auto-formatting
-- 5. Terminal settings
--
-- These provide automatic behaviors based on different events in Neovim.
--------------------------------------------------------------------------------

-- Helper function to create augroups
local function augroup(name)
  return vim.api.nvim_create_augroup("neocode_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

--------------------------------------------------------------------------------
-- General Behaviors
--------------------------------------------------------------------------------

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
  desc = "Highlight text on yank",
})

-- Auto resize panes when resizing window
autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
  desc = "Auto-resize splits on window resize",
})

-- Don't auto comment new lines
autocmd("BufEnter", {
  group = augroup("disable_auto_comment"),
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable auto-commenting new lines",
})

-- Auto-create directories when saving files
autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  desc = "Create directory if it doesn't exist on save",
})

-- Go to last location when opening a buffer
autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].neocode_last_loc then
      return
    end
    vim.b[buf].neocode_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Go to last location when opening a buffer",
})

-- Check for file changes and reload
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
  desc = "Check for file changes",
})

--------------------------------------------------------------------------------
-- File Type Specific Settings
--------------------------------------------------------------------------------

-- Close some filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "checkhealth",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "PlenaryTestPopup",
    "neotest-output",
    "neotest-summary",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
  desc = "Close certain filetypes with q",
})

-- Make help windows open vertically
autocmd("FileType", {
  group = augroup("help_vertical"),
  pattern = { "help" },
  callback = function()
    vim.cmd("wincmd L")
  end,
  desc = "Help windows open vertically",
})

-- Make quickfix open below
autocmd("FileType", {
  group = augroup("quickfix_below"),
  pattern = { "qf" },
  callback = function()
    vim.cmd("wincmd J")
  end,
  desc = "Open quickfix below",
})

-- Python indentation
autocmd("FileType", {
  group = augroup("filetype_settings"),
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
  desc = "Python indentation",
})

-- Go indentation
autocmd("FileType", {
  group = augroup("filetype_settings"),
  pattern = { "go" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
  desc = "Go indentation",
})

-- Web development indentation
autocmd("FileType", {
  group = augroup("filetype_settings"),
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "html", "css", "scss" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
  desc = "Web development indentation",
})

-- Set spell checking for text files
autocmd("FileType", {
  group = augroup("filetype_settings"),
  pattern = { "markdown", "text", "tex", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
  desc = "Enable spellchecking for text files",
})

-- Wrap and check for spell in text filetypes
autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
  desc = "Enable word wrap and spell check for text files",
})

-- Disable conceallevel for JSON files
autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
  desc = "Disable conceallevel for JSON files",
})

--------------------------------------------------------------------------------
-- Terminal Settings
--------------------------------------------------------------------------------

-- Terminal window settings
autocmd("TermOpen", {
  group = augroup("terminal"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
  desc = "Terminal settings",
})

--------------------------------------------------------------------------------
-- Format On Save
--------------------------------------------------------------------------------

-- Format on save
autocmd("BufWritePre", {
  group = augroup("auto_format"),
  callback = function()
    -- Check if auto-formatting is disabled for this buffer
    if vim.b.disable_autoformat or vim.g.disable_autoformat then
      return
    end

    -- Format with LSP if available
    if vim.lsp.buf.format then
      vim.lsp.buf.format({ timeout_ms = 1000 })
    end
  end,
  desc = "Format on save",
})
