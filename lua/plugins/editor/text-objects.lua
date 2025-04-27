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
-- 5. Treesitter-aware text objects
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

	-- Enhanced treesitter textobjects support
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			---@diagnostic disable-next-line: missing-fields
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

			-- Make TreeSitter textobject motions repeatable with ; and ,
			local rm = require("nvim-treesitter.textobjects.repeatable_move")

			local function move_f()
				vim.api.nvim_feedkeys("f", "n", true)
			end

			local function move_F()
				vim.api.nvim_feedkeys("F", "n", true)
			end

			local function move_t()
				vim.api.nvim_feedkeys("t", "n", true)
			end

			local function move_T()
				vim.api.nvim_feedkeys("T", "n", true)
			end

			local f, F = rm.make_repeatable_move_pair(move_f, move_F)
			local t, T = rm.make_repeatable_move_pair(move_t, move_T)

			-- Repeat movement between functions, classes, etc.
			vim.keymap.set({ "n", "x", "o" }, ";", rm.repeat_last_move, { desc = "Repeat last move" })
			vim.keymap.set({ "n", "x", "o" }, ",", rm.repeat_last_move_opposite, { desc = "Repeat last move (opposite)" })

			-- Make f, t, F, T work with ; and , (in case of conflict with ts motions)
			vim.keymap.set({ "n", "x", "o" }, "f", f, { desc = "Repeatable f" })
			vim.keymap.set({ "n", "x", "o" }, "F", F, { desc = "Repeatable F" })
			vim.keymap.set({ "n", "x", "o" }, "t", t, { desc = "Repeatable t" })
			vim.keymap.set({ "n", "x", "o" }, "T", T, { desc = "Repeatable T" })
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

			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				matchup = {
					enable = true,
					disable_virtual_text = false,
					include_match_words = true,
				},
			})
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
