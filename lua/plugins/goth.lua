-- Configuration for GOTH stack (Go, Templ, HTMX)
return {
  -- Templ syntax support
  {
    "joerdav/templ.vim",
    ft = "templ",
  },
  
  -- Go Support
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lsp_cfg = true,
      lsp_on_attach = function(client, bufnr)
        -- Add specific Go keymaps here if needed
        local wk = require("which-key")
        wk.register({
          ["<leader>cg"] = {
            name = "Go Tools",
            a = { "<cmd>GoAddTag<cr>", "Add Tags" },
            d = { "<cmd>GoClearTag<cr>", "Clear Tags" },
            e = { "<cmd>GoIfErr<cr>", "Add if err" },
            f = { "<cmd>GoFillStruct<cr>", "Fill Struct" },
            s = { "<cmd>GoFillSwitch<cr>", "Fill Switch" },
            t = { "<cmd>GoTestFunc<cr>", "Test Function" },
            T = { "<cmd>GoTestFile<cr>", "Test File" },
            i = { "<cmd>GoImpl<cr>", "Implement Interface" },
          },
        }, { buffer = bufnr })
      end,
      lsp_document_formatting = true,
      lsp_inlay_hints = {
        enable = true,
      },
      luasnip = true, -- set to false if you don't use LuaSnip
      trouble = true, -- set to true if you use trouble.nvim
      diagnostic = {
        hdlr = true, -- hook lsp diagnostic handler
        underline = true,
        virtual_text = true,
        signs = true,
        update_in_insert = false,
      },
      dap_debug = true,
      dap_debug_gui = true,
      gocoverage_sign = "█",
      goimport = "gopls", -- goimport command, can be gopls[default] or goimport
      gotests_template = "", -- sets gotests -template parameter (check gotests for details)
      gotests_template_dir = "", -- sets gotests -template_dir parameter (check gotests for details)
      comment_placeholder = "   ",
      icons = { breakpoint = "🧘", currentpos = "🏃" }, -- set to false if you don't use icons
      sign_priority = 5, -- change to a higher number to override other signs
      goto_definition_commands = {
        edit = "e",
        split = "s",
        vsplit = "v",
        tab = "t",
        tabe = "t", -- same as tab
      },
      test_runner = "go", -- one of {`go`, `richgo`, `dlv`, `ginkgo`, `gotestsum`}
      verbose_tests = true, -- set to false to disable verbose output when running tests
      run_in_floaterm = false, -- set to true to run tests in a float window
    },
    event = { "CmdlineEnter", "BufReadPost", "BufNewFile" },
    ft = { "go", "gomod", "gosum", "gowork", "gotmpl", "gohtmltmpl", "templ" },
    config = function(_, opts)
      require("go").setup(opts)
    end,
    build = ':lua require("go.install").update_all_sync()',
  },
  
  -- Templ LSP support
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        templ = {
          -- Configure templ language server
          filetypes = { "templ" },
        },
        gopls = {
          -- Enhanced gopls configuration for Go templates
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
      },
    },
  },
  
  -- HTMX-specific tools
  {
    "windwp/nvim-ts-autotag",
    opts = {
      filetypes = { "html", "jsx", "tsx", "templ", "svelte", "vue", "rescript" },
      skip_tags = {
        "area", "base", "br", "col", "command", "embed", "hr", "img", "slot",
        "input", "keygen", "link", "meta", "param", "source", "track", "wbr"
      },
    },
  },
  
  -- Tailwind CSS integration (common in HTMX projects)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    },
    opts = function(_, opts)
      -- Add tailwindcss completion formatting
      local format_kinds = opts.formatting.format
      opts.formatting.format = function(entry, item)
        format_kinds(entry, item)
        return require("tailwindcss-colorizer-cmp").formatter(entry, item)
      end
    end,
  },
  
  -- Treesitter configuration for HTML and HTMX
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "html", "css", "go", "gomod", "gosum", "gowork", "templ"
        })
      end
      
      -- Add custom query for HTMX attributes
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.templ = {
        install_info = {
          url = "https://github.com/vrischmann/tree-sitter-templ.git",
          files = {"src/parser.c", "src/scanner.c"},
          branch = "master",
        },
        filetype = "templ",
      }
    end,
  },
  
  -- Set up specific formatter for Go/Templ/HTMX
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        templ = { "templ" },
        go = { "gofumpt", "goimports" },
      },
      formatters = {
        templ = {
          command = "templ",
          args = { "fmt", "$FILENAME" },
          stdin = false,
        },
        gofumpt = {
          command = "gofumpt",
          args = { "-l", "-w", "$FILENAME" },
          stdin = false,
        },
      },
    },
  },
  
  -- Add HTMX snippets
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      
      -- HTMX snippets
      ls.add_snippets("html", {
        s("hx-get", {
          t('hx-get="'),
          i(1, "/path"),
          t('"'),
        }),
        s("hx-post", {
          t('hx-post="'),
          i(1, "/path"),
          t('"'),
        }),
        s("hx-trigger", {
          t('hx-trigger="'),
          i(1, "event"),
          t('"'),
        }),
        s("hx-swap", {
          t('hx-swap="'),
          i(1, "innerHTML"),
          t('"'),
        }),
        s("hx-target", {
          t('hx-target="'),
          i(1, "#id"),
          t('"'),
        }),
      })
      
      -- Add the same snippets to templ files
      ls.filetype_extend("templ", { "html", "javascript" })
    end,
  },
  
  -- Show HTML preview (useful for HTMX development)
  {
    "turbio/bracey.vim",
    build = "npm install --prefix server",
    cmd = { "Bracey", "BraceyStop", "BraceyReload" },
  },
}
