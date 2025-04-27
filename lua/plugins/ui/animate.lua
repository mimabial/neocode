--------------------------------------------------------------------------------
-- Animations for Neovim
--------------------------------------------------------------------------------
--
-- This module configures animations for various Neovim operations,
-- enhancing the visual experience while keeping things efficient.
--
-- Features:
-- 1. Smooth window open/close animations
-- 2. Cursor jump animations
-- 3. Scroll animations
-- 4. Various animation easing functions
-- 5. Performance controls to prevent slowdowns
--
-- These subtle animations make Neovim feel more polished while maintaining
-- the speed and responsiveness expected from a terminal editor.
--------------------------------------------------------------------------------

return {
	"echasnovski/mini.animate",
	event = "VeryLazy",
	opts = {
		-- Modules that are enabled
		cursor = {
			-- Animate cursor movement
			enable = true,
			-- Timing of animation (how many steps and pause between steps)
			timing = function(_, n)
				-- Gradually increase step delay for longer movements
				-- For smooth 60fps-like movement
				if n < 5 then
					return 120, 10
				else
					return 80, 5
				end
			end,
			-- Path generator for visualizing cursor movement
			path = "gentle", -- "line" | "arc" | "gentle" | "subpixel"
			-- Whether to draw the path immediately
			draw_path = false,
		},

		-- Animate scrolling
		scroll = {
			enable = true,
			-- Timing for scrolling animation
			timing = function(_, n)
				return 150, 7
			end,
			-- Subscroll is for smoother scrolling when using C-d/C-u/etc
			subscroll = "sine", -- "linear" | "quadratic" | "cubic" | "quartic" | "sine"
		},

		-- Animate resize
		resize = {
			enable = true,
			-- Timing for resize animation
			timing = function(_, n)
				return 120, 20
			end,
			-- Don't animate resizing in specific modes
			exclude = function()
				-- Don't animate in insert mode to avoid interrupting typing
				if vim.fn.mode() == "i" then
					return true
				end
				-- Don't animate resizing if the window is too small
				local width = vim.o.columns
				local height = vim.o.lines
				if width < 50 or height < 10 then
					return true
				end
				return false
			end,
		},

		-- Animate open/close windows
		open = {
			enable = true,
			-- Timing for opening window animation
			timing = function(_, n)
				return 250, 15
			end,
			-- Windows with specific filetypes to exclude from animation
			exclude = {
				event = { "BufEnter" },
				filetype = {
					"lazy",
					"mason",
					"notify",
					"terminal",
					"help",
					"dashboard",
					"alpha",
					"TelescopePrompt",
					"noice",
				},
				-- Don't animate if window is too big
				size = function(width, height)
					return width > 100 or height > 20
				end,
			},
		},

		-- Animate closing windows
		close = {
			enable = true,
			-- Timing for closing window animation
			timing = function(_, n)
				return 250, 15
			end,
			-- Exclude same windows as with 'open'
			exclude = {
				event = { "BufEnter" },
				filetype = {
					"lazy",
					"mason",
					"notify",
					"terminal",
					"help",
					"dashboard",
					"alpha",
					"TelescopePrompt",
					"noice",
				},
				-- Don't animate if window is too big
				size = function(width, height)
					return width > 100 or height > 20
				end,
			},
		},
	},
	config = function(_, opts)
		require("mini.animate").setup(opts)

		-- Add command to toggle animations
		vim.api.nvim_create_user_command("AnimateToggle", function()
			-- Get current animate config
			local mini_animate = require("mini.animate")
			local config = mini_animate.config

			if config.cursor.enable or config.scroll.enable or config.resize.enable then
				-- Store current settings
				vim.g.animate_settings = vim.deepcopy(config)

				-- Disable all animations
				mini_animate.setup({
					cursor = { enable = false },
					scroll = { enable = false },
					resize = { enable = false },
					open = { enable = false },
					close = { enable = false },
				})

				vim.notify("Animations disabled", vim.log.levels.INFO)
			else
				-- Restore previous settings or use defaults
				local settings = vim.g.animate_settings or opts
				mini_animate.setup(settings)
				vim.notify("Animations enabled", vim.log.levels.INFO)
			end
		end, { desc = "Toggle animations" })

		-- Add keymap to toggle animations
		vim.keymap.set("n", "<leader>ua", "<cmd>AnimateToggle<cr>", { desc = "Toggle animations" })
	end,
}
