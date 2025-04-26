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

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General settings
local general = augroup("General", { clear = true })

-- Highlight on yank
autocmd("TextYankPost", {
	group = general,
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
	end,
	desc = "Highlight text on yank",
})

-- Auto resize panes when resizing window
autocmd("VimResized", {
	group = general,
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
	desc = "Auto-resize splits on window resize",
})

-- Don't auto comment new lines
autocmd("BufEnter", {
	group = general,
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
	desc = "Disable auto-commenting new lines",
})

-- Close some filetypes with <q>
autocmd("FileType", {
	group = general,
	pattern = {
		"qf",
		"help",
		"man",
		"notify",
		"lspinfo",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
	desc = "Close certain filetypes with q",
})

-- Make help windows open vertically
autocmd("FileType", {
	group = general,
	pattern = { "help" },
	callback = function()
		vim.cmd("wincmd L")
	end,
	desc = "Open help vertically",
})

-- Make quickfix open below
autocmd("FileType", {
	group = general,
	pattern = { "qf" },
	callback = function()
		vim.cmd("wincmd J")
	end,
	desc = "Open quickfix below",
})

-- Check for file changes and reload
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = general,
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
	desc = "Check for file changes",
})

-- Terminal settings
local terminal = augroup("Terminal", { clear = true })

-- Terminal settings
autocmd("TermOpen", {
	group = terminal,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.cmd("startinsert")
	end,
	desc = "Terminal settings",
})

-- Format on save
local format_group = augroup("AutoFormat", { clear = true })

autocmd("BufWritePre", {
	group = format_group,
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

-- Filetype-specific settings
local filetype_settings = augroup("FiletypeSettings", { clear = true })

-- Set tab width for specific file types
autocmd("FileType", {
	group = filetype_settings,
	pattern = { "python" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.expandtab = true
	end,
	desc = "Python indentation",
})

autocmd("FileType", {
	group = filetype_settings,
	pattern = { "go" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.expandtab = false
	end,
	desc = "Go indentation",
})

autocmd("FileType", {
	group = filetype_settings,
	pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "html", "css", "scss" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
	end,
	desc = "Web development indentation",
})

-- Set spell checking for some file types
autocmd("FileType", {
	group = filetype_settings,
	pattern = { "markdown", "text", "tex", "gitcommit" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us"
	end,
	desc = "Enable spellchecking for text files",
})

-- Auto-create directories when saving files
autocmd("BufWritePre", {
	group = general,
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.loop.fs_realpath(event.match) or event.match
		local dir = vim.fn.fnamemodify(file, ":p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
	desc = "Create directory if it doesn't exist on save",
})
