--------------------------------------------------------------------------------
-- Utility Plugins
--------------------------------------------------------------------------------
--
-- This module loads all utility plugins:
-- 1. Telescope (telescope.lua)
-- 2. Treesitter (treesitter.lua)
-- 3. Various utility plugins
--
-- These plugins provide general functionality used throughout Neovim.
--------------------------------------------------------------------------------

return {
	-- Import utility modules
	{ import = "plugins.util.telescope" },
	{ import = "plugins.util.treesitter" },

	-- Detect tabstop and shiftwidth automatically
	{
		"tpope/vim-sleuth",
		event = "BufReadPre",
	},

	-- Better buffer/window delete
	{
		"echasnovski/mini.bufremove",
		keys = {
			{
				"<leader>bd",
				function()
					require("mini.bufremove").delete(0, false)
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>bD",
				function()
					require("mini.bufremove").delete(0, true)
				end,
				desc = "Delete Buffer (Force)",
			},
		},
	},

	-- Extended character information
	{
		"tpope/vim-characterize",
		event = "BufReadPost",
		keys = {
			{ "ga", "<Plug>(characterize)", desc = "Show character info" },
		},
	},

	-- Add text objects based on indentation
	{
		"echasnovski/mini.ai",
		event = "BufReadPost",
		dependencies = { "nvim-treesitter-textobjects" },
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}, {}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^>]+>" }, -- HTML tag
				},
			}
		end,
	},

	-- Better surround text objects
	{
		"echasnovski/mini.surround",
		keys = function(_, keys)
			-- Populate the keys based on the user's options
			local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
			local opts = require("lazy.core.plugin").values(plugin, "opts", false)
			local mappings = {
				{ opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
				{ opts.mappings.delete, desc = "Delete surrounding" },
				{ opts.mappings.find, desc = "Find right surrounding" },
				{ opts.mappings.find_left, desc = "Find left surrounding" },
				{ opts.mappings.highlight, desc = "Highlight surrounding" },
				{ opts.mappings.replace, desc = "Replace surrounding" },
				{ opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
			}
			mappings = vim.tbl_filter(function(m)
				return m[1] and #m[1] > 0
			end, mappings)
			return vim.list_extend(mappings, keys)
		end,
		opts = {
			mappings = {
				add = "gsa", -- Add surrounding in Normal and Visual modes
				delete = "gsd", -- Delete surrounding
				find = "gsf", -- Find surrounding (to the right)
				find_left = "gsF", -- Find surrounding (to the left)
				highlight = "gsh", -- Highlight surrounding
				replace = "gsr", -- Replace surrounding
				update_n_lines = "gsn", -- Update `n_lines`
			},
		},
	},

	-- Add/delete comments
	{
				end,
			},
		},
		config = function(_, opts)
			require("mini.comment").setup(opts)
		end,
	},

	-- Alignment
	{
		"echasnovski/mini.align",
		event = "BufReadPost",
		config = function()
			require("mini.align").setup()
		end,
	},

	-- Better jumplist
	{
		"cbochs/portal.nvim",
		keys = {
			{ "<leader>j", "<cmd>Portal jumplist backward<cr>", desc = "Portal Jump Backward" },
			{ "<leader>k", "<cmd>Portal jumplist forward<cr>", desc = "Portal Jump Forward" },
		},
		dependencies = {
			"cbochs/grapple.nvim",
			"ThePrimeagen/harpoon",
		},
		opts = {
			window_options = {
				relative = "cursor",
				width = 80,
				height = 10,
				col = 0,
				row = 0,
				style = "minimal",
				border = "rounded",
				title = { { "Portal" } },
				title_pos = "center",
			},
		},
	},

	-- Motion
	{
			label = {
				style = "overlay",
				reuse = "all",
			},
			jump = {
				-- Autojump if there's only one match
				autojump = true,
			},
			modes = {
				-- Configuration for different modes
				search = {
					enabled = true,
				},
				char = {
					-- Allow jump over windows
					multi_window = true,
					-- Enable incremental input
					incremental = true,
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
				desc = "Flash",
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
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
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

	-- Search and replace
	{
		"windwp/nvim-spectre",
		keys = {
			{
				"<leader>sr",
				function()
					require("spectre").open()
				end,
				desc = "Replace in files",
			},
		},
	},

	-- Search/replace in visual selection
	{
		},
	},

	-- Immproved search highlighting
	{
		"rktjmp/highlight-current-n.nvim",
		event = "BufReadPost",
		config = function()
			require("highlight_current_n").setup({
				highlight_group = "IncSearch",
			})

			-- Override / and ? to highlight matches
			vim.keymap.set("n", "/", "<Plug>(highlight-current-n)/", { noremap = false })
			vim.keymap.set("n", "?", "<Plug>(highlight-current-n)?", { noremap = false })
			vim.keymap.set("n", "n", "<Plug>(highlight-current-n-n)", { noremap = false })
			vim.keymap.set("n", "N", "<Plug>(highlight-current-n-N)", { noremap = false })
		end,
	},

	-- Submodes and key mapping hints
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
				["<leader>gh"] = { name = "+hunks" },
				["<leader>q"] = { name = "+quit/session" },
				["<leader>s"] = { name = "+search" },
				["<leader>sn"] = { name = "+noice" },
				["<leader>u"] = { name = "+ui" },
				["<leader>w"] = { name = "+windows" },
				["<leader>x"] = { name = "+diagnostics/quickfix" },
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.add(opts.defaults)
		end,
	},

	-- Icons
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		opts = {
			default = true,
			strict = true,
			override = {
				zsh = {
					icon = "",
					color = "#428850",
					cterm_color = "65",
					name = "Zsh",
				},
			},
			override_by_filename = {
				[".gitignore"] = {
					icon = "",
					color = "#f1502f",
					name = "Gitignore",
				},
			},
		},
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

	-- Improved keymaps
	{
		"folke/lazyvim.nvim",
		event = "VeryLazy",
		config = function()
			-- List of Lua modules to load as part of the keymap configuration
			local keys = {
				-- Additional keys to bind for common operations
				{ "j", "v:count == 0 ? 'gj' : 'j'", expr = true, silent = true },
				{ "k", "v:count == 0 ? 'gk' : 'k'", expr = true, silent = true },
				{ "<C-s>", "<cmd>w<cr><esc>", desc = "Save file" },
				{ "<C-h>", "<cmd>wincmd h<cr>", desc = "Go to left window" },
				{ "<C-j>", "<cmd>wincmd j<cr>", desc = "Go to lower window" },
				{ "<C-k>", "<cmd>wincmd k<cr>", desc = "Go to upper window" },
				{ "<C-l>", "<cmd>wincmd l<cr>", desc = "Go to right window" },
				{ "<C-Up>", "<cmd>resize +2<cr>", desc = "Increase window height" },
				{ "<C-Down>", "<cmd>resize -2<cr>", desc = "Decrease window height" },
				{ "<C-Left>", "<cmd>vertical resize -2<cr>", desc = "Decrease window width" },
				{ "<C-Right>", "<cmd>vertical resize +2<cr>", desc = "Increase window width" },
				{ "<S-h>", "<cmd>bprevious<cr>", desc = "Prev buffer" },
				{ "<S-l>", "<cmd>bnext<cr>", desc = "Next buffer" },
				{ "[b", "<cmd>bprevious<cr>", desc = "Prev buffer" },
				{ "]b", "<cmd>bnext<cr>", desc = "Next buffer" },
				{ "<leader>bb", "<cmd>e #<cr>", desc = "Switch to Other Buffer" },
				{ "<leader>`", "<cmd>e #<cr>", desc = "Switch to Other Buffer" },
				{ "<leader>.", "<cmd>cd %:p:h<cr>", desc = "Set CWD to current file directory" },
			}

			-- Apply keymaps
			for _, key in ipairs(keys) do
				local mode = key.mode or "n"
				key.mode = nil
				vim.keymap.set(mode, key[1], key[2], key)
			end
		end,
	},

	-- Better quickfix
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		opts = {
			auto_enable = true,
			auto_resize_height = true,
			preview = {
				win_height = 12,
				win_vheight = 12,
				delay_syntax = 80,
				border = "rounded",
				show_title = false,
				should_preview_cb = function(bufnr, qwinid)
					local ret = true
					local bufname = vim.api.nvim_buf_get_name(bufnr)
					local fsize = vim.fn.getfsize(bufname)
					if fsize > 100 * 1024 then
						ret = false
					end
					return ret
				end,
			},
			func_map = {
				open = "<CR>",
				openc = "o",
				drop = "O",
				split = "<C-s>",
				vsplit = "<C-v>",
				tab = "t",
				tabb = "T",
				tabc = "u",
				tabdrop = "<C-t>",
				ptogglemode = "zp",
				ptoggleitem = "p",
				ptoggleauto = "P",
				pscrollup = "<C-b>",
				pscrolldown = "<C-f>",
				pscrollorig = "zo",
				prevfile = "<C-p>",
				nextfile = "<C-n>",
				prevhist = "<",
				nexthist = ">",
				lastleave = [['"]],
				stoggleup = "<S-Tab>",
				stoggledown = "<Tab>",
				stogglevm = "<Tab>",
				stogglebuf = "'<Tab>",
				sclear = "z<Tab>",
				filter = "zn",
				filterr = "zN",
				fzffilter = "zf",
			},
		},
	},

	-- Todo comments
	{
		"folke/todo-comments.nvim",
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = "BufReadPost",
		config = true,
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next todo comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous todo comment",
			},
			{ "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
			{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
		},
	},

	-- Better increase/decrease
	{
		"monaqa/dial.nvim",
		keys = {
			{
				"<C-a>",
				function()
					return require("dial.map").inc_normal()
				end,
				expr = true,
				desc = "Increment",
			},
			{
				"<C-x>",
				function()
					return require("dial.map").dec_normal()
				end,
				expr = true,
				desc = "Decrement",
			},
		},
		config = function()
			local augend = require("dial.augend")
			require("dial.config").augends:register_group({
				default = {
					augend.integer.alias.decimal,
					augend.integer.alias.hex,
					augend.date.alias["%Y/%m/%d"],
					augend.constant.alias.bool,
					augend.semver.alias.semver,
					augend.constant.new({
						elements = { "let", "const" },
						word = true,
						cyclic = true,
					}),
					augend.constant.new({
						elements = { "&&", "||" },
						word = false,
						cyclic = true,
					}),
				},
			})
		end,
	},

	-- Visual multi cursor
	{
		"mg979/vim-visual-multi",
		event = "BufReadPost",
		init = function()
			vim.g.VM_maps = {
				["Find Under"] = "<C-d>",
				["Find Subword Under"] = "<C-d>",
				["Select All"] = "<C-a>",
				["Select Cursor Down"] = "<M-j>",
				["Select Cursor Up"] = "<M-k>",
			}
		end,
	},
}
