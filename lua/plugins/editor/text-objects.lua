--------------------------------------------------------------------------------
-- Text Objects
--------------------------------------------------------------------------------
--
-- This module provides enhanced text objects for more precise editing:
--
-- Features:
-- 1. TreeSitter-based text objects for language constructs
-- 2. Enhanced motions with mini.ai
-- 3. Better surrounding management
-- 4. Smart pair manipulation
-- 5. Advanced targetting with flash.nvim
--
-- Text objects make it easier to select and manipulate specific
-- elements in your code, enhancing editing efficiency.
--------------------------------------------------------------------------------

return {
	-- Enhanced text objects with mini.ai
	{
		"echasnovski/mini.ai",
		version = false,
		event = "VeryLazy",
		dependencies = {
			-- Optional TreeSitter integration
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500, -- Maximum number of lines to look for text objects
				custom_textobjects = {
					-- Add custom text objects or override built-ins
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}, {}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^>]+>" }, -- HTML tag

					-- Additional useful text objects
					d = { "%f[%d]%d+" },                 -- Digits
					w = { "%f[%w]%w+" },                 -- Single word
					h = { "^#[^\n]+" },                  -- Markdown headers
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
				-- Options for showing window with textobject info
				silent = false,
				-- Array of custom textobject eager captures
				search_method = "cover_or_nearest",
			}
		end,
	},

	-- Better surrounding manipulation
	{
		"kylechui/nvim-surround",
		version = "*", -- Use latest release
		event = "VeryLazy",
		opts = {
			keymaps = {
				insert = "<C-g>s",   -- Insert surround in insert mode
				insert_line = "<C-g>S", -- Insert surround on new lines
				normal = "ys",       -- Add surround in normal mode
				normal_cur = "yss",  -- Add surround to current line
				normal_line = "yS",  -- Add surround to current line on new lines
				normal_cur_line = "ySS", -- Add surround to current line on new lines
				visual = "S",        -- Add surround in visual mode
				visual_line = "gS",  -- Add surround to selection on new lines
				delete = "ds",       -- Delete surround
				change = "cs",       -- Change surround
				change_line = "cS",  -- Change surround with new lines
			},
			aliases = {
				["a"] = ">",                               -- alias for angle brackets
				["b"] = ")",                               -- alias for brackets
				["B"] = "}",                               -- alias for braces
				["q"] = { "'", '"', "`" },                 -- quotes
				["s"] = { "}", "]", ")", ">", "'", '"', "`" }, -- Any surrounding
			},
			highlight = {
				duration = 150,   -- Highlight duration in milliseconds
			},
			move_cursor = "begin", -- Move cursor after adding surrounding
			indent_lines = function(start, stop)
				-- Only indent if more than one line is affected
				if start + 1 < stop then
					vim.cmd(string.format("silent %d,%d normal! >>", start + 1, stop))
				end
			end,
		},
	},

	-- Better targets (comma-separated arguments, doc comments, more)
	{
		"wellle/targets.vim",
		event = "VeryLazy",
		init = function()
			-- Configure targets.vim
			vim.g.targets_aiAI = { 'a', 'i', 'A', 'I' }
			vim.g.targets_nlNL = { 'n', 'l', 'N', 'L' }

			-- Set targets to seek backward first then forward
			vim.g.targets_seekRanges = 'bc cr cb cB lc ac Ac lr rr ll lb ar ab lB Ar aB Ab AB rb rB al Al'
		end,
	},

	-- Enhanced treesitter textobjects support
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = "nvim-treesitter/nvim-treesitter",
		lazy = true,
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- Auto-jump to textobj
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
							["aC"] = "@comment.outer",
							["iC"] = "@comment.inner",
						},
						selection_modes = {
							['@parameter.outer'] = 'v', -- charwise
							['@function.outer'] = 'V', -- linewise
							['@class.outer'] = 'V', -- linewise
						},
						include_surrounding_whitespace = false,
					},
					move = {
						enable = true,
						set_jumps = true, -- Add to jumplist
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
							["]a"] = "@parameter.inner",
							["]l"] = "@loop.outer",
							["]s"] = "@statement.outer",
							["]b"] = "@block.outer",
							["]C"] = "@comment.outer",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
							["]A"] = "@parameter.inner",
							["]L"] = "@loop.outer",
							["]S"] = "@statement.outer",
							["]B"] = "@block.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
							["[a"] = "@parameter.inner",
							["[l"] = "@loop.outer",
							["[s"] = "@statement.outer",
							["[b"] = "@block.outer",
							["[C"] = "@comment.outer",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
							["[A"] = "@parameter.inner",
							["[L"] = "@loop.outer",
							["[S"] = "@statement.outer",
							["[B"] = "@block.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>sa"] = "@parameter.inner", -- Swap with next parameter
							["<leader>sf"] = "@function.outer", -- Swap with next function
							["<leader>sm"] = "@statement.outer", -- Swap with next statement
						},
						swap_previous = {
							["<leader>sA"] = "@parameter.inner", -- Swap with previous parameter
							["<leader>sF"] = "@function.outer", -- Swap with previous function
							["<leader>sM"] = "@statement.outer", -- Swap with previous statement
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

			-- Enable repeatable jumps with ; and ,
			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

			-- Make builtin f, F, t, T, etc. repeatable with ; and ,
			local next_func, prev_func = ts_repeat_move.make_repeatable_move_pair(function()
				vim.cmd("normal! ;")
			end, function()
				vim.cmd("normal! ,")
			end)

			-- Map ; and , to repeat the last f, t, F, or T
			vim.keymap.set({ "n", "x", "o" }, ";", next_func, { desc = "Repeat latest f, t, F, or T" })
			vim.keymap.set(
				{ "n", "x", "o" },
				",",
				prev_func,
				{ desc = "Repeat latest f, t, F, or T in opposite direction" }
			)

			-- Make TreeSitter textobject motions repeatable with ; and ,
			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

			-- Repeat movement between functions, classes, etc.
			vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
			vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

			-- Make f, t, F, T work with ; and , (in case of conflict with ts motions)
			vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
			vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
			vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
			vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
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
			require("telescope").load_extension("yank_history")
		end,
	},

	-- Split/join blocks of code
	{
		"Wansmer/treesj",
		keys = {
			{ "gJ", "<cmd>TSJJoin<cr>",   desc = "Join Block" },
			{ "gS", "<cmd>TSJSplit<cr>",  desc = "Split Block" },
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
				-- Common formats for languages
				langs = {
					-- For all languages where TreeSitter is available
					['*'] = require('treesj.langs.utils').merge_preset_langs({}),
				},
			})
		end,
	},
}
