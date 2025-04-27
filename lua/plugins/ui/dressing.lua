--------------------------------------------------------------------------------
-- Enhanced Input UI
--------------------------------------------------------------------------------
--
-- This module configures dressing.nvim, which enhances Neovim's vim.ui interfaces:
--
-- Features:
-- 1. Stylish floating window for vim.ui.input
-- 2. Telescope integration for vim.ui.select
-- 3. Consistent styling for UI elements
-- 4. Customizable appearance and behavior
-- 5. Improved keyboard navigation
--
-- These enhancements make built-in UI elements more visually appealing
-- and consistent with the rest of your Neovim configuration.
--------------------------------------------------------------------------------

return {
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
		-- Configuration for input fields
		input = {
			-- Set to false to disable the vim.ui.input implementation
			enabled = true,

			-- Default prompt string
			default_prompt = "Input:",

			-- Can be 'left', 'right', or 'center'
			prompt_align = "left",

			-- When true, <Esc> will close the modal
			insert_only = true,

			-- When true, input will start in insert mode
			start_in_insert = true,

			-- These are passed to nvim_open_win
			anchor = "SW",
			border = "rounded",

			-- Window position, relative to anchor point
			relative = "cursor",

			-- Window layout preferences
			prefer_width = 40,
			width = nil,
			max_width = { 140, 0.9 },
			min_width = { 20, 0.2 },

			-- Window height
			height = nil,
			max_height = 0.9,
			min_height = { 1, 0.1 },

			-- Override the vim.ui.input interface
			override = function(conf)
				-- This function allows you to override the configuration
				-- for specific inputs. You can check conf.prompt to
				-- identify which input is being set up.

				-- Example: special handling for file paths
				if conf.prompt and conf.prompt:find("Path:") then
					conf.prefer_width = 60
				end

				-- Example: use different border style for Git commit messages
				if conf.prompt and conf.prompt:find("Commit") then
					conf.border = "double"
				end

				return conf
			end,

			-- Window transparency
			win_options = {
				-- Window transparency (0-100)
				winblend = 10,
				-- Set window highlight groups for different parts of the window
				winhighlight = "Normal:Normal,NormalNC:NormalNC,FloatBorder:FloatBorder",
			},

			-- Custom mappings for input window
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
					["<C-p>"] = "HistoryPrev",
					["<C-n>"] = "HistoryNext",
				},
			},

			-- Custom history handler
			history = {
				-- Maximum number of inputs to remember
				max_entries = 100,
				-- Patterns to skip history for
				skip_patterns = { "^%s+$" },
			},
		},

		-- Configuration for item selection
		select = {
			-- Set to false to disable the vim.ui.select implementation
			enabled = true,

			-- Priority list of preferred vim.select implementations
			backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },

			-- Trim the prompt text
			trim_prompt = true,

			-- Options for telescope selector
			telescope = {
				-- Can be 'dropdown', 'cursor', 'bottom_pane', etc.
				layout_strategy = "center",
				layout_config = {
					width = 0.5,
					height = 0.35,
					prompt_position = "top",
					preview_cutoff = 120,
				},
			},

			-- Options for fzf selector
			fzf = {
				window = {
					width = 0.5,
					height = 0.5,
				},
			},

			-- Options for fzf-lua
			fzf_lua = {
				-- Options passed to fzf-lua
				winopts = {
					width = 0.5,
					height = 0.5,
				},
			},

			-- Options for nui Menu
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
					cursorline = true,
				},
				max_width = 80,
				max_height = 40,
				min_width = 40,
				min_height = 10,
			},

			-- Options for built-in selector
			builtin = {
				-- Display options for the builtin selector
				show_numbers = true,
				border = "rounded",
				relative = "editor",
				buf_options = {},
				win_options = {
					winblend = 10,
					cursorline = true,
					winhighlight = "Normal:Normal,NormalNC:NormalNC,FloatBorder:FloatBorder",
				},
				width = nil,
				max_width = { 140, 0.8 },
				min_width = { 40, 0.2 },
				height = nil,
				max_height = 0.9,
				min_height = { 10, 0.2 },

				-- Mappings for the builtin selector
				mappings = {
					["<Esc>"] = "Close",
					["<C-c>"] = "Close",
					["<CR>"] = "Confirm",
				},
			},

			-- Format function for displaying items
			format_item_override = {
				-- Example: Format filetype items
				filetype = function(filetype)
					return filetype:upper()
				end,
			},

			-- Handle specific prompt types differently
			get_config = function(opts)
				if opts.kind == "codeaction" then
					return {
						backend = "telescope",
						telescope = {
							layout_strategy = "cursor",
							layout_config = {
								width = 0.7,
								height = 0.5,
							},
						},
					}
				end
			end,
		},
	},
}
