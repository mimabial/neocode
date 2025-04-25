--------------------------------------------------------------------------------
-- Plugins Configuration
--------------------------------------------------------------------------------
--
-- This is the main entry point for plugin configurations.
-- It imports all plugin modules from their respective directories:
--
-- Structure:
-- 1. Core plugins that are always loaded
-- 2. Import modules from subdirectories:
--    - editor/: Navigation, text objects, etc.
--    - coding/: Completion, LSP, snippets, etc.
--    - langs/: Language-specific plugins
--    - tools/: Git, terminal, etc.
--    - ui/: Themes, statusline, etc.
--    - util/: Telescope, which-key, etc.
--
-- Each plugin is configured with lazy.nvim's declarative syntax.
-- For more info about lazy.nvim, see: https://github.com/folke/lazy.nvim
--------------------------------------------------------------------------------

return {
	-- Core plugins (always loaded)

	-- Package Manager (manages itself)
	{
		"folke/lazy.nvim",
		version = false,
	},

	-- Icons (dependency for many plugins)
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		config = function()
			require("nvim-web-devicons").setup({
				override = {},
				default = true,
			})
		end,
	},

	-- Plenary (dependency for many plugins)
	{
		"nvim-lua/plenary.nvim",
		lazy = true,
	},

	-- Improved UI for messages, cmdline, and popup
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
				signature = {
					enabled = true,
					auto_open = {
						enabled = true,
						trigger = true,
						luasnip = true,
						throttle = 50,
					},
				},
				hover = {
					enabled = true,
					silent = false,
					view = nil, -- Use default
					opts = {},
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = true,
				lsp_doc_border = true,
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						kind = "",
						find = "written",
					},
					opts = { skip = true },
				},
			},
		},
		keys = {
			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},
			{
				"<leader>nl",
				function()
					require("noice").cmd("last")
				end,
				desc = "Noice Last Message",
			},
			{
				"<leader>nh",
				function()
					require("noice").cmd("history")
				end,
				desc = "Noice History",
			},
			{
				"<leader>na",
				function()
					require("noice").cmd("all")
				end,
				desc = "Noice All",
			},
			{
				"<leader>nd",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss All",
			},
			{
				"<c-f>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<c-f>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll forward",
				mode = { "i", "n", "s" },
			},
			{
				"<c-b>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<c-b>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll backward",
				mode = { "i", "n", "s" },
			},
		},
	},

	-- Better UI components
	{
		"stevearc/dressing.nvim",
		lazy = true,
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.input(...)
			end
		end,
		opts = {
			input = {
				enabled = true,
				default_prompt = "Input:",
				prompt_align = "left",
				insert_only = true,
				border = "rounded",
				relative = "cursor",
				prefer_width = 40,
				width = nil,
				max_width = { 140, 0.9 },
				min_width = { 20, 0.2 },
				win_options = {
					winblend = 10,
					winhighlight = "Normal:Normal,NormalNC:NormalNC",
				},
				mappings = {
					n = {
						["<Esc>"] = "Close",
						["<CR>"] = "Confirm",
					},
					i = {
						["<C-c>"] = "Close",
						["<CR>"] = "Confirm",
						["<Up>"] = "HistoryPrev",
						["<Down>"] = "HistoryNext",
					},
				},
				override = function(conf)
					return conf
				end,
				get_config = nil,
			},
			select = {
				enabled = true,
				backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
				trim_prompt = true,
				telescope = {
					layout_strategy = "center",
					layout_config = {
						width = 0.5,
						height = 0.35,
						prompt_position = "top",
						preview_cutoff = 120,
					},
				},
				nui = {
					position = "50%",
					size = nil,
					relative = "editor",
					border = {
						style = "rounded",
					},
					buf_options = {
						swapfile = false,
						filetype = "DressingSelect",
					},
					win_options = {
						winblend = 10,
					},
					max_width = 80,
					max_height = 40,
					min_width = 40,
					min_height = 10,
				},
				builtin = {
					border = "rounded",
					relative = "editor",
					win_options = {
						winblend = 10,
						winhighlight = "Normal:Normal,NormalNC:NormalNC",
					},
					width = nil,
					max_width = { 140, 0.8 },
					min_width = { 40, 0.2 },
					height = nil,
					max_height = 0.9,
					min_height = { 10, 0.2 },
					mappings = {
						["<Esc>"] = "Close",
						["<CR>"] = "Confirm",
					},
					override = function(conf)
						return conf
					end,
				},
				format_item_override = {},
				get_config = nil,
			},
		},
	},

	-- Notifications
	{
		"rcarriga/nvim-notify",
		keys = {
			{
				"<leader>un",
				function()
					require("notify").dismiss({ silent = true, pending = true })
				end,
				desc = "Dismiss all Notifications",
			},
		},
		opts = {
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { zindex = 100 })
			end,
			background_colour = "#000000",
			stages = "fade_in_slide_out",
			top_down = true,
		},
		config = function(_, opts)
			require("notify").setup(opts)
			vim.notify = require("notify")
		end,
	},

	-- Better vim.ui.select and vim.ui.input
	{
		"MunifTanjim/nui.nvim",
		lazy = true,
	},

	-- Which-key for keybinding hints
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			plugins = { spelling = true },
			defaults = {
				mode = { "n", "v" },
				["g"] = { name = "+goto" },
				["gz"] = { name = "+surround" },
				["]"] = { name = "+next" },
				["["] = { name = "+prev" },
				["<leader>b"] = { name = "+buffer" },
				["<leader>c"] = { name = "+code" },
				["<leader>f"] = { name = "+file/find" },
				["<leader>g"] = { name = "+git" },
				["<leader>h"] = { name = "+hunks" },
				["<leader>q"] = { name = "+quit/session" },
				["<leader>s"] = { name = "+search" },
				["<leader>u"] = { name = "+ui" },
				["<leader>w"] = { name = "+windows" },
				["<leader>x"] = { name = "+diagnostics/quickfix" },
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.register(opts.defaults)
		end,
	},

	-- Import all plugin modules
	{ import = "plugins.editor" }, -- Editor enhancements
	{ import = "plugins.coding" }, -- Coding support (LSP, completion, etc.)
	{ import = "plugins.langs" }, -- Language specific plugins
	{ import = "plugins.tools" }, -- Development tools (git, terminal, etc.)
	{ import = "plugins.ui" }, -- UI components
	{ import = "plugins.util" }, -- Utilities (telescope, etc.)
}
