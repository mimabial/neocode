--------------------------------------------------------------------------------
-- Dashboard Configuration
--------------------------------------------------------------------------------
--
-- This module configures a welcome dashboard for Neovim:
--
-- Features:
-- 1. Stylish logo and welcome message
-- 2. Quick action shortcuts
-- 3. Recent files display
-- 4. Session management
-- 5. Project shortcuts
-- 6. Startup performance metrics
--
-- The dashboard provides a clean interface when starting Neovim
-- with quick access to common actions.
--------------------------------------------------------------------------------

return {
	-- Dashboard with alpha.nvim
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		enabled = true, -- Set to false to disable dashboard
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- Set header with custom logo
			dashboard.section.header.val = {
				[[                                                                       ]],
				[[                                                                       ]],
				[[                                                                       ]],
				[[                                                                       ]],
				[[          ███╗   ██╗███████╗ ██████╗  ██████╗ ██████╗ ██████╗ ███████╗]],
				[[          ████╗  ██║██╔════╝██╔═══██╗██╔════╝██╔═══██╗██╔══██╗██╔════╝]],
				[[          ██╔██╗ ██║█████╗  ██║   ██║██║     ██║   ██║██║  ██║█████╗  ]],
				[[          ██║╚██╗██║██╔══╝  ██║   ██║██║     ██║   ██║██║  ██║██╔══╝  ]],
				[[          ██║ ╚████║███████╗╚██████╔╝╚██████╗╚██████╔╝██████╔╝███████╗]],
				[[          ╚═╝  ╚═══╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝]],
				[[                                                                       ]],
				[[                  The Modern Neovim Configuration                      ]],
				[[                                                                       ]],
			}

			-- Configure menu with enhanced icons and shortcut keys
			dashboard.section.buttons.val = {
				dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
				dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
				dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
				dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
				dashboard.button("p", "  Find project", ":Telescope projects <CR>"),
				dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
				dashboard.button("s", "  Restore Session", ":lua require('persistence').load() <CR>"),
				dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
				dashboard.button("m", "  Mason", ":Mason<CR>"),
				dashboard.button("t", "  Change Theme", ":ThemeSwitch<CR>"),
				dashboard.button("q", "  Quit", ":qa<CR>"),
			}

			-- Apply theme to buttons
			for _, button in ipairs(dashboard.section.buttons.val) do
				button.opts.hl = "AlphaButtons"
				button.opts.hl_shortcut = "AlphaShortcut"
			end

			-- Set section headings
			dashboard.section.header.opts.hl = "AlphaHeader"
			dashboard.section.buttons.opts.hl = "AlphaButtons"
			dashboard.section.footer.opts.hl = "AlphaFooter"

			-- Adjust layout
			dashboard.opts.layout[1].val = 3 -- Adjust header spacing

			-- Dynamic footer with lazy stats and session info
			dashboard.section.footer.val = function()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
				local v = vim.version()
				local version_info = "   v" .. v.major .. "." .. v.minor .. "." .. v.patch
				local plugins_count = "   " .. stats.count .. " plugins loaded in " .. ms .. "ms"
				local datetime = os.date("   %a %b %d, %H:%M")

				-- Get session info
				local session_info = ""
				local has_persistence, persistence = pcall(require, "persistence")
				if has_persistence then
					local last_session = persistence.get_current()
					if last_session then
						session_info = "    Last session: " .. vim.fn.fnamemodify(last_session, ":t:r")
					end
				end

				return {
					version_info,
					plugins_count,
					datetime,
					session_info,
					"",
					"  NeoCode - The Modern Neovim Experience",
				}
			end

			-- Configure dashboard
			dashboard.config.opts.noautocmd = true

			-- Set up alpha
			alpha.setup(dashboard.config)

			-- Hide status line and tab line on dashboard
			vim.api.nvim_create_autocmd("User", {
				pattern = "AlphaReady",
				callback = function()
					vim.opt.laststatus = 0
					vim.opt.showtabline = 0

					-- Restore on BufUnload
					vim.api.nvim_create_autocmd("BufUnload", {
						buffer = 0,
						callback = function()
							vim.opt.laststatus = 3
							vim.opt.showtabline = 2
						end,
					})
				end,
			})

			-- Define highlight groups for the dashboard
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					-- Default colors
					local header_color = "#89b4fa" -- Catppuccin blue
					local shortcut_color = "#f38ba8" -- Catppuccin red
					local button_color = "#cdd6f4" -- Catppuccin text
					local footer_color = "#a6e3a1" -- Catppuccin green

					-- Try to get colors from colorscheme
					local ok, colors = pcall(function()
						if vim.g.colors_name == "tokyonight" then
							return require("tokyonight.colors").setup()
						elseif vim.g.colors_name:match("^catppuccin") then
							return require("catppuccin.palettes").get_palette()
						elseif vim.g.colors_name == "nightfox" or vim.g.colors_name:match("fox$") then
							return require("nightfox.palette").load(vim.g.colors_name)
						end
						return nil
					end)

					if ok and colors then
						-- Use theme colors if available
						header_color = colors.blue or colors.sapphire or header_color
						shortcut_color = colors.red or colors.maroon or shortcut_color
						button_color = colors.fg or colors.text or button_color
						footer_color = colors.green or footer_color
					end

					-- Set dashboard colors
					vim.api.nvim_set_hl(0, "AlphaHeader", { fg = header_color })
					vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = shortcut_color, bold = true })
					vim.api.nvim_set_hl(0, "AlphaButtons", { fg = button_color })
					vim.api.nvim_set_hl(0, "AlphaFooter", { fg = footer_color, italic = true })
				end,
			})

			-- Trigger the autocmd to set colors on startup
			vim.cmd("doautocmd ColorScheme")
		end,
	},

	-- Alternative dashboard (disabled by default, uncomment to use)
	{
		"nvimdev/dashboard-nvim",
		enabled = false, -- Set to true to use this instead of alpha-nvim
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			theme = "doom",
			config = {
				header = {
					"                                                  ",
					"                                                  ",
					"                                                  ",
					"                                                  ",
					"                                                  ",
					"       ███╗   ██╗███████╗ ██████╗  ██████╗       ",
					"       ████╗  ██║██╔════╝██╔═══██╗██╔════╝       ",
					"       ██╔██╗ ██║█████╗  ██║   ██║██║            ",
					"       ██║╚██╗██║██╔══╝  ██║   ██║██║            ",
					"       ██║ ╚████║███████╗╚██████╔╝╚██████╗       ",
					"       ╚═╝  ╚═══╝╚══════╝ ╚═════╝  ╚═════╝       ",
					"                                                  ",
					"                                                  ",
					"           Modern Neovim Configuration            ",
					"                                                  ",
				},
				center = {
					{
						icon = "󰈞 ",
						icon_hl = "Title",
						desc = "Find File",
						desc_hl = "String",
						key = "f",
						keymap = "SPC f f",
						key_hl = "Number",
						action = "Telescope find_files",
					},
					{
						icon = " ",
						icon_hl = "Title",
						desc = "New File",
						desc_hl = "String",
						key = "n",
						keymap = "SPC n",
						key_hl = "Number",
						action = "enew",
					},
					{
						icon = " ",
						icon_hl = "Title",
						desc = "Recent Files",
						desc_hl = "String",
						key = "r",
						keymap = "SPC f r",
						key_hl = "Number",
						action = "Telescope oldfiles",
					},
					{
						icon = " ",
						icon_hl = "Title",
						desc = "Find Word",
						desc_hl = "String",
						key = "g",
						keymap = "SPC f g",
						key_hl = "Number",
						action = "Telescope live_grep",
					},
					{
						icon = " ",
						icon_hl = "Title",
						desc = "Configuration",
						desc_hl = "String",
						key = "c",
						keymap = "SPC f P",
						key_hl = "Number",
						action = "e $MYVIMRC",
					},
					{
						icon = " ",
						icon_hl = "Title",
						desc = "Plugins",
						desc_hl = "String",
						key = "l",
						keymap = "SPC p l",
						key_hl = "Number",
						action = "Lazy",
					},
					{
						icon = " ",
						icon_hl = "Title",
						desc = "Quit",
						desc_hl = "String",
						key = "q",
						keymap = "SPC q",
						key_hl = "Number",
						action = "qa",
					},
				},
				footer = function()
					local stats = require("lazy").stats()
					local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
					return {
						"⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
						"NeoCode v1.0 - The Modern Neovim Experience",
					}
				end,
			},
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

	-- Startup time display
	{
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		config = function()
			vim.g.startuptime_tries = 10
			vim.g.startuptime_exe_args = { "+let g:auto_session_enabled = 0" }
		end,
	},
}
