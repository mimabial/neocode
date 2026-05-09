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

      -- Build ensure_installed list based on available languages
      local ensure_installed = {
        -- Always install (don't require runtime)
        "lua_ls", "bashls", "jsonls", "yamlls", "marksman",
        -- Web Development (usually available via npm)
        "html", "cssls", "ts_ls", "eslint",
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

      vim.list_extend(ensure_installed, { "taplo", "lemminx" })

      -- Defaults applied to every server (merged with bundled nvim-lspconfig configs)
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("lua_ls", {
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

      vim.lsp.config("jsonls", {
        filetypes = { "json", "jsonc" },
        settings = { json = { schemas = require("schemastore").json.schemas() } },
      })

      vim.lsp.config("eslint", { settings = { packageManager = "npm" } })

      vim.lsp.config("intelephense", {
        settings = {
          intelephense = {
            telemetry = { enabled = false },
            files = {
              maxSize = 1000000,
              exclude = {
                "**/.git/**", "**/.svn/**", "**/.hg/**",
                "**/node_modules/**", "**/vendor/**", "**/storage/**",
                "**/var/**", "**/cache/**", "**/tmp/**",
                "**/build/**", "**/dist/**", "**/coverage/**",
              },
            },
          },
        },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            codelenses = {
              gc_details = false, generate = true, regenerate_cgo = true,
              run_govulncheck = true, test = true, tidy = true,
              upgrade_dependency = true, vendor = true,
            },
            hints = {
              assignVariableTypes = true, compositeLiteralFields = true,
              compositeLiteralTypes = true, constantValues = true,
              functionTypeParameters = true, parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              fieldalignment = true, nilness = true, unusedparams = true,
              unusedwrite = true, useany = true,
            },
            usePlaceholders = true, completeUnimported = true, staticcheck = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            semanticTokens = true,
          },
        },
      })

      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            imports = { granularity = { group = "module" }, prefix = "self" },
            cargo = { buildScripts = { enable = true } },
            procMacro = { enable = true },
            checkOnSave = { command = "clippy" },
          },
        },
      })

      vim.lsp.config("pyright", {
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

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemas = require("schemastore").yaml.schemas(),
            schemaStore = { enable = false, url = "" },
          },
        },
      })

      vim.lsp.config("clangd", {
        capabilities = { offsetEncoding = { "utf-16" } },
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

      -- Bashls handles zsh via filetype override (replaces standalone autocmd)
      vim.lsp.config("bashls", { filetypes = { "sh", "bash", "zsh" } })

      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
        automatic_enable = true,
      })

      -- Note: Diagnostic configuration in config/autocmds.lua
      -- Note: Hover border + LSP keymaps in config/keymaps.lua (LspAttach autocmd)
    end,
  },
}
