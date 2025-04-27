--------------------------------------------------------------------------------
-- Navigation Enhancements
--------------------------------------------------------------------------------
--
-- This module provides enhanced navigation capabilities:
--
-- Features:
-- 1. Quick jumping within the buffer with flash.nvim (modern leap replacement)
-- 2. Quick file navigation with harpoon
-- 3. Better marks and bookmarks
-- 4. Enhanced motion commands
-- 5. Session management
--
-- These plugins make it easier to navigate within and between files,
-- enhancing movement efficiency throughout your codebase.
--------------------------------------------------------------------------------

return {
	-- Quick navigation with flash.nvim (modern replacement for hop/leap)
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

	-- Quick file navigation with Harpoon
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2", -- Use the new version
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")

			-- Setup harpoon
			harpoon.setup({
				settings = {
					save_on_toggle = true,
					sync_on_ui_close = true,
					key = function()
						-- Get a unique key per project
						return vim.loop.cwd()
					end,
				},
				-- Configuration for the Harpoon UI menu
				menu = {
					width = math.floor(vim.api.nvim_win_get_width(0) * 0.6),
					height = math.floor(vim.api.nvim_win_get_height(0) * 0.6),
					borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				},
			})

			-- Set keymaps for harpoon
			vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end,
				{ desc = "Harpoon Add File" })
			vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
				{ desc = "Harpoon Menu" })

			-- Quick navigation to the first 4 harpoon marks
			vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end,
				{ desc = "Harpoon File 1" })
			vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end,
				{ desc = "Harpoon File 2" })
			vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end,
				{ desc = "Harpoon File 3" })
			vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end,
				{ desc = "Harpoon File 4" })

			-- Navigate through harpoon marks
			vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end,
				{ desc = "Harpoon Prev File" })
			vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end,
				{ desc = "Harpoon Next File" })

			-- Add Telescope extension for harpoon
			local telescope_available, telescope = pcall(require, "telescope")
			if telescope_available then
				telescope.load_extension("harpoon")
			end
		end,
		keys = {
			{ "<leader>hf", "<cmd>Telescope harpoon marks<cr>", desc = "Harpoon Find" },
		},
	},

	-- Better marks and bookmark management
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
					virt_text = "bookmark",
					annotate = false,
				},
				mappings = {
					set = "m",
					set_next = "m,",
					toggle = "m;",
					next = "m]",
					prev = "m[",
					preview = "m:",
					next_bookmark = "m}",
					prev_bookmark = "m{",
					delete = "dm",
					delete_line = "dm-",
					delete_bookmark = "dm=",
					delete_buf = "dm<space>",
				},
			})
		end,
		keys = {
			{ "m",  desc = "Set mark" },
			{ "m]", desc = "Next mark" },
			{ "m[", desc = "Previous mark" },
			{ "m;", desc = "Toggle mark" },
			{ "m:", desc = "Preview mark" },
			{ "dm", desc = "Delete mark" },
		},
	},

	-- Session management
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {
			-- Directory where session files are stored
			dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
			-- Options to save
			options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
			-- Don't save buffers for certain filetypes
			pre_save = function()
				-- Don't save these filetypes
				local ignored_filetypes = { "gitcommit" }
				-- Close floating windows before saving
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_get_config(win).relative ~= "" then
						vim.api.nvim_win_close(win, false)
					end
				end
				-- Close unwanted buffers
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buf) then
						local buftype = vim.bo[buf].buftype
						local filetype = vim.bo[buf].filetype
						if buftype == "nofile" or vim.tbl_contains(ignored_filetypes, filetype) then
							vim.api.nvim_buf_delete(buf, { force = true })
						end
					end
				end
			end,
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

	-- Enhanced yanking and history
	{
		"gbprod/yanky.nvim",
		dependencies = { { "kkharji/sqlite.lua", optional = true } },
		opts = {
			ring = {
				history_length = 100,
				storage = "memory", -- or "sqlite" if sqlite.lua is available
				storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db",
				sync_with_numbered_registers = true,
				cancel_event = "update",
			},
			picker = {
				select = {
					action = nil,
				},
				telescope = {
					mappings = nil,
				},
			},
			system_clipboard = {
				sync_with_ring = true,
			},
			highlight = {
				on_put = true,
				on_yank = true,
				timer = 500,
			},
			preserve_cursor_position = {
				enabled = true,
			},
		},
		keys = {
			{ "y",          "<Plug>(YankyYank)",               mode = { "n", "x" },                         desc = "Yank text" },
			{ "p",          "<Plug>(YankyPutAfter)",           mode = { "n", "x" },                         desc = "Put after cursor" },
			{ "P",          "<Plug>(YankyPutBefore)",          mode = { "n", "x" },                         desc = "Put before cursor" },
			{ "gp",         "<Plug>(YankyGPutAfter)",          mode = { "n", "x" },                         desc = "Put after cursor and leave cursor after" },
			{ "gP",         "<Plug>(YankyGPutBefore)",         mode = { "n", "x" },                         desc = "Put before cursor and leave cursor after" },
			{ "<c-n>",      "<Plug>(YankyCycleForward)",       desc = "Cycle forward through yank history" },
			{ "<c-p>",      "<Plug>(YankyCycleBackward)",      desc = "Cycle backward through yank history" },
			{ "<leader>fy", "<cmd>Telescope yank_history<CR>", desc = "Yank history" },
		},
		config = function(_, opts)
			require("yanky").setup(opts)

			-- Setup Telescope extension if available
			local has_telescope, telescope = pcall(require, "telescope")
			if has_telescope then
				telescope.load_extension("yank_history")
			end
		end,
	},

	-- Portal for enhanced jumplist navigation
	{
		"cbochs/portal.nvim",
		keys = {
			{ "<leader>j", "<cmd>Portal jumplist backward<cr>", desc = "Portal Jump Backward" },
			{ "<leader>k", "<cmd>Portal jumplist forward<cr>",  desc = "Portal Jump Forward" },
		},
		dependencies = {
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
}
