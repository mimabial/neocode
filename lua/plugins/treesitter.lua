-- lua/plugins/treesitter.lua
-- Treesitter, rainbow delimiters, autotag, and autopairs integrations
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
      "HiPhish/rainbow-delimiters.nvim", -- Added as explicit dependency
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<C-space>", desc = "Increment selection" },
      { "<BS>", mode = "x", desc = "Decrement selection" },
    },
    opts = {
      ensure_installed = {
        -- Core languages
        "bash",
        "c",
        "cpp",
        "css",
        "diff",
        "dockerfile",
        "lua",
        "luadoc",
        "luap",
        "vim",
        "vimdoc",
        "query",
        -- Web languages
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "scss",
        "graphql",
        "tsx",
        "typescript",
        -- GOTH stack
        "go",
        "gomod",
        "gosum",
        "gowork",
        "templ",
        -- Next.js stack
        "tsx",
        "typescript",
        "javascript",
        "jsx",
        "prisma",
        "regex",
        "markdown",
        "markdown_inline",
        -- Additional useful parsers
        "sql",
        "svelte",
        "terraform",
        "toml",
        "yaml",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "templ" }, -- Enable additional highlighting for templ
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<BS>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- capture group-based selections
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aP"] = "@parameter.outer",
            ["iP"] = "@parameter.inner",
            ["aa"] = "@assignment.outer",
            ["ia"] = "@assignment.inner",
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            ["ar"] = "@return.outer",
            ["ir"] = "@return.inner",
            ["aC"] = "@comment.outer",
            ["iC"] = "@comment.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]i"] = "@conditional.outer",
            ["]l"] = "@loop.outer",
            ["]s"] = { query = "@scope", query_group = "locals" },
            ["]z"] = { query = "@fold", query_group = "folds" },
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]I"] = "@conditional.outer",
            ["]L"] = "@loop.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[i"] = "@conditional.outer",
            ["[l"] = "@loop.outer",
            ["[s"] = { query = "@scope", query_group = "locals" },
            ["[z"] = { query = "@fold", query_group = "folds" },
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[I"] = "@conditional.outer",
            ["[L"] = "@loop.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = { ["<leader>a"] = "@parameter.inner" },
          swap_previous = { ["<leader>A"] = "@parameter.inner" },
        },
        lsp_interop = {
          enable = true,
          border = "rounded",
          peek_definition_code = {
            ["<leader>pf"] = "@function.outer",
            ["<leader>pF"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      -- Remove duplicates in ensure_installed
      local seen = {}
      opts.ensure_installed = vim.tbl_filter(function(lang)
        if seen[lang] then
          return false
        end
        seen[lang] = true
        return true
      end, opts.ensure_installed)

      -- Setup TS
      require("nvim-treesitter.configs").setup(opts)

      -- Rainbow delimiters setup - fail-safe with pcall
      local has_rainbow, rainbow_delimiters = pcall(require, "rainbow-delimiters")
      if has_rainbow then
        vim.g.rainbow_delimiters = {
          strategy = {
            [""] = rainbow_delimiters.strategy.global,
            vim = rainbow_delimiters.strategy["local"],
          },
          query = {
            [""] = "rainbow-delimiters",
            lua = "rainbow-blocks",
            html = "rainbow-tags",
            tsx = "rainbow-tags",
            templ = "rainbow-tags",
          },
          highlight = {
            "RainbowDelimiterRed",
            "RainbowDelimiterYellow",
            "RainbowDelimiterBlue",
            "RainbowDelimiterOrange",
            "RainbowDelimiterGreen",
            "RainbowDelimiterViolet",
            "RainbowDelimiterCyan",
          },
        }
      end

      -- templ parser support
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      if not parser_config.templ then
        parser_config.templ = {
          install_info = {
            url = "https://github.com/vrischmann/tree-sitter-templ.git",
            files = { "src/parser.c", "src/scanner.c" },
            branch = "main",
          },
          filetype = "templ",
        }
      end

      -- Add HTMX attribute highlighting - FIX: use direct references to the parse module instead of local variables
      local parsers = require("nvim-treesitter.parsers")
      if parsers and parsers.filetype_to_parsername then
        parsers.filetype_to_parsername.templ = "templ"
        parsers.filetype_to_parsername.html = "html"
      end

      -- Create HTMX injection for HTML files
      vim.treesitter.query.set(
        "html",
        "injections",
        [[
        ((attribute
          (attribute_name) @_attr_name
          (attribute_value) @injection.content)
         (#match? @_attr_name "^hx-.*$")
         (#set! injection.language "javascript"))
      ]]
      )

      -- Create similar injection for templ files
      vim.treesitter.query.set(
        "templ",
        "injections",
        [[
        ((attribute
          (attribute_name) @_attr_name
          (attribute_value) @injection.content)
         (#match? @_attr_name "^hx-.*$")
         (#set! injection.language "javascript"))
      ]]
      )

      -- Setup custom highlights
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Gruvbox-material compatibility
          if vim.g.colors_name == "gruvbox-material" then
            local colors = _G.get_gruvbox_colors and _G.get_gruvbox_colors()
              or {
                red = "#ea6962",
                orange = "#e78a4e",
                yellow = "#d8a657",
                green = "#89b482",
                blue = "#7daea3",
                purple = "#d3869b",
                cyan = "#89b482",
              }

            vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = colors.red })
            vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = colors.yellow })
            vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = colors.blue })
            vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = colors.orange })
            vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = colors.green })
            vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = colors.purple })
            vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = colors.cyan })

            -- HTMX attribute highlighting
            vim.api.nvim_set_hl(0, "@attribute.htmx", { fg = colors.green, italic = true, bold = true })
            vim.api.nvim_set_hl(0, "@tag.attribute.htmx", { fg = colors.green, italic = true, bold = true })

            -- Go highlights
            vim.api.nvim_set_hl(0, "@type.go", { fg = colors.yellow })
            vim.api.nvim_set_hl(0, "@function.go", { fg = colors.blue })

            -- React/JSX highlights
            vim.api.nvim_set_hl(0, "@tag.tsx", { fg = colors.red })
            vim.api.nvim_set_hl(0, "@tag.delimiter.tsx", { fg = colors.orange })
            vim.api.nvim_set_hl(0, "@constructor.tsx", { fg = colors.purple })
          end
        end,
      })
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter", "hrsh7th/nvim-cmp" },
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
        typescript = { "template_string" },
        go = { "string" },
        templ = { "string" },
      },
      disable_filetype = { "TelescopePrompt" },
    },
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
      local has_cmp, cmp = pcall(require, "cmp")
      if has_cmp then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-ts-autotag").setup({
        filetypes = {
          "html",
          "xml",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "jsx",
          "tsx",
          "templ",
          "erb",
        },
        skip_tags = {
          "area",
          "base",
          "br",
          "col",
          "command",
          "embed",
          "hr",
          "img",
          "input",
          "keygen",
          "link",
          "meta",
          "param",
          "source",
          "track",
          "wbr",
        },
      })
    end,
  },
}
