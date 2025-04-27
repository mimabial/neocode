--------------------------------------------------------------------------------
-- Navigation Enhancements
--------------------------------------------------------------------------------
--
-- This module provides enhanced navigation capabilities:
--
-- Features:
-- 1. Quick jumping within the buffer
-- 2. Buffer and tab navigation
-- 3. File browsing
-- 4. Visualization aids
-- 5. Session management
--
-- These plugins make it easier to navigate within and between files,
-- enhancing movement efficiency throughout your codebase.
--------------------------------------------------------------------------------

return {
	-- Quick navigation - EasyMotion/Hop replacement
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			labels = "asdfghjklqwertyuiopzxcvbnm",
			search = {
				-- Search behavior options
				multi_window = true,
				incremental = true,
				exclude = {
					"notify",
					"cmp_menu",
					"noice",
					"flash_prompt",
					function(win)
						-- Exclude non-focusable windows
						return not vim.api.nvim_win_get_config(win).focusable
					end,
				},
			},
			jump = {
				-- Jump behavior options
				nohlsearch = true,
				autojump = true,
			},
			label = {
				-- Label appearance options
				uppercase = false,
				exclude = "",
				rainbow = {
					enabled = true,
					shade = 5,
				},
			},
			modes = {
				-- Mode-specific configuration
				char = {
					enabled = true,
					keys = { "f", "F", "t", "T", ";", "," },
					jump_labels = true,
				},
				search = {
					enabled = true,
					highlight = {
						backdrop = true,
						matches = true,
					},
				},
				treesitter = {
					labels = "abcdefghijklmnopqrstuvwxyz",
					jump = { pos = "range" },
				},
			},
			prompt = {
				enabled = true,
				prefix = { { "⚡", "FlashPromptIcon" } },
				win_config = {
					relative = "editor",
					width = 40,
					height = 1,
					row = -1, -- Bottom of editor
					col = "50%",
					border = "rounded",
				},
			},
		},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash Jump",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Flash Remote",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Flash Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},

	-- Enhanced folder/file browser
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "Oil",
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
		},
		opts = {
			-- Oil configuration
			columns = {
				"icon",
				"permissions",
				"size",
				"mtime",
			},
			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},
			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "n",
			},
			default_file_explorer = true,
			restore_win_options = true,
			skip_confirm_for_simple_edits = false,
			delete_to_trash = true,
			prompt_save_on_select_new_entry = true,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-v>"] = "actions.select_vsplit",
				["<C-s>"] = "actions.select_split",
				["<C-t>"] = "actions.select_tab",
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-r>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "actions.tcd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
			},
			use_default_keymaps = true,
			view_options = {
				show_hidden = false,
				is_hidden_file = function(name)
					return vim.startswith(name, ".")
				end,
				sort = {
					-- sort order: directories, files, symlinks
					func = "name",
					reverse = false,
				},
			},
			float = {
				padding = 2,
				max_width = 80,
				max_height = 30,
				border = "rounded",
				win_options = {
					winblend = 10,
				},
			},
			preview = {
				max_width = 0.7,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = 0.8,
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
			},
			progress = {
				max_width = 0.3,
				min_width = { 20, 0.2 },
				width = nil,
				max_height = 0.3,
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				minimized_border = "none",
				win_options = {
					winblend = 0,
				},
			},
		},
	},

	-- File browser with telescope integration
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").load_extension("file_browser")
		end,
		keys = {
			{
				"<leader>fB",
				"<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>",
				desc = "File Browser (current dir)",
			},
		},
	},

	-- Advanced search and replace
	{
		"nvim-pack/nvim-spectre",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{
				"<leader>sr",
				function()
					require("spectre").open()
				end,
				desc = "Replace in files (Spectre)",
			},
		},
		config = function()
			require("spectre").setup({
				color_devicons = true,
				open_cmd = "vnew",
				live_update = true,
				line_sep_start = "┌─────────────────────────────────────────────────────────",
				result_padding = "│  ",
				line_sep = "└─────────────────────────────────────────────────────────",
				highlight = {
					ui = "String",
					search = "DiffChange",
					replace = "DiffDelete",
				},
			})
		end,
	},

	-- Buffer and tab management
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				mode = "buffers",
				numbers = "none",
				close_command = "bdelete! %d",
				right_mouse_command = "bdelete! %d",
				left_mouse_command = "buffer %d",
				middle_mouse_command = nil,
				indicator = {
					icon = "▎",
					style = "icon",
				},
				buffer_close_icon = "",
				modified_icon = "●",
				close_icon = "",
				left_trunc_marker = "",
				right_trunc_marker = "",
				max_name_length = 18,
				max_prefix_length = 15,
				tab_size = 18,
				diagnostics = "nvim_lsp",
				diagnostics_update_in_insert = false,
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						text_align = "center",
						separator = true,
					},
				},
				color_icons = true,
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = true,
				show_tab_indicators = true,
				separator_style = "thin",
				enforce_regular_tabs = false,
				always_show_bufferline = true,
				sort_by = "insert_after_current",
			},
		},
		keys = {
			{ "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
			{ "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick & close buffer" },
			{ "<leader>bP", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle pin buffer" },
			{ "<leader>bC", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Close all unpinned buffers" },
		},
	},

	-- Remember last location in files
	{
		"ethanholz/nvim-lastplace",
		event = "BufReadPre",
		config = function()
			require("nvim-lastplace").setup({
				lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
				lastplace_ignore_filetype = { "gitcommit", "gitrebase" },
				lastplace_open_folds = true,
			})
		end,
	},

	-- UI for tabs
	{
		"nanozuki/tabby.nvim",
		event = "VeryLazy",
		config = function()
			local util = require("tabby.util")
			local filename = require("tabby.filename")
			local cwd = function()
				return " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " "
			end

			require("tabby.tabline").set(function(line)
				return {
					{
						{ cwd(), hl = "TabLineSel" },
						line.sep("", "TabLineSel", "TabLine"),
					},
					line.tabs().foreach(function(tab)
						local hl = tab.is_current() and "TabLineSel" or "TabLine"
						return {
							line.sep("", hl, "TabLine"),
							tab.is_current() and "" or "",
							tab.number(),
							tab.name(),
							tab.close_btn(""),
							line.sep("", hl, "TabLine"),
							hl = hl,
							margin = " ",
						}
					end),
					line.spacer(),
					line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
						local hl = win.is_current() and "TabLineSel" or "TabLine"
						return {
							line.sep("", hl, "TabLine"),
							win.is_current() and "" or "",
							filename.unique(win.buf_name()),
							line.sep("", hl, "TabLine"),
							hl = hl,
							margin = " ",
						}
					end),
					{
						line.sep("", "TabLineSel", "TabLine"),
						{ "  ", hl = "TabLineSel" },
					},
					hl = "TabLine",
				}
			end)
		end,
	},

	-- Scrollbar with diagnostics and git status
	{
				marks = {
					Search = {
						text = { "-", "=" },
						priority = 0,
						color = colors.orange,
						cterm = nil,
						highlight = "Search",
					},
					Error = {
						text = { "-", "=" },
						priority = 1,
						color = colors.error,
						cterm = nil,
						highlight = "DiagnosticVirtualTextError",
					},
					Warn = {
						text = { "-", "=" },
						priority = 2,
						color = colors.warning,
						cterm = nil,
						highlight = "DiagnosticVirtualTextWarn",
					},
					Info = {
						text = { "-", "=" },
						priority = 3,
						color = colors.info,
						cterm = nil,
						highlight = "DiagnosticVirtualTextInfo",
					},
					Hint = {
						text = { "-", "=" },
						priority = 4,
						color = colors.hint,
						cterm = nil,
						highlight = "DiagnosticVirtualTextHint",
					},
					Misc = {
						text = { "-", "=" },
						priority = 5,
						color = colors.purple,
						cterm = nil,
						highlight = "Normal",
					},
				},
				excluded_buftypes = {
					"terminal",
				},
				excluded_filetypes = {
					"prompt",
					"TelescopePrompt",
					"noice",
					"NvimTree",
					"neo-tree",
				},
				autocmd = {
					render = {
						"BufWinEnter",
						"TabEnter",
						"TermEnter",
						"WinEnter",
						"CmdwinLeave",
						"TextChanged",
						"VimResized",
						"WinScrolled",
					},
					clear = {
						"BufWinLeave",
						"TabLeave",
						"TermLeave",
						"WinLeave",
					},
				},
				handlers = {
					cursor = true,
					diagnostic = true,
					gitsigns = true,
					handle = true,
					search = true,
				},
			})
		end,
	},

	-- Better marks
	{
		"chentoast/marks.nvim",
		event = "BufReadPost",
		config = function()
			require("marks").setup({
				default_mappings = true,
				builtin_marks = { ".", "<", ">", "^" },
				cyclic = true,
				force_write_shada = false,
				refresh_interval = 250,
				sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
				excluded_filetypes = {},
				bookmark_0 = {
					sign = "⚑",
					virt_text = "hello world",
					annotate = false,
				},
				mappings = {},
			})
		end,
	},

	-- Session management
	{
			pre_save = nil,
			save_empty = false,
		},
		keys = {
			{
				"<leader>qs",
				function()
					require("persistence").load()
				end,
				desc = "Restore Session",
			},
			{
				"<leader>ql",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Restore Last Session",
			},
			{
				"<leader>qd",
				function()
					require("persistence").stop()
				end,
				desc = "Don't Save Current Session",
			},
		},
	},
}
