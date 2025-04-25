--------------------------------------------------------------------------------
-- LSP UI Components
--------------------------------------------------------------------------------
--
-- This module configures the UI aspects of LSP functionality:
--
-- Features:
-- 1. Prettier diagnostic display
-- 2. Symbol outline
-- 3. Better code action UI
-- 4. Floating windows for hover and signature
-- 5. Progress indicators
-- 6. Status indicators in status line
--
-- These enhancements make LSP interactions more visually appealing
-- and provide better information display.
--------------------------------------------------------------------------------

local M = {}

-- Configure diagnostic display
function M.setup_diagnostics()
	-- Define diagnostic signs
	local signs = {
		{ name = "DiagnosticSignError", text = " ", texthl = "DiagnosticSignError" },
		{ name = "DiagnosticSignWarn", text = " ", texthl = "DiagnosticSignWarn" },
		{ name = "DiagnosticSignHint", text = "󰌵 ", texthl = "DiagnosticSignHint" },
		{ name = "DiagnosticSignInfo", text = " ", texthl = "DiagnosticSignInfo" },
	}

	-- Register signs
	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.texthl, text = sign.text, numhl = sign.texthl })
	end

	-- Configure diagnostics display
	vim.diagnostic.config({
		underline = true,
		update_in_insert = false,
		virtual_text = {
			spacing = 4,
			prefix = "●",
			source = "if_many",
		},
		severity_sort = true,
		float = {
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	})

	-- Configure handler for hover windows
	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
		width = 60,
		-- Add additional styling to hover windows
		stylize_markdown = true,
	})

	-- Configure handler for signature help
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
		close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
	})
end

-- Configure LSP symbols in winbar (breadcrumbs)
function M.setup_winbar()
	-- Only setup if navic is available
	local ok, navic = pcall(require, "nvim-navic")
	if not ok then
		return
	end

	-- Configure appearance
	navic.setup({
		icons = {
			File = " ",
			Module = " ",
			Namespace = " ",
			Package = " ",
			Class = " ",
			Method = " ",
			Property = " ",
			Field = " ",
			Constructor = " ",
			Enum = " ",
			Interface = " ",
			Function = " ",
			Variable = " ",
			Constant = " ",
			String = " ",
			Number = " ",
			Boolean = " ",
			Array = " ",
			Object = " ",
			Key = " ",
			Null = " ",
			EnumMember = " ",
			Struct = " ",
			Event = " ",
			Operator = " ",
			TypeParameter = " ",
		},
		highlight = true,
		separator = " › ",
		depth_limit = 0,
		depth_limit_indicator = "...",
		safe_output = true,
	})

	-- Add winbar to certain file types
	local exclude_filetypes = {
		"help",
		"dashboard",
		"lazy",
		"mason",
		"notify",
		"toggleterm",
		"lazyterm",
		"Trouble",
		"spectre_panel",
		"TelescopePrompt",
		"NvimTree",
		"neo-tree",
		"oil",
	}

	-- Create winbar using navic
	local create_winbar = function()
		if vim.tbl_contains(exclude_filetypes, vim.bo.filetype) then
			return
		end

		-- Don't show in special buffers
		local buftype = vim.bo.buftype
		if buftype == "terminal" or buftype == "prompt" or buftype == "nofile" or buftype == "quickfix" then
			return
		end

		-- Get current file name
		local filename = vim.fn.expand("%:t")
		if filename == "" then
			filename = "[No Name]"
		end

		-- Get file icon
		local file_icon = ""
		local extension = vim.fn.expand("%:e")
		if extension and extension ~= "" then
			-- Use devicons if available
			local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
			if devicons_ok then
				file_icon, _ = devicons.get_icon_by_filetype(vim.bo.filetype) or devicons.get_icon(filename, extension)
				if file_icon then
					file_icon = file_icon .. " "
				end
			end
		end

		-- Create the winbar
		local winbar = " " .. file_icon .. filename

		-- Add navic location if available
		if navic.is_available() then
			local location = navic.get_location()
			if location and location ~= "" then
				winbar = winbar .. " › " .. location
			end
		end

		-- Set the winbar
		vim.wo.winbar = winbar
	end

	-- Set up autocommand to update winbar
	vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost" }, {
		callback = create_winbar,
	})

	-- Also create on initial setup
	create_winbar()
