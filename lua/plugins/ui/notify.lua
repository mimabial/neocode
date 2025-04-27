--------------------------------------------------------------------------------
-- Notification System
--------------------------------------------------------------------------------
--
-- This module configures nvim-notify, a fancy notification system for Neovim.
--
-- Features:
-- 1. Stylish notification windows
-- 2. Notification history
-- 3. Customizable appearance (animations, colors)
-- 4. API for sending rich notifications
-- 5. Integration with other plugins
--
-- Notifications provide important feedback without disrupting workflow.
--------------------------------------------------------------------------------

return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	keys = {
		{
			"<leader>un",
			function()
				require("notify").dismiss({ silent = true, pending = true })
			end,
			desc = "Dismiss all Notifications",
		},
		{
			"<leader>sn",
			function()
				require("telescope").extensions.notify.notify()
			end,
			desc = "Notification History",
		},
	},
	opts = {
		-- General settings
		timeout = 3000, -- Default timeout (3 seconds)
		max_height = function()
			return math.floor(vim.o.lines * 0.75)
		end,
		max_width = function()
			return math.floor(vim.o.columns * 0.75)
		end,
		-- Whether notifications render on top of windows
		top_down = true,
		-- Background color (transparent by default)
		background_colour = "#000000",
		-- Minimum width of notification window
		minimum_width = 50,
		-- Icons for different notification levels
		icons = {
			ERROR = "",
			WARN = "",
			INFO = "",
			DEBUG = "",
			TRACE = "✎",
		},
		-- Set to true to disable animations
		fps = 30,
		-- Animation style for notifications
		stages = "fade_in_slide_out",
		-- How notifications are stacked
		render = "default",
		-- Function to call when a notification window is closed
		on_close = nil,
		-- Function to call when a notification window opens
		on_open = function(win)
			vim.api.nvim_win_set_config(win, { zindex = 100 })
			if not vim.g.notifications_enabled then
				vim.cmd.close()
			end
		end,
		-- Function to call when notification window is displayed/updated
		on_displayed = nil,
	},
	config = function(_, opts)
		local notify = require("notify")
		notify.setup(opts)

		-- Set as default notify function
		vim.notify = notify

		-- If telescope is available, load the notify extension
		if pcall(require, "telescope") then
			require("telescope").load_extension("notify")
		end

		-- Add command to toggle notifications
		vim.api.nvim_create_user_command("NotificationsToggle", function()
			vim.g.notifications_enabled = not vim.g.notifications_enabled
			if vim.g.notifications_enabled then
				vim.notify("Notifications enabled", vim.log.levels.INFO)
			else
				print("Notifications disabled")
			end
		end, { desc = "Toggle notifications" })

		-- Add command to view notification history
		vim.api.nvim_create_user_command("NotificationsHistory", function()
			require("telescope").extensions.notify.notify()
		end, { desc = "View notification history" })

		-- Enable by default
		vim.g.notifications_enabled = true

		-- Custom notification function with levels
		_G.nf = function(msg, level, opts)
			opts = opts or {}
			level = level or vim.log.levels.INFO

			-- Allow passing a table to be inspected
			if type(msg) == "table" then
				msg = vim.inspect(msg)
			end

			-- Send notification
			vim.notify(msg, level, opts)
		end

		-- Custom notification shortcuts for different levels
		_G.nf_error = function(msg, opts)
			_G.nf(msg, vim.log.levels.ERROR, opts)
		end

		_G.nf_warn = function(msg, opts)
			_G.nf(msg, vim.log.levels.WARN, opts)
		end

		_G.nf_info = function(msg, opts)
			_G.nf(msg, vim.log.levels.INFO, opts)
		end
	end,
}
