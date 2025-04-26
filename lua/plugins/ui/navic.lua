--------------------------------------------------------------------------------
-- Code Context Display (navic)
--------------------------------------------------------------------------------
--
-- This module configures nvim-navic for displaying code context in the winbar.
--
-- Features:
-- 1. Display current position in code (function, class, etc.)
-- 2. Navigation breadcrumbs for current file location
-- 3. Integration with LSP for accurate context information
-- 4. Customizable appearance with icons and highlights
--
-- This provides a clear visual indicator of where you are in your code.
--------------------------------------------------------------------------------

return {
	"SmiteshP/nvim-navic",
	dependencies = "neovim/nvim-lspconfig",
	event = "LspAttach",
	opts = {
		-- Icons for different symbol kinds
		icons = {
			File = " ",
			Module = " ",
			Namespace = " ",
			Package = " ",
			Class = " ",
			Method = " ",
			Property = " ",
			Field = " ",
			Constructor = " ",
			Enum = " ",
			Interface = " ",
			Function = " ",
			Variable = " ",
			Constant = " ",
			String = " ",
			Number = " ",
			Boolean = " ",
			Array = " ",
			Object = " ",
			Key = " ",
			Null = " ",
			EnumMember = " ",
			Struct = " ",
			Event = " ",
			Operator = " ",
			TypeParameter = " ",
		},
		-- Appearance settings
		highlight = true,
		separator = " › ",
		depth_limit = 0,
		depth_limit_indicator = "..",
		safe_output = true,
		click = false,
	},
	config = function(_, opts)
		require("nvim-navic").setup(opts)

		-- Setup winbar with navic
		-- Exclude certain filetypes
		local excluded_filetypes = {
			"help",
			"dashboard",
			"lazy",
			"mason",
			"notify",
			"toggleterm",
			"lazyterm",
			"Trouble",
			"spectre_panel",
			"TelescopePrompt",
			"NvimTree",
			"neo-tree",
			"oil",
		}

		-- Function to display navic location in the winbar
		local function navic_winbar()
			if vim.tbl_contains(excluded_filetypes, vim.bo.filetype) then
				return
			end

			-- Skip special buffers
			local buftype = vim.bo.buftype
			if buftype == "terminal" or buftype == "prompt" or buftype == "nofile" or buftype == "quickfix" then
				return
			end

			-- Get current file name
			local filename = vim.fn.expand("%:t")
			if filename == "" then
				filename = "[No Name]"
			end

			-- Get file icon
			local file_icon = ""
			local extension = vim.fn.expand("%:e")
			if extension and extension ~= "" then
				-- Use devicons if available
				local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
				if devicons_ok then
					file_icon, _ = devicons.get_icon_by_filetype(vim.bo.filetype)
						or devicons.get_icon(filename, extension)
					if file_icon then
						file_icon = file_icon .. " "
					end
				end
			end

			-- Create the winbar
			local winbar = " " .. file_icon .. filename

			-- Add navic location if available
			local navic_ok, navic = pcall(require, "nvim-navic")
			if navic_ok and navic.is_available() then
				local location = navic.get_location()
				if location and location ~= "" then
					winbar = winbar .. " › " .. location
				end
			end

			-- Set the winbar
			vim.wo.winbar = winbar
		end

		-- Set up autocommand to update winbar
		vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost" }, {
			callback = navic_winbar,
		})

		-- Also create on initial setup
		navic_winbar()
	end,
}
