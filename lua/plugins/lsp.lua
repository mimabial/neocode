return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for neovim
    { "williamboman/mason.nvim", config = true },
    "williamboman/mason-lspconfig.nvim",
    -- Useful status updates for LSP
    { "j-hui/fidget.nvim", tag = "legacy", opts = {} },
    -- Additional lua configuration specifically for working on neovim config
    { "folke/neodev.nvim" },
    -- Show code context
    { "SmiteshP/nvim-navic", 
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
      "nvimdev/lsp-inlayhints.nvim",
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
          -- Priority of highlight group (higher is on the top)
          priority = 0,
        }
      }
    }
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
        prefix = "",
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
      jsonls = {},
      
      -- General purpose
      yamlls = {
        settings = {
          yaml = {
            keyOrdering = false,
          },
        },
      },
      dockerls = {},
      bashls = {},
    },
    
    -- you can do any additional lsp server setup here
    -- return true if you don't want this server to be setup with lspconfig
    setup = {
      -- example to setup with typescript.nvim
      -- tsserver = function(_, opts)
      --   require("typescript").setup({ server = opts })
      --   return true
      -- end,
      -- Specify * to use this function as a fallback for any server
      -- ["*"] = function(server, opts) end,
    },
  },
  config = function(_, opts)
    -- Setup neodev for neovim config development
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
      if client.supports_method("textDocument/inlayHint") and 
         opts.inlay_hints and 
         opts.inlay_hints.enabled 
      then
        require("lsp-inlayhints").on_attach(client, bufnr)
      end
      
      -- Setup navic if supported
      if client.supports_method("textDocument/documentSymbol") then
        require("nvim-navic").attach(client, bufnr)
      end
      
      -- Create keymaps
      local nmap = function(keys, func, desc)
        if desc then
          desc = "LSP: " .. desc
        end
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
      end

      nmap("<leader>rn", vim.lsp.buf.rename, "Rename")
      nmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")

      nmap("gd", vim.lsp.buf.definition, "Go to Definition")
      nmap("gr", require("telescope.builtin").lsp_references, "Go to References")
      nmap("gI", vim.lsp.buf.implementation, "Go to Implementation")
      nmap("gD", vim.lsp.buf.declaration, "Go to Declaration")
      nmap("<leader>D", vim.lsp.buf.type_definition, "Type Definition")
      nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
      nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")

      -- See `:help K` for why this keymap
      nmap("K", vim.lsp.buf.hover, "Hover Documentation")
      nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

      -- Lesser used LSP functionality
      nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "Workspace Add Folder")
      nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Workspace Remove Folder")
      nmap("<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, "Workspace List Folders")

      -- Create a command `:Format` local to the LSP buffer
      vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        vim.lsp.buf.format({ async = true })
      end, { desc = "Format current buffer with LSP" })

      nmap("<leader>cf", function()
        vim.lsp.buf.format({ async = true })
      end, "Format")

      -- Show diagnostics in a floating window
      nmap("<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
      
      -- Apply stack-specific settings
      local filetype = vim.bo[bufnr].filetype
      
      -- For GOTH stack
      if filetype == "go" or filetype == "templ" then
        -- Set appropriate options for Go
        if filetype == "go" then
          -- Special Go actions
          nmap("<leader>sgi", "<cmd>GoImports<cr>", "Go Imports")
          nmap("<leader>sgc", "<cmd>GoCoverage<cr>", "Go Coverage")
          nmap("<leader>sgt", "<cmd>GoTest<cr>", "Go Test")
          nmap("<leader>sgm", "<cmd>GoModTidy<cr>", "Go Mod Tidy")
        end
        
        -- For Templ files
        if filetype == "templ" then
          -- Add Templ-specific commands
          vim.api.nvim_buf_create_user_command(bufnr, "TemplFmt", function()
            vim.cmd("!templ fmt " .. vim.fn.expand("%"))
            vim.cmd("e!") -- Reload the file
          end, { desc = "Format Templ file" })
          
          nmap("<leader>stf", "<cmd>TemplFmt<cr>", "Templ Format")
        end
      end
      
      -- For Next.js stack
      if filetype == "javascript" or filetype == "typescript" or filetype == "javascriptreact" or filetype == "typescriptreact" then
        -- Add Next.js specific commands
        if client.name == "tsserver" then
          nmap("<leader>sno", "<cmd>TypescriptOrganizeImports<cr>", "Organize Imports")
          nmap("<leader>snr", "<cmd>TypescriptRenameFile<cr>", "Rename File")
          nmap("<leader>sni", "<cmd>TypescriptAddMissingImports<cr>", "Add Missing Imports")
          nmap("<leader>snu", "<cmd>TypescriptRemoveUnused<cr>", "Remove Unused")
          nmap("<leader>snf", "<cmd>TypescriptFixAll<cr>", "Fix All")
        end
      end
    end

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

    -- Configure diagnostic display
    for name, icon in pairs(opts.diagnostics.signs.text) do
      name = "DiagnosticSign" .. name
      vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
    end
    
    vim.diagnostic.config(opts.diagnostics)

    -- Setup mason so it can manage external tooling
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    })

    -- Enable the following language servers with mason
    local mason_lspconfig = require("mason-lspconfig")

    -- Enable mason-lspconfig integration
    mason_lspconfig.setup({
      ensure_installed = vim.tbl_keys(opts.servers),
      automatic_installation = true,
    })

    -- Add special handling for Templ LSP which may not be in Mason yet
    require("lspconfig")["templ"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    mason_lspconfig.setup_handlers({
      function(server_name)
        local server_opts = opts.servers[server_name] or {}
        server_opts.capabilities = capabilities
        server_opts.on_attach = on_attach

        -- This handles overriding only values explicitly passed
        -- by the server configuration above. Useful when disabling
        -- certain features of an LSP (like formatting)
        if opts.setup[server_name] then
          if opts.setup[server_name](server_name, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server_name, server_opts) then
            return
          end
        end

        require("lspconfig")[server_name].setup(server_opts)
      end,
    })
    
    -- Add handler for turning inlay hints on if it's supported
    vim.api.nvim_create_user_command("ToggleInlayHints", function()
      -- Toggle the global setting
      opts.inlay_hints.enabled = not opts.inlay_hints.enabled
      
      -- Apply to all buffers with active clients
      local buffers = vim.api.nvim_list_bufs()
      for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
          for _, client in ipairs(clients) do
            if client.supports_method("textDocument/inlayHint") then
              if opts.inlay_hints.enabled then
                require("lsp-inlayhints").on_attach(client, bufnr)
              else
                require("lsp-inlayhints").disable()
              end
            end
          end
        end
      end
      
      vim.notify("Inlay hints " .. (opts.inlay_hints.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle inlay hints" })
    
    -- Add command to restart all LSPs
    vim.api.nvim_create_user_command("LspRestart", function()
      vim.lsp.stop_client(vim.lsp.get_active_clients())
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
      vim.lsp.stop_client(vim.lsp.get_active_clients({
        name = { "gopls", "templ", "html" }
      }))
      vim.cmd("edit")
    end, { desc = "Configure LSP for GOTH stack" })
    
    vim.api.nvim_create_user_command("LspNextJS", function()
      -- Specifically focus on Next.js stack capabilities
      vim.g.current_stack = "nextjs"
      vim.notify("LSP settings optimized for Next.js stack", vim.log.levels.INFO)
      
      -- Adjust any specific settings if needed
      require("lspconfig").tsserver.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = opts.servers.tsserver.settings,
      })
      
      require("lspconfig").tailwindcss.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = opts.servers.tailwindcss.settings,
      })
      
      -- Restart relevant servers
      vim.lsp.stop_client(vim.lsp.get_active_clients({
        name = { "tsserver", "eslint", "tailwindcss", "cssls" }
      }))
      vim.cmd("edit")
    end, { desc = "Configure LSP for Next.js stack" })
  end,
}
