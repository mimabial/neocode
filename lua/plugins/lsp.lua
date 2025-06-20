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
      -- Schemas for JSON/YAML
      "b0o/SchemaStore.nvim",
      -- Signature help
      "ray-x/lsp_signature.nvim",
    },
    config = function()
      -- Set up Mason first for server management
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      -- Check if Neovim supports inlay hints (0.10+)
      local inlay_hints_supported = vim.fn.has("nvim-0.10") == 1

      -- Shared capabilities for all servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      -- Add folding ranges capability
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      local lspconfig_defaults = require("lspconfig").util.default_config
      lspconfig_defaults.capabilities =
        vim.tbl_deep_extend("force", lspconfig_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Configure keymaps when LSP attaches to buffer
      local on_attach = function(client, bufnr)
        -- Skip certain LSP clients for keymappings
        if client.name == "copilot" or client.name == "null-ls" then
          return
        end

        -- Set up buffer-local keymaps
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

        -- Enable inlay hints if supported
        if inlay_hints_supported and client.server_capabilities.inlayHintProvider then
          -- Only use this specific approach for Neovim 0.10+
          pcall(function()
            if vim.lsp.inlay_hint and type(vim.lsp.inlay_hint.enable) == "function" then
              vim.lsp.inlay_hint.enable(bufnr, true)
            end
          end)
        end

        -- Setup lsp_signature
        local signature_ok, signature = pcall(require, "lsp_signature")
        if signature_ok then
          signature.on_attach({
            bind = true,
            handler_opts = { border = "rounded" },
            hint_enable = true,
            hint_prefix = "🔍 ",
            hint_scheme = "String",
            hi_parameter = "IncSearch",
            toggle_key = "<C-k>",
          }, bufnr)
        end

        -- Stack-specific keymaps
        if client.name == "gopls" then
          -- Go-specific keymaps
          buf_set_keymap(
            "n",
            "<leader>goi",
            "<cmd>lua require('utils.go_utils').organize_imports()<CR>",
            { desc = "Organize imports" }
          )
          buf_set_keymap("n", "<leader>gie", "<cmd>GoIfErr<CR>", { desc = "Add if err" })
          buf_set_keymap("n", "<leader>gfs", "<cmd>GoFillStruct<CR>", { desc = "Fill struct" })
        end

        if client.name == "tsserver" or client.name == "typescript-tools" then
          -- TypeScript-specific keymaps
          buf_set_keymap("n", "<leader>toi", "<cmd>TypescriptOrganizeImports<CR>", { desc = "Organize imports" })
          buf_set_keymap("n", "<leader>tru", "<cmd>TypescriptRemoveUnused<CR>", { desc = "Remove unused" })
          buf_set_keymap("n", "<leader>tfa", "<cmd>TypescriptFixAll<CR>", { desc = "Fix all" })
          buf_set_keymap("n", "<leader>tai", "<cmd>TypescriptAddMissingImports<CR>", { desc = "Add missing imports" })
        end
      end

      require("mason-lspconfig").setup({
        ensure_installed = {
          -- Core language servers for both stacks
          "lua_ls",
          -- GOTH stack
          "gopls",
          "templ",
          "html",
          -- Next.js stack
          "tailwindcss",
          "cssls",
          "eslint",
          "jsonls",
        },
        automatic_installation = true,
        handlers = {
          -- Default handler for servers without custom config
          function(server_name)
            require("lspconfig")[server_name].setup({
              on_attach = on_attach,
              capabilities = capabilities,
            })
          end,

          -- Custom handlers for specific servers
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
                -- Disable formatting if using prettier
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
                  templ = "html",
                },
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

      -- Set up diagnostic signs and style
      local signs = { Error = "", Warn = "", Info = "", Hint = "" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- Configure diagnostics display
      vim.diagnostic.config({
        virtual_text = {
          prefix = " ",
          spacing = 4,
          source = "if_many",
        },
        float = {
          border = "rounded",
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

      -- Set up LSP handlers with borders
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
    end,
  },

  -- Signature help
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = true,
      handler_opts = { border = "single" },
      hint_enable = true,
      hint_prefix = "🔍 ",
      hint_scheme = "String",
      hi_parameter = "IncSearch",
      fix_pos = false,
      toggle_key = "<C-k>",
    },
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
      if not vim.g.current_stack or vim.g.current_stack == "nextjs" or vim.g.current_stack == "goth+nextjs" then
        require("typescript-tools").setup(opts)

        -- Create TypeScript commands
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

  -- JSON schema support
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
  },
}
