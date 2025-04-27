--------------------------------------------------------------------------------
-- Buffer Line Configuration
--------------------------------------------------------------------------------
--
-- This module configures a modern buffer line with tabs, file icons,
-- diagnostics, and close buttons.
--
-- Features:
-- 1. Stylish tab display for open buffers
-- 2. Buffer groups and pinning options
-- 3. Integration with LSP diagnostics
-- 4. Mouse-friendly tab navigation
-- 5. Customizable appearance to match colorscheme
--
-- The buffer line enhances navigation between open files and provides
-- better visual cues about the current state of each buffer.
--------------------------------------------------------------------------------

return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		-- Buffer management keymaps
		{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
		{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
		{ "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
		{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
		{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
		-- Buffer navigation keymaps
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
		{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
		{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
		-- Buffer selection keymaps
		{ "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Buffer 1" },
		{ "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Buffer 2" },
		{ "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Buffer 3" },
		{ "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Buffer 4" },
		{ "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Buffer 5" },
		{ "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Buffer 6" },
		{ "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Buffer 7" },
		{ "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Buffer 8" },
		{ "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "Buffer 9" },
	},
	opts = {
		options = {
			mode = "buffers", -- "buffers" or "tabs"
			numbers = "none", -- "none" | "ordinal" | "buffer_id" | "both"
			close_command = function(n)
				-- Use mini.bufremove to close buffers nicely
				require("mini.bufremove").delete(n, false)
			end,
			right_mouse_command = function(n)
				require("mini.bufremove").delete(n, false)
			end,
			left_mouse_command = "buffer %d", -- Can be a string | function
			middle_mouse_command = nil, -- Can be a string | function
			indicator = {
				icon = "▎", -- This should be omitted if indicator style is not 'icon'
				style = "icon", -- 'icon' | 'underline' | 'none'
			},
			buffer_close_icon = "",
			modified_icon = "●",
			close_icon = "",
			left_trunc_marker = "",
			right_trunc_marker = "",
			max_name_length = 18,
			max_prefix_length = 15, -- Prefix used for a buffer from multiple windows
			truncate_names = true, -- Whether to truncate buffer names
			tab_size = 18,
			diagnostics = "nvim_lsp", -- false | "nvim_lsp" | "coc"
			diagnostics_update_in_insert = false,
			diagnostics_indicator = function(count, level)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,
			-- Configure offsets for file explorers or other windows
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
			color_icons = true, -- Enable file icons with colors
			show_buffer_icons = true,
			show_buffer_close_icons = true,
			show_close_icon = true,
			show_tab_indicators = true,
			show_duplicate_prefix = true, -- Whether to show duplicate buffer prefix
			persist_buffer_sort = true, -- Whether to persist buffer sorting
			separator_style = "thin", -- "slant" | "slope" | "thick" | "thin" | { 'any', 'any' }
			enforce_regular_tabs = true,
			always_show_bufferline = true,
			hover = {
				enabled = true,
				delay = 200,
				reveal = { "close" },
			},
			sort_by = "insert_after_current", -- "id" | "extension" | "relative_directory" | "directory" | "tabs"
			groups = {
				options = {
					toggle_hidden_on_enter = true,
				},
				items = {
					{
						name = "Tests",
						priority = 2,
						icon = "",
						matcher = function(buf)
							return buf.name:match("%_test") or buf.name:match("%_spec") or buf.name:match("test%.")
						end,
					},
					{
						name = "Docs",
						priority = 3,
						icon = "",
						matcher = function(buf)
							local ext = vim.fn.fnamemodify(buf.path, ":e")
							return ext == "md" or ext == "txt" or ext == "org" or ext == "norg" or ext == "wiki"
						end,
					},
					{
						name = "Config",
						priority = 4,
						icon = "",
						matcher = function(buf)
							return buf.name:match("%.json$")
								or buf.name:match("%.ya?ml$")
								or buf.name:match("%.toml$")
								or buf.name:match("%.conf$")
								or buf.name:match("rc$")
						end,
					},
				},
			},
		},
		-- Configure highlights to match colorscheme
		highlights = {
			fill = {
				fg = { attribute = "fg", highlight = "TabLine" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			background = {
				fg = { attribute = "fg", highlight = "TabLine" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			buffer_visible = {
				fg = { attribute = "fg", highlight = "TabLine" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			buffer_selected = {
				fg = { attribute = "fg", highlight = "Normal" },
				bg = { attribute = "bg", highlight = "Normal" },
				bold = true,
				italic = false,
			},
			separator = {
				fg = { attribute = "bg", highlight = "TabLine" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			separator_selected = {
				fg = { attribute = "bg", highlight = "TabLine" },
				bg = { attribute = "bg", highlight = "Normal" },
			},
			separator_visible = {
				fg = { attribute = "bg", highlight = "TabLine" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			close_button = {
				fg = { attribute = "fg", highlight = "TabLine" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			close_button_selected = {
				fg = { attribute = "fg", highlight = "TabLineSel" },
				bg = { attribute = "bg", highlight = "Normal" },
			},
			modified = {
				fg = { attribute = "fg", highlight = "TabLine" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			modified_selected = {
				fg = { attribute = "fg", highlight = "WildMenu" },
				bg = { attribute = "bg", highlight = "Normal" },
			},
			duplicate = {
				fg = { attribute = "fg", highlight = "TabLine" },
				bg = { attribute = "bg", highlight = "TabLine" },
				italic = true,
			},
			duplicate_selected = {
				fg = { attribute = "fg", highlight = "TabLineSel" },
				bg = { attribute = "bg", highlight = "Normal" },
				italic = true,
			},
			indicator_selected = {
				fg = { attribute = "fg", highlight = "LspDiagnosticsDefaultHint" },
				bg = { attribute = "bg", highlight = "Normal" },
			},
			diagnostic = {
				fg = { attribute = "fg", highlight = "Comment" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			diagnostic_selected = {
				fg = { attribute = "fg", highlight = "Comment" },
				bg = { attribute = "bg", highlight = "Normal" },
				bold = true,
				italic = true,
			},
			hint = {
				fg = { attribute = "fg", highlight = "DiagnosticHint" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			hint_selected = {
				fg = { attribute = "fg", highlight = "DiagnosticHint" },
				bg = { attribute = "bg", highlight = "Normal" },
				bold = true,
			},
			warning = {
				fg = { attribute = "fg", highlight = "DiagnosticWarn" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			warning_selected = {
				fg = { attribute = "fg", highlight = "DiagnosticWarn" },
				bg = { attribute = "bg", highlight = "Normal" },
				bold = true,
			},
			error = {
				fg = { attribute = "fg", highlight = "DiagnosticError" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			error_selected = {
				fg = { attribute = "fg", highlight = "DiagnosticError" },
				bg = { attribute = "bg", highlight = "Normal" },
				bold = true,
			},
			info = {
				fg = { attribute = "fg", highlight = "DiagnosticInfo" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			info_selected = {
				fg = { attribute = "fg", highlight = "DiagnosticInfo" },
				bg = { attribute = "bg", highlight = "Normal" },
				bold = true,
			},
			pick = {
				fg = { attribute = "fg", highlight = "LspDiagnosticsDefaultError" },
				bg = { attribute = "bg", highlight = "TabLine" },
				bold = true,
				italic = true,
			},
			pick_selected = {
				fg = { attribute = "fg", highlight = "LspDiagnosticsDefaultError" },
				bg = { attribute = "bg", highlight = "Normal" },
				bold = true,
				italic = true,
			},
			tab = {
				fg = { attribute = "fg", highlight = "TabLine" },
				bg = { attribute = "bg", highlight = "TabLine" },
			},
			tab_selected = {
				fg = { attribute = "fg", highlight = "WildMenu" },
				bg = { attribute = "bg", highlight = "WildMenu" },
			},
			tab_close = {
				fg = { attribute = "fg", highlight = "TabLineSel" },
				bg = { attribute = "bg", highlight = "Normal" },
			},
		},
	},
	config = function(_, opts)
		require("bufferline").setup(opts)

		-- Commands for toggling certain functionality
		vim.api.nvim_create_user_command("BufferlineToggleOffsets", function()
			local bufferline = require("bufferline")
			bufferline.setup({
				options = {
					offsets = not bufferline.config.options.offsets or {},
				},
			})
			vim.notify("Toggled bufferline offsets")
		end, {})

		-- Command to sort buffers by directory
		vim.api.nvim_create_user_command("BufferlineSortByDirectory", function()
			require("bufferline").setup({
				options = {
					sort_by = "directory",
				},
			})
			vim.notify("Sorted buffers by directory")
		end, {})

		-- Command to sort buffers by relative dir
		vim.api.nvim_create_user_command("BufferlineSortByRelative", function()
			require("bufferline").setup({
				options = {
					sort_by = "relative_directory",
				},
			})
			vim.notify("Sorted buffers by relative directory")
		end, {})

		-- Command to reset sort order to default
		vim.api.nvim_create_user_command("BufferlineSortByDefault", function()
			require("bufferline").setup({
				options = {
					sort_by = "insert_after_current",
				},
			})
			vim.notify("Reset buffer sorting to default")
		end, {})
	end,
}
