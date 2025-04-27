--------------------------------------------------------------------------------
-- Navigation Enhancements
--------------------------------------------------------------------------------
--
-- This module provides enhanced navigation capabilities:
--
-- Features:
-- 1. Quick jumping within the buffer with flash.nvim (modern leap replacement)
-- 2. File browsing with oil.nvim (buffer-based explorer)
-- 3. Harpoon for quick file navigation
-- 4. Better marks and bookmarks
-- 5. Enhanced motion commands
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
			harpoon:setup({
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
			require("telescope").load_extension("harpoon")
		end,
		keys = {
			{ "<leader>hf", "<cmd>Telescope harpoon marks<cr>", desc = "Harpoon Find" },
		},
	},

	-- Buffer-based file explorer with oil.nvim
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
		},
		config = function(_, opts)
			require("oil").setup(opts)

			-- Add command to toggle between float and normal modes
			vim.api.nvim_create_user_command("OilFloat", function()
				require("oil").open_float()
			end, { desc = "Open Oil in float mode" })

			-- Add keybinding for the float mode
			vim.keymap.set("n", "<leader>fo", "<cmd>OilFloat<cr>", { desc = "Float File Explorer" })
		end,
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
						local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
						local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
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
}
