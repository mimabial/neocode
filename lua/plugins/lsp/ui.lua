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

return {
	-- Better UI for LSP hover and signature help
	{
		"ray-x/lsp_signature.nvim",
		event = "LspAttach",
		opts = {
			bind = true, -- Automatically setup bindings
			handler_opts = {
				border = "rounded",
			},
			hint_enable = true, -- Show hints about parameter names
			hint_prefix = "🔍 ",
			hint_scheme = "String", -- Highlight group for hints
			hi_parameter = "Search", -- Highlight group for active parameter
			max_height = 12, -- Max height of signature help window
			max_width = 120, -- Max width of signature help window
			padding = " ", -- Additional padding for the signature window
			transparency = nil, -- 0 = fully opaque, 100 = fully transparent
			toggle_key = "<C-k>", -- Toggle signature on and off in insert mode
			select_signature_key = "<C-n>", -- Cycle between signatures
			floating_window = true, -- Show floating window
			floating_window_above_cur_line = true, -- Show above current line when possible
			zindex = 200, -- Z-index of the popup
			always_trigger = false, -- Trigger signature even if there's no completion item
			timer_interval = 100, -- Debounce timer
		},
	},

	-- LSP progress indicator
	{
		"j-hui/fidget.nvim",
		opts = {
			notification = {
				window = {
					winblend = 0, -- No transparency
					border = "none", -- No border
				},
				view = {
					stack_upwards = true, -- Newest at the top
					icon_separator = " ", -- Icon separator
					group_separator = "---", -- Group separator
				},
				-- Customize the appearance of the fidget notification window
				rust_analyzer = {
					-- Override the default notification settings for a specific LSP client
					view = {
						icon = "🦀", -- Use a crab for rust_analyzer notifications
					},
				},
			},
			progress = {
				poll_rate = 0, -- No polling when not in a focused state
				ignore_done_already = true, -- Ignore tasks that were already done when Neovim starts up
				ignore_empty_message = true, -- Skip displaying notifications with empty messages
				clear_on_detach = function(client_id)
					local client = vim.lsp.get_client_by_id(client_id)
					return client and client.name or nil
				end,
				notification_group = function(msg)
					-- Put rust_analyzer build notifs in a group to de-clutter things
					if msg.lsp_client.name == "rust_analyzer" then
						if msg.title:find("build") then
							return "rust-build"
						end
					end
					-- Default: use LSP client name
					return msg.lsp_client.name
				end,
			},
			integration = {
				["nvim-tree"] = {
					enable = true, -- Integrate with nvim-tree
				},
			},
			logger = {
				level = vim.log.levels.WARN, -- Minimum logging level
				float_precision = 0.01, -- Floating point precision in seconds
				path = string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache")), -- Log path
			},
		},
	},

	-- Code outline/structure view
	{
		"simrat39/symbols-outline.nvim",
		cmd = { "SymbolsOutline", "SymbolsOutlineOpen", "SymbolsOutlineClose" },
		keys = {
			{ "<leader>lo", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" },
		},
		opts = {
			highlight_hovered_item = true,
			show_guides = true,
			auto_preview = false, -- Don't automatically preview symbol
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
			lsp_blacklist = {}, -- LSP servers to ignore
			symbol_blacklist = {}, -- Symbols to ignore
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
		},
	},

	-- Improved LSP user interface
	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "K", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Doc" },
			{ "<leader>la", "<cmd>Lspsaga code_action<CR>", desc = "Code Action" },
			{ "<leader>lr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
			{ "<leader>lp", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek Definition" },
			{ "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Line Diagnostics" },
			{ "<leader>lo", "<cmd>Lspsaga outline<CR>", desc = "Outline" },
			{ "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Previous Diagnostic" },
			{ "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next Diagnostic" },
		},
		opts = {
			ui = {
				border = "rounded",
				winblend = 0, -- No transparency
				theme = "round",
				title = true,
				devicon = true, -- Show devicons in code actions
				kind = true, -- Show kind in completion menu
			},
			symbol_in_winbar = {
				enable = false, -- We use nvim-navic instead
			},
			lightbulb = {
				enable = true, -- Show lightbulb for code actions
				sign = true, -- Show sign column
				virtual_text = false, -- Don't show virtual text
				debounce = 100, -- Debounce time
			},
			outline = {
				win_width = 30,
				auto_preview = false,
				auto_close = true,
				keys = {
					jump = "o",
					expand_collapse = "u",
					quit = "q",
				},
			},
			beacon = {
				enable = true, -- Show animated beacon when jumping to locations
				frequency = 8, -- Animation frequency
			},
			code_action = {
				show_server_name = true, -- Show where code action is coming from
				extend_gitsigns = true, -- Show actions from gitsigns
				keys = {
					quit = "q",
					exec = "<CR>",
				},
			},
			diagnostic = {
				show_code_action = true,
				show_source = true,
				jump_num_shortcut = true,
				keys = {
					exec_action = "o",
					quit = "q",
					go_action = "g",
				},
			},
			rename = {
				auto_save = true, -- Automatically save after rename
				keys = {
					quit = "<C-c>",
					exec = "<CR>",
					select = "x",
				},
			},
			finder = {
				max_height = 0.8,
				keys = {
					jump_to = "o",
					edit = "e",
					vsplit = "s",
					split = "i",
					tabe = "t",
					quit = { "q", "<ESC>" },
				},
			},
			definition = {
				keys = {
					edit = "o",
					vsplit = "s",
					split = "i",
					tabe = "t",
					quit = "q",
				},
			},
		},
	},

	-- Better UI for diagnostics
	{
		"folke/trouble.nvim",
		cmd = { "Trouble", "TroubleToggle", "TroubleClose", "TroubleRefresh" },
		opts = {
			position = "bottom", -- Position of trouble list
			height = 10, -- Height of the trouble list
			width = 50, -- Width of the list when position is left or right
			icons = true, -- Use icons
			mode = "workspace_diagnostics", -- Default mode
			fold_open = "", -- Icon for open folds
			fold_closed = "", -- Icon for closed folds
			group = true, -- Group results by file
			padding = true, -- Add extra padding
			action_keys = { -- Key mappings for actions in the trouble list
				close = "q", -- Close the list
				cancel = "<esc>", -- Cancel
				refresh = "r", -- Manually refresh
				jump = { "<cr>", "<tab>" }, -- Jump to the diagnostic or open / close folds
				open_split = { "<c-x>" }, -- Open buffer in new split
				open_vsplit = { "<c-v>" }, -- Open buffer in new vsplit
				open_tab = { "<c-t>" }, -- Open buffer in new tab
				jump_close = { "o" }, -- Jump to the diagnostic and close the list
				toggle_mode = "m", -- Toggle between "workspace" and "document" diagnostics mode
				toggle_preview = "P", -- Toggle auto_preview
				hover = "K", -- Opens a small popup with the full multiline message
				preview = "p", -- Preview the diagnostic location
				close_folds = { "zM", "zm" }, -- Close all folds
				open_folds = { "zR", "zr" }, -- Open all folds
				toggle_fold = { "zA", "za" }, -- Toggle fold of current file
				previous = "k", -- Previous item
				next = "j", -- Next item
			},
			indent_lines = true, -- Add an indent guide below the fold icons
			auto_open = false, -- Automatically open the list when you have diagnostics
			auto_close = false, -- Automatically close the list when you have no diagnostics
			auto_preview = true, -- Automatically preview the location of the diagnostic
			auto_fold = false, -- Automatically fold a file trouble list at creation
			auto_jump = { "lsp_definitions" }, -- For the given modes, automatically jump if there is only a single result
			signs = {
				-- Icons / text used for a diagnostic
				error = "",
				warning = "",
				hint = "󰌵",
				information = "",
				other = "﫠",
			},
			use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
		},
		keys = {
			{ "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
			{ "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics" },
			{ "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
			{ "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Location List" },
			{ "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List" },
			{ "gR", "<cmd>TroubleToggle lsp_references<cr>", desc = "LSP References" },
			{ "gD", "<cmd>TroubleToggle lsp_definitions<cr>", desc = "LSP Definitions" },
			{ "gT", "<cmd>TroubleToggle lsp_type_definitions<cr>", desc = "LSP Type Definitions" },
		},
	},

	-- Breadcrumbs in winbar
	{
		"SmiteshP/nvim-navic",
		lazy = true,
		init = function()
			vim.g.navic_silence = true
		end,
		opts = {
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
			depth_limit_indicator = "..",
			safe_output = true,
		},
	},
}
