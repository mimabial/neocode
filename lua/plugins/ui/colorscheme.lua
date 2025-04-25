--------------------------------------------------------------------------------
-- Colorscheme Configuration
--------------------------------------------------------------------------------
--
-- This module configures color themes and styling for Neovim:
--
-- Features:
-- 1. Modern colorschemes
-- 2. Customization options
-- 3. Semantic highlighting
-- 4. Consistent UI styling
-- 5. Transparency support
--
-- The colorscheme is a key element of the UI and affects readability
-- and the overall user experience.
--------------------------------------------------------------------------------

return {
	-- Tokyonight - A clean, dark theme
	{
		"folke/tokyonight.nvim",
		lazy = false, -- We want the colorscheme to load immediately
		priority = 1000, -- Load before other plugins
		opts = {
			style = "night", -- The theme comes in four styles: storm, moon, night, day
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
				"vista_kind",
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
				-- colors.hint = colors.orange
				-- colors.error = "#ff0000"
			end,
			on_highlights = function(highlights, colors)
				-- Customize specific highlight groups
				highlights.DiagnosticVirtualTextError = { fg = colors.error, bg = colors.bg_dark, italic = true }
				highlights.DiagnosticVirtualTextWarn = { fg = colors.warning, bg = colors.bg_dark, italic = true }
				highlights.DiagnosticVirtualTextInfo = { fg = colors.info, bg = colors.bg_dark, italic = true }
				highlights.DiagnosticVirtualTextHint = { fg = colors.hint, bg = colors.bg_dark, italic = true }
			end,
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- Catppuccin - Soothing pastel theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true, -- Load on demand, not by default
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
			no_italic = false,
			no_bold = false,
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
				telescope = true,
				notify = true,
				mini = true,
				leap = true,
				fidget = true,
				which_key = true,
				dashboard = true,
				neogit = true,
				noice = true,
				treesitter = true,
				treesitter_context = true,
				symbols_outline = true,
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
			},
		},
	},

	-- Kanagawa - Japanese traditional theme
	{
		"rebelot/kanagawa.nvim",
		lazy = true, -- Load on demand
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
				return {
					-- Override specific highlight groups
					DiagnosticVirtualTextError = {
						fg = colors.palette.samuraiRed,
						bg = colors.palette.sumiInk2,
						italic = true,
					},
					DiagnosticVirtualTextWarn = {
						fg = colors.palette.roninYellow,
						bg = colors.palette.sumiInk2,
						italic = true,
					},
					DiagnosticVirtualTextInfo = {
						fg = colors.palette.waveAqua1,
						bg = colors.palette.sumiInk2,
						italic = true,
					},
					DiagnosticVirtualTextHint = {
						fg = colors.palette.springViolet1,
						bg = colors.palette.sumiInk2,
						italic = true,
					},
				}
			end,
			theme = "wave", -- Wave, lotus, or dragon
			background = {
				dark = "wave",
				light = "lotus",
			},
		},
	},

	-- Nightfox - Comfortable, functional, and customizable theme
	{
		"EdenEast/nightfox.nvim",
		lazy = true, -- Load on demand
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
			palettes = {
				-- Custom nightfox palette
			},
			specs = {
				-- Custom nightfox specs
			},
			groups = {
				all = {
					-- Custom highlight groups for all styles
					DiagnosticVirtualTextError = { fg = "${error}", bg = "${bg_dark}", style = "italic" },
					DiagnosticVirtualTextWarn = { fg = "${warning}", bg = "${bg_dark}", style = "italic" },
					DiagnosticVirtualTextInfo = { fg = "${info}", bg = "${bg_dark}", style = "italic" },
					DiagnosticVirtualTextHint = { fg = "${hint}", bg = "${bg_dark}", style = "italic" },
				},
			},
		},
	},

	-- Gruvbox Material - Modified version of Gruvbox with material palette
	{
		"sainnhe/gruvbox-material",
		lazy = true, -- Load on demand
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
			vim.g.gruvbox_material_statusline_style = "material" -- Options: default, mix, material
			vim.g.gruvbox_material_diagnostic_text_highlight = 1
			vim.g.gruvbox_material_diagnostic_line_highlight = 1
			vim.g.gruvbox_material_diagnostic_virtual_text = "colored" -- Options: grey, colored, highlight
			vim.g.gruvbox_material_current_word = "bold" -- Options: grey, bold, underline, italic
		end,
	},

	-- Nord - Arctic, north-bluish color palette
	{
		"shaunsingh/nord.nvim",
		lazy = true, -- Load on demand
		init = function()
			vim.g.nord_contrast = true
			vim.g.nord_borders = true
			vim.g.nord_disable_background = false
			vim.g.nord_italic = true
			vim.g.nord_uniform_diff_background = true
			vim.g.nord_bold = true
		end,
	},

	-- One Dark - Atom's iconic theme
	{
		"navarasu/onedark.nvim",
		lazy = true, -- Load on demand
		opts = {
			style = "dark", -- Default theme style. 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'
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
			-- Custom colors
			colors = {},
			-- Custom highlights
			highlights = {},
			diagnostics = {
				darker = true, -- darker colors for diagnostics
				undercurl = true, -- use undercurl for diagnostics
				background = true, -- use background color for virtual text
			},
		},
	},

	-- Oxocarbon - IBM Carbon-inspired color scheme
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = true, -- Load on demand
	},

	-- Dracula - Dark theme inspired by Dracula
	{
		"Mofiqul/dracula.nvim",
		lazy = true, -- Load on demand
		opts = {
			show_end_of_buffer = false, -- Show the '~' characters after the end of buffers
			transparent_bg = false, -- Make background transparent
			term_colors = true, -- Use terminal colors
			italic_comment = true, -- Italic comments
			overrides = {
				-- Override specific highlight groups
			},
		},
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

	-- Command to switch colorschemes
	{
		"norcalli/nvim-colorizer.lua",
		lazy = true,
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("colorizer").setup({
				"*", -- Highlight all files
				css = { css = true }, -- Enable all CSS features
				html = { css = true }, -- Enable CSS for HTML files
			})
		end,
	},

	-- Add commands for switching themes
	{
		"NvChad/nvim-colorizer.lua",
		lazy = true,
		config = function()
			-- Add user commands for color scheme switching
			vim.api.nvim_create_user_command("ColorSchemeTokyoNight", function()
				vim.cmd.colorscheme("tokyonight")
			end, {})

			vim.api.nvim_create_user_command("ColorSchemeCatppuccin", function()
				vim.cmd.colorscheme("catppuccin")
			end, {})

			vim.api.nvim_create_user_command("ColorSchemeKanagawa", function()
				vim.cmd.colorscheme("kanagawa")
			end, {})

			vim.api.nvim_create_user_command("ColorSchemeNightfox", function()
				vim.cmd.colorscheme("nightfox")
			end, {})

			vim.api.nvim_create_user_command("ColorSchemeGruvbox", function()
				vim.cmd.colorscheme("gruvbox-material")
			end, {})

			vim.api.nvim_create_user_command("ColorSchemeNord", function()
				vim.cmd.colorscheme("nord")
			end, {})

			vim.api.nvim_create_user_command("ColorSchemeOneDark", function()
				vim.cmd.colorscheme("onedark")
			end, {})

			vim.api.nvim_create_user_command("ColorSchemeOxocarbon", function()
				vim.cmd.colorscheme("oxocarbon")
			end, {})

			vim.api.nvim_create_user_command("ColorSchemeDracula", function()
				vim.cmd.colorscheme("dracula")
			end, {})
		end,
	},
}
