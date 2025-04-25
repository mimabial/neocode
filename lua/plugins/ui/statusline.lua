--------------------------------------------------------------------------------
-- Statusline Configuration
--------------------------------------------------------------------------------
--
-- This module configures a beautiful and informative statusline:
--
-- Features:
-- 1. Mode indicator
-- 2. Git information
-- 3. File path and status
-- 4. Language server status
-- 5. Diagnostics counts
-- 6. Position information
-- 7. Filetype icon
--
-- The statusline provides important contextual information at a glance.
--------------------------------------------------------------------------------

return {
	-- Lualine status line
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = function()
			-- Get colors from current colorscheme for customizing
			local colors = {
				bg = "#202328",
				fg = "#bbc2cf",
				yellow = "#ECBE7B",
				cyan = "#008080",
				darkblue = "#081633",
				green = "#98be65",
				orange = "#FF8800",
				violet = "#a9a1e1",
				magenta = "#c678dd",
				blue = "#51afef",
				red = "#ec5f67",
			}

			-- Try to use theme colors if available
			local ok, theme = pcall(function()
				if vim.g.colors_name == "tokyonight" then
					return require("tokyonight.colors").setup()
				elseif vim.g.colors_name == "catppuccin" then
					return require("catppuccin.palettes").get_palette()
				end
				return nil
			end)

			if ok and theme then
				colors.bg = theme.bg or theme.base or theme.mantle or colors.bg
				colors.fg = theme.fg or theme.text or colors.fg
				colors.yellow = theme.yellow or colors.yellow
				colors.cyan = theme.cyan or theme.teal or colors.cyan
				colors.darkblue = theme.dark or theme.surface0 or colors.darkblue
				colors.green = theme.green or colors.green
				colors.orange = theme.orange or theme.peach or colors.orange
				colors.violet = theme.purple or colors.violet
				colors.magenta = theme.magenta or theme.mauve or colors.magenta
				colors.blue = theme.blue or colors.blue
				colors.red = theme.red or colors.red
			end

			local conditions = {
				buffer_not_empty = function()
					return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
				end,
				hide_in_width = function()
					return vim.fn.winwidth(0) > 80
				end,
				check_git_workspace = function()
					local filepath = vim.fn.expand("%:p:h")
					local gitdir = vim.fn.finddir(".git", filepath .. ";")
					return gitdir and #gitdir > 0 and #gitdir < #filepath
				end,
			}

			-- Customize mode names
			local mode_color = {
				n = colors.blue,
				i = colors.green,
				v = colors.magenta,
				[""] = colors.magenta,
				V = colors.magenta,
				c = colors.yellow,
				no = colors.red,
				s = colors.orange,
				S = colors.orange,
				[""] = colors.orange,
				ic = colors.yellow,
				R = colors.violet,
				Rv = colors.violet,
				cv = colors.red,
				ce = colors.red,
				r = colors.cyan,
				rm = colors.cyan,
				["r?"] = colors.cyan,
				["!"] = colors.red,
				t = colors.red,
			}

			-- Config
			return {
				options = {
					-- Disable sections and component separators
					component_separators = "",
					section_separators = "",
					globalstatus = true,
					theme = {
						-- We'll customize the theme ourselves
						normal = { c = { fg = colors.fg, bg = colors.bg } },
						inactive = { c = { fg = colors.fg, bg = colors.bg } },
					},
					refresh = {
						statusline = 1000,
						tabline = 1000,
						winbar = 1000,
					},
					disabled_filetypes = {
						statusline = { "dashboard", "alpha", "starter" },
						winbar = {
							"help",
							"dashboard",
							"alpha",
							"starter",
							"neo-tree",
							"Trouble",
							"lazy",
							"mason",
							"nvim-tree",
						},
					},
				},
				sections = {
					-- Left side
					lualine_a = {
						{
							function()
								return "▊"
							end,
							color = function()
								-- Auto change color according to Neovim's mode
								return { fg = mode_color[vim.fn.mode()] }
							end,
							padding = { left = 0, right = 1 },
						},
						{
							-- Show mode name
							function()
								return ""
							end,
							color = function()
								-- Auto change color according to Neovim's mode
								return { fg = mode_color[vim.fn.mode()], gui = "bold" }
							end,
							padding = { right = 1 },
						},
					},
					lualine_b = {
						{
							"branch",
							icon = "",
							color = { fg = colors.violet, gui = "bold" },
						},
						{
							"diff",
							symbols = { added = " ", modified = "󰝤 ", removed = " " },
							diff_color = {
								added = { fg = colors.green },
								modified = { fg = colors.orange },
								removed = { fg = colors.red },
							},
							cond = conditions.hide_in_width,
						},
					},
					lualine_c = {
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
							diagnostics_color = {
								error = { fg = colors.red },
								warn = { fg = colors.yellow },
								info = { fg = colors.cyan },
								hint = { fg = colors.green },
							},
							colored = true,
						},
						{
							"filetype",
							icon_only = true,
							separator = "",
							padding = { left = 1, right = 0 },
						},
						{
							"filename",
							cond = conditions.buffer_not_empty,
							path = 1, -- Show relative path
							symbols = {
								modified = "●", -- Text to show when the file is modified
								readonly = "󰌾", -- Text to show when the file is non-modifiable or readonly
								unnamed = "[No Name]", -- Text to show for unnamed buffers
								newfile = "[New]", -- Text to show for newly created file before first write
							},
							color = { gui = "bold" },
						},
						{
							function()
								return require("nvim-navic").get_location()
							end,
							cond = function()
								return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
							end,
						},
					},
					lualine_x = {
						-- LSP servers info
						{
							function()
								local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
								local clients = vim.lsp.get_active_clients()
								if next(clients) == nil then
									return "No LSP"
								end

								local lsp_clients = {}
								for _, client in ipairs(clients) do
									local filetypes = client.config.filetypes
									if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
										table.insert(lsp_clients, client.name)
									end
								end

								return table.concat(lsp_clients, ", ")
							end,
							icon = " ",
							color = { fg = colors.green, gui = "bold" },
							cond = conditions.hide_in_width,
						},
						-- Show if spell check is enabled
						{
							function()
								if vim.o.spell then
									return "SPELL"
								end
								return ""
							end,
							icon = "暈",
							color = { fg = colors.blue },
							cond = conditions.hide_in_width,
						},
						-- Show filetype
						{
							"filetype",
							colored = true,
							icon_only = false,
							color = { fg = colors.fg },
							cond = conditions.hide_in_width,
						},
						-- Encoding info
						{
							"encoding",
							fmt = string.upper,
							color = { fg = colors.green },
							cond = conditions.hide_in_width,
						},
						-- File format
						{
							"fileformat",
							fmt = string.upper,
							icons_enabled = true,
							color = { fg = colors.green },
							cond = conditions.hide_in_width,
						},
					},
					lualine_y = {
						{
							-- Progress information
							"progress",
							color = { fg = colors.fg, gui = "bold" },
						},
					},
					lualine_z = {
						{
							-- Location information
							"location",
							color = { fg = colors.fg, gui = "bold" },
						},
						{
							function()
								return "▊"
							end,
							color = function()
								-- Auto change color according to Neovim's mode
								return { fg = mode_color[vim.fn.mode()] }
							end,
							padding = { left = 1 },
						},
					},
				},
				inactive_sections = {
					-- Left sections for inactive windows
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{
							"filename",
							path = 1,
							symbols = {
								modified = "●",
								readonly = "󰌾",
								unnamed = "[No Name]",
								newfile = "[New]",
							},
							color = { fg = colors.fg, gui = "italic" },
						},
					},
					-- Right sections for inactive windows
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
				-- Tab line
				tabline = {},
				-- Winbar (top of window)
				winbar = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{
							"filename",
							path = 1,
							symbols = {
								modified = "●",
								readonly = "󰌾",
								unnamed = "[No Name]",
								newfile = "[New]",
							},
							color = { fg = colors.fg, gui = "bold" },
						},
						{
							function()
								return require("nvim-navic").get_location()
							end,
							cond = function()
								return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
							end,
							color = { fg = colors.fg },
						},
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
				-- Inactive winbar
				inactive_winbar = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{
							"filename",
							path = 1,
							symbols = {
								modified = "●",
								readonly = "󰌾",
								unnamed = "[No Name]",
								newfile = "[New]",
							},
							color = { fg = colors.fg, gui = "italic" },
						},
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
				-- Additional extensions for specific plugins
				extensions = {
					"neo-tree",
					"lazy",
					"mason",
					"aerial",
					"trouble",
					"nvim-dap-ui",
					"toggleterm",
				},
			}
		end,
	},

	-- Tab line
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
			{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
			{ "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
			{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
			{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
			{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
			{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
			{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
		},
		opts = {
			options = {
				mode = "buffers", -- | "tabs"
				numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
				close_command = function(n)
					require("mini.bufremove").delete(n, false)
				end,
				right_mouse_command = function(n)
					require("mini.bufremove").delete(n, false)
				end,
				left_mouse_command = "buffer %d", -- Can be a string | function, | false
				middle_mouse_command = nil, -- Can be a string | function, | false
				indicator = {
					icon = "▎", -- This should be omitted if indicator style is not 'icon'
					style = "icon", -- | 'underline' | 'none',
				},
				buffer_close_icon = "",
				modified_icon = "●",
				close_icon = "",
				left_trunc_marker = "",
				right_trunc_marker = "",
				max_name_length = 30,
				max_prefix_length = 30, -- Prefix used for a buffer from multiple windows
				truncate_names = true, -- Whether to truncate buffer names
				tab_size = 21,
				diagnostics = "nvim_lsp", -- | "nvim_lsp" | "coc" | false,
				diagnostics_update_in_insert = false,
				diagnostics_indicator = function(count, level, diagnostics_dict, context)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
				offsets = {
					{
						filetype = "neo-tree",
						text = "File Explorer",
						highlight = "Directory",
						text_align = "left",
						separator = true,
					},
					{
						filetype = "NvimTree",
						text = "File Explorer",
						highlight = "Directory",
						text_align = "left",
						separator = true,
					},
				},
				color_icons = true, -- Boolean to enable file icons with colors
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = true,
				show_tab_indicators = true,
				show_duplicate_prefix = true, -- Whether to show duplicate buffer prefix
				persist_buffer_sort = true, -- Whether to persist buffer sorting
				separator_style = "thin", -- | "slope" | "thick" | "thin" | { 'any', 'any' },
				enforce_regular_tabs = true,
				always_show_bufferline = true,
				hover = {
					enabled = true,
					delay = 200,
					reveal = { "close" },
				},
				sort_by = "insert_after_current", -- |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b),
			},
			-- Configure highlights to match colorscheme
			highlights = function()
				local highlights = require("catppuccin.groups.integrations.bufferline").get()
				return highlights
			end,
		},
	},

	-- Mini buffer remove (clean buffer closing)
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

	-- Filename in window title
	{
		"b0o/incline.nvim",
		event = "BufReadPre",
		priority = 1200,
		config = function()
			require("incline").setup({
				highlight = {
					groups = {
						InclineNormal = { guibg = "#FC56B1", guifg = "#000000" },
						InclineNormalNC = { guifg = "#FC56B1", guibg = "#000000" },
					},
				},
				window = { margin = { vertical = 0, horizontal = 1 } },
				hide = {
					cursorline = true,
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					local icon, color = require("nvim-web-devicons").get_icon_color(filename)
					return { { icon, guifg = color }, { " " }, { filename } }
				end,
			})
		end,
	},
}
