--------------------------------------------------------------------------------
-- Go Development Configuration
--------------------------------------------------------------------------------
--
-- This module provides comprehensive support for Go development:
--
-- Features:
-- 1. LSP integration with gopls
-- 2. Auto-formatting with gofmt/goimports
-- 3. Build, test, and run capabilities
-- 4. Linting and static analysis
-- 5. Debug support with Delve
-- 6. Syntax highlighting with TreeSitter
-- 7. Snippets and completions
-- 8. Structure view with symbols outline
-- 9. Go-specific keybindings
--
-- When editing Go files, you get:
-- - Intelligent code completion with documentation
-- - Real-time error checking and linting
-- - Code navigation and symbol search
-- - Auto-imports and formatting
-- - Test generation and running
--------------------------------------------------------------------------------

return {
	-- LSP Setup
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Add gopls to ensure_installed
			if not opts.servers then
				opts.servers = {}
			end

			-- Configure gopls with recommended settings
			opts.servers.gopls = {
				settings = {
					gopls = {
						-- Analysis settings
						analyses = {
							unusedparams = true,
							shadow = true,
							nilness = true,
							unusedwrite = true,
							useany = true,
						},
						-- Code quality settings
						staticcheck = true,
						gofumpt = true,
						-- Completion settings
						usePlaceholders = true,
						completeUnimported = true,
						-- Extra settings
						semanticTokens = true,
						experimentalPostfixCompletions = true,
					},
				},
				-- Custom capabilities or handlers can be added here
			}
		end,
	},

	-- Go development tools
	{
		"ray-x/go.nvim",
		dependencies = {
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		ft = { "go", "gomod", "gowork", "gotmpl" },
		opts = {
			-- LSP config overrides
			lsp_cfg = false, -- We configure LSP through lspconfig

			-- LSP inlay hints (go 1.18+)
			lsp_inlay_hints = {
				enable = true,
				-- highlight = "LspInlayHint",
				only_current_line = false,
				parameter_hints_prefix = "← ",
				other_hints_prefix = "=> ",
			},

			-- Diagnostics configuration
			lsp_diag_update_in_insert = false,

			-- Go tools configuration
			lsp_document_formatting = true,
			lsp_keymaps = false, -- We set up our own keymaps

			-- Formatter config
			formatter = "gofumpt", -- "gofmt", "goimports", "gofumpt"

			-- Test configuration
			test_flags = { "-v" },
			test_timeout = "30s",
			test_env = {},

			-- Auto tags configuration
			tag_transform = "camelcase", -- snakecase, camelcase
			tag_options = "json=omitempty",

			-- Trouble integration for tests
			trouble = true,

			-- Test runner
			test_runner = "go",
			run_in_floaterm = true,

			-- Go commands
			go = "go", -- can be go[run, build, test], gobuild, gofmt, goimports, golint etc.
			max_line_len = 120,
		},
		config = function(_, opts)
			require("go").setup(opts)

			-- Set up autoformatting
			local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.go",
				callback = function()
					-- Skip formatting if explicitly disabled for this buffer
					if vim.b.disable_autoformat or vim.g.disable_autoformat then
						return
					end

					require("go.format").goimport()
				end,
				group = format_sync_grp,
			})

			-- Add Go-specific keybindings
			local map = function(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = true })
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "go",
				callback = function()
					-- Go specific mappings
					map("n", "<leader>cR", "<cmd>GoRun<CR>", "Run Go Program")
					map("n", "<leader>cB", "<cmd>GoBuild<CR>", "Build Go Program")
					map("n", "<leader>ct", "<cmd>GoTest<CR>", "Run Tests")
					map("n", "<leader>cT", "<cmd>GoTestFunc<CR>", "Test Function")
					map("n", "<leader>cc", "<cmd>GoCoverage<CR>", "Show Coverage")
					map("n", "<leader>ci", "<cmd>GoImpl<CR>", "Generate Interface Implementation")
					map("n", "<leader>cf", "<cmd>GoFillStruct<CR>", "Fill Struct")
					map("n", "<leader>ca", "<cmd>GoAddTag<CR>", "Add Tags")
					map("n", "<leader>cr", "<cmd>GoRmTag<CR>", "Remove Tags")
					map("n", "<leader>cd", "<cmd>GoDoc<CR>", "Show Documentation")
					map("n", "<leader>cA", "<cmd>GoAlt<CR>", "Open Alternate File")
					map("n", "<leader>cI", "<cmd>GoModInit<CR>", "Init Module")
					map("n", "<leader>cX", "<cmd>GoFixPlurals<CR>", "Fix Variable Plurals")
				end,
			})
		end,
	},

	-- DAP (Debug Adapter Protocol) for Go
	{
		"leoluz/nvim-dap-go",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		ft = "go",
		config = function()
			require("dap-go").setup({
				-- Path to delve executable
				dap_configurations = {
					{
						type = "go",
						name = "Debug",
						request = "launch",
						program = "${file}",
					},
					{
						type = "go",
						name = "Debug test", -- configuration for debugging test files
						request = "launch",
						mode = "test",
						program = "${file}",
					},
					{
						type = "go",
						name = "Debug test (go.mod)",
						request = "launch",
						mode = "test",
						program = "./${relativeFileDirname}",
					},
				},
				-- Additional delve configurations
				delve = {
					-- Time to wait for delve to initialize the debug session.
					-- Default to 20 seconds
					initialize_timeout_sec = 20,
					-- Port to connect to delve. Default to 38697
					port = 38697,
				},
			})

			-- Add key mappings for debugging
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "go",
				callback = function()
					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = true })
					end

					map("n", "<leader>dt", "<cmd>lua require('dap-go').debug_test()<CR>", "Debug Go Test")
					map("n", "<leader>dl", "<cmd>lua require('dap-go').debug_last_test()<CR>", "Debug Last Go Test")
				end,
			})
		end,
	},

	-- Make sure we have treesitter support for Go
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "go", "gomod", "gosum", "gowork" })
			end
		end,
	},

	-- Ensure Go-related tools are installed
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, {
					"gopls", -- Go language server
					"gofumpt", -- Stricter gofmt
					"goimports", -- Import management
					"golangci-lint", -- Linter
					"delve", -- Debugger
				})
			end
		end,
	},
}
