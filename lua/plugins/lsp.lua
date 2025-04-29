return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for neovim
    { 
      "williamboman/mason.nvim", 
      build = ":MasonUpdate", 
      config = true, 
      priority = 80,  -- Load mason early
    },
    { 
      "williamboman/mason-lspconfig.nvim", 
      priority = 70   -- Load after mason but before LSP
    },
    
    -- Useful status updates for LSP
    { "j-hui/fidget.nvim", tag = "legacy", opts = {} },
    
    -- Additional lua configuration specifically for working on neovim config
    { "folke/neodev.nvim", ft = "lua" },
    
    -- Show code context
    { 
      "SmiteshP/nvim-navic", 
      opts = {
        icons = {
          File = " ",
          Module = " ",
          Namespace = " ",
          Package = " ",
          Class = " ",
          Method = " ",
          Property = " ",
          Field = " ",
          Constructor = " ",
          Enum = " ",
          Interface = " ",
          Function = " ",
          Variable = " ",
          Constant = " ",
          String = " ",
          Number = " ",
          Boolean = " ",
          Array = " ",
          Object = " ",
          Key = " ",
          Null = " ",
          EnumMember = " ",
          Struct = " ",
          Event = " ",
          Operator = " ",
          TypeParameter = " ",
        },
        highlight = true,
        separator = " › ",
        depth_limit = 0,
        depth_limit_indicator = "...",
      }
    },
    
    -- Visualize lsp progress
    {
      "linrongbin16/lsp-progress.nvim",
      opts = {
        format = function(client_messages)
          if #client_messages > 0 then
            return " LSP:" .. table.concat(client_messages, " ")
          end
          return ""
        end,
      }
    },
    
    -- Enhanced inlay hints
    {
      "lvimuser/lsp-inlayhints.nvim",
      opts = {
        inlay_hints = {
          parameter_hints = {
            show = true,
            prefix = "<- ",
            separator = ", ",
            remove_colon_start = false,
            remove_colon_end = true,
          },
          type_hints = {
            show = true,
            prefix = "=> ",
            separator = ", ",
            remove_colon_start = false,
            remove_colon_end = false,
          },
          only_current_line = false,
          labels_separator = " ",
          highlight = "LspInlayHint",
          priority = 0,
        }
      },
      cond = function()
        -- Only load if Neovim < 0.10 as newer versions have native inlay hints
        return vim.fn.has("nvim-0.10") == 0
      end,
    },
    
    -- Typescript tools if needed
    {
      "pmizio/typescript-tools.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      ft = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },
    },
    
    -- Schema store for JSON/YAML validation
    {
      "b0o/SchemaStore.nvim",
      lazy = true,
      version = false, -- latest
    },
  },
  opts = {
    -- options for vim.diagnostic.config()
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
      severity_sort = true,
      float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = function(diagnostic)
          local signs = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = " ",
          }
          return signs[diagnostic.severity] .. " "
        end,
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = " ",
        },
      },
    },
    
    -- Enable inlay hints by default
    inlay_hints = {
      enabled = true,
    },
    
    -- LSP Server Settings
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            completion = {
              callSnippet = "Replace",
            },
            telemetry = { enable = false },
            diagnostics = {
              globals = { "vim" },
            },
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
      
      -- GOTH Stack (Go + Templ + HTMX)
      gopls = {
        settings = {
          gopls = {
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
              unusedparams = true,
              unusedvariable = true,
              fieldalignment = true,
              nilness = true,
              shadow = true,
              useany = true,
            },
            semanticTokens = true,
            usePlaceholders = true,
            staticcheck = true,
            directoryFilters = {
              "-node_modules",
              "-vendor",
              "-build",
              "-dist",
            },
            codelenses = {
              generate = true,
              gc_details = true,
              regenerate_cgo = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            expandWorkspaceToModule = true,
          },
        },
      },
      templ = {
        filetypes = { "templ" },
      },
      html = {
        filetypes = { "html", "templ" },
        settings = {
          html = {
            hover = {
              documentation = true,
              references = true,
            },
            suggest = {
              html5 = true,
            },
            validate = {
              scripts = true,
              styles = true,
            },
            format = {
              enable = true,
              wrapAttributes = "auto",
              wrapLineLength = 120,
            },
          },
        },
      },
      
      -- Next.js Stack
      tsserver = {
        -- This will be handled by typescript-tools.nvim
      },
      cssls = {},
      tailwindcss = {
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { "classnames\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { "twMerge\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              },
            },
            validate = true,
          },
        },
      },
      eslint = {
        settings = {
          workingDirectories = { { mode = "auto" } },
        },
      },
      jsonls = {
        -- Get schemas from SchemaStore
        settings = {
          json = {
            schemas = function()
              local has_schemastore, schemastore = pcall(require, "schemastore")
              if has_schemastore then
                return schemastore.json.schemas()
              end
              return {}
            end,
            validate = { enable = true },
          }
        }
      },
      
      -- General purpose
      yamlls = {
        settings = {
          yaml = {
            keyOrdering = false,
            schemas = function()
              local has_schemastore, schemastore = pcall(require, "schemastore")
              if has_schemastore then 
                return schemastore.yaml.schemas()
              end
              return {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/docker-compose.json"] = "*docker-compose*.yml",
              }
            end,
            validate = true,
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },
          },
        },
      },
      dockerls = {},
      bashls = {},
    },
    
    -- Setup handlers for LSP servers
    setup = {
      -- Skip tsserver setup since it's handled by typescript-tools
      tsserver = function()
        return true
      end,
    },
  },

  config = function(_, opts)
    -- Setup neodev for neovim config development - do this BEFORE lspconfig setup
    require("neodev").setup({
      library = {
        plugins = {
          "nvim-dap-ui",
          "neotest",
        },
        types = true,
      },
    })

    -- Setup keymaps when an LSP connects to a buffer
    local on_attach = function(client, bufnr)
      -- Setup inlay hints if supported
      if client.supports_method("textDocument/inlayHint") then
        if vim.fn.has("nvim-0.10") == 1 then
          -- Use native Neovim 0.10+ inlay hints
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(opts.inlay_hints.enabled, { bufnr = bufnr })
          end
        elseif package.loaded["lsp-inlayhints"] then
          -- Fallback to plugin for older versions
          require("lsp-inlayhints").on_attach(client, bufnr)
        end
      end
      
      -- Setup navic if supported
      if client.supports_method("textDocument/documentSymbol") then
        require("nvim-navic").attach(client, bufnr)
      end
      
      -- Enable semantic tokens if supported
      if client.supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = vim.deepcopy(
          client.server_capabilities.semanticTokensProvider or {
            full = true,
            legend = {
              tokenTypes = {},
              tokenModifiers = {},
            },
            range = true,
          })
      end
      
      -- Create keymaps
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc and "LSP: " .. desc or nil })
      end

      map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

      map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
      map("n", "gr", require("telescope.builtin").lsp_references, "Go to References")
      map("n", "gI", vim.lsp.buf.implementation, "Go to Implementation")
      map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
      map("n", "<leader>D", vim.lsp.buf.type_definition, "Type Definition")
      map("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
      map("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")

      map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
      map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

      map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Workspace Add Folder")
      map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Workspace Remove Folder")
      map("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, "Workspace List Folders")

      -- Create a command `:Format` local to the LSP buffer
      vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        if vim.lsp.buf.format then
          vim.lsp.buf.format({ async = true })
        else
          vim.lsp.buf.formatting_sync() -- Fallback for older versions
        end
      end, { desc = "Format current buffer with LSP" })

      map("n", "<leader>cf", function()
        if vim.lsp.buf.format then
          vim.lsp.buf.format({ async = true })
        else
          vim.lsp.buf.formatting_sync() -- Fallback for older versions
        end
      end, "Format")

      -- Show diagnostics in a floating window
      map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
      
      -- Apply stack-specific settings
      local filetype = vim.bo[bufnr].filetype
      
      -- For GOTH stack
      if filetype == "go" or filetype == "templ" then
        -- Set appropriate options for Go
        if filetype == "go" then
          if package.loaded["go"] then
            -- Special Go actions using ray-x/go.nvim if available
            map("n", "<leader>sgi", "<cmd>GoImports<cr>", "Go Imports")
            map("n", "<leader>sgc", "<cmd>GoCoverage<cr>", "Go Coverage")
            map("n", "<leader>sgt", "<cmd>GoTest<cr>", "Go Test")
            map("n", "<leader>sgm", "<cmd>GoModTidy<cr>", "Go Mod Tidy")
          else
            -- Fallback to gopls commands
            map("n", "<leader>sgi", function()
              vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
            end, "Go Imports")
          end
        end
        
        -- For Templ files
        if filetype == "templ" then
          -- Add Templ-specific commands
          vim.api.nvim_buf_create_user_command(bufnr, "TemplFmt", function()
            -- Check if conform.nvim is available
            if package.loaded["conform"] then
              require("conform").format({ bufnr = bufnr, formatters = { "templ" } })
            else
              vim.cmd("!templ fmt " .. vim.fn.expand("%"))
              vim.cmd("e!") -- Reload the file
            end
          end, { desc = "Format Templ file" })
          
          map("n", "<leader>stf", "<cmd>TemplFmt<cr>", "Templ Format")
        end
      end
      
      -- For Next.js stack
      if filetype == "javascript" or filetype == "typescript" or filetype == "javascriptreact" or filetype == "typescriptreact" then
        -- Add Next.js specific commands
        if client.name == "tsserver" or client.name == "typescript-tools" then
          if package.loaded["typescript-tools"] then
            map("n", "<leader>sno", function() require("typescript-tools.api").organize_imports() end, "Organize Imports")
            map("n", "<leader>snr", function() require("typescript-tools.api").rename_file() end, "Rename File")
            map("n", "<leader>sni", function() require("typescript-tools.api").add_missing_imports() end, "Add Missing Imports")
            map("n", "<leader>snu", function() require("typescript-tools.api").remove_unused() end, "Remove Unused")
            map("n", "<leader>snf", function() require("typescript-tools.api").fix_all() end, "Fix All")
          else
            -- Fallback to standard tsserver commands
            map("n", "<leader>sno", function()
              vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
            end, "Organize Imports")
          end
        end
      end
    end

    -- Configure enhanced LSP capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    
    -- Add completion capabilities
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = {
        "documentation",
        "detail",
        "additionalTextEdits",
      }
    }
    
    -- Add folding capabilities
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true
    }
    
    -- Add semantic tokens capabilities
    capabilities.textDocument.semanticTokens = {
      dynamicRegistration = false,
      tokenTypes = {
        "namespace", "type", "class", "enum", "interface", "struct",
        "typeParameter", "parameter", "variable", "property", "function",
        "method", "macro", "keyword", "comment", "string", "number",
        "regexp", "operator", "decorator"
      },
      tokenModifiers = {
        "declaration", "definition", "readonly", "static", "deprecated",
        "abstract", "async", "modification", "documentation", "defaultLibrary"
      },
      formats = { "relative" },
      requests = {
        range = true,
        full = true
      }
    }
    
    -- Update with nvim-cmp capabilities if available
    if package.loaded["cmp_nvim_lsp"] then
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
    end

    -- Configure diagnostic display
    for name, icon in pairs(opts.diagnostics.signs.text) do
      name = "DiagnosticSign" .. name
      vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
    end
    
    vim.diagnostic.config(opts.diagnostics)
    
    -- Setup enhanced handlers for hover and signature help
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover, {
        border = "rounded",
        max_width = 80,
        max_height = 30,
      }
    )
    
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help, {
        border = "rounded",
        max_width = 80,
        max_height = 20,
      }
    )

    -- Setup mason first
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      },
      max_concurrent_installers = 10,
    })

    -- Extract server names from opts.servers table to create servers_to_install
    local servers_to_install = {}
    for server_name, _ in pairs(opts.servers) do
      table.insert(servers_to_install, server_name)
    end

    -- Then set up mason-lspconfig
    require("mason-lspconfig").setup({
      ensure_installed = servers_to_install,
      automatic_installation = true,
      handlers = {        
        function(server_name)
          -- Skip setup for servers that should be handled elsewhere
          if opts.setup[server_name] then
            if opts.setup[server_name](server_name, opts.servers[server_name] or {}) then
              return
            end
          end
    
          local server_opts = opts.servers[server_name] or {}
          server_opts.capabilities = capabilities
          server_opts.on_attach = on_attach
    
          require("lspconfig")[server_name].setup(server_opts)
        end,
      }
    })
    
    -- Add special handling for Templ LSP which may not be in Mason yet
    if not vim.tbl_contains(servers_to_install, "templ") then
      require("lspconfig")["templ"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end
    
    -- Add command to toggle inlay hints
    vim.api.nvim_create_user_command("ToggleInlayHints", function()
      -- Toggle the global setting
      opts.inlay_hints.enabled = not opts.inlay_hints.enabled
      
      -- Apply to all buffers with active clients
      local buffers = vim.api.nvim_list_bufs()
      for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          local clients = vim.lsp.get_clients({ bufnr = bufnr })
          for _, client in ipairs(clients) do
            if client.supports_method("textDocument/inlayHint") then
              -- Use native Neovim 0.10+ inlay hints if available
              if vim.fn.has("nvim-0.10") == 1 and vim.lsp.inlay_hint then
                vim.lsp.inlay_hint.enable(opts.inlay_hints.enabled, { bufnr = bufnr })
              elseif package.loaded["lsp-inlayhints"] then
                if opts.inlay_hints.enabled then
                  require("lsp-inlayhints").on_attach(client, bufnr)
                else
                  require("lsp-inlayhints").disable()
                end
              end
            end
          end
        end
      end
      
      vim.notify("Inlay hints " .. (opts.inlay_hints.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle inlay hints" })
    
    -- Add keybinding for toggling inlay hints
    vim.keymap.set("n", "<leader>uh", "<cmd>ToggleInlayHints<CR>", { desc = "Toggle inlay hints" })
    
    -- Add command to restart all LSPs
    vim.api.nvim_create_user_command("LspRestart", function()
      vim.lsp.stop_client(vim.lsp.get_clients())
      vim.cmd("edit")
      vim.notify("LSP servers restarted", vim.log.levels.INFO)
    end, { desc = "Restart LSP servers" })
    
    -- Add command for specific stacks
    vim.api.nvim_create_user_command("LspGOTH", function()
      -- Specifically focus on GOTH stack capabilities
      vim.g.current_stack = "goth"
      vim.notify("LSP settings optimized for GOTH stack", vim.log.levels.INFO)
      
      -- Adjust any specific settings if needed
      require("lspconfig").gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = opts.servers.gopls.settings,
      })
      
      require("lspconfig").templ.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
      
      -- Restart relevant servers
      vim.lsp.stop_client(vim.lsp.get_clients({
        name = { "gopls", "templ", "html" }
      }))
      vim.cmd("edit")
    end, { desc = "Configure LSP for GOTH stack" })
    
    vim.api.nvim_create_user_command("LspNextJS", function()
      -- Specifically focus on Next.js stack capabilities
      vim.g.current_stack = "nextjs"
      vim.notify("LSP settings optimized for Next.js stack", vim.log.levels.INFO)
      
      -- Adjust any specific settings if needed
      require("lspconfig").tailwindcss.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = opts.servers.tailwindcss.settings,
      })
      
      -- Restart relevant servers
      vim.lsp.stop_client(vim.lsp.get_clients({
        name = { "eslint", "tailwindcss", "cssls" }
      }))
      vim.cmd("edit")
    end, { desc = "Configure LSP for Next.js stack" })

    -- Setup typescript-tools if available
    if package.loaded["typescript-tools"] then
      require("typescript-tools").setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          -- For Next.js
          tsserver_plugins = {
            "@styled/typescript-styled-plugin",
          },
          expose_as_code_action = {
            "fix_all",
            "add_missing_imports",
            "remove_unused",
          },
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
      })
    end
  end,
}