end

-- Setup trouble.nvim for better diagnostics display
function M.setup_trouble()
	-- Only setup if available
	local ok, trouble = pcall(require, "trouble")
	if not ok then
		return
	end

	-- Configure trouble.nvim
	trouble.setup({
		position = "bottom",
		height = 10,
		width = 50,
		icons = true,
		mode = "workspace_diagnostics",
		fold_open = "",
		fold_closed = "",
		group = true,
		padding = true,
		action_keys = {
			close = "q",
			cancel = "<esc>",
			refresh = "r",
			jump = { "<cr>", "<tab>" },
			open_split = { "<c-x>" },
			open_vsplit = { "<c-v>" },
			open_tab = { "<c-t>" },
			jump_close = { "o" },
			toggle_mode = "m",
			toggle_preview = "P",
			hover = "K",
			preview = "p",
			close_folds = { "zM", "zm" },
			open_folds = { "zR", "zr" },
			toggle_fold = { "zA", "za" },
			previous = "k",
			next = "j",
		},
		indent_lines = true,
		auto_open = false,
		auto_close = false,
		auto_preview = true,
		auto_fold = false,
		auto_jump = { "lsp_definitions" },
		signs = {
			error = "",
			warning = "",
			hint = "󰌵",
			information = "",
			other = "﫠",
		},
		use_diagnostic_signs = false,
	})

	-- Configure keymaps
	vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Toggle Trouble" })
	vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { desc = "Document Diagnostics" })
	vim.keymap.set(
		"n",
		"<leader>xw",
		"<cmd>TroubleToggle workspace_diagnostics<cr>",
		{ desc = "Workspace Diagnostics" }
	)
	vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { desc = "Location List" })
	vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { desc = "Quickfix List" })
	vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", { desc = "LSP References" })
	vim.keymap.set("n", "gD", "<cmd>TroubleToggle lsp_definitions<cr>", { desc = "LSP Definitions" })
	vim.keymap.set("n", "gT", "<cmd>TroubleToggle lsp_type_definitions<cr>", { desc = "LSP Type Definitions" })
end

-- Setup LSP kind icons for completion and UI
function M.setup_lspkind()
	local present, lspkind = pcall(require, "lspkind")
	if not present then
		return
	end

	lspkind.init({
		mode = "symbol_text",
		preset = "codicons",
		symbol_map = {
			Text = "󰉿",
			Method = "󰆧",
			Function = "󰊕",
			Constructor = "",
			Field = "󰜢",
			Variable = "󰀫",
			Class = "󰠱",
			Interface = "",
			Module = "",
			Property = "󰜢",
			Unit = "󰑭",
			Value = "󰎠",
			Enum = "",
			Keyword = "󰌋",
			Snippet = "",
			Color = "󰏘",
			File = "󰈙",
			Reference = "󰈇",
			Folder = "󰉋",
			EnumMember = "",
			Constant = "󰏿",
			Struct = "󰙅",
			Event = "",
			Operator = "󰆕",
			TypeParameter = "",
			Table = "",
			Object = "󰅩",
			Tag = "",
			Array = "[]",
			Boolean = "",
			Number = "",
			Null = "󰟢",
			String = "󰀬",
			Calendar = "",
			Watch = "󰥔",
			Package = "",
			Copilot = "",
			Codeium = "",
		},
	})
end

-- Setup fidget.nvim for LSP progress display
function M.setup_fidget()
	local ok, fidget = pcall(require, "fidget")
	if not ok then
		return
	end

	fidget.setup({
		text = {
			spinner = "moon",
			done = "✓",
			commenced = "Started",
			completed = "Completed",
		},
		align = {
			bottom = true,
			right = true,
		},
		timer = {
			spinner_rate = 125,
			fidget_decay = 2000,
			task_decay = 1000,
		},
		window = {
			relative = "editor",
			blend = 0,
			zindex = 50,
			border = "rounded",
		},
		fmt = {
			max_width = 0,
			task = function(task_name, message, percentage)
				if task_name:match("code_action") or task_name:match("diagnostics") then
					return false
				end
				return string.format(
					"%s%s [%s]",
					message,
					percentage and string.format(" (%s%%)", percentage) or "",
					task_name
				)
			end,
		},
	})
