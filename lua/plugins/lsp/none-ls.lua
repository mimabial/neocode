--------------------------------------------------------------------------------
-- none-ls Configuration
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
-- This is a core utility for LSP that enables using any CLI tool with the
-- LSP infrastructure.
--------------------------------------------------------------------------------

return {
	"nvimtools/none-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local null_ls_ok, null_ls = pcall(require, "none-ls")
		if not null_ls_ok then
			vim.notify("none-ls not found. Install with :Lazy install", vim.log.levels.WARN)
			return
		end

		-- List of sources organized by language
		local sources = {
			-- Lua
			null_ls.builtins.formatting.stylua,
			null_ls.builtins.diagnostics.luacheck.with({
				extra_args = { "--globals", "vim", "--no-max-line-length" },
			}),

			-- JavaScript/TypeScript
			null_ls.builtins.formatting.prettier.with({
				filetypes = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"vue",
					"css",
					"scss",
					"less",
					"html",
					"json",
					"jsonc",
					"yaml",
					"markdown",
					"graphql",
					"handlebars",
				},
				extra_args = { "--single-quote", "--jsx-single-quote" },
			}),
			null_ls.builtins.diagnostics.eslint_d,
			null_ls.builtins.code_actions.eslint_d,

			-- Python
			null_ls.builtins.formatting.black,
			null_ls.builtins.formatting.isort,
			null_ls.builtins.diagnostics.flake8.with({
				extra_args = { "--max-line-length", "88", "--extend-ignore", "E203" },
			}),
			null_ls.builtins.diagnostics.mypy,

			-- Go
			null_ls.builtins.formatting.gofmt,
			null_ls.builtins.formatting.goimports,

			-- Rust
			null_ls.builtins.formatting.rustfmt,

			-- Shell
			null_ls.builtins.formatting.shfmt,
			null_ls.builtins.diagnostics.shellcheck,
			null_ls.builtins.code_actions.shellcheck,

			-- Markdown
			null_ls.builtins.formatting.markdownlint,
			null_ls.builtins.diagnostics.markdownlint,

			-- General
			null_ls.builtins.diagnostics.codespell.with({
				filetypes = {
					"javascript",
					"typescript",
					"python",
					"lua",
					"rust",
					"go",
					"c",
					"cpp",
					"java",
					"markdown",
					"text",
				},
			}),
			null_ls.builtins.code_actions.gitsigns,
		}

		-- Setup null-ls with sources
		null_ls.setup({
			debug = false,
			sources = sources,

			-- Auto-format on save functionality
			on_attach = function(client, bufnr)
				-- Format on save
				if client.supports_method("textDocument/formatting") then
					local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							-- Skip formatting if explicitly disabled for this buffer
							if vim.b.disable_autoformat or vim.g.disable_autoformat then
								return
							end

							-- Format buffer
							vim.lsp.buf.format({
								bufnr = bufnr,
								filter = function(fmt_client)
									-- Use null-ls for formatting if available
									return fmt_client.name == "null-ls"
								end,
							})
						end,
					})
				end
			end,
		})

		-- Format commands
		vim.api.nvim_create_user_command("Format", function()
			vim.lsp.buf.format({ async = true })
			vim.notify("Formatted document", vim.log.levels.INFO)
		end, { desc = "Format document" })

		-- Commands to toggle auto-formatting
		vim.api.nvim_create_user_command("FormatToggle", function()
			vim.b.disable_autoformat = not vim.b.disable_autoformat
			vim.notify(
				"Autoformatting " .. (vim.b.disable_autoformat and "disabled" or "enabled") .. " for this buffer",
				vim.log.levels.INFO
			)
		end, { desc = "Toggle autoformatting for current buffer" })

		vim.api.nvim_create_user_command("FormatDisable", function()
			vim.b.disable_autoformat = true
			vim.notify("Autoformatting disabled for this buffer", vim.log.levels.INFO)
		end, { desc = "Disable autoformatting for current buffer" })

		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.notify("Autoformatting enabled for this buffer", vim.log.levels.INFO)
		end, { desc = "Enable autoformatting for current buffer" })

		-- Global commands
		vim.api.nvim_create_user_command("FormatToggleGlobal", function()
			vim.g.disable_autoformat = not vim.g.disable_autoformat
			vim.notify(
				"Autoformatting " .. (vim.g.disable_autoformat and "disabled" or "enabled") .. " globally",
				vim.log.levels.INFO
			)
		end, { desc = "Toggle autoformatting globally" })

		vim.api.nvim_create_user_command("FormatDisableGlobal", function()
			vim.g.disable_autoformat = true
			vim.notify("Autoformatting disabled globally", vim.log.levels.INFO)
		end, { desc = "Disable autoformatting globally" })

		vim.api.nvim_create_user_command("FormatEnableGlobal", function()
			vim.g.disable_autoformat = false
			vim.notify("Autoformatting enabled globally", vim.log.levels.INFO)
		end, { desc = "Enable autoformatting globally" })
	end,
}
