--------------------------------------------------------------------------------
-- Editor Enhancements
--------------------------------------------------------------------------------
--
-- This module loads all editor enhancement plugins including:
-- 1. Navigation (navigation.lua)
-- 2. Text objects (text-objects.lua)
-- 3. Commenting, indentation, etc.
--
-- These plugins improve the basic editing experience within Neovim,
-- making text manipulation and navigation more efficient.
--------------------------------------------------------------------------------

return {
	-- Import all editor-related modules
	{ import = "plugins.editor.navigation" },
	{ import = "plugins.editor.text-objects" },

	-- Commenting support
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			local comment = require("Comment")
			local ts_context = require("ts_context_commentstring.integrations.comment_nvim")

			comment.setup({
				pre_hook = ts_context.create_pre_hook(),
				padding = true,
				sticky = true,
				ignore = "^$", -- Ignore empty lines
				toggler = {
					line = "gcc",
					block = "gbc",
				},
				opleader = {
					line = "gc",
					block = "gb",
				},
				extra = {
					above = "gcO",
					below = "gco",
					eol = "gcA",
				},
				mappings = {
					basic = true,
					extra = true,
				},
			})
		end,
	},

	-- Auto pairs for brackets, quotes, etc.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true, -- Use treesitter to check for pairs
				ts_config = {
					lua = { "string", "source" }, -- Don't add pairs in lua string treesitter nodes
					javascript = { "string", "template_string" }, -- Don't add pairs in javascript template_string
				},
				fast_wrap = {
					map = "<M-e>", -- Mapping to wrap with pairs
					chars = { "{", "[", "(", '"', "'" },
					pattern = [=[[%'%"%>%]%)%}%,]]=],
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "Search",
					highlight_grey = "Comment",
				},
				disable_filetype = { "TelescopePrompt", "vim" },
			})
		end,
	},

	-- Better surround operations
	{
		"kylechui/nvim-surround",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					insert = "<C-g>s",
					insert_line = "<C-g>S",
					normal = "ys",
					normal_cur = "yss",
					normal_line = "yS",
					normal_cur_line = "ySS",
					visual = "S",
					visual_line = "gS",
					delete = "ds",
					change = "cs",
				},
				aliases = {
					["a"] = ">", -- angle brackets
					["b"] = ")", -- brackets
					["B"] = "}", -- braces
					["q"] = { '"', "'", "`" }, -- quotes
					["s"] = { "}", "]", ")", ">", '"', "'", "`" }, -- any surrounding
				},
			})
		end,
	},

	-- Indentation guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
					tab_char = "│",
				},
				scope = { enabled = true },
				exclude = {
					filetypes = {
						"help",
						"alpha",
						"dashboard",
						"neo-tree",
						"Trouble",
						"trouble",
						"lazy",
						"mason",
						"notify",
						"toggleterm",
						"lazyterm",
					},
				},
			})
		end,
	},

	-- Better word motions
	{
		"chrisgrieser/nvim-spider",
		keys = {
			{ "w", "<cmd>lua require('spider').motion('w')<CR>", mode = { "n", "o", "x" }, desc = "Spider-w" },
			{ "e", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" }, desc = "Spider-e" },
			{ "b", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" }, desc = "Spider-b" },
			{ "ge", "<cmd>lua require('spider').motion('ge')<CR>", mode = { "n", "o", "x" }, desc = "Spider-ge" },
		},
		config = function()
			require("spider").setup({
				skipInsignificantPunctuation = true,
			})
		end,
	},

	-- Multiple cursors
	{
		"mg979/vim-visual-multi",
		branch = "master",
		event = "BufReadPost",
		init = function()
			vim.g.VM_leader = ";"
			vim.g.VM_theme = "iceblue"
			vim.g.VM_highlight_matches = "underline"
			vim.g.VM_maps = {
				["Find Under"] = "<C-d>",
				["Find Subword Under"] = "<C-d>",
				["Select Cursor Down"] = "<C-Down>",
				["Select Cursor Up"] = "<C-Up>",
			}
		end,
	},

	-- Highlight same words under cursor
	{
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("illuminate").configure({
				providers = {
					"lsp",
					"treesitter",
					"regex",
				},
				delay = 100,
				filetype_overrides = {},
				filetypes_denylist = {
					"dirbuf",
					"dirvish",
					"fugitive",
					"alpha",
					"NvimTree",
					"lazy",
					"neogitstatus",
					"Trouble",
					"lir",
					"Outline",
					"spectre_panel",
					"toggleterm",
					"DressingSelect",
					"TelescopePrompt",
				},
				under_cursor = true,
				large_file_cutoff = 2000,
				large_file_overrides = nil,
			})
		end,
	},

	-- Split/join blocks of code
	{
		"Wansmer/treesj",
		keys = {
			{ "gJ", "<cmd>TSJJoin<cr>", desc = "Join Block" },
			{ "gS", "<cmd>TSJSplit<cr>", desc = "Split Block" },
			{ "gT", "<cmd>TSJToggle<cr>", desc = "Toggle Block" },
		},
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesj").setup({
				use_default_keymaps = false,
				check_syntax_error = true,
				max_join_length = 120,
				cursor_behavior = "hold",
				notify = true,
			})
		end,
	},

	-- Highlight todo comments
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("todo-comments").setup({
				signs = true,
				keywords = {
					FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "FIX", "ISSUE" } },
					TODO = { icon = " ", color = "info" },
					HACK = { icon = " ", color = "warning" },
					WARN = { icon = " ", color = "warning", alt = { "WARNING", "ATTENTION", "CAUTION" } },
					PERF = { icon = " ", color = "default", alt = { "PERFORMANCE", "OPTIMIZE" } },
					NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
					TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
				},
				highlight = {
					multiline = true,
					multiline_pattern = "^.",
					multiline_context = 10,
					before = "",
					after = "fg",
					keyword = "wide",
					max_line_len = 400,
					pattern = [[.*<(KEYWORDS)\s*:]],
				},
				colors = {
					error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
					warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
					info = { "DiagnosticInfo", "#2563EB" },
					hint = { "DiagnosticHint", "#10B981" },
					default = { "Identifier", "#7C3AED" },
					test = { "Identifier", "#FF00FF" },
				},
			})
		end,
		keys = {
			{ "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
			{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find Todos" },
		},
	},

	-- Add more text manipulation plugins as needed
}
