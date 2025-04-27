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
-- 5. Dynamic context updates as you navigate code
--
-- This provides a clear visual indicator of where you are in your codebase.
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
		depth_limit = 0, -- 0 means no limit
		depth_limit_indicator = "..",
		safe_output = true,
		click = false, -- Enable clicking on breadcrumb elements
		format_text = nil, -- Function to format text if needed
		lazy_update_context = false, -- Whether to update context only on cursor hold
		lsp = {
			auto_attach = true, -- Auto attach to LSP servers
			preference = nil, -- List of preferred LSP servers to use for navic
		},
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
			"alpha",
			"dap-repl",
		}

		-- Function to check if current buffer should be excluded
		local function is_excluded()
			-- Check filetype
			if vim.tbl_contains(excluded_filetypes, vim.bo.filetype) then
				return true
			end

			-- Skip special buffers
			local buftype = vim.bo.buftype
			if buftype == "terminal" or buftype == "prompt" or buftype == "nofile" or buftype == "quickfix" then
				return true
			end

			-- Skip small windows
			local win_width = vim.fn.winwidth(0)
			if win_width < 70 then
				return true
			end

			return false
		end

		-- Function to display navic location in the winbar
		local function navic_winbar()
			if is_excluded() then
				vim.opt_local.winbar = nil
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
			local padding = " "

			if extension and extension ~= "" then
				-- Use devicons if available
				local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
				if devicons_ok then
					file_icon, _ = devicons.get_icon_by_filetype(vim.bo.filetype)
						or devicons.get_icon(filename, extension)
					if file_icon then
						file_icon = file_icon .. padding
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
			vim.opt_local.winbar = winbar
		end

		-- Set up autocommand to update winbar
		vim.api.nvim_create_augroup("NavicWinbar", { clear = true })

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorHold", "BufWinEnter", "BufFilePost" }, {
			group = "NavicWinbar",
			callback = navic_winbar,
		})

		-- Set up LSP attach hook to add navic
		vim.api.nvim_create_autocmd("LspAttach", {
			group = "NavicWinbar",
			callback = function(args)
				local buffer = args.buf
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.server_capabilities.documentSymbolProvider then
					require("nvim-navic").attach(client, buffer)
					navic_winbar() -- Update immediately after attach
				end
			end,
		})

		-- Trigger an initial update
		navic_winbar()

		-- Add command to toggle navic
		vim.api.nvim_create_user_command("NavicToggle", function()
			if vim.g.navic_enabled == false then
				vim.g.navic_enabled = true
				navic_winbar()
				vim.notify("Code context enabled", vim.log.levels.INFO)
			else
				vim.g.navic_enabled = false
				vim.opt_local.winbar = nil
				vim.notify("Code context disabled", vim.log.levels.INFO)
			end
		end, { desc = "Toggle code context display" })

		-- Enable by default
		vim.g.navic_enabled = true

		-- Add keymap to toggle navic
		vim.keymap.set("n", "<leader>uc", "<cmd>NavicToggle<cr>", { desc = "Toggle code context" })
	end,
}
