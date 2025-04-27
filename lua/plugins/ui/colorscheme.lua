--------------------------------------------------------------------------------
-- Colorscheme Configuration
--------------------------------------------------------------------------------
--
-- This module configures color themes and styling for Neovim:
--
-- Features:
-- 1. Modern colorschemes with semantic highlighting
-- 2. Theme switching capabilities
-- 3. Advanced customization options
-- 4. Transparency support
-- 5. Consistent highlighting across plugins
--
-- The colorscheme is a key element of the UI that affects readability
-- and the overall user experience.
--------------------------------------------------------------------------------

return {
	-- Tokyonight - A clean, dark Neovim theme
	{
		"folke/tokyonight.nvim",
		lazy = false, -- We want the colorscheme to load immediately
		priority = 1000, -- Load before other plugins
		opts = {
			style = "night", -- The theme comes in five styles: storm, moon, night, day, terminal
			transparent = false, -- Enable this to disable the background color
			terminal_colors = true, -- Configure the colors used when opening a `:terminal`
			styles = {
				-- Style to be applied to different syntax groups
				comments = { italic = true },
				keywords = { italic = true },
				functions = {},
				variables = {},
				sidebars = "dark", -- Style for sidebars
				floats = "dark", -- Style for floating windows
			},
			sidebars = {
				"qf",
				"help",
				"terminal",
				"packer",
				"spectre_panel",
				"telescopeprompt",
				"toggleterm",
				"nvim-tree",
			},
			day_brightness = 0.3, -- Adjusts the brightness of the colors of the Day style
			hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines
			dim_inactive = true, -- Dims inactive windows
			lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
			on_colors = function(colors)
				-- Customize theme colors
				colors.hint = colors.orange
				colors.error = colors.red
			end,
			on_highlights = function(highlights, colors)
				-- Customize specific highlight groups
				highlights.DiagnosticVirtualTextError = { fg = colors.error, bg = colors.none, italic = true }
				highlights.DiagnosticVirtualTextWarn = { fg = colors.warning, bg = colors.none, italic = true }
				highlights.DiagnosticVirtualTextInfo = { fg = colors.info, bg = colors.none, italic = true }
				highlights.DiagnosticVirtualTextHint = { fg = colors.hint, bg = colors.none, italic = true }

				-- Custom highlights for plugins
				highlights.NeoTreeNormal = { bg = colors.bg_dark }
				highlights.MiniIndentscopeSymbol = { fg = colors.blue }
				highlights.IlluminatedWordText = { bg = colors.fg_gutter, bold = false }
				highlights.IlluminatedWordRead = { bg = colors.fg_gutter, bold = false }
				highlights.IlluminatedWordWrite = { bg = colors.fg_gutter, bold = false }

				-- Remove background from line numbers for cleaner look
				highlights.LineNr = { fg = colors.fg_gutter, bg = colors.none }

				-- Custom fold highlights
				highlights.Folded = { fg = colors.blue, bg = colors.terminal_black, italic = true }
			end,
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			-- Don't set colorscheme here, we'll do it at the end
		end,
	},

	-- Catppuccin - Soothing pastel theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			background = { -- Use the given styles accordingly
				light = "latte",
				dark = "mocha",
			},
			transparent_background = false,
			term_colors = true,
			dim_inactive = {
				enabled = true,
				shade = "dark",
				percentage = 0.15,
			},
			no_italic = false, -- Force no italic
			no_bold = false, -- Force no bold
			no_underline = false, -- Force no underline
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
				loops = {},
				functions = {},
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
				operators = {},
			},
			color_overrides = {},
			custom_highlights = {},
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				neotree = true,
				treesitter = true,
				notify = true,
				mini = true,
				leap = true,
				fidget = true,
				which_key = true,
				dashboard = true,
				neogit = true,
				noice = true,
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
				},
				dap = {
					enabled = true,
					enable_ui = true,
				},
				indent_blankline = {
					enabled = true,
					colored_indent_levels = false,
				},
				telescope = {
					enabled = true,
				},
				markdown = true,
				mason = true,
				lsp_trouble = true,
				navic = {
					enabled = true,
					custom_bg = "NONE",
				},
				illuminate = {
					enabled = true,
					lsp = true,
				},
				ufo = true,
			},
		},
	},

	-- Kanagawa - Japanese traditional theme
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		opts = {
			compile = true, -- Enable compiling the colorscheme for faster loading
			undercurl = true, -- Enable undercurls
			commentStyle = { italic = true },
			functionStyle = {},
			keywordStyle = { italic = true },
			statementStyle = { bold = true },
			typeStyle = {},
			transparent = false, -- Set background color
			dimInactive = true, -- Dim inactive windows
			terminalColors = true, -- Define terminal colors
			theme = "dragon", -- Wave, lotus, or dragon
			background = {
				dark = "dragon",
				light = "lotus",
			},
			colors = {
				palette = {},
				theme = {
					wave = {},
					lotus = {},
					dragon = {},
					all = {
						ui = {
							bg_gutter = "none",
						},
					},
				},
			},
			overrides = function(colors)
				local theme = colors.theme

				return {
					-- Custom overrides go here
					DiagnosticVirtualTextError = {
						fg = colors.diag.error,
						bg = colors.none,
						italic = true,
					},
					DiagnosticVirtualTextWarn = {
						fg = colors.diag.warning,
						bg = colors.none,
						italic = true,
					},
					DiagnosticVirtualTextInfo = {
						fg = colors.diag.info,
						bg = colors.none,
						italic = true,
					},
					DiagnosticVirtualTextHint = {
						fg = colors.diag.hint,
						bg = colors.none,
						italic = true,
					},
					Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
					PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
					PmenuSbar = { bg = theme.ui.bg_m1 },
					PmenuThumb = { bg = theme.ui.bg_p2 },
					TelescopeTitle = { fg = theme.ui.special, bold = true },
					TelescopePromptNormal = { bg = theme.ui.bg_p1 },
					TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
					TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
					TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
					TelescopePreviewNormal = { bg = theme.ui.bg_dim },
					TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
				}
			end,
		},
	},

	-- Rosé Pine - All natural pine, faux fur and a bit of soho vibes
	{
		"rose-pine/neovim",
		name = "rose-pine",
		priority = 1000,
		opts = {
			variant = "moon", -- Auto, main, moon, or dawn
			dark_variant = "moon",
			dim_inactive_windows = true,
			extend_background_behind_borders = true,

			styles = {
				bold = true,
				italic = true,
				transparency = false,
			},

			groups = {
				border = "muted",
				link = "iris",
				panel = "surface",

				error = "love",
				hint = "iris",
				info = "foam",
				warn = "gold",

				git_add = "foam",
				git_change = "rose",
				git_delete = "love",
				git_dirty = "rose",
				git_ignore = "muted",
				git_merge = "iris",
				git_rename = "pine",
				git_stage = "iris",
				git_text = "rose",
				git_untracked = "subtle",
			},

			highlight_groups = {
				-- Custom highlight group overrides go here
				DiagnosticVirtualTextError = { fg = "love", bg = "none", italic = true },
				DiagnosticVirtualTextWarn = { fg = "gold", bg = "none", italic = true },
				DiagnosticVirtualTextInfo = { fg = "foam", bg = "none", italic = true },
				DiagnosticVirtualTextHint = { fg = "iris", bg = "none", italic = true },

				-- Telescope highlights
				TelescopeBorder = { fg = "overlay", bg = "overlay" },
				TelescopeNormal = { bg = "overlay" },
				TelescopeSelection = { fg = "text", bg = "highlight_med" },
				TelescopeMatching = { fg = "iris" },

				-- Indent scope line
				MiniIndentscopeSymbol = { fg = "highlight_high" },
			},
		},
	},

	-- Gruvbox Material - Modified version of Gruvbox with material palette
	{
		"sainnhe/gruvbox-material",
		priority = 1000,
		init = function()
			vim.g.gruvbox_material_better_performance = 1
			vim.g.gruvbox_material_background = "hard" -- Options: hard, medium, soft
			vim.g.gruvbox_material_foreground = "material" -- Options: material, mix, original
			vim.g.gruvbox_material_ui_contrast = "high" -- Options: high, low
			vim.g.gruvbox_material_enable_italic = 1
			vim.g.gruvbox_material_disable_italic_comment = 0
			vim.g.gruvbox_material_enable_bold = 1
			vim.g.gruvbox_material_cursor = "auto" -- Options: auto, material, mix, original
			vim.g.gruvbox_material_transparent_background = 0
			vim.g.gruvbox_material_dim_inactive_windows = 1
			vim.g.gruvbox_material_visual = "reverse" -- Options: grey, reverse, green, blue
			vim.g.gruvbox_material_sign_column_background = "none" -- Options: none, grey
			vim.g.gruvbox_material_diagnostic_text_highlight = 1
			vim.g.gruvbox_material_diagnostic_line_highlight = 1
			vim.g.gruvbox_material_diagnostic_virtual_text = "colored" -- Options: grey, colored, highlight
			vim.g.gruvbox_material_current_word = "bold" -- Options: grey, bold, underline, italic
		end,
	},

	-- Nord - Arctic, north-bluish color palette
	{
		"shaunsingh/nord.nvim",
		priority = 1000,
		init = function()
			vim.g.nord_contrast = true
			vim.g.nord_borders = true
			vim.g.nord_disable_background = false
			vim.g.nord_italic = true
			vim.g.nord_uniform_diff_background = true
			vim.g.nord_bold = true
		end,
	},

	-- Nightfox - Comfortable, functional, and customizable colorscheme
	{
		"EdenEast/nightfox.nvim",
		priority = 1000,
		opts = {
			options = {
				compile_path = vim.fn.stdpath("cache") .. "/nightfox",
				compile_file_suffix = "_compiled", -- Compiled file suffix
				transparent = false, -- Disable setting background
				terminal_colors = true, -- Set terminal colors
				dim_inactive = true, -- Non focused panes dimmed
				module_default = true, -- Default enable value for modules
				colorblind = {
					enable = false, -- Enable colorblind support
					simulate_only = false, -- Only show simulated colorblind colors and not diff
					severity = {
						protan = 0, -- Severity [0,1] for protanopia
						deutan = 0, -- Severity [0,1] for deuteranopia
						tritan = 0, -- Severity [0,1] for tritanopia
					},
				},
				styles = {
					comments = "italic",
					conditionals = "NONE",
					constants = "NONE",
					functions = "NONE",
					keywords = "italic",
					numbers = "NONE",
					operators = "NONE",
					strings = "NONE",
					types = "NONE",
					variables = "NONE",
				},
				inverse = {
					match_paren = false,
					visual = false,
					search = false,
				},
			},
			groups = {
				all = {
					-- Custom highlight groups for all styles
					DiagnosticVirtualTextError = { fg = "${error}", bg = "none", style = "italic" },
					DiagnosticVirtualTextWarn = { fg = "${warning}", bg = "none", style = "italic" },
					DiagnosticVirtualTextInfo = { fg = "${info}", bg = "none", style = "italic" },
					DiagnosticVirtualTextHint = { fg = "${hint}", bg = "none", style = "italic" },
				},
			},
		},
	},

	-- Onedark Pro - Atom's iconic theme
	{
		"navarasu/onedark.nvim",
		priority = 1000,
		opts = {
			style = "dark", -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
			transparent = false, -- Show/hide background
			term_colors = true, -- Change terminal color
			ending_tildes = false, -- Show the end-of-buffer tildes
			cmp_itemkind_reverse = false, -- reverse item kind in cmp menu

			-- toggle theme style
			toggle_style_key = "<leader>ts", -- Toggle between styles
			toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" }, -- List of styles to toggle

			-- Change code style
			code_style = {
				comments = "italic",
				keywords = "italic",
				functions = "none",
				strings = "none",
				variables = "none",
			},

			-- Custom highlights
			diagnostics = {
				darker = true, -- darker colors for diagnostic
				undercurl = true, -- use undercurl for diagnostics
				background = false, -- use background color for virtual text
			},
		},
	},

	-- One dark - Another variation with transparency
	{
		"lunarvim/onedarker.nvim",
		priority = 1000,
		config = function()
			require("onedarker").setup()
		end,
	},

	-- Oxocarbon - IBM Carbon-inspired color scheme
	{
		"nyoom-engineering/oxocarbon.nvim",
		priority = 1000,
	},

	-- Dracula - Dark theme inspired by Dracula
	{
		"Mofiqul/dracula.nvim",
		priority = 1000,
		opts = {
			show_end_of_buffer = false, -- Show the '~' characters after the end of buffers
			transparent_bg = false, -- Make background transparent
			term_colors = true, -- Use terminal colors
			italic_comment = true, -- Italic comments
			overrides = {
				-- Override specific highlight groups
				DiagnosticVirtualTextError = { fg = "#ff5555", bg = "NONE", italic = true },
				DiagnosticVirtualTextWarn = { fg = "#f1fa8c", bg = "NONE", italic = true },
				DiagnosticVirtualTextInfo = { fg = "#8be9fd", bg = "NONE", italic = true },
				DiagnosticVirtualTextHint = { fg = "#50fa7b", bg = "NONE", italic = true },
			},
		},
	},

	-- Auto-switch dark/light theme based on system preference
	{
		"f-person/auto-dark-mode.nvim",
		priority = 900,
		config = function()
			-- Only enable on macOS
			if vim.fn.has("mac") == 1 then
				local auto_dark_mode = require("auto-dark-mode")
				auto_dark_mode.setup({
					update_interval = 1000,
					set_dark_mode = function()
						vim.opt.background = "dark"
						vim.cmd("colorscheme tokyonight")
					end,
					set_light_mode = function()
						vim.opt.background = "light"
						vim.cmd("colorscheme catppuccin-latte")
					end,
				})
				auto_dark_mode.init()
			end
		end,
	},

	-- Helper for transparency
	{
		"xiyaowong/transparent.nvim",
		lazy = false,
		opts = {
			groups = {
				"Normal",
				"NormalNC",
				"Comment",
				"Constant",
				"Special",
				"Identifier",
				"Statement",
				"PreProc",
				"Type",
				"Underlined",
				"Todo",
				"String",
				"Function",
				"Conditional",
				"Repeat",
				"Operator",
				"Structure",
				"LineNr",
				"NonText",
				"SignColumn",
				"CursorLineNr",
				"EndOfBuffer",
			},
			extra_groups = {
				"NormalFloat",
				"FloatBorder",
				"NvimTreeNormal",
				"NvimTreeNormalNC",
				"NvimTreeEndOfBuffer",
				"NeoTreeNormal",
				"NeoTreeNormalNC",
				"NeoTreeEndOfBuffer",
				"TroubleNormal",
				"TelescopeNormal",
				"TelescopeBorder",
				"WhichKeyFloat",
				"DashboardNormal",
				"NotifyBackground",
			},
			exclude_groups = {},
		},
		keys = {
			{ "<leader>ut", "<cmd>TransparentToggle<CR>", desc = "Toggle Transparency" },
		},
	},

	-- Add theme switcher command
	{
		"nvim-lua/plenary.nvim",
		lazy = true,
		config = function()
			-- Add user commands for color scheme switching
			local themes = {
				{ name = "TokyoNight", command = "colorscheme tokyonight" },
				{ name = "Catppuccin", command = "colorscheme catppuccin" },
				{ name = "Kanagawa", command = "colorscheme kanagawa" },
				{ name = "RosePine", command = "colorscheme rose-pine" },
				{ name = "Gruvbox", command = "colorscheme gruvbox-material" },
				{ name = "Nord", command = "colorscheme nord" },
				{ name = "Nightfox", command = "colorscheme nightfox" },
				{ name = "OneDark", command = "colorscheme onedark" },
				{ name = "OneDarker", command = "colorscheme onedarker" },
				{ name = "Oxocarbon", command = "colorscheme oxocarbon" },
				{ name = "Dracula", command = "colorscheme dracula" },
			}

			-- Create commands for each theme
			for _, theme in ipairs(themes) do
				vim.api.nvim_create_user_command("Theme" .. theme.name, function()
					vim.cmd(theme.command)
					vim.notify("Color scheme changed to " .. theme.name, vim.log.levels.INFO)
				end, {})
			end

			-- Add a command to pick a theme using Telescope
			if pcall(require, "telescope") then
				vim.api.nvim_create_user_command("ThemeSwitch", function()
					vim.cmd("Telescope colorscheme")
				end, { desc = "Switch color scheme using Telescope" })
			end

			-- Set the default color scheme
			vim.cmd("colorscheme tokyonight")
		end,
	},
}
