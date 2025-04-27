--------------------------------------------------------------------------------
-- LSP Server Configurations
--------------------------------------------------------------------------------
--
-- This module defines the configuration for all language servers.
-- Each server can have custom settings while sharing common capabilities.
--
-- Structure:
-- 1. List of servers to install automatically
-- 2. Server-specific settings for each LSP
--
-- Add new language servers:
-- 1. Add the server name to ensure_installed list
-- 2. Add server settings to the settings table
--
-- See :help lspconfig-server-configurations for available servers and options
--------------------------------------------------------------------------------

return {
	-- Plugin specification for nvim-lspconfig
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			-- Useful status updates for LSP
			{ "j-hui/fidget.nvim", opts = {} },
			-- Additional lua configuration for nvim development
			{ "folke/neodev.nvim", opts = {} },
		},
		opts = {
			-- Enable this to show diagnostics numbers in the sign column
			inlay_hints = { enabled = true },

			-- Options for vim.diagnostics.config()
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					prefix = "●",
					source = "if_many",
				},
				severity_sort = true,
				float = {
					focusable = true,
					border = "rounded",
					source = "always",
				},
			},

			-- LSP Server Settings
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							runtime = {
								version = "LuaJIT",
							},
							diagnostics = {
								globals = { "vim" }, -- Recognize vim global in Neovim config
							},
							workspace = {
								library = {
									vim.fn.expand("$VIMRUNTIME/lua"),
									vim.fn.stdpath("config") .. "/lua",
								},
								-- Don't prompt about third-party dependencies
								checkThirdParty = false,
							},
							telemetry = {
								enable = false, -- Disable telemetry
							},
							completion = {
								callSnippet = "Replace", -- Show function call snippets
							},
							hint = { -- Inlay hints (Neovim 0.10+)
								enable = true,
								setType = true,
								paramType = true,
								paramName = "Literal",
								semicolon = "Disable",
								arrayIndex = "Enable",
							},
						},
					},
				},

				-- Python
				pyright = {
					settings = {
						python = {
							analysis = {
								autoSearchPaths = true,
								diagnosticMode = "workspace",
								useLibraryCodeForTypes = true,
								typeCheckingMode = "basic", -- Choose from: off, basic, strict
								inlayHints = {
									variableTypes = true,
									functionReturnTypes = true,
									parameterTypes = true,
								},
							},
						},
					},
				},

				-- Python (additional linting with ruff)
				ruff_lsp = {
					settings = {
						ruff = {
							lint = {
								run = "onSave", -- Run on save
							},
						},
					},
					init_options = {
						settings = {
							args = {},
						},
					},
				},

				-- JSON with schema support
				jsonls = {
					settings = {
						json = {
							schemas = function()
								-- Try to use schemastore if available, otherwise use manual schemas
								local ok, schemastore = pcall(require, "schemastore")
								if ok then
									return schemastore.json.schemas()
								else
									-- Fallback to manually defined schemas
									return {
										{
											fileMatch = { "package.json" },
											url = "https://json.schemastore.org/package.json",
										},
										{
											fileMatch = { "tsconfig.json", "tsconfig.*.json" },
											url = "https://json.schemastore.org/tsconfig.json",
										},
										{
											fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
											url = "https://json.schemastore.org/prettierrc.json",
										},
										{
											fileMatch = { ".eslintrc", ".eslintrc.json" },
											url = "https://json.schemastore.org/eslintrc.json",
										},
										{
											fileMatch = { "lerna.json" },
											url = "https://json.schemastore.org/lerna.json",
										},
										{
											fileMatch = { "babel.config.json", ".babelrc", ".babelrc.json" },
											url = "https://json.schemastore.org/babelrc.json",
										},
										{
											fileMatch = { "jest.config.json" },
											url = "https://json.schemastore.org/jest.json",
										},
									}
								end
							end,
							validate = { enable = true },
							format = { enable = true },
						},
					},
				},

				-- YAML with schema support
				yamlls = {
					settings = {
						yaml = {
							schemaStore = {
								enable = true,
								url = "https://www.schemastore.org/api/json/catalog.json",
							},
							schemas = function()
								-- Try to use schemastore if available, otherwise use manual schemas
								local ok, schemastore = pcall(require, "schemastore")
								if ok then
									return schemastore.yaml.schemas()
								else
									-- Fallback to manually defined schemas
									return {
										["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
										["https://json.schemastore.org/github-action.json"] = ".github/action.{yml,yaml}",
										["https://json.schemastore.org/prettierrc.json"] = ".prettierrc.{yml,yaml}",
										["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
										["https://json.schemastore.org/ansible-playbook.json"] = "*play*.{yml,yaml}",
										["https://json.schemastore.org/chart.json"] = "Chart.{yml,yaml}",
										["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.{yml,yaml}",
										["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
										["https://kubernetes-schemas.devbu.io/helm.toolkit.fluxcd.io/helmrelease_v2beta1.json"] = "*helmrelease.{yml,yaml}",
									}
								end
							end,
							format = { enable = true },
							validate = true,
							completion = true,
						},
					},
				},

				-- TypeScript/JavaScript
				tsserver = {
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
							suggest = {
								completeFunctionCalls = true,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
							suggest = {
								completeFunctionCalls = true,
							},
						},
					},
				},

				-- CSS
				cssls = {
					settings = {
						css = {
							validate = true,
							lint = {
								unknownAtRules = "ignore", -- Ignore unknown at-rules for framework compatibility
							},
						},
						scss = {
							validate = true,
							lint = {
								unknownAtRules = "ignore",
							},
						},
						less = {
							validate = true,
							lint = {
								unknownAtRules = "ignore",
							},
						},
					},
				},

				-- HTML
				html = {
					settings = {
						html = {
							format = {
								indentInnerHtml = true,
								wrapLineLength = 120,
								wrapAttributes = "auto",
							},
							hover = {
								documentation = true,
								references = true,
							},
							suggest = {
								html5 = true,
							},
						},
					},
					filetypes = { "html", "htmldjango" }, -- Support Django templates
				},

				-- Tailwind CSS
				tailwindcss = {
					settings = {
						tailwindCSS = {
							experimental = {
								classRegex = {
									'class[:]\\s*"([^"]*)"',
									'className[:]\\s*"([^"]*)"',
									"class[:]\\s*'([^']*)'",
									"className[:]\\s*'([^']*)'",
									"tw`([^`]*)",
									"tw\\.[^`]+`([^`]*)`",
									"tw\\(.*?\\).*?`([^`]*)",
								},
							},
							includeLanguages = {
								typescript = "javascript",
								typescriptreact = "javascript",
								["html-eex"] = "html",
								["phoenix-heex"] = "html",
								heex = "html",
								eelixir = "html",
								elixir = "html",
								elm = "html",
								erb = "html",
								svelte = "html",
								javascriptreact = "javascript",
								astro = "html",
							},
							validate = true,
						},
					},
				},

				-- Vue
				volar = {
					filetypes = { "vue", "typescript", "javascript" },
				},

				-- Emmet
				emmet_ls = {
					filetypes = {
						"html",
						"css",
						"scss",
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
						"vue",
						"svelte",
						"astro",
					},
				},

				-- Rust
				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							checkOnSave = {
								command = "clippy", -- Use clippy for more advanced linting
							},
							cargo = {
								allFeatures = true, -- Enable all cargo features
								loadOutDirsFromCheck = true,
							},
							inlayHints = {
								lifetimeElisionHints = {
									enable = true,
									useParameterNames = true,
								},
								reborrowHints = {
									enable = true,
								},
								closureReturnTypeHints = {
									enable = "always",
								},
							},
							procMacro = {
								enable = true,
							},
						},
					},
				},

				-- Go
				gopls = {
					settings = {
						gopls = {
							analyses = {
								unusedparams = true,
								shadow = true,
								nilness = true,
								unusedwrite = true,
								useany = true,
							},
							staticcheck = true,
							gofumpt = true, -- Stricter formatting than gofmt
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				},

				-- C/C++
				clangd = {
					cmd = {
						"clangd",
						"--background-index",
						"--suggest-missing-includes",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
				},

				-- Java
				jdtls = {
					-- JDTLS has a more complex setup managed by nvim-jdtls
					-- See lua/plugins/langs/java.lua for complete setup
				},

				-- Docker
				dockerls = {},

				-- Bash
				bashls = {
					filetypes = { "sh", "bash", "zsh" },
				},

				-- Terraform
				terraformls = {
					filetypes = { "terraform", "tf", "terraform-vars" },
				},

				-- TOML
				taplo = {},

				-- Markdown
				marksman = {},

				-- LTeX for LaTeX/Markdown spelling and grammar
				ltex = {
					settings = {
						ltex = {
							language = "en-US",
							diagnosticSeverity = "information",
							additionalRules = {
								enablePickyRules = true,
							},
							disabledRules = {},
							hiddenFalsePositives = {},
						},
					},
				},

				-- Denols (Deno)
				denols = {
					root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
				},

				-- Ruby
				ruby_ls = {},

				-- PHP
				phpactor = {},

				-- GraphQL
				graphql = {
					filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				},

				-- Astro
				astro = {},

				-- Svelte
				svelte = {},

				-- Angular
				angularls = {},

				-- Elixir
				elixirls = {
					settings = {
						elixirLS = {
							dialyzerEnabled = true,
							fetchDeps = true,
						},
					},
				},

				-- Prisma ORM
				prismals = {},

				-- SQL
				sqlls = {
					settings = {
						sqlLanguageServer = {
							lint = {
								lintOnChangeDebounce = 500,
							},
						},
					},
				},

				-- Typos for spelling errors
				typos_lsp = {},
			},

			-- Options passed to lspconfig.setup for each server
			setup = {
				-- Example of custom server setup
				-- rust_analyzer = function(_, opts)
				--   require("rust-tools").setup({ server = opts })
				--   return true -- Return true to prevent default setup
				-- end,
			},
		},
		config = function(_, opts)
			-- Setup diagnostics
			vim.diagnostic.config(opts.diagnostics)

			-- Setup all configured servers
			local servers = opts.servers
			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities(),
				opts.capabilities or {}
			)

			-- Enable inlay hints if supported
			local function setup_inlay_hints(client, bufnr)
				if
					client.supports_method("textDocument/inlayHint")
					and vim.lsp.inlay_hint
					and opts.inlay_hints.enabled
				then
					vim.lsp.inlay_hint.enable(bufnr, true)
				end
			end

			-- Global on_attach function
			local function on_attach(client, bufnr)
				-- Setup keymaps
				require("plugins.lsp.keymaps").on_attach(client, bufnr)

				-- Setup inlay hints
				setup_inlay_hints(client, bufnr)

				-- Setup navic (code context)
				if client.server_capabilities.documentSymbolProvider then
					pcall(function()
						require("nvim-navic").attach(client, bufnr)
					end)
				end
			end

			-- Setup mason-lspconfig to install and configure servers
			require("mason").setup()
			local mlsp = require("mason-lspconfig")

			mlsp.setup({
				ensure_installed = vim.tbl_keys(servers),
				automatic_installation = true,
			})

			mlsp.setup_handlers({
				function(server_name)
					local server_opts = servers[server_name] or {}
					server_opts.capabilities = capabilities
					server_opts.on_attach = on_attach

					-- Check for custom server setup
					if opts.setup[server_name] then
						if opts.setup[server_name](server_name, server_opts) then
							return -- If custom setup returns true, skip default setup
						end
					end

					-- Default setup
					require("lspconfig")[server_name].setup(server_opts)
				end,
			})
		end,
	},

	-- List of servers to ensure are installed
	ensure_installed = {
		-- Common Languages
		"lua_ls", -- Lua
		"pyright", -- Python
		"ruff_lsp", -- Python linting/formatting
		"tsserver", -- TypeScript/JavaScript
		"jsonls", -- JSON
		"yamlls", -- YAML
		"html", -- HTML
		"cssls", -- CSS

		-- Web Development
		"eslint", -- ESLint
		"tailwindcss", -- Tailwind CSS
		"volar", -- Vue
		"astro", -- Astro
		"emmet_ls", -- Emmet
		"graphql", -- GraphQL
		"prismals", -- Prisma ORM
		"svelte", -- Svelte
		"angularls", -- Angular

		-- Systems Programming
		"clangd", -- C/C++
		"rust_analyzer", -- Rust
		"gopls", -- Go
		"zls", -- Zig

		-- JVM Languages
		"jdtls", -- Java
		"kotlin_language_server", -- Kotlin
		"groovyls", -- Groovy
		"lemminx", -- XML

		-- Scripting Languages
		"bashls", -- Bash
		"powershell_es", -- PowerShell

		-- Data Science & ML
		"pyright", -- Python
		"r_language_server", -- R
		"julials", -- Julia

		-- Cloud & DevOps
		"dockerls", -- Docker
		"docker_compose_language_service", -- Docker Compose
		"terraformls", -- Terraform
		"helm_ls", -- Helm
		"ansiblels", -- Ansible
		"awk_ls", -- AWK

		-- Databases
		"sqlls", -- SQL

		-- Markup/Documentation
		"marksman", -- Markdown
		"ltex", -- LaTeX/Text
		"taplo", -- TOML

		-- Other Languages
		"elixirls", -- Elixir
		"phpactor", -- PHP
		"ruby_ls", -- Ruby
		"crystalline", -- Crystal
		"ocamllsp", -- OCaml
		"hls", -- Haskell
		"dartls", -- Dart
		"denols", -- Deno
		"typos_lsp", -- Spelling
	},
}
