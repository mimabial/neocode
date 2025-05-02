-- lua/plugins/lsp.lua
return {
  -- Core LSP functionality
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Server management
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      -- LSP completion
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Set up Mason first for server management
      require("mason").setup({
        ui = {
          border = "single",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          -- Core language servers for both stacks
          "lua_ls",
          -- GOTH stack
          "gopls",
          "templ",
          "htmx",
          -- Next.js stack
          "ts_ls",
          "tailwindcss",
          "cssls",
          "eslint",
          "jsonls",
        },
        automatic_installation = true,
      })

      -- Shared capabilities for all servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      -- Enable inlay hints if Neovim >= 0.10
      local inlay_hints = {
        enabled = vim.fn.has("nvim-0.10") == 1,
      }

      -- Configure keymaps when LSP attaches to buffer
      local on_attach = function(client, bufnr)
        -- Skip certain LSP clients for keymappings
        if client.name == "copilot" or client.name == "null-ls" then
          return
        end

        -- LSP buffer-specific keymaps are handled in autocmds.lua
      end

      -- Configure language servers
      local lspconfig = require("lspconfig")

      -- Lua LSP configuration
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim", "require" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
            inlayHints = inlay_hints,
          },
        },
      })

      -- Go LSP configuration
      lspconfig.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
              fieldalignment = true,
              nilness = true,
              unusedwrite = true,
            },
            staticcheck = true,
            gofumpt = true,
            usePlaceholders = true,
            completeUnimported = true,
            matcher = "fuzzy",
            symbolMatcher = "fuzzy",
            buildFlags = { "-tags=integration,e2e" },
            experimentalPostfixCompletions = true,
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
      })

      -- Templ LSP configuration
      lspconfig.templ.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- HTMX LSP configuration (if available)
      if lspconfig.htmx then
        lspconfig.htmx.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          filetypes = { "html", "templ" },
        })
      end

      -- TypeScript/JavaScript configuration
      lspconfig.ts_ls.setup({
        on_attach = function(client, bufnr)
          -- Disable formatting if using prettier through null-ls/conform
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          on_attach(client, bufnr)
        end,
        capabilities = capabilities,
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
          },
        },
      })

      -- Tailwind CSS configuration
      lspconfig.tailwindcss.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = {
          "html",
          "css",
          "scss",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "templ",
        },
        init_options = {
          userLanguages = {
            templ = "html", -- Treat templ as HTML for tailwind
          },
        },
      })

      -- CSS configuration
      lspconfig.cssls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- ESLint configuration
      lspconfig.eslint.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          packageManager = "npm",
          experimental = {
            useFlatConfig = false,
          },
        },
      })

      -- JSON configuration with SchemaStore support
      lspconfig.jsonls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- Set up LSP handlers with borders
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
          severity = { min = vim.diagnostic.severity.HINT },
          source = "if_many",
        },
        float = {
          border = "rounded",
          severity_sort = true,
          source = "always",
          header = "",
          prefix = function(diagnostic)
            local icons = {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.INFO] = " ",
              [vim.diagnostic.severity.HINT] = " ",
            }
            return icons[diagnostic.severity] or ""
          end,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Define diagnostic signs
      local signs = { Error = "", Warn = "", Info = "", Hint = "" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end,
  },

  -- LSP UI and additional features
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = true,
      handler_opts = { border = "rounded" },
      hint_enable = true,
      hint_prefix = "🔍 ",
      hint_scheme = "String",
      hi_parameter = "IncSearch",
      fix_pos = false,
      toggle_key = "<C-k>",
    },
  },

  -- SchemaStore for JSON validation
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
  },

  -- Inlay hints for Neovim < 0.10
  {
    "lvimuser/lsp-inlayhints.nvim",
    event = "LspAttach",
    enabled = vim.fn.has("nvim-0.10") == 0,
    opts = {
      inlay_hints = {
        parameter_hints = { show = true },
        type_hints = { show = true },
        label_formatter = function(label, hint)
          return " " .. label .. " "
        end,
      },
    },
    config = function(_, opts)
      require("lsp-inlayhints").setup(opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          if not (args.data and args.data.client_id) then
            return
          end
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.inlayHintProvider then
            require("lsp-inlayhints").on_attach(client, args.buf)
          end
        end,
      })
    end,
  },

  -- GOTH-specific tools
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
    },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    opts = {
      lsp_cfg = false, -- handled by lspconfig
      lsp_gofumpt = true,
      lsp_on_attach = function(_, bufnr)
        -- Go-specific keymaps
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map("n", "<leader>gi", "<cmd>GoImpl<CR>", "Go Implement Interface")
        map("n", "<leader>gfs", "<cmd>GoFillStruct<CR>", "Go Fill Struct")
        map("n", "<leader>ge", "<cmd>GoIfErr<CR>", "Go If Err")
      end,
      trouble = true,
      luasnip = true,
    },
  },

  -- Next.js/TypeScript-specific tools
  {
    "pmizio/typescript-tools.nvim",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      tsserver_plugins = { "@styled/typescript-styled-plugin" },
      expose_as_code_action = { "fix_all", "add_missing_imports", "remove_unused" },
      tsserver_file_preferences = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    config = function(_, opts)
      -- Setup only for Next.js stack or if both stacks are active
      if not vim.g.current_stack or vim.g.current_stack == "nextjs" then
        require("typescript-tools").setup(opts)

        -- Create TypeScript commands
        local api = require("typescript-tools.api")
        for cmd, fn in pairs({
          TSOrganizeImports = api.organize_imports,
          TSRenameFile = api.rename_file,
          TSAddMissingImports = api.add_missing_imports,
          TSRemoveUnused = api.remove_unused,
          TSFixAll = api.fix_all,
        }) do
          vim.api.nvim_create_user_command(cmd, fn, { desc = cmd })
        end
      end
    end,
  },
}