end

-- Setup symbols-outline.nvim for code outline
function M.setup_symbols_outline()
	local ok, outline = pcall(require, "symbols-outline")
	if not ok then
		return
	end

	outline.setup({
		highlight_hovered_item = true,
		show_guides = true,
		auto_preview = false,
		position = "right",
		relative_width = true,
		width = 25,
		auto_close = false,
		show_numbers = false,
		show_relative_numbers = false,
		show_symbol_details = true,
		preview_bg_highlight = "Pmenu",
		autofold_depth = nil,
		auto_unfold_hover = true,
		fold_markers = { "", "" },
		wrap = false,
		keymaps = {
			close = { "<Esc>", "q" },
			goto_location = "<Cr>",
			focus_location = "o",
			hover_symbol = "<C-space>",
			toggle_preview = "K",
			rename_symbol = "r",
			code_actions = "a",
			fold = "h",
			unfold = "l",
			fold_all = "W",
			unfold_all = "E",
			fold_reset = "R",
		},
		lsp_blacklist = {},
		symbol_blacklist = {},
		symbols = {
			File = { icon = "", hl = "@text.uri" },
			Module = { icon = "", hl = "@namespace" },
			Namespace = { icon = "", hl = "@namespace" },
			Package = { icon = "", hl = "@namespace" },
			Class = { icon = "󰠱", hl = "@type" },
			Method = { icon = "󰆧", hl = "@method" },
			Property = { icon = "󰜢", hl = "@method" },
			Field = { icon = "󰜢", hl = "@field" },
			Constructor = { icon = "", hl = "@constructor" },
			Enum = { icon = "", hl = "@type" },
			Interface = { icon = "", hl = "@type" },
			Function = { icon = "󰊕", hl = "@function" },
			Variable = { icon = "󰀫", hl = "@constant" },
			Constant = { icon = "󰏿", hl = "@constant" },
			String = { icon = "󰀬", hl = "@string" },
			Number = { icon = "", hl = "@number" },
			Boolean = { icon = "", hl = "@boolean" },
			Array = { icon = "[]", hl = "@constant" },
			Object = { icon = "󰅩", hl = "@type" },
			Key = { icon = "󰌋", hl = "@type" },
			Null = { icon = "󰟢", hl = "@type" },
			EnumMember = { icon = "", hl = "@field" },
			Struct = { icon = "󰙅", hl = "@type" },
			Event = { icon = "", hl = "@type" },
			Operator = { icon = "󰆕", hl = "@operator" },
			TypeParameter = { icon = "", hl = "@parameter" },
			Component = { icon = "󰅴", hl = "@function" },
			Fragment = { icon = "󰅴", hl = "@constant" },
		},
	})

	vim.keymap.set("n", "<leader>lo", "<cmd>SymbolsOutline<CR>", { desc = "Toggle Symbols Outline" })
end

-- Setup LSP colors
function M.setup_colors()
	-- Set LSP diagnostic colors
	vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#F44747" })
	vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#FF8800" })
	vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#01AEFA" })
	vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#15AABF" })

	-- Set virtual text colors
	vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#F44747", bg = "#342C30" })
	vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#FF8800", bg = "#2D2A27" })
	vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#01AEFA", bg = "#24283B" })
	vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#15AABF", bg = "#262D35" })

	-- Set underline colors
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#F44747" })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#FF8800" })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#01AEFA" })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#15AABF" })

	-- Set floating window colors
	vim.api.nvim_set_hl(0, "LspFloatWinBorder", { fg = "#6D6F7B" })
	vim.api.nvim_set_hl(0, "LspFloatWinNormal", { bg = "#22252B" })

	-- Set sign colors
	vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#F44747", bg = "NONE" })
	vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#FF8800", bg = "NONE" })
	vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#01AEFA", bg = "NONE" })
	vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#15AABF", bg = "NONE" })
end

-- Master function to setup all LSP UI components
function M.setup()
	M.setup_diagnostics()
	M.setup_winbar()
	M.setup_trouble()
	M.setup_lspkind()
	M.setup_fidget()
	M.setup_symbols_outline()
	M.setup_colors()
end

return M
