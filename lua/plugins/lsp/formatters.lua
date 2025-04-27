--------------------------------------------------------------------------------
-- Formatters Configuration
--------------------------------------------------------------------------------
--
-- This module configures code formatters for different languages.
-- We use conform.nvim to integrate formatters with Neovim.
--
-- Each formatter is configured with:
-- 1. The file types it supports
-- 2. Any special configuration it needs
-- 3. Any command-line arguments to customize behavior
--
-- To add a new formatter:
-- 1. Check if it's available in conform.formatters
-- 2. Add it to the formatters_by_ft table
--------------------------------------------------------------------------------

return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				desc = "Format Document",
				mode = { "n" },
			},
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				desc = "Format Selection",
				mode = { "v" },
			},
		},
		opts = {
			-- Define formatters by filetype
			formatters_by_ft = {
				-- Lua
				lua = { "stylua" },

				-- Python
				python = { "ruff_format", "black", "isort" },

				-- JavaScript/TypeScript
				javascript = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				javascriptreact = { { "prettierd", "prettier" } },
				typescriptreact = { { "prettierd", "prettier" } },

				-- Frontend
				html = { { "prettierd", "prettier" } },
				css = { { "prettierd", "prettier" } },
				scss = { { "prettierd", "prettier" } },
				less = { { "prettierd", "prettier" } },

				-- Other web formats
				json = { { "prettierd", "prettier" } },
				jsonc = { { "prettierd", "prettier" } },
				yaml = { { "prettierd", "prettier" } },
				markdown = { { "prettierd", "prettier" } },
				graphql = { { "prettierd", "prettier" } },

				-- Frameworks
				svelte = { { "prettierd", "prettier" } },
				vue = { { "prettierd", "prettier" } },
				astro = { { "prettierd", "prettier" } },

				-- Rust
				rust = { "rustfmt" },

				-- Go
				go = { "gofmt", "goimports" },

				-- C/C++/Java etc.
				c = { "clang_format" },
				cpp = { "clang_format" },
				cs = { "clang_format" },
				java = { "clang_format" },
				cuda = { "clang_format" },
				proto = { "clang_format" },

				-- Shell
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },

				-- SQL
				sql = { "sql_formatter" },

				-- XML/HTML
				xml = { "xmlformat" },

				-- Format multiple filetypes with one formatter
				["_"] = { "trim_whitespace", "trim_newlines" },
			},

			-- Formatter-specific configuration
			formatters = {
				-- Lua
				stylua = {
					args = { "--indent-type", "Spaces", "--indent-width", "2" },
					condition = function(ctx)
						-- Only use if stylua.toml or .stylua.toml exists
						return vim.fs.find({ "stylua.toml", ".stylua.toml" }, { path = ctx.filename, upward = true })[1]
					end,
				},

				-- Python
				black = {
					args = { "--line-length", "88", "--preview" },
					-- Try to use local virtualenv if available
					prepend_args = function()
						local venv = os.getenv("VIRTUAL_ENV")
						if venv then
							return { "--quiet" }
						end
						return {}
					end,
				},
				isort = {
					args = { "--profile", "black" },
				},
				ruff_format = {
					-- Uses ruff.toml if available
				},

				-- Web development
				prettierd = {
					-- Uses .prettierrc if available
					condition = function()
						return vim.fn.executable("prettierd") > 0
					end,
				},
				prettier = {
					-- Fallback if prettierd is not available
					args = { "--prose-wrap", "always" },
				},

				-- Go
				gofmt = {},
				goimports = {},

				-- Shell
				shfmt = {
					args = { "-i", "2", "-ci", "-bn" },
				},

				-- Rust
				rustfmt = {
					args = { "--edition", "2021" },
				},

				-- C/C++/Java
				clang_format = {
					args = { "-style=file:.clang-format", "-fallback-style=Google" },
				},

				-- SQL
				sql_formatter = {
					args = { "--language", "postgresql" },
				},

				-- Common utility formatters for all files
				trim_whitespace = {
					command = "sed",
					args = { "-E", "s/[[:space:]]+$//g" },
				},
				trim_newlines = {
					command = "sed",
					args = { "-E", "s/\\n\\n\\n+/\\n\\n/g" },
				},
			},

			-- Format on save settings
			format_on_save = {
				-- I recommend these options with format on save
				lsp_fallback = true,
				async = false,
				timeout_ms = 500,
			},

			-- Notify on formatting errors
			notify_on_error = true,

			-- Respect .editorconfig
			respect_editor_config = true,
		},

		-- Additional setup code
		config = function(_, opts)
			local conform = require("conform")

			-- Setup conform.nvim with the provided options
			conform.setup(opts)

			-- Add commands to toggle format_on_save
			vim.api.nvim_create_user_command("FormatToggle", function()
				vim.b.disable_autoformat = not vim.b.disable_autoformat
				vim.notify(
					"Format on save " .. (vim.b.disable_autoformat and "disabled" or "enabled") .. " for current buffer",
					vim.log.levels.INFO
				)
			end, { desc = "Toggle format on save for current buffer" })

			vim.api.nvim_create_user_command("FormatToggleGlobal", function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify(
					"Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled") .. " globally",
					vim.log.levels.INFO
				)
			end, { desc = "Toggle format on save globally" })
		end,
	},
}
