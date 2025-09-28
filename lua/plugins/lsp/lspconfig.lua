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
        if client.name == "null-ls" then return end

        -- Enable inlay hints if supported
        if vim.fn.has("nvim-0.10") == 1 and client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "html", "jsonls", "pyright" },
        automatic_installation = false,
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

          ["gopls"] = function()
            require("lspconfig").gopls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                gopls = {
                  analyses = {
                    unusedparams = true,
                    shadow = true,
                  },
                  staticcheck = true,
                  gofumpt = true,
                  usePlaceholders = true,
                  completeUnimported = true,
                  hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    constantValues = true,
                    parameterNames = true,
                  },
                },
              },
            })
          end,

          ["ts_ls"] = function()
            require("lspconfig").ts_ls.setup({
              capabilities = capabilities,
              on_attach = function(client, bufnr)
                -- Disable formatting (use prettier)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
                on_attach(client, bufnr)
              end,
              settings = {
                typescript = {
                  inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                  },
                },
              },
            })
          end,

          ["html"] = function()
            require("lspconfig").html.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              filetypes = { "html", "templ" },
            })
          end,

          ["tailwindcss"] = function()
            require("lspconfig").tailwindcss.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              filetypes = {
                "html", "css", "javascript", "javascriptreact",
                "typescript", "typescriptreact", "templ",
              },
              init_options = { userLanguages = { templ = "html" } },
            })
          end,

          ["jsonls"] = function()
            require("lspconfig").jsonls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
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
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help,
        { border = "single" })
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
