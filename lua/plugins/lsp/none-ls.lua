--------------------------------------------------------------------------------
-- none-ls Configuration (External Formatter and Linter Integration)
--------------------------------------------------------------------------------
--
-- This module configures none-ls (null-ls), which integrates non-LSP sources
-- like linters and formatters into the LSP client.
--
-- Features:
-- 1. Code formatting with tools like prettier, black, stylua, etc.
-- 2. Code linting with tools like eslint, flake8, shellcheck, etc.
-- 3. Code actions from non-LSP sources
-- 4. Integration with the LSP client for a unified experience
--
-- This plugin has been replaced by conform.nvim for formatting and nvim-lint
-- for linting in this configuration, but we keep it for compatibility with
-- some plugins that expect null-ls to be present.
--------------------------------------------------------------------------------

return {
	"nvimtools/none-ls.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = { "BufReadPre", "BufNewFile" },
	opts = {},
	config = function()
		local null_ls = require("none-ls")

		-- Setup none-ls with all sources
		null_ls.setup({
			debug = false,
			sources = {
				-- These are commented out because we use conform.nvim and nvim-lint instead.
				-- We're just initializing none-ls for compatibility with other plugins.

				-- You can uncomment these if you prefer using none-ls directly
				-- instead of the more specialized plugins.

				-- Formatting
				-- null_ls.builtins.formatting.prettier,
				-- null_ls.builtins.formatting.black,
				-- null_ls.builtins.formatting.stylua,
				-- null_ls.builtins.formatting.shfmt,
				-- null_ls.builtins.formatting.rustfmt,

				-- Diagnostics
				-- null_ls.builtins.diagnostics.eslint_d,
				-- null_ls.builtins.diagnostics.flake8,
				-- null_ls.builtins.diagnostics.shellcheck,
				-- null_ls.builtins.diagnostics.luacheck,

				-- Code Actions
				-- null_ls.builtins.code_actions.gitsigns,
				-- null_ls.builtins.code_actions.eslint_d,
			},

			-- Auto-format on save functionality is handled by conform.nvim
			on_attach = function(client, bufnr)
				-- We don't need to set up formatting here as conform.nvim handles it
			end,
		})

		-- Create commands for compatibility with plugins that expect null-ls
		vim.api.nvim_create_user_command("NullLsInfo", function()
			vim.notify(
				"Using none-ls as compatibility layer. Primary formatting and linting is handled by conform.nvim and nvim-lint.",
				vim.log.levels.INFO
			)
			require("none-ls").print_sources()
		end, { desc = "Show none-ls sources" })
	end,
}
