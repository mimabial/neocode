--------------------------------------------------------------------------------
-- Minimap / Code Outline
--------------------------------------------------------------------------------
--
-- This module configures a minimap/code outline similar to popular GUI editors.
--
-- Features:
-- 1. Visual overview of the current buffer
-- 2. Syntax highlighting in the minimap
-- 3. Indicator for the current viewport position
-- 4. Configurable appearance and behavior
-- 5. Intelligent auto-sizing and positioning
--
-- The minimap provides spatial awareness when navigating large files.
--------------------------------------------------------------------------------

return {
	"gorbit99/codewindow.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		{ "<leader>um", "<cmd>lua require('codewindow').toggle_minimap()<CR>", desc = "Toggle Minimap" },
		{ "<leader>uf", "<cmd>lua require('codewindow').toggle_focus()<CR>", desc = "Toggle Minimap Focus" },
	},
	event = "BufReadPost", -- Load for all buffers after reading
	enabled = true, -- Set to false to disable this plugin entirely
	opts = {
		-- Standard options
		active_in_terminals = false, -- Disable in terminal buffers
		auto_enable = false, -- Don't auto-enable minimap
		exclude_filetypes = { "help", "dashboard", "NvimTree", "Outline", "TelescopePrompt", "Trouble" },
		max_minimap_height = nil, -- Use adaptive height
		max_lines = nil, -- Don't limit lines shown (may affect performance)
		minimap_width = 20, -- Width of the minimap
		use_lsp = true, -- Use LSP to enhance the minimap
		use_treesitter = true, -- Use treesitter for better syntax highlighting
		use_git = true, -- Show git additions/deletions
		width_multiplier = 4, -- How many characters one minimap character represents
		z_index = 10, -- Position of the minimap (lower numbers are behind)
		show_cursor = true, -- Show the cursor position in the minimap
		window_border = "single", -- Border style

		-- Integrations
		integrations = {
			-- Show diagnostic signs from nvim-lspconfig
			diagnostic = {
				enable = true,
				show_errors = true,
				show_warnings = true,
				show_hints = true,
				show_info = true,
			},

			-- Show git signs
			gitsigns = {
				enable = true,
				show_modified = true,
				show_added = true,
				show_removed = true,
			},
		},

		-- Appearance
		symbols = {
			-- Symbol to represent text in the minimap
			text = "░",
			-- Symbol for diagnostics
			diagnostic_error = "▓",
			diagnostic_warning = "▓",
			diagnostic_info = "▓",
			diagnostic_hint = "▓",
			-- Git symbols
			git_added = "▓",
			git_modified = "▓",
			git_removed = "▓",
		},

		-- Colors
		colors = {
			-- Background of the window
			background = "#24283b", -- Dark background for minimap
			-- Highlighted text colors
			error = "#db4b4b", -- Red for errors
			warning = "#e0af68", -- Yellow for warnings
			info = "#0db9d7", -- Blue for info
			hint = "#1abc9c", -- Cyan for hints
			-- Git colors
			git_added = "#9ece6a", -- Green for additions
			git_modified = "#7aa2f7", -- Blue for modifications
			git_removed = "#f7768e", -- Red for deletions
		},
	},
	config = function(_, opts)
		require("codewindow").setup(opts)

		-- Auto-open behaviors
		local codewindow_group = vim.api.nvim_create_augroup("CodewindowGroup", { clear = true })

		-- Open minimap for certain filetypes automatically
		if opts.auto_enable then
			vim.api.nvim_create_autocmd("FileType", {
				group = codewindow_group,
				pattern = { "python", "lua", "javascript", "typescript", "rust", "go", "c", "cpp", "java" },
				callback = function()
					-- Don't enable for excluded filetypes
					if vim.tbl_contains(opts.exclude_filetypes, vim.bo.filetype) then
						return
					end
					-- Don't enable for small files (< 100 lines)
					if vim.api.nvim_buf_line_count(0) < 100 then
						return
					end
					-- Enable minimap
					require("codewindow").open_minimap()
				end,
			})
		end

		-- Close minimap when changing buffers
		vim.api.nvim_create_autocmd("BufLeave", {
			group = codewindow_group,
			callback = function()
				require("codewindow").close_minimap()
			end,
		})

		-- Command to toggle auto-enable
		vim.api.nvim_create_user_command("MinimapAutoToggle", function()
			opts.auto_enable = not opts.auto_enable
			vim.notify("Minimap auto-enable " .. (opts.auto_enable and "enabled" or "disabled"))
		end, { desc = "Toggle minimap auto-enable" })
	end,
}
