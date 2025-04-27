--------------------------------------------------------------------------------
-- Noice UI Enhancement
--------------------------------------------------------------------------------
--
-- This module configures Noice, which replaces various Neovim UI components with
-- a more modern and customizable interface.
--
-- Features:
-- 1. Command line UI overhaul
-- 2. Enhanced message display
-- 3. Improved LSP progress notifications
-- 4. Fancy search UI
-- 5. Custom views for LSP functionality
--
-- Noice makes Neovim's interface more polished and informative while
-- maintaining performance and staying out of your way.
--------------------------------------------------------------------------------

return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	opts = {
		-- Command line configuration
		cmdline = {
			enabled = true,
			view = "cmdline_popup", -- "cmdline" | "cmdline_popup"
			opts = {
				position = {
					row = "50%",
					col = "50%",
				},
				size = {
					width = "auto",
					height = "auto",
				},
			},
			format = {
				cmdline = { icon = " " },
				search_down = { icon = " " },
				search_up = { icon = " " },
				filter = { icon = "$ " },
				lua = { icon = " " },
				help = { icon = " " },
			},
		},

		-- Message configuration
		messages = {
			enabled = true,
			view = "notify", -- "notify" | "mini" | "split"
			view_error = "notify", -- view for errors
			view_warn = "notify", -- view for warnings
			view_history = "messages", -- view for :messages
			view_search = "virtualtext", -- view for search count messages
		},

		-- LSP progress notifications
		lsp = {
			-- Override markdown rendering so that cmp and other plugins use Treesitter
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
			hover = {
				enabled = true,
				silent = false, -- set to true to not show a message if hover is not available
			},
			signature = {
				enabled = true,
				auto_open = {
					enabled = true,
					trigger = true, -- enable signature on trigger
					luasnip = true, -- enable signature in luasnip node jump
					throttle = 50, -- debounce lsp signature help requests
				},
			},
			-- Show messages from LSP in a floating window
			message = {
				enabled = true,
				-- When true, show all diagnostics regardless of severity
				view = "notify",
				-- Options for floating windows
				opts = {},
			},
			-- Show LSP progress in a mini view
			progress = {
				enabled = true,
				view = "mini",
			},
		},

		-- Presets for common functionality
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
			command_palette = true, -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = true, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = true, -- add a border to hover docs and signature help
		},

		-- Routes to filter out or modify messages
		routes = {
			-- Hide unwanted messages
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "written",
				},
				opts = { skip = true },
			},
			-- Redirect command outputs to split
			{
				filter = {
					event = "msg_show",
					kind = "echo",
					find = "more than",
				},
				view = "split",
			},
			-- Fold long LSP messages
			{
				filter = {
					event = "lsp",
					kind = "progress",
				},
				view = "mini",
			},
		},

		-- Custom views
		views = {
			cmdline_popup = {
				position = {
					row = 5,
					col = "50%",
				},
				size = {
					width = 80,
					height = "auto",
				},
				border = {
					style = "rounded",
					padding = { 1, 2 },
				},
				filter_options = {},
				win_options = {
					winhighlight = {
						Normal = "NormalFloat",
						FloatBorder = "FloatBorder",
					},
					cursorline = false,
				},
			},
			mini = {
				zindex = 100,
				win_options = {
					winblend = 0,
					winhighlight = {
						Normal = "NoicePopup",
						IncSearch = "",
						Search = "",
					},
				},
			},
		},

		-- Custom notify backend
		notify = {
			enabled = true,
			view = "notify",
		},

		-- Show current mode in statusline rather than cmdline
		status = {
			command = {
				pattern = "^:",
				icon = "",
				lang = "vim",
			},
			search = {
				pattern = "^/",
				icon = "",
				lang = "regex",
			},
			lua = {
				pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
				icon = "",
				lang = "lua",
			},
		},

		-- Show search results count
		search = {
			enabled = true,
			view = "virtualtext",
		},

		-- Record history for display
		history = {
			view = "split",
			opts = {
				enter = true,
				format = "details",
			},
			filter = {
				any = {
					{ event = "notify" },
					{ error = true },
					{ warning = true },
					{ event = "msg_show", kind = { "" } },
					{ event = "lsp", kind = "message" },
				},
			},
		},

		-- Smart-split behavior
		smart_move = {
			enabled = true, -- Keep cursor in command-line when noice opens
			excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
		},
	},
	config = function(_, opts)
		require("noice").setup(opts)

		-- Add key mappings
		vim.keymap.set("n", "<leader>sna", function()
			require("noice").cmd("all")
		end, { desc = "Noice All Messages" })
		vim.keymap.set("n", "<leader>snh", function()
			require("noice").cmd("history")
		end, { desc = "Noice History" })
		vim.keymap.set("n", "<leader>snl", function()
			require("noice").cmd("last")
		end, { desc = "Noice Last Message" })
		vim.keymap.set("n", "<leader>snd", function()
			require("noice").cmd("dismiss")
		end, { desc = "Dismiss All" })

		-- Jump to next/prev notification with <C-j> and <C-k>
		vim.keymap.set({ "n", "i", "s" }, "<c-j>", function()
			if not require("noice.lsp").scroll(4) then
				return "<c-j>"
			end
		end, { silent = true, expr = true })

		vim.keymap.set({ "n", "i", "s" }, "<c-k>", function()
			if not require("noice.lsp").scroll(-4) then
				return "<c-k>"
			end
		end, { silent = true, expr = true })
	end,
}
