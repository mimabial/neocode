--------------------------------------------------------------------------------
-- Text Objects
--------------------------------------------------------------------------------
--
-- This module provides enhanced text objects for more precise editing:
--
-- Features:
-- 1. Treesitter-based text objects for language constructs
-- 2. Additional text objects like entire buffer, line, indentation
-- 3. Custom text objects for specific languages
-- 4. Mappings to select, delete, and operate on text objects
--
-- Text objects make it easier to select and manipulate specific
-- elements in your code, enhancing editing efficiency.
--------------------------------------------------------------------------------

return {
	-- Treesitter text objects
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- Automatically jump forward to textobj
						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							["al"] = "@loop.outer",
							["il"] = "@loop.inner",
							["ai"] = "@conditional.outer",
							["ii"] = "@conditional.inner",
							["ab"] = "@block.outer",
							["ib"] = "@block.inner",
							["as"] = "@statement.outer",
							["is"] = "@statement.inner",
							["aB"] = "@block.outer", -- Alias for block
							["iB"] = "@block.inner",
							["aS"] = "@scope.outer", -- Scope (e.g., function body)
							["iS"] = "@scope.inner",
							["aC"] = "@comment.outer",
							["iC"] = "@comment.outer",
						},
						selection_modes = {
							["@parameter.outer"] = "v", -- charwise
							["@function.outer"] = "V", -- linewise
							["@class.outer"] = "V", -- linewise
						},
						include_surrounding_whitespace = true,
					},

					swap = {
						enable = true,
						swap_next = {
							["<leader>a"] = "@parameter.inner",
							["<leader>f"] = "@function.outer",
							["<leader>m"] = "@statement.outer",
						},
						swap_previous = {
							["<leader>A"] = "@parameter.inner",
							["<leader>F"] = "@function.outer",
							["<leader>M"] = "@statement.outer",
						},
					},

					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
							["]p"] = "@parameter.inner",
							["]i"] = "@conditional.outer",
							["]l"] = "@loop.outer",
							["]s"] = "@statement.outer",
							["]b"] = "@block.outer",
							["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
							["]P"] = "@parameter.inner",
							["]I"] = "@conditional.outer",
							["]L"] = "@loop.outer",
							["]S"] = "@statement.outer",
							["]B"] = "@block.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
							["[p"] = "@parameter.inner",
							["[i"] = "@conditional.outer",
							["[l"] = "@loop.outer",
							["[s"] = "@statement.outer",
							["[b"] = "@block.outer",
							["[z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
							["[P"] = "@parameter.inner",
							["[I"] = "@conditional.outer",
							["[L"] = "@loop.outer",
							["[S"] = "@statement.outer",
							["[B"] = "@block.outer",
						},
					},

					lsp_interop = {
						enable = true,
						border = "rounded",
						floating_preview_opts = {},
						peek_definition_code = {
							["<leader>pf"] = "@function.outer",
							["<leader>pc"] = "@class.outer",
						},
					},
				},
			})
		end,
	},

	-- Additional text objects
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
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
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^>]+>" }, -- HTML/XML tag

					-- Custom text objects
					d = { "%f[%d]%d+" }, -- Digits
					w = { "%f[%w]%w+" }, -- Word
					h = { "^#[^\n]+" }, -- Markdown/code headers
					b = { "^```.-\n(.-)```", "^```(.-)```" }, -- Markdown code blocks
					q = { "%f[%p'\"]%p['\"].-['\"]%p" }, -- Quoted text with punctuation
				},
				mappings = {
					-- Main textobject prefixes
					around = "a",
					inside = "i",

					-- Next/last text objects
					around_next = "an",
					around_last = "al",
					inside_next = "in",
					inside_last = "il",

					-- Move cursor to corresponding edge of `a` textobject
					goto_left = "g[",
					goto_right = "g]",
				},
			}
		end,
		config = function(_, opts)
			require("mini.ai").setup(opts)

			-- Add treesitter groups for `B` (block) text objects
			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

			-- Make builtin f, F, t, T, etc. repeatable with ; and ,
			local next_func, prev_func = ts_repeat_move.make_repeatable_move_pair(function()
				vim.cmd("normal! ;")
			end, function()
				vim.cmd("normal! ,")
			end)

			vim.keymap.set({ "n", "x", "o" }, ";", next_func, { desc = "Repeat latest f, t, F, or T" })
			vim.keymap.set(
				{ "n", "x", "o" },
				",",
				prev_func,
				{ desc = "Repeat latest f, t, F, or T in opposite direction" }
			)
		end,
	},

	-- Extend and enhance f/t motions
	{
		"ggandor/flit.nvim",
		keys = function()
			-- Generate key mappings for f, F, t, T with a repeat option
			local ret = {}
			for _, key in ipairs({ "f", "F", "t", "T" }) do
				ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
			end
			return ret
		end,
		opts = {
			keys = { f = "f", F = "F", t = "t", T = "T" },
			labeled_modes = "nx",
			multiline = true,
			opts = {},
		},
	},

	-- Enhanced f/t motions with labels
	{
		"ggandor/leap.nvim",
		keys = {
			{ "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
			{ "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
			{ "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
		},
		config = function()
			local leap = require("leap")
			leap.add_default_mappings()

			-- Use native highlighting
			leap.opts.highlight_unlabeled_phase_one_targets = true

			-- Define custom colors
			vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
			vim.api.nvim_set_hl(0, "LeapMatch", { fg = "white", bold = true, nocombine = true })
			vim.api.nvim_set_hl(0, "LeapLabelPrimary", { fg = "#ff007c", bold = true, nocombine = true })
			vim.api.nvim_set_hl(0, "LeapLabelSecondary", { fg = "#00dfff", bold = true, nocombine = true })

			-- Integrate with other plugins
			-- Smart-looking bidirectional search
			vim.keymap.set("n", "<Leader>J", function()
				local current_window = vim.fn.win_getid()
				require("leap").leap({
					target_windows = { current_window },
					action = function(target)
						target = target or {}
						local line, column = target.pos[1], target.pos[2]
						require("leap-search").leap_to_line(line, column)
					end,
				})
			end, { desc = "Leap search" })
		end,
	},

	-- Improved matching pairs navigation
	{
		"andymass/vim-matchup",
		event = { "BufReadPost" },
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
			vim.g.matchup_surround_enabled = 1
			vim.g.matchup_transmute_enabled = 1
			vim.g.matchup_matchparen_deferred = 1
			vim.g.matchup_matchparen_timeout = 100
			vim.g.matchup_matchparen_insert_timeout = 30

			require("nvim-treesitter.configs").setup({
				matchup = {
					enable = true,
					disable_virtual_text = false,
					include_match_words = true,
				},
			})
		end,
	},

	-- Enhanced keybindings for yanking and pasting
	{
		"gbprod/yanky.nvim",
		dependencies = { "kkharji/sqlite.lua" },
		opts = {
			ring = {
				history_length = 100,
				storage = "sqlite",
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
			{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
			{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after cursor" },
			{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before cursor" },
			{ "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put after cursor and leave cursor after" },
			{ "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put before cursor and leave cursor after" },
			{ "<c-n>", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
			{ "<c-p>", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
			{ "<leader>fy", "<cmd>Telescope yank_history<CR>", desc = "Yank history" },
		},
	},
}
