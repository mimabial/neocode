--------------------------------------------------------------------------------
-- UI Components
--------------------------------------------------------------------------------
--
-- This module loads all UI-related components:
-- 1. Colorscheme (colorscheme.lua)
-- 2. Status line (statusline.lua)
-- 3. Dashboard (dashboard.lua)
-- 4. File explorer (explorer.lua) - consolidated from multiple sources
-- 5. UI input improvements (dressing.lua)
-- 6. Notification system (notify.lua)
-- 7. Code context (navic.lua)
-- 8. Animations (animate.lua)
--
-- These plugins improve the visual appearance and interface of Neovim while
-- maintaining performance and responsiveness.
--------------------------------------------------------------------------------

return {
	-- Import UI modules
	{ import = "plugins.ui.colorscheme" }, -- Color themes
	{ import = "plugins.ui.statusline" }, -- Status line
	{ import = "plugins.ui.dashboard" },  -- Welcome screen
	{ import = "plugins.ui.notify" },     -- Notification system
	{ import = "plugins.ui.noice" },      -- Command line and messages
	{ import = "plugins.ui.explorer" },   -- Consolidated file explorer
	{ import = "plugins.ui.navic" },      -- Code context
	{ import = "plugins.ui.animate" },
	{ import = "plugins.ui.bufferline" },
	{ import = "plugins.ui.codewindows" },
	{ import = "plugins.ui.dressing" },
	{ import = "plugins.ui.headlines" },
	{ import = "plugins.ui.noice" },
	{ import = "plugins.ui.notify" },
	{ import = "plugins.ui.statusline" },

	-- Better UI components
	{
		"stevearc/dressing.nvim",
		lazy = true,
		init = function()
			-- Load dressing.nvim when vim.ui functions are called
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
				border = "rounded",
				win_options = { winblend = 10 },
			},
			select = {
				enabled = true,
				backend = { "telescope", "builtin" },
				telescope = { layout_strategy = "center" },
				builtin = {
					border = "rounded",
					win_options = { winblend = 10 },
				},
			},
		},
	},

	-- Active indent guides and indent text objects
	{
		"echasnovski/mini.indentscope",
		version = false,
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			symbol = "│",
			options = { try_as_border = true },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},

	-- Scrollbar with integration for diagnostics, search, git, etc.
	{
		"petertriho/nvim-scrollbar",
		event = "BufReadPost",
		opts = {
			show = true,
			handle = {
				text = " ",
				color = "#44475a",
				cterm = nil,
				highlight = "CursorColumn",
				hide_if_all_visible = true,
			},
			marks = {
				Search = {
					text = { "-", "=" },
					priority = 0,
					color = "#ff9e64",
				},
				Error = {
					text = { "-", "=" },
					priority = 1,
					color = "#f7768e",
				},
				Warn = {
					text = { "-", "=" },
					priority = 2,
					color = "#e0af68",
				},
				Info = {
					text = { "-", "=" },
					priority = 3,
					color = "#7aa2f7",
				},
				Hint = {
					text = { "-", "=" },
					priority = 4,
					color = "#1abc9c",
				},
				Misc = {
					text = { "-", "=" },
					priority = 5,
					color = "#9d7cd8",
				},
			},
			handlers = {
				cursor = true,
				diagnostic = true,
				gitsigns = true,
				handle = true,
				search = true,
			},
		},
	},

	-- Improved folds with pretty UI
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async",
			{
				"luukvbaal/statuscol.nvim",
				config = function()
					local builtin = require("statuscol.builtin")
					require("statuscol").setup({
						relculright = true,
						segments = {
							{ text = { builtin.foldfunc },      click = "v:lua.ScFa" },
							{ text = { "%s" },                  click = "v:lua.ScSa" },
							{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
						},
					})
				end,
			},
		},
		event = "BufReadPost",
		opts = {
			provider_selector = function()
				return { "treesitter", "indent" }
			end,
			open_fold_hl_timeout = 150,
			preview = {
				win_config = {
					border = { "", "─", "", "", "", "─", "", "" },
					winhighlight = "Normal:Folded",
					winblend = 0,
				},
				mappings = {
					scrollU = "<C-u>",
					scrollD = "<C-d>",
					jumpTop = "[",
					jumpBot = "]",
				},
			},
		},
		init = function()
			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- UFO folding keymaps
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
			vim.keymap.set("n", "K", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end)
		end,
	},

	-- Which-key for keybinding help
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
				["<leader>u"] = { name = "+ui" },
				["<leader>w"] = { name = "+windows" },
				["<leader>x"] = { name = "+diagnostics/quickfix" },
				["<leader>a"] = { name = "+ai" },
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.add(opts.defaults)
		end,
	},
}
