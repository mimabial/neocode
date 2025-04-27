--------------------------------------------------------------------------------
-- Statusline Configuration
--------------------------------------------------------------------------------
--
-- This module configures lualine, a feature-rich and extensible statusline.
--
-- Features:
-- 1. Mode indicator with color changes based on current mode
-- 2. Git information (branch, changes)
-- 3. LSP diagnostics counters and indicators
-- 4. Filename with modification status
-- 5. File type, encoding, and format information
-- 6. Position information
-- 7. Code context via navic integration
-- 8. Easily customizable sections
--
-- The statusline provides valuable context while maintaining clean aesthetics
-- and good performance.
--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"SmiteshP/nvim-navic", -- For showing code context
	},
	opts = function()
		-- Try to get colors from colorscheme if possible
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
			-- Custom color categories
			git = {
				add = "#98be65",  -- green
				change = "#51afef", -- blue
				delete = "#ec5f67", -- red
				conflict = "#ECBE7B", -- yellow
			},
			diagnostics = {
				error = "#ec5f67",
				warn = "#ECBE7B",
				info = "#51afef",
				hint = "#98be65",
			},
		}

		-- Check if we can use theme colors
		local ok, theme = pcall(function()
			if vim.g.colors_name == "tokyonight" then
				return require("tokyonight.colors").setup()
			elseif vim.g.colors_name:match("^catppuccin") then
				return require("catppuccin.palettes").get_palette()
			elseif vim.g.colors_name == "kanagawa" then
				return require("kanagawa.colors").setup()
			elseif vim.g.colors_name == "nightfox" or vim.g.colors_name:match("fox$") then
				return require("nightfox.palette").load(vim.g.colors_name)
			end
			return nil
		end)

		-- Override with theme colors if available
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

			-- Diagnostics colors
			colors.diagnostics.error = theme.red or theme.error or colors.diagnostics.error
			colors.diagnostics.warn = theme.yellow or theme.warning or colors.diagnostics.warn
			colors.diagnostics.info = theme.blue or theme.info or colors.diagnostics.info
			colors.diagnostics.hint = theme.green or theme.hint or colors.diagnostics.hint

			-- Git colors
			colors.git.add = theme.green or theme.git_add or colors.git.add
			colors.git.change = theme.blue or theme.git_change or colors.git.change
			colors.git.delete = theme.red or theme.git_delete or colors.git.delete
		end

		local conditions = {
			-- Helper conditions for components
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

		-- Mode color mapping
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

		-- Icons for various parts of the statusline
		local icons = {
			diagnostics = {
				Error = " ",
				Warn = " ",
				Info = " ",
				Hint = "󰌵 ",
			},
			git = {
				added = " ",
				modified = "󰝤 ",
				removed = " ",
			},
			kinds = {
				Array = " ",
				Boolean = " ",
				Class = " ",
				Color = " ",
				Constant = " ",
				Constructor = " ",
				Enum = " ",
				EnumMember = " ",
				Event = " ",
				Field = " ",
				File = " ",
				Folder = " ",
				Function = " ",
				Interface = " ",
				Key = " ",
				Keyword = " ",
				Method = " ",
				Module = " ",
				Namespace = " ",
				Null = " ",
				Number = " ",
				Object = " ",
				Operator = " ",
				Package = " ",
				Property = " ",
				Reference = " ",
				Snippet = " ",
				String = " ",
				Struct = " ",
				Text = " ",
				TypeParameter = " ",
				Unit = " ",
				Value = " ",
				Variable = " ",
			},
		}

		return {
			options = {
				-- General statusline options
				theme = "auto",
				component_separators = "",
				section_separators = "",
				globalstatus = true, -- Use single statusline for all windows (Neovim 0.7+)
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
				refresh = {
					statusline = 1000, -- Update every 1s
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				-- Left sections
				lualine_a = {
					{
						-- Mode indicator with decorative edge
						function()
							return "▊"
						end,
						color = function()
							-- Match the color to the current mode
							return { fg = mode_color[vim.fn.mode()] }
						end,
						padding = { left = 0, right = 1 },
					},
					{
						-- Show mode name with icon
						function()
							-- Define mode names and icons
							local mode_map = {
								n = "NORMAL",
								i = "INSERT",
								v = "VISUAL",
								[""] = "V-BLOCK",
								V = "V-LINE",
								c = "COMMAND",
								no = "OP-PENDING",
								s = "SELECT",
								S = "S-LINE",
								[""] = "S-BLOCK",
								ic = "INS-COMP",
								R = "REPLACE",
								Rv = "VIRTUAL",
								cv = "VIM-EX",
								ce = "EX",
								r = "PROMPT",
								rm = "MORE",
								["r?"] = "CONFIRM",
								["!"] = "SHELL",
								t = "TERMINAL",
							}

							local mode_icon = {
								n = " ", -- Normal
								i = " ", -- Insert
								v = " ", -- Visual
								[""] = " ", -- V-Block
								V = " ", -- V-Line
								c = " ", -- Command
								R = " ", -- Replace
								t = " ", -- Terminal
							}

							local current_mode = vim.fn.mode()
							local icon = mode_icon[current_mode] or ""
							local mode_name = mode_map[current_mode] or current_mode

							return icon .. " " .. mode_name
						end,
						color = function()
							-- Match the color to the current mode
							return { fg = mode_color[vim.fn.mode()], gui = "bold" }
						end,
						padding = { right = 1 },
					},
				},
				lualine_b = {
					{
						-- Git branch name
						"branch",
						icon = "",
						color = { fg = colors.violet, gui = "bold" },
					},
					{
						-- Git changes (added, modified, removed)
						"diff",
						symbols = {
							added = icons.git.added,
							modified = icons.git.modified,
							removed = icons.git.removed,
						},
						diff_color = {
							added = { fg = colors.git.add },
							modified = { fg = colors.git.change },
							removed = { fg = colors.git.delete },
						},
						cond = conditions.hide_in_width,
					},
				},
				lualine_c = {
					{
						-- Diagnostic counts with icons
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = {
							error = icons.diagnostics.Error,
							warn = icons.diagnostics.Warn,
							info = icons.diagnostics.Info,
							hint = icons.diagnostics.Hint,
						},
						diagnostics_color = {
							error = { fg = colors.diagnostics.error },
							warn = { fg = colors.diagnostics.warn },
							info = { fg = colors.diagnostics.info },
							hint = { fg = colors.diagnostics.hint },
						},
						colored = true,
					},
					{
						-- File icon
						"filetype",
						icon_only = true,
						separator = "",
						padding = { left = 1, right = 0 },
					},
					{
						-- Filename with path and status
						"filename",
						cond = conditions.buffer_not_empty,
						path = 1, -- Show relative path
						symbols = {
							modified = "●", -- Text to show when the file is modified
							readonly = "󰌾", -- Text to show when the file is non-modifiable or readonly
							unnamed = "[No Name]", -- Text to show for unnamed buffers
							newfile = "[New]", -- Text to show for newly created file
						},
						color = { gui = "bold" },
					},
					{
						-- Show code navigation context
						function()
							local navic = require("nvim-navic")
							if navic.is_available() then
								local context = navic.get_location()
								if context ~= "" then
									return context
								end
							end
							return ""
						end,
						cond = function()
							return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
						end,
					},
				},
				-- Right sections
				lualine_x = {
					{
						-- LSP servers info
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

							return #lsp_clients > 0 and table.concat(lsp_clients, ", ") or "LSP"
						end,
						icon = " ",
						color = { fg = colors.green, gui = "bold" },
						cond = conditions.hide_in_width,
					},
					{
						-- Spell check status
						function()
							if vim.o.spell then
								local lang = vim.opt.spelllang:get()
								lang = type(lang) == "table" and lang[1] or lang
								return "SPELL[" .. lang .. "]"
							end
							return ""
						end,
						icon = "暈",
						color = { fg = colors.blue },
						cond = function()
							return vim.o.spell
						end,
					},
					{
						-- Filetype
						"filetype",
						colored = true,
						icon_only = false,
						color = { fg = colors.fg },
						cond = conditions.hide_in_width,
					},
					{
						-- File encoding
						"encoding",
						fmt = string.upper,
						color = { fg = colors.green },
						cond = conditions.hide_in_width,
					},
					{
						-- File format (unix, dos, mac)
						"fileformat",
						fmt = string.upper,
						icons_enabled = true,
						symbols = {
							unix = "LF",
							dos = "CRLF",
							mac = "CR",
						},
						color = { fg = colors.green },
						cond = conditions.hide_in_width,
					},
				},
				lualine_y = {
					{
						-- Progress info
						"progress",
						color = { fg = colors.fg, gui = "bold" },
					},
				},
				lualine_z = {
					{
						-- Location info (line:column)
						"location",
						color = { fg = colors.fg, gui = "bold" },
					},
					{
						-- Decorative end marker
						function()
							return "▊"
						end,
						color = function()
							-- Match the color to the current mode
							return { fg = mode_color[vim.fn.mode()] }
						end,
						padding = { left = 1 },
					},
				},
			},
			-- Inactive windows have a simplified statusline
			inactive_sections = {
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
			-- Tab line configuration (if used)
			tabline = {},
			-- Winbar configuration (context at top of windows)
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
						-- Show code context in winbar
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
			-- Extensions for specific plugins
			extensions = {
				"neo-tree",
				"lazy",
				"mason",
				"aerial",
				"trouble",
				"nvim-dap-ui",
				"toggleterm",
				"oil",
			},
		}
	end,
	config = function(_, opts)
		require("lualine").setup(opts)

		-- Add a command to toggle the statusline style
		vim.api.nvim_create_user_command("StatuslineToggleStyle", function()
			-- Get current config
			local lualine = require("lualine")
			local config = require("lualine.config").get_config()

			-- Toggle between default and minimal styles
			if config.options.component_separators == "" and config.options.section_separators == "" then
				-- Switch to fancy style
				lualine.setup({
					options = {
						component_separators = { left = "", right = "" },
						section_separators = { left = "", right = "" },
					},
				})
				vim.notify("Switched to fancy statusline style")
			else
				-- Switch to minimal style
				lualine.setup({
					options = {
						component_separators = "",
						section_separators = "",
					},
				})
				vim.notify("Switched to minimal statusline style")
			end
		end, {})

		-- Add command to toggle global statusline (Neovim 0.7+)
		if vim.fn.has("nvim-0.7") == 1 then
			vim.api.nvim_create_user_command("StatuslineToggleGlobal", function()
				local lualine = require("lualine")
				local config = require("lualine.config").get_config()

				-- Toggle global statusline
				config.options.globalstatus = not config.options.globalstatus
				lualine.setup(config)

				-- Apply the setting to Neovim as well
				vim.opt.laststatus = config.options.globalstatus and 3 or 2

				vim.notify("Global statusline " .. (config.options.globalstatus and "enabled" or "disabled"))
			end, {})
		end

		-- Add keymapping for toggling the statusline style
		vim.keymap.set("n", "<leader>us", "<cmd>StatuslineToggleStyle<cr>", { desc = "Toggle statusline style" })
	end,
}
