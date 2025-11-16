return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/SchemaStore.nvim",
    },

    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local function on_attach(client, bufnr)
        -- Enable inlay hints if supported
        if vim.fn.has("nvim-0.10") == 1 and client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end

      require("mason-lspconfig").setup({
        -- LazyVim-style comprehensive language server list
        ensure_installed = {
          -- Web Development
          "html",           -- HTML
          "cssls",          -- CSS
          "tailwindcss",    -- TailwindCSS
          "emmet_ls",       -- Emmet

          -- JavaScript/TypeScript
          "ts_ls",          -- TypeScript/JavaScript
          "eslint",         -- ESLint
          "volar",          -- Vue
          "svelte",         -- Svelte
          "astro",          -- Astro

          -- Backend
          "gopls",          -- Go
          "rust_analyzer",  -- Rust
          "pyright",        -- Python
          "ruff_lsp",       -- Python (Ruff)
          "ruby_lsp",       -- Ruby
          "solargraph",     -- Ruby (alternative)
          "elixirls",       -- Elixir

          -- Systems & Low-level
          "clangd",         -- C/C++
          "cmake",          -- CMake

          -- JVM Languages
          "jdtls",          -- Java
          "kotlin_language_server", -- Kotlin

          -- .NET
          "omnisharp",      -- C#

          -- Scripting
          "lua_ls",         -- Lua
          "bashls",         -- Bash
          "powershell_es",  -- PowerShell

          -- Data & Config
          "jsonls",         -- JSON
          "yamlls",         -- YAML
          "taplo",          -- TOML
          "lemminx",        -- XML

          -- Markup
          "marksman",       -- Markdown

          -- Database
          "sqlls",          -- SQL

          -- DevOps
          "dockerls",       -- Docker
          "docker_compose_language_service", -- Docker Compose
          "terraformls",    -- Terraform
          "helm_ls",        -- Helm

          -- PHP
          "intelephense",   -- PHP
        },
        automatic_installation = true, -- Auto-install missing servers
        handlers = {
          -- Default handler for all servers
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
              on_attach = on_attach,
            })
          end,

          -- Custom configurations
          ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  diagnostics = { globals = { "vim" } },
                  workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                  },
                  telemetry = { enable = false },
                  hint = { enable = true },
                },
              },
            })
          end,

          ["jsonls"] = function()
            require("lspconfig").jsonls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              filetypes = { "json", "jsonc" },
              settings = {
                json = { schemas = require("schemastore").json.schemas() },
              },
            })
          end,

          ["eslint"] = function()
            require("lspconfig").eslint.setup({
              capabilities = capabilities,
              on_attach = function(client, bufnr)
                vim.api.nvim_create_autocmd("BufWritePre", {
                  buffer = bufnr,
                  command = "EslintFixAll",
                })
                on_attach(client, bufnr)
              end,
              settings = {
                packageManager = "npm",
              },
            })
          end,

          -- Go
          ["gopls"] = function()
            require("lspconfig").gopls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                gopls = {
                  gofumpt = true,
                  codelenses = {
                    gc_details = false,
                    generate = true,
                    regenerate_cgo = true,
                    run_govulncheck = true,
                    test = true,
                    tidy = true,
                    upgrade_dependency = true,
                    vendor = true,
                  },
                  hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                  },
                  analyses = {
                    fieldalignment = true,
                    nilness = true,
                    unusedparams = true,
                    unusedwrite = true,
                    useany = true,
                  },
                  usePlaceholders = true,
                  completeUnimported = true,
                  staticcheck = true,
                  directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                  semanticTokens = true,
                },
              },
            })
          end,

          -- Rust
          ["rust_analyzer"] = function()
            require("lspconfig").rust_analyzer.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                ["rust-analyzer"] = {
                  imports = {
                    granularity = {
                      group = "module",
                    },
                    prefix = "self",
                  },
                  cargo = {
                    buildScripts = {
                      enable = true,
                    },
                  },
                  procMacro = {
                    enable = true,
                  },
                  checkOnSave = {
                    command = "clippy",
                  },
                },
              },
            })
          end,

          -- Python (Pyright)
          ["pyright"] = function()
            require("lspconfig").pyright.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                python = {
                  analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "workspace",
                    useLibraryCodeForTypes = true,
                    typeCheckingMode = "basic",
                  },
                },
              },
            })
          end,

          -- YAML
          ["yamlls"] = function()
            require("lspconfig").yamlls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                yaml = {
                  schemas = require("schemastore").yaml.schemas(),
                  schemaStore = {
                    enable = false,
                    url = "",
                  },
                },
              },
            })
          end,

          -- TailwindCSS
          ["tailwindcss"] = function()
            require("lspconfig").tailwindcss.setup({
              capabilities = capabilities,
              on_attach = on_attach,
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
            })
          end,

          -- C/C++
          ["clangd"] = function()
            require("lspconfig").clangd.setup({
              capabilities = vim.tbl_deep_extend("force", capabilities, {
                offsetEncoding = { "utf-16" },
              }),
              on_attach = on_attach,
              cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
              },
            })
          end,
        },
      })

      vim.diagnostic.config({
        virtual_text = { prefix = " ", spacing = 4 },
        float = { border = "single", source = "always" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
    end,
  },

  -- Schema support
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },

  -- Mason-lspconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    lazy = true,
  },

  -- TypeScript tools (optional enhancement)
  {
    "pmizio/typescript-tools.nvim",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    enabled = function()
      return vim.fn.executable("node") == 1
    end,
    opts = {
      settings = {
        expose_as_code_action = { "fix_all", "add_missing_imports", "remove_unused" },
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayFunctionParameterTypeHints = true,
        },
      },
    },
  },

  -- Inlay hints for older Neovim
  {
    "lvimuser/lsp-inlayhints.nvim",
    event = "LspAttach",
    enabled = vim.fn.has("nvim-0.10") == 0,
    opts = {},
    config = function(_, opts)
      require("lsp-inlayhints").setup(opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.inlayHintProvider then
            require("lsp-inlayhints").on_attach(client, args.buf)
          end
        end,
      })
    end,
  },
}
