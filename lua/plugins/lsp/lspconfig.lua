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

      -- Build ensure_installed list based on available languages
      local ensure_installed = {
        -- Always install (don't require runtime)
        "lua_ls",         -- Lua
        "bashls",         -- Bash
        "jsonls",         -- JSON
        "yamlls",         -- YAML
        "marksman",       -- Markdown

        -- Web Development (usually available via npm)
        "html",           -- HTML
        "cssls",          -- CSS
        "ts_ls",          -- TypeScript/JavaScript
        "eslint",         -- ESLint
      }

      -- Conditionally add servers based on available runtimes
      local optional_servers = {
        { cmd = "node", servers = { "tailwindcss", "emmet_ls", "vuels", "svelte", "astro" } },
        { cmd = "go", servers = { "gopls" } },
        { cmd = "rustc", servers = { "rust_analyzer" } },
        { cmd = "python3", servers = { "pyright", "ruff" } },
        { cmd = "ruby", servers = { "ruby_lsp", "solargraph" } },
        { cmd = "elixir", servers = { "elixirls" } },
        { cmd = "clang", servers = { "clangd" } },
        { cmd = "cmake", servers = { "cmake" } },
        { cmd = "java", servers = { "jdtls" } },
        { cmd = "dotnet", servers = { "omnisharp" } },
        { cmd = "pwsh", servers = { "powershell_es" } },
        { cmd = "docker", servers = { "dockerls", "docker_compose_language_service" } },
        { cmd = "terraform", servers = { "terraformls" } },
        { cmd = "helm", servers = { "helm_ls" } },
        { cmd = "php", servers = { "intelephense" } },
        { cmd = "sqlite3", servers = { "sqlls" } },
      }

      for _, entry in ipairs(optional_servers) do
        if vim.fn.executable(entry.cmd) == 1 then
          vim.list_extend(ensure_installed, entry.servers)
        end
      end

      -- Always add these (work without specific runtime)
      vim.list_extend(ensure_installed, { "taplo", "lemminx" })

      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
        automatic_installation = false, -- Don't auto-install to avoid errors
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

          -- cssls uses default handler (GTK CSS excluded via filetype in autocmds.lua)

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

          ["intelephense"] = function()
            require("lspconfig").intelephense.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                intelephense = {
                  telemetry = { enabled = false },
                  files = {
                    maxSize = 1000000,
                    exclude = {
                      "**/.git/**",
                      "**/.svn/**",
                      "**/.hg/**",
                      "**/node_modules/**",
                      "**/vendor/**",
                      "**/storage/**",
                      "**/var/**",
                      "**/cache/**",
                      "**/tmp/**",
                      "**/build/**",
                      "**/dist/**",
                      "**/coverage/**",
                    },
                  },
                },
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
              root_dir = function(fname)
                local root_pattern = require("lspconfig").util.root_pattern(
                  "tailwind.config.js",
                  "tailwind.config.cjs",
                  "tailwind.config.mjs",
                  "tailwind.config.ts"
                )
                -- Only activate if a tailwind config file is found
                return root_pattern(fname)
              end,
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

      -- Note: Diagnostic configuration is in config/autocmds.lua

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
