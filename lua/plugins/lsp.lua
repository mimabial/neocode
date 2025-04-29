return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "williamboman/mason.nvim",
      build = ":MasonUpdate",
      config = true,
      priority = 90,  -- Load mason early
    },
    {
      "williamboman/mason-lspconfig.nvim",
      priority = 85   -- Load after mason but before LSP
    },
    {
      "j-hui/fidget.nvim",
      tag = "legacy",
      opts = {
        text = { spinner = "dots" },
        window = { blend = 0, relative = "editor" },
        sources = { ["null-ls"] = { ignore = true } },
      },
      priority = 80
    },
    {
      "folke/neodev.nvim",
      ft = "lua",
      opts = {
        library = {
          plugins = { "nvim-dap-ui", "neotest" },
          types = true,
        },
      },
      priority = 81
    },
    {
      "SmiteshP/nvim-navic",
      opts = {
        icons = {
          File        = " ", Module     = " ", Namespace   = " ",
          Package     = " ", Class      = " ", Method      = " ",
          Property    = " ", Field      = " ", Constructor = " ",
          Enum        = " ", Interface  = " ", Function    = " ",
          Variable    = " ", Constant   = " ", String      = " ",
          Number      = " ", Boolean    = " ", Array       = " ",
          Object      = " ", Key        = " ", Null        = " ",
          EnumMember  = " ", Struct     = " ", Event       = " ",
          Operator    = " ", TypeParameter = " ",
        },
        highlight = true,
        separator = " › ",
        depth_limit = 0,
        depth_limit_indicator = "...",
      },
      priority = 75
    },
    {
      "linrongbin16/lsp-progress.nvim",
      opts = {
        format = function(client_messages)
          if #client_messages > 0 then
            return " LSP:" .. table.concat(client_messages, " ")
          end
          return ""
        end,
      },
      priority = 76
    },
    {
      "b0o/SchemaStore.nvim",
      lazy = true,
      version = false,
      priority = 70
    },
  },
  opts = {
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
      severity_sort = true,
      float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = function(diagnostic)
          local signs = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
          }
          return signs[diagnostic.severity] .. " "
        end,
      },
      signs = { text = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN]  = " ",
        [vim.diagnostic.severity.INFO]  = " ",
        [vim.diagnostic.severity.HINT]  = " ",
      } },
    },
    inlay_hints = { enabled = true },
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
            hint = {
              enable = true,
              setType = true,
              paramType = true,
              paramName = "Literal",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      },
      gopls = {
        settings = {
          gopls = {
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes  = true,
              constantValues         = true,
              functionTypeParameters = true,
              parameterNames         = true,
              rangeVariableTypes     = true,
            },
            analyses = {
              unusedparams    = true,
              unusedvariable  = true,
              fieldalignment  = true,
              nilness         = true,
              shadow          = true,
              useany          = true,
            },
            semanticTokens     = true,
            usePlaceholders    = true,
            staticcheck        = true,
            directoryFilters   = { "-node_modules", "-vendor", "-build", "-dist" },
            codelenses = {
              generate       = true,
              gc_details     = true,
              regenerate_cgo = true,
              tidy           = true,
              upgrade_dependency = true,
              vendor         = true,
            },
            expandWorkspaceToModule = true,
          },
        },
      },
      templ = { filetypes = { "templ" } },
      html = {
        filetypes = { "html", "templ" },
        settings = {
          html = {
            hover = { documentation = true, references = true },
            suggest = { html5 = true },
            validate = { scripts = true, styles = true },
            format = { enable = true, wrapAttributes = "auto", wrapLineLength = 120 },
          },
        },
      },
      tsserver = {}, cssls = {},
      tailwindcss = {
        settings = { tailwindCSS = {
          experimental = { classRegex = {
            { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
            { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
            { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
            { "classnames\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
            { "twMerge\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          } },
          validate = true,
        } },
      },
      eslint  = { settings = { workingDirectories = { { mode = "auto" } } } },
      jsonls  = { settings = { json = {
        schemas = function()
          local ok, schemastore = pcall(require, "schemastore")
          return ok and schemastore.json.schemas() or {}
        end,
        validate = { enable = true },
      } } },
      yamlls = { settings = {
        yaml = {
          keyOrdering = false,
          schemas = function()
            local ok, schemastore = pcall(require, "schemastore")
            if ok then return schemastore.yaml.schemas() end
            return {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              ["https://json.schemestore.org/docker-compose.json"]  = "*docker-compose*.yml",
            }
          end,
          validate     = true,
          schemaStore  = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
        },
      } },
      dockerls = {}, bashls = {},
    },
    setup = { tsserver = function() return true end },
  },

  config = function(_, opts)
    -- Neodev for Lua configuration
    require("neodev").setup(opts.neodev or opts)

    -- Define on_attach for LSP clients
    local on_attach = function(client, bufnr)
      -- Inlay hints
      if client.supports_method("textDocument/inlayHint") then
        if vim.fn.has("nvim-0.10") == 1 and vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(opts.inlay_hints.enabled, { bufnr = bufnr })
        elseif package.loaded["lsp-inlayhints"] then
          require("lsp-inlayhints").on_attach(client, bufnr)
        end
      end

      -- Navic context
      if client.supports_method("textDocument/documentSymbol") then
        require("nvim-navic").attach(client, bufnr)
      end

      -- Semantic tokens fallback
      if client.supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = vim.deepcopy(
          client.server_capabilities.semanticTokensProvider or {
            full = true,
            legend = { tokenTypes = {}, tokenModifiers = {} },
            range = true,
          }
        )
      end

      -- Keymapping helper
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc and "LSP: "..desc })
      end

      -- Core LSP mappings
      map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
      map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
      map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
      map("n", "gr", vim.lsp.buf.references, "Go to References")
      map("n", "K",  vim.lsp.buf.hover, "Hover Documentation")
      map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
      map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Folder")
      map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Folder")
      map("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, "List Folders")

      -- Buffer-local Format command
      vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
        vim.lsp.buf.format({ async = true })
      end, { desc = "Format current buffer" })

      -- Diagnostics
      map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
      map("n", "<leader>cq", vim.diagnostic.setqflist, "Set QF List")

      -- Stack-specific
      local ft = vim.bo[bufnr].filetype
      if ft == "go" then
        if package.loaded["go"] then
          map("n", "<leader>sgi", "<cmd>GoImports<cr>", "Go Imports")
          map("n", "<leader>sgc", "<cmd>GoCoverage<cr>", "Go Coverage")
          map("n", "<leader>sgt", "<cmd>GoTest<cr>", "Go Test")
          map("n", "<leader>sgm", "<cmd>GoModTidy<cr>", "Go Mod Tidy")
        else
          map("n", "<leader>sgi", function()
            vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
          end, "Go Imports")
        end
      elseif ft == "templ" then
        vim.api.nvim_buf_create_user_command(bufnr, "TemplFmt", function()
          if package.loaded["conform"] then
            require("conform").format({ bufnr = bufnr, formatters = { "templ" } })
          else
            vim.cmd("!templ fmt " .. vim.fn.expand("%"))
            vim.cmd("e!")
          end
        end, { desc = "Format Templ file" })
        map("n", "<leader>stf", "<cmd>TemplFmt<cr>", "Templ Format")
      end

      if ft:match("javascript") or ft:match("typescript") then
        if package.loaded["typescript-tools"] then
          map("n", "<leader>sno", function() require("typescript-tools.api").organize_imports() end, "Organize Imports")
        end
      end
    end

    -- Capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = { "documentation", "detail", "additionalTextEdits" }
    }
    capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
    capabilities.textDocument.semanticTokens = {
      dynamicRegistration = false,
      tokenTypes      = { "namespace", "type", "class", "enum", "interface", "struct", "typeParameter", "parameter", "variable", "property", "function", "method", "macro", "keyword", "comment", "string", "number", "regexp", "operator", "decorator" },
      tokenModifiers  = { "declaration", "definition", "readonly", "static", "deprecated", "abstract", "async", "modification", "documentation", "defaultLibrary" },
      formats         = { "relative" },
      requests        = { range = true, full = true }
    }
    if package.loaded["cmp_nvim_lsp"] then
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
    end

    -- Diagnostics signs
    for name, icon in pairs(opts.diagnostics.signs.text) do
      vim.fn.sign_define("DiagnosticSign" .. name, { text = icon, texthl = "DiagnosticSign" .. name })
    end
    vim.diagnostic.config(opts.diagnostics)

    -- Handlers
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", max_width = 80, max_height = 30 })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", max_width = 80, max_height = 20 })

    -- Mason setup
    require("mason").setup({
      ui = { border = "rounded", icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } },
      max_concurrent_installers = 10,
    })

    -- Mason-lspconfig
    local servers = {}
    for name, _ in pairs(opts.servers) do
      if not opts.setup[name] then table.insert(servers, name) end
    end
    require("mason-lspconfig").setup({ ensure_installed = servers, automatic_installation = true, handlers = { function(server)
      if opts.setup[server] and opts.setup[server](server, opts.servers[server] or {}) then return end
      local server_opts = vim.tbl_extend("force", { capabilities = capabilities, on_attach = on_attach }, opts.servers[server] or {})
      require("lspconfig")[server].setup(server_opts)
    end } })

    -- Templ may not be in mason
    if not vim.tbl_contains(servers, "templ") then
      require("lspconfig").templ.setup({ capabilities = capabilities, on_attach = on_attach })
    end

    -- Commands
    vim.api.nvim_create_user_command("ToggleInlayHints", function()
      opts.inlay_hints.enabled = not opts.inlay_hints.enabled
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
          if client.supports_method("textDocument/inlayHint") then
            if vim.fn.has("nvim-0.10") == 1 and vim.lsp.inlay_hint then
              vim.lsp.inlay_hint.enable(opts.inlay_hints.enabled, { bufnr = buf })
            elseif package.loaded["lsp-inlayhints"] then
              if opts.inlay_hints.enabled then require("lsp-inlayhints").on_attach(client, buf) else require("lsp-inlayhints").disable() end
            end
          end
        end
      end
      vim.notify("Inlay hints " .. (opts.inlay_hints.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle inlay hints" })

    vim.keymap.set("n", "<leader>uh", "<cmd>ToggleInlayHints<CR>", { desc = "Toggle inlay hints" })
    vim.api.nvim_create_user_command("LspRestart", function()
      vim.lsp.stop_client(vim.lsp.get_clients())
      vim.cmd("edit")
      vim.notify("LSP servers restarted", vim.log.levels.INFO)
    end, { desc = "Restart LSP servers" })

    vim.api.nvim_create_user_command("LspGOTH", function()
      vim.g.current_stack = "goth"
      vim.notify("LSP settings optimized for GOTH stack", vim.log.levels.INFO)
      require("lspconfig").gopls.setup({ on_attach = on_attach, capabilities = capabilities, settings = opts.servers.gopls.settings })
      require("lspconfig").templ.setup({ on_attach = on_attach, capabilities = capabilities })
      require("lspconfig").html.setup({ on_attach = on_attach, capabilities = capabilities, filetypes = { "html", "templ" }, settings = opts.servers.html.settings })
      vim.lsp.stop_client(vim.lsp.get_clients({ name = { "gopls", "templ", "html" } }))
      vim.cmd("edit")
    end, { desc = "Configure LSP for GOTH stack" })

    vim.api.nvim_create_user_command("LspNextJS", function()
      vim.g.current_stack = "nextjs"
      vim.notify("LSP settings optimized for Next.js stack", vim.log.levels.INFO)
      if package.loaded["typescript-tools"] then
        require("typescript-tools").setup({ on_attach = on_attach, capabilities = capabilities, settings = opts.servers.tsserver })
      end
      require("lspconfig").tailwindcss.setup({ on_attach = on_attach, capabilities = capabilities, settings = opts.servers.tailwindcss.settings })
      require("lspconfig").cssls.setup({ on_attach = on_attach, capabilities = capabilities })
      require("lspconfig").eslint.setup({ on_attach = on_attach, capabilities = capabilities, settings = opts.servers.eslint.settings })
      vim.lsp.stop_client(vim.lsp.get_clients({ name = { "tsserver", "eslint", "tailwindcss", "cssls" } }))
      vim.cmd("edit")
    end, { desc = "Configure LSP for Next.js stack" })

    -- Typescript-tools fallback
    if package.loaded["typescript-tools"] then
      require("typescript-tools").setup({ on_attach = on_attach, capabilities = capabilities, settings = opts.servers.tsserver })
    end

    -- ColorScheme highlights
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        local green  = vim.api.nvim_get_hl(0, { name = "GruvboxGreen"  }).fg or "#89b482"
        local aqua   = vim.api.nvim_get_hl(0, { name = "GruvboxAqua"   }).fg or "#7daea3"
        local red    = vim.api.nvim_get_hl(0, { name = "GruvboxRed"    }).fg or "#ea6962"
        local yellow = vim.api.nvim_get_hl(0, { name = "GruvboxYellow" }).fg or "#d8a657"
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = red })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn",  { fg = yellow })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo",  { fg = aqua })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint",  { fg = green })
        vim.api.nvim_set_hl(0, "LspInlayHint",               { fg = "#665c54", italic = true })
      end,
    })
  end,
}

