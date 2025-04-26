--------------------------------------------------------------------------------
-- LSP (Language Server Protocol) Configuration
--------------------------------------------------------------------------------
--
-- This module configures Language Server Protocol integration which provides:
-- * Code completion
-- * Diagnostics (errors, warnings)
-- * Hover documentation
-- * Go-to-definition
-- * Symbol search
-- * Code actions
-- * Inlay hints
-- * And more...
--
-- The configuration is modular:
-- 1. LSP servers configuration (servers.lua)
-- 2. Formatting tools (formatters.lua)
-- 3. Linters (linters.lua)
-- 4. LSP-specific keymaps (keymaps.lua)
-- 5. LSP UI configuration (ui.lua)
-- 6. Non-LSP sources via none-ls.nvim (none-ls.lua)
--
-- We use the following components:
-- * nvim-lspconfig: Base LSP configuration
-- * mason.nvim: Install LSP servers, formatters, and linters
-- * mason-lspconfig.nvim: Bridge between mason and lspconfig
-- * none-ls.nvim: Non-LSP sources (formatters, linters)
-- * nvim-navic: Code context in winbar
-- * fidget.nvim: LSP progress indicator
-- * lsp_signature.nvim: Function signature help
--------------------------------------------------------------------------------

return {
	-- Main LSP configuration plugin
	{ import = "plugins.lsp.servers" },
	{ import = "plugins.lsp.formatters" },
	{ import = "plugins.lsp.linters" },
	{ import = "plugins.lsp.keymaps" },
	{ import = "plugins.lsp.ui" },
	{ import = "plugins.lsp.none-ls" }, -- Make sure this line is present to load none-ls.lua

	-- Mason for installing LSP servers, formatters, linters, and DAP
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>lm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {
				-- Core formatters and linters for common languages
				"stylua", -- Lua
				"shfmt", -- Shell
				"shellcheck", -- Shell
				"black", -- Python
				"isort", -- Python
				"flake8", -- Python
				"prettier", -- Web
				"eslint_d", -- JavaScript/TypeScript
				-- Add none-ls here to ensure it gets installed
				"none-ls.nvim",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)

			-- Ensure the specified tools are installed
			local mr = require("mason-registry")
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end

			-- Auto-install if mason registry is available
			if mr.refresh then
				mr.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},

	-- Bridge between Mason and LSP config
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = require("plugins.lsp.servers").ensure_installed,
				automatic_installation = true,
			})
		end,
	},

	-- LSP Status
	{
		"j-hui/fidget.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
		event = "LspAttach",
		opts = {
			notification = {
				window = { winblend = 0 },
			},
		},
	},

	-- Enhanced LSP signature help
	{
		"ray-x/lsp_signature.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
		event = "LspAttach",
		opts = {
			bind = true,
			handler_opts = {
				border = "rounded",
			},
			hint_enable = true,
			hint_prefix = "🔍 ",
			hint_scheme = "String",
			hi_parameter = "Search",
			toggle_key = "<C-k>", -- Toggle signature on and off in insert mode
			select_signature_key = "<C-n>", -- Cycle between signatures
		},
	},

	-- Improved LSP UI components
	{
		"glepnir/lspsaga.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		event = "LspAttach",
		config = function()
			require("lspsaga").setup({
				ui = {
					border = "rounded",
					winblend = 0,
					theme = "round",
					title = true,
				},
				symbol_in_winbar = {
					enable = false, -- We use nvim-navic instead
				},
				lightbulb = {
					enable = true,
					sign = true,
					virtual_text = false,
				},
				outline = {
					win_width = 30,
					auto_preview = false,
					auto_close = true,
				},
			})
		end,
		keys = {
			{ "K", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Doc" },
			{ "<leader>la", "<cmd>Lspsaga code_action<CR>", desc = "Code Action" },
			{ "<leader>lr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
			{ "<leader>lp", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek Definition" },
			{ "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Line Diagnostics" },
			{ "<leader>lo", "<cmd>Lspsaga outline<CR>", desc = "Outline" },
			{ "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Previous Diagnostic" },
			{ "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next Diagnostic" },
		},
	},
}
