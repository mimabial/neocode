-- lua/config/lsp.lua
-- Enhanced LSP configuration that integrates with existing stack detection

local M = {}

-- Utility function for safe requires
local function safe_require(mod)
  local ok, result = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[LSP] Failed to load %s", mod), vim.log.levels.WARN)
    return nil
  end
  return result
end

-- Enhanced capabilities with nvim-cmp integration
M.capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Add nvim-cmp capabilities
  local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if cmp_ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  -- Enhance capabilities for better experience
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.preselectSupport = true
  capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
  capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }

  -- Add foldingRange capability
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  return capabilities
end

-- Common on_attach function for LSP server enhancements
-- NOTE: Doesn't set keymaps since those are handled in keymaps.lua via autocmd
M.on_attach = function(client, bufnr)
  -- Skip certain LSP clients
  if client.name == "copilot" then
    return
  end

  -- Setup lsp_signature if available
  local signature_ok, signature = pcall(require, "lsp_signature")
  if signature_ok then
    signature.on_attach({
      bind = true,
      handler_opts = { border = "rounded" },
      hint_enable = true,
      hint_prefix = "📝 ",
      hint_scheme = "String",
      hi_parameter = "Search",
      max_width = 120,
      max_height = 30,
      padding = " ",
    }, bufnr)
  end

  -- Enable inlay hints for applicable servers (Neovim >=0.10)
  if vim.fn.has("nvim-0.10") == 1 and client.server_capabilities.inlayHintProvider then
    if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
      vim.lsp.inlay_hint.enable(bufnr, true)
    end
  end
end

-- Server configurations for all the LSP servers we use
M.server_configs = {
  -- Go language server
  gopls = {
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
        directoryFilters = { "-.git", "-.vscode", "-.idea", "-node_modules" },
        semanticTokens = true,
        codelenses = {
          gc_details = true,
          generate = true,
          regenerate_cgo = true,
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

  -- TypeScript Tools (alternative to tsserver)
  ["typescript-tools"] = {
    settings = {
      -- typescript-tools specific settings
      tsserver_file_preferences = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      tsserver_plugins = {
        "@styled/typescript-styled-plugin", -- For styled-components
      },
      expose_as_code_action = { "fix_all", "add_missing_imports", "remove_unused" },
    },
  },

  -- HTML language server
  html = {
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
  },

  -- CSS language server
  cssls = {
    settings = {
      css = {
        validate = true,
        lint = {
          unknownAtRules = "ignore",
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

  -- Templ language server
  templ = {
    filetypes = { "templ" },
  },

  -- JSON language server
  jsonls = {
    settings = {
      json = {
        validate = { enable = true },
      },
    },
  },

  -- YAML language server
  yamlls = {
    settings = {
      yaml = {
        schemaStore = {
          enable = true,
          url = "https://www.schemastore.org/api/json/catalog.json",
        },
      },
    },
  },

  -- ESLint language server
  eslint = {
    settings = {
      packageManager = "npm",
      useESLintClass = true,
      experimental = {
        useFlatConfig = false,
      },
      workingDirectories = { mode = "auto" },
    },
  },

  -- Lua language server
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = vim.split(package.path, ";"),
        },
        diagnostics = {
          globals = { "vim", "describe", "it", "before_each", "after_each", "packer_plugins" },
          disable = { "missing-fields", "no-unknown" },
        },
        workspace = {
          library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
          checkThirdParty = false,
        },
        telemetry = { enable = false },
        completion = {
          callSnippet = "Replace",
        },
        hint = {
          enable = true,
          setType = true,
          paramType = true,
          paramName = "All",
          semicolon = "All",
          arrayIndex = "All",
        },
        format = {
          enable = true,
          defaultConfig = {
            indent_style = "space",
            indent_size = "2",
            max_line_length = "120",
          },
        },
      },
    },
  },
}

-- Setup function
function M.setup()
  -- Initialize Mason if available
  local mason_ok, mason = pcall(require, "mason")
  if mason_ok then
    mason.setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })
  end

  -- Initialize Mason-LSPconfig if available
  local mason_lsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
  if mason_lsp_ok then
    mason_lspconfig.setup({
      ensure_installed = {
        -- GOTH stack
        "gopls",
        "templ",

        -- Next.js stack
        "tsserver",
        "eslint",
        "cssls",
        "html",
        "jsonls",
        "tailwindcss",

        -- Common
        "lua_ls",
        "yamlls",
      },
      automatic_installation = true,
    })
  end

  -- Initialize LSP configuration
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  if not lspconfig_ok then
    vim.notify("Failed to load lspconfig", vim.log.levels.ERROR)
    return
  end

  -- Global diagnostic configuration
  vim.diagnostic.config({
    virtual_text = {
      prefix = "●",
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
        return icons[diagnostic.severity] or "", ""
      end,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- Setup sign column icons
  local signs = { Error = "", Warn = "", Hint = "", Info = "" }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- Load SchemaStore if available for JSON schemas
  local schemastore_ok, schemastore = pcall(require, "schemastore")
  if schemastore_ok then
    if M.server_configs.jsonls and M.server_configs.jsonls.settings and M.server_configs.jsonls.settings.json then
      M.server_configs.jsonls.settings.json.schemas = schemastore.json.schemas()
    end

    if M.server_configs.yamlls and M.server_configs.yamlls.settings and M.server_configs.yamlls.settings.yaml then
      M.server_configs.yamlls.settings.yaml.schemas = schemastore.yaml.schemas()
    end
  end

  -- Set up default servers that don't need stack-specific config
  local base_servers = {
    "lua_ls",
    "pyright",
    "rust_analyzer",
    "clangd",
  }

  -- Let the stack-specific config in stacks.lua handle gopls, templ, tsserver, etc.
  -- We're only setting up servers that don't overlap with stack detection
  for _, server_name in ipairs(base_servers) do
    if lspconfig[server_name] then
      local server_config = vim.tbl_deep_extend("force", {
        on_attach = M.on_attach,
        capabilities = M.capabilities(),
      }, M.server_configs[server_name] or {})

      lspconfig[server_name].setup(server_config)
    end
  end
end

return M
