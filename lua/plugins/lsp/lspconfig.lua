return {
  -- Core LSP functionality
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
      local inlay_hints_supported = vim.fn.has("nvim-0.10") == 1

      -- Shared capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      -- On attach function
      local on_attach = function(client, bufnr)
        if client.name == "copilot" or client.name == "null-ls" then return end

        local function buf_set_keymap(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        -- LSP navigation
        buf_set_keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
        buf_set_keymap("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
        buf_set_keymap("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
        buf_set_keymap("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
        buf_set_keymap("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

        -- LSP information
        buf_set_keymap("n", "K", vim.lsp.buf.hover, { desc = "Show hover information" })
        buf_set_keymap("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help" })

        -- LSP actions
        buf_set_keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
        buf_set_keymap("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })

        -- Diagnostics
        buf_set_keymap("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostics" })
        buf_set_keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
        buf_set_keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
        buf_set_keymap("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

        -- Enable inlay hints
        if inlay_hints_supported and client.server_capabilities.inlayHintProvider then
          pcall(function()
            if vim.lsp.inlay_hint and type(vim.lsp.inlay_hint.enable) == "function" then
              vim.lsp.inlay_hint.enable(bufnr, true)
            end
          end)
        end

        -- Stack-specific keymaps
        if client.name == "gopls" then
          buf_set_keymap("n", "<leader>goi", "<cmd>lua require('utils.go_utils').organize_imports()<CR>",
            { desc = "Organize imports" })
          buf_set_keymap("n", "<leader>gie", "<cmd>GoIfErr<CR>", { desc = "Add if err" })
          buf_set_keymap("n", "<leader>gfs", "<cmd>GoFillStruct<CR>", { desc = "Fill struct" })
        end

        if client.name == "tsserver" or client.name == "typescript-tools" then
          buf_set_keymap("n", "<leader>toi", "<cmd>TypescriptOrganizeImports<CR>", { desc = "Organize imports" })
          buf_set_keymap("n", "<leader>tru", "<cmd>TypescriptRemoveUnused<CR>", { desc = "Remove unused" })
          buf_set_keymap("n", "<leader>tfa", "<cmd>TypescriptFixAll<CR>", { desc = "Fix all" })
          buf_set_keymap("n", "<leader>tai", "<cmd>TypescriptAddMissingImports<CR>", { desc = "Add missing imports" })
        end
      end

      -- Mason-lspconfig setup
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls" },
        automatic_installation = false,
        handlers = {
          -- Default handler
          function(server_name)
            local ok, lspconfig = pcall(require, "lspconfig")
            if not ok then return end
            pcall(function()
              lspconfig[server_name].setup({
                on_attach = on_attach,
                capabilities = capabilities,
              })
            end)
          end,

          -- Custom server configurations
          ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  diagnostics = {
                    globals = { "vim", "require" },
                    disable = { "missing-fields", "no-unknown" },
                  },
                  workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                  },
                  telemetry = { enable = false },
                  hint = inlay_hints_supported and {
                    enable = true,
                    setType = true,
                    paramType = true,
                    paramName = "All",
                    semicolon = "All",
                    arrayIndex = "All",
                  } or nil,
                },
              },
            })
          end,

          ["gopls"] = function()
            require("lspconfig").gopls.setup({
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
                    useany = true,
                  },
                  staticcheck = true,
                  gofumpt = true,
                  usePlaceholders = true,
                  completeUnimported = true,
                  matcher = "fuzzy",
                  symbolMatcher = "fuzzy",
                  buildFlags = { "-tags=integration,e2e" },
                  experimentalPostfixCompletions = true,
                  hints = inlay_hints_supported and {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                  } or nil,
                },
              },
            })
          end,

          ["html"] = function()
            require("lspconfig").html.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              filetypes = { "html", "templ" },
              settings = {
                html = {
                  format = {
                    indentInnerHtml = true,
                    wrapLineLength = 100,
                    wrapAttributes = "auto",
                  },
                  hover = {
                    documentation = true,
                    references = true,
                  },
                },
              },
            })
          end,

          ["ts_ls"] = function()
            require("lspconfig").ts_ls.setup({
              on_attach = function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
                on_attach(client, bufnr)
              end,
              capabilities = capabilities,
              settings = {
                typescript = {
                  inlayHints = inlay_hints_supported and {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                  } or nil,
                },
                javascript = {
                  inlayHints = inlay_hints_supported and {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                  } or nil,
                },
              },
            })
          end,

          ["tailwindcss"] = function()
            require("lspconfig").tailwindcss.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              filetypes = {
                "html", "css", "scss", "javascript", "javascriptreact",
                "typescript", "typescriptreact", "templ",
              },
              init_options = {
                userLanguages = { templ = "html" },
              },
            })
          end,

          ["jsonls"] = function()
            require("lspconfig").jsonls.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                json = {
                  schemas = require("schemastore").json.schemas(),
                  validate = { enable = true },
                },
              },
            })
          end,

          ["pyright"] = function()
            require("lspconfig").pyright.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                python = {
                  analysis = {
                    typeCheckingMode = "basic",
                    diagnosticMode = "workspace",
                    inlayHints = {
                      variableTypes = true,
                      functionReturnTypes = true,
                    },
                  },
                  venvPath = vim.fn.exists("$VIRTUAL_ENV") == 1 and vim.fn.expand("$VIRTUAL_ENV") or "",
                },
              },
            })
          end,
        },
      })

      -- Diagnostic configuration
      local signs = { Error = "", Warn = "", Info = "", Hint = "" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      vim.diagnostic.config({
        virtual_text = {
          prefix = " ",
          spacing = 4,
          source = "if_many",
        },
        float = {
          border = "single",
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

      -- LSP handlers with borders
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help,
        { border = "single" })
    end,
  },

  -- JSON schema support
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

  -- GOTH stack tools
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua", "neovim/nvim-lspconfig" },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    opts = {
      lsp_cfg = false,
      lsp_gofumpt = true,
      lsp_on_attach = function(_, bufnr)
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

  -- Next.js/TypeScript tools
  {
    "pmizio/typescript-tools.nvim",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
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
      if not vim.g.current_stack or vim.g.current_stack == "nextjs" or vim.g.current_stack == "goth+nextjs" then
        require("typescript-tools").setup(opts)

        local api = require("typescript-tools.api")
        for cmd, fn in pairs({
          TypescriptOrganizeImports = api.organize_imports,
          TypescriptRenameFile = api.rename_file,
          TypescriptAddMissingImports = api.add_missing_imports,
          TypescriptRemoveUnused = api.remove_unused,
          TypescriptFixAll = api.fix_all,
        }) do
          vim.api.nvim_create_user_command(cmd, fn, { desc = cmd })
        end
      end
    end,
  },

  -- Templ support
  { "joerdav/templ.vim", ft = "templ" },

  -- Inlay hints for older Neovim
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
          if not (args.data and args.data.client_id) then return end
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.inlayHintProvider then
            require("lsp-inlayhints").on_attach(client, args.buf)
          end
        end,
      })
    end,
  },
}
