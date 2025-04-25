--------------------------------------------------------------------------------
-- Dashboard Configuration
--------------------------------------------------------------------------------
--
-- This module configures a welcome dashboard for Neovim:
--
-- Features:
-- 1. Startup screen with logo and info
-- 2. Quick action buttons
-- 3. Recent files
-- 4. Session management integration
-- 5. Custom header and footer
--
-- The dashboard provides a welcome screen when Neovim starts without arguments.
--------------------------------------------------------------------------------

return {
	-- Dashboard
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = function()
			local logo = [[
      ███╗   ██╗███████╗ ██████╗  ██████╗ ██████╗ ██████╗ ███████╗
      ████╗  ██║██╔════╝██╔═══██╗██╔════╝██╔═══██╗██╔══██╗██╔════╝
      ██╔██╗ ██║█████╗  ██║   ██║██║     ██║   ██║██║  ██║█████╗  
      ██║╚██╗██║██╔══╝  ██║   ██║██║     ██║   ██║██║  ██║██╔══╝  
      ██║ ╚████║███████╗╚██████╔╝╚██████╗╚██████╔╝██████╔╝███████╗
      ╚═╝  ╚═══╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝
                                                               
             Welcome to NeoCode - Your Enhanced Neovim Setup                                                        
      ]]

			logo = string.rep("\n", 8) .. logo .. "\n\n"

			local opts = {
				theme = "doom",
				hide = {
					-- This is taken care of by lualine
					-- Remove if you use something else
					statusline = false,
					tabline = false,
					winbar = false,
				},
				config = {
					header = vim.split(logo, "\n"),
          -- stylua: ignore
          center = {
            { action = "Telescope find_files",              desc = " Find file",         icon = " ", key = "f" },
            { action = "ene | startinsert",                 desc = " New file",          icon = " ", key = "n" },
            { action = "Telescope oldfiles",                desc = " Recent files",      icon = " ", key = "r" },
            { action = "Telescope live_grep",               desc = " Find text",         icon = " ", key = "g" },
            { action = "e $MYVIMRC",                        desc = " Config",            icon = " ", key = "c" },
            { action = 'lua require("persistence").load()', desc = " Restore Session",   icon = " ", key = "s" },
            { action = "Lazy",                              desc = " Lazy",              icon = "󰒲 ", key = "l" },
            { action = "qa",                                desc = " Quit",              icon = " ", key = "q" },
          },
					footer = function()
						local stats = require("lazy").stats()
						local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
						return {
							"⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms",
							"NeoCode v1.0.0 - https://github.com/yourusername/neocode",
						}
					end,
				},
				buttons = {
					-- Text, highlight group, key
					{ "  Find File", "DashboardShortCut", "f" },
					{ "  New File", "DashboardShortCut", "n" },
					{ "  Recent Files", "DashboardShortCut", "r" },
					{ "  Find Word", "DashboardShortCut", "g" },
					{ "  Settings", "DashboardShortCut", "c" },
					{ "  Restore Session", "DashboardShortCut", "s" },
					{ "󰒲  Lazy", "DashboardShortCut", "l" },
					{ "  Quit", "DashboardShortCut", "q" },
				},
			}

			-- Show dashboard in a clean environment
			for _, button in ipairs(opts.config.center) do
				button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
				button.key_format = "  %s"
			end

			-- Close Lazy and re-open when the dashboard is ready
			if vim.o.filetype == "lazy" then
				vim.cmd.close()
				vim.api.nvim_create_autocmd("User", {
					pattern = "DashboardLoaded",
					callback = function()
						require("lazy").show()
					end,
				})
			end

			return opts
		end,
	},

	-- Session management
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {
			dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
			options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
			pre_save = nil,
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

	-- Alpha dashboard (alternative dashboard)
	{
		"goolord/alpha-nvim",
		enabled = false, -- Disabled by default, use dashboard-nvim instead
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local dashboard = require("alpha.themes.dashboard")
			local logo = [[
      ███╗   ██╗███████╗ ██████╗  ██████╗ ██████╗ ██████╗ ███████╗
      ████╗  ██║██╔════╝██╔═══██╗██╔════╝██╔═══██╗██╔══██╗██╔════╝
      ██╔██╗ ██║█████╗  ██║   ██║██║     ██║   ██║██║  ██║█████╗  
      ██║╚██╗██║██╔══╝  ██║   ██║██║     ██║   ██║██║  ██║██╔══╝  
      ██║ ╚████║███████╗╚██████╔╝╚██████╗╚██████╔╝██████╔╝███████╗
      ╚═╝  ╚═══╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝
                                                               
             Welcome to NeoCode - Your Enhanced Neovim Setup                                                        
      ]]

			dashboard.section.header.val = vim.split(logo, "\n")
			dashboard.section.buttons.val = {
				dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
				dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
				dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
				dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
				dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
				dashboard.button("s", "  Restore Session", [[:lua require("persistence").load() <cr>]]),
				dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
				dashboard.button("q", "  Quit", ":qa<CR>"),
			}

			for _, button in ipairs(dashboard.section.buttons.val) do
				button.opts.hl = "AlphaButtons"
				button.opts.hl_shortcut = "AlphaShortcut"
			end

			dashboard.section.header.opts.hl = "AlphaHeader"
			dashboard.section.buttons.opts.hl = "AlphaButtons"
			dashboard.section.footer.opts.hl = "AlphaFooter"
			dashboard.opts.layout[1].val = 8

			dashboard.section.footer.val = {
				" ",
				" ",
				"⚡ Neovim loaded " .. require("lazy").stats().count .. " plugins",
				"NeoCode v1.0.0 - https://github.com/yourusername/neocode",
			}

			require("alpha").setup(dashboard.opts)

			-- Hide the tabline and status line on the dashboard
			vim.api.nvim_create_autocmd("User", {
				pattern = "AlphaReady",
				callback = function()
					vim.opt.laststatus = 0
					vim.opt.showtabline = 0

					vim.api.nvim_create_autocmd("BufUnload", {
						buffer = 0,
						callback = function()
							vim.opt.laststatus = 3
							vim.opt.showtabline = 2
						end,
					})
				end,
			})
		end,
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
