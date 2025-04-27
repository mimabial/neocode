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
--
-- We use the following components:
-- * nvim-lspconfig: Base LSP configuration
-- * mason.nvim: Install LSP servers, formatters, and linters
-- * mason-lspconfig.nvim: Bridge between mason and lspconfig
-- * conform.nvim: Formatting
-- * nvim-lint: Linting
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
				"shfmt",  -- Shell
				"shellcheck", -- Shell
				"black",  -- Python
				"isort",  -- Python
				"flake8", -- Python
				"prettier", -- Web
				"eslint_d", -- JavaScript/TypeScript
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
				handlers = {
					function(server_name)
						local server_config = require("plugins.lsp.servers").settings[server_name] or {}

						-- Add common on_attach and capabilities
						server_config.on_attach = server_config.on_attach
								or function(client, bufnr)
									require("plugins.lsp.keymaps").on_attach(client, bufnr)
									-- Add optional navic integration if available
									if client.server_capabilities.documentSymbolProvider then
										pcall(function()
											require("nvim-navic").attach(client, bufnr)
										end)
									end
								end

						server_config.capabilities = server_config.capabilities
								or vim.lsp.protocol.make_client_capabilities()
						if pcall(require, "cmp_nvim_lsp") then
							server_config.capabilities =
									require("cmp_nvim_lsp").default_capabilities(server_config.capabilities)
						end

						require("lspconfig")[server_name].setup(server_config)
					end,
				},
			})
		end,
	},

	-- LSP Status with Fidget
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {
			notification = {
				window = { winblend = 0 },
			},
			progress = {
				display = {
					render_limit = 3, -- Only show 3 active notifications
					done_ttl = 3, -- Display time for completed tasks
					progress_ttl = 60, -- Max time a notification can stay
				},
			},
		},
	},

	-- Additional lua configuration for nvim development
	{
		"folke/neodev.nvim",
		ft = "lua",
		opts = {
			library = {
				enabled = true,
				runtime = true,
				types = true,
				plugins = true,
			},
			setup_jsonls = true,
			lspconfig = true,
			pathStrict = true,
		},
	},

	-- Enhanced LSP signature help
	{
		"ray-x/lsp_signature.nvim",
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
			toggle_key = "<C-k>",        -- Toggle signature on and off in insert mode
			select_signature_key = "<C-n>", -- Cycle between signatures
		},
	},

	-- Linting
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "InsertLeave" },
		config = function()
			local lint = require("lint")

			-- Set up autocmd for automatic linting
			local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					-- Skip linting if explicitly disabled
					if vim.b.disable_autoformat or vim.g.disable_autoformat then
						return
					end

					-- Don't lint large files
					local max_filesize = 500 * 1024 -- 500 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
					if ok and stats and stats.size > max_filesize then
						return
					end

					-- Don't lint certain filetypes
					local exclude_filetypes = { "alpha", "dashboard", "help", "NvimTree", "neo-tree", "Trouble", "lazy" }
					if vim.tbl_contains(exclude_filetypes, vim.bo.filetype) then
						return
					end

					lint.try_lint()
				end,
			})

			-- Command to manually trigger linting
			vim.api.nvim_create_user_command("Lint", function()
				lint.try_lint()
			end, { desc = "Trigger linting for current file" })

			-- Command to toggle automatic linting
			vim.api.nvim_create_user_command("LintToggle", function()
				vim.b.disable_linting = not vim.b.disable_linting
				vim.notify(
					"Automatic linting " .. (vim.b.disable_linting and "disabled" or "enabled") .. " for current buffer",
					vim.log.levels.INFO
				)
			end, { desc = "Toggle automatic linting for current buffer" })

			-- Keymap to toggle linting
			vim.keymap.set("n", "<leader>ul", function()
				vim.b.disable_linting = not vim.b.disable_linting
				vim.notify("Linting " .. (vim.b.disable_linting and "disabled" or "enabled"), vim.log.levels.INFO)
			end, { desc = "Toggle linting" })
		end,
	},

	-- Formatting
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
			-- Format on save settings
			format_on_save = function(bufnr)
				-- Check if auto-formatting is disabled for this buffer
				if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
					return
				end

				-- Check for certain filetypes we don't want to auto-format
				local exclude_filetypes = { "alpha", "dashboard", "help", "NvimTree", "neo-tree", "Trouble", "lazy" }
				if vim.tbl_contains(exclude_filetypes, vim.bo[bufnr].filetype) then
					return
				end

				-- Check filesize limits to avoid formatting huge files
				local max_filesize = 500 * 1024 -- 500 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
				if ok and stats and stats.size > max_filesize then
					vim.notify("File too large for auto-formatting", vim.log.levels.WARN)
					return
				end

				-- Return default formatting options
				return {
					timeout_ms = 1000,
					lsp_fallback = true,
					async = false,
				}
			end,

			-- Notify on formatting errors
			notify_on_error = true,

			-- Respect .editorconfig
			respect_editor_config = true,
		},
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

			-- Add keymap to toggle autoformat
			vim.keymap.set("n", "<leader>uf", function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify("Autoformatting " .. (vim.g.disable_autoformat and "disabled" or "enabled"), vim.log.levels.INFO)
			end, { desc = "Toggle autoformatting" })
		end,
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
			{ "K",          "<cmd>Lspsaga hover_doc<CR>",             desc = "Hover Doc" },
			{ "<leader>la", "<cmd>Lspsaga code_action<CR>",           desc = "Code Action" },
			{ "<leader>lr", "<cmd>Lspsaga rename<CR>",                desc = "Rename" },
			{ "<leader>lp", "<cmd>Lspsaga peek_definition<CR>",       desc = "Peek Definition" },
			{ "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Line Diagnostics" },
			{ "<leader>lo", "<cmd>Lspsaga outline<CR>",               desc = "Outline" },
			{ "[e",         "<cmd>Lspsaga diagnostic_jump_prev<CR>",  desc = "Previous Diagnostic" },
			{ "]e",         "<cmd>Lspsaga diagnostic_jump_next<CR>",  desc = "Next Diagnostic" },
		},
	},

	-- Better diagnostics list and navigation
	{
		"folke/trouble.nvim",
		cmd = { "Trouble", "TroubleToggle", "TroubleClose", "TroubleRefresh" },
		opts = {
			position = "bottom",         -- Position of trouble list
			height = 10,                 -- Height of the trouble list
			width = 50,                  -- Width of the list when position is left or right
			icons = true,                -- Use icons
			mode = "workspace_diagnostics", -- Default mode
			fold_open = "",              -- Icon for open folds
			fold_closed = "",            -- Icon for closed folds
			group = true,                -- Group results by file
			padding = true,              -- Add extra padding
			severity = nil,              -- nil (all) or vim.diagnostic.severity.ERROR|WARN|INFO|HINT
			auto_open = false,           -- Automatically open the list when you have diagnostics
			auto_close = false,          -- Automatically close the list when you have no diagnostics
			auto_preview = true,         -- Automatically preview the location of the diagnostic
			auto_fold = false,           -- Automatically fold a file trouble list at creation
			signs = {
				-- Icons / text used for a diagnostic
				error = "",
				warning = "",
				hint = "󰌵",
				information = "",
				other = "",
			},
			use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
		},
		keys = {
			{ "<leader>xx", "<cmd>TroubleToggle<cr>",                       desc = "Toggle Trouble" },
			{ "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",  desc = "Document Diagnostics" },
			{ "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
			{ "<leader>xl", "<cmd>TroubleToggle loclist<cr>",               desc = "Location List" },
			{ "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",              desc = "Quickfix List" },
			{ "gR",         "<cmd>TroubleToggle lsp_references<cr>",        desc = "LSP References" },
			{ "gD",         "<cmd>TroubleToggle lsp_definitions<cr>",       desc = "LSP Definitions" },
			{ "gT",         "<cmd>TroubleToggle lsp_type_definitions<cr>",  desc = "LSP Type Definitions" },
		},
	},
}
