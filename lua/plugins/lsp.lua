return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for neovim
    { "williamboman/mason.nvim", config = true },
    -- Useful status updates for LSP
    { "j-hui/fidget.nvim", tag = "legacy", opts = {} },
    -- Additional lua configuration specifically for working on neovim config
    { "folke/neodev.nvim" },
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
      },
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
          },
        },
      },
      -- Frontend
      tsserver = {},
      cssls = {},
      tailwindcss = {},
      eslint = {},
      html = {},
      jsonls = {},
      -- Backend
      pyright = {},
      gopls = {},
      rust_analyzer = {},
      -- DevOps
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
    -- Setup neovim lua configuration
    require("neodev").setup()

    -- Setup keymaps when an LSP connects to a buffer
    local on_attach = function(client, bufnr)
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
        vim.lsp.buf.format()
      end, { desc = "Format current buffer with LSP" })

      nmap("<leader>cf", vim.lsp.buf.format, "Format")
      
      -- Show diagnostics in a floating window
      nmap("<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
    end

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

    -- Setup mason so it can manage external tooling
    require("mason").setup()

    -- Enable the following language servers
    local mason_lspconfig = require("mason-lspconfig")

    -- Enable mason-lspconfig integration
    mason_lspconfig.setup({
      ensure_installed = vim.tbl_keys(opts.servers),
      automatic_installation = true,
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

    -- Configure diagnostic display
    vim.diagnostic.config(opts.diagnostics)

    -- Configure signs
    local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
  end,
}
