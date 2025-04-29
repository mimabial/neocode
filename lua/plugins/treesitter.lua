return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    priority = 50, -- Add priority to ensure it loads early
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      {
        "nvim-treesitter/nvim-treesitter-context",
        opts = { 
          mode = "cursor",
          max_lines = 3,
          trim_scope = "outer", 
          multiline_threshold = 3,
        },
      },
      "HiPhish/rainbow-delimiters.nvim",
      "windwp/nvim-ts-autotag", -- Add as direct dependency
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>", desc = "Decrement selection", mode = "x" },
    },
    opts = {
      highlight = { 
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "diff",
        "dockerfile",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "graphql",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "prisma",
        "python",
        "query",
        "regex",
        "rust",
        "scss",
        "sql",
        "svelte",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      autotag = {
        enable = true, -- Enable nvim-ts-autotag integration
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = { query = "@function.outer", desc = "Select outer part of a function" },
            ["if"] = { query = "@function.inner", desc = "Select inner part of a function" },
            ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
            ["aP"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
            ["iP"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },
            ["aa"] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
            ["ia"] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
            ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
            ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
            ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
            ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
            ["ab"] = { query = "@block.outer", desc = "Select outer part of a block" },
            ["ib"] = { query = "@block.inner", desc = "Select inner part of a block" },
            ["ar"] = { query = "@return.outer", desc = "Select outer part of a return statement" },
            ["ir"] = { query = "@return.inner", desc = "Select inner part of a return statement" },
            ["aC"] = { query = "@comment.outer", desc = "Select outer part of a comment" },
            ["iC"] = { query = "@comment.inner", desc = "Select inner part of a comment" },
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]f"] = { query = "@function.outer", desc = "Next function start" },
            ["]c"] = { query = "@class.outer", desc = "Next class start" },
            ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
            ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
            ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_next_end = {
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]C"] = { query = "@class.outer", desc = "Next class end" },
            ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
            ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
          },
          goto_previous_start = {
            ["[f"] = { query = "@function.outer", desc = "Previous function start" },
            ["[c"] = { query = "@class.outer", desc = "Previous class start" },
            ["[i"] = { query = "@conditional.outer", desc = "Previous conditional start" },
            ["[l"] = { query = "@loop.outer", desc = "Previous loop start" },
            ["[s"] = { query = "@scope", query_group = "locals", desc = "Previous scope" },
            ["[z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
          },
          goto_previous_end = {
            ["[F"] = { query = "@function.outer", desc = "Previous function end" },
            ["[C"] = { query = "@class.outer", desc = "Previous class end" },
            ["[I"] = { query = "@conditional.outer", desc = "Previous conditional end" },
            ["[L"] = { query = "@loop.outer", desc = "Previous loop end" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
        lsp_interop = {
          enable = true,
          border = "rounded",
          floating_preview_opts = {},
          peek_definition_code = {
            ["<leader>pf"] = "@function.outer",
            ["<leader>pF"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      
      -- Ensure parsers are installed first
      require("nvim-treesitter.configs").setup(opts)
      
      -- Setup rainbow delimiters
      local rainbow_delimiters = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
          javascript = "rainbow-delimiters-react",
          tsx = "rainbow-parens",
          typescript = "rainbow-delimiters-react",
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
      
      -- Add specific parsers for GOTH stack
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      
      -- Make sure templ parser is properly configured
      if not parser_config.templ then
        parser_config.templ = {
          install_info = {
            url = "https://github.com/vrischmann/tree-sitter-templ.git",
            files = {"src/parser.c", "src/scanner.c"},
            branch = "master",
          },
          filetype = "templ",
        }
      end
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter", "hrsh7th/nvim-cmp" },
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string" }, -- don't add pairs in lua string treesitter nodes
        javascript = { "template_string" }, -- don't add pairs in javascript template_string
      },
      disable_filetype = { "TelescopePrompt" },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      npairs.setup(opts)

      -- Make autopairs and completion work together
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      
      -- This is recommended by nvim-autopairs
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      -- Add spaces between parentheses
      local Rule = require("nvim-autopairs.rule")
      local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }
      
      -- Add space between brackets
      npairs.add_rules({
        Rule(" ", " ")
          :with_pair(function(opts)
            local pair = opts.line:sub(opts.col - 1, opts.col)
            return vim.tbl_contains({
              brackets[1][1] .. brackets[1][2],
              brackets[2][1] .. brackets[2][2],
              brackets[3][1] .. brackets[3][2],
            }, pair)
          end)
          :with_move(function(opts)
            return opts.prev_char:match(".%]") ~= nil
          end)
          :with_cr(function(opts)
            return false
          end)
          :with_del(function(opts)
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local context = opts.line:sub(col - 1, col + 2)
            return vim.tbl_contains({
              brackets[1][1] .. "  " .. brackets[1][2],
              brackets[2][1] .. "  " .. brackets[2][2],
              brackets[3][1] .. "  " .. brackets[3][2],
            }, context)
          end),
      })
      
      -- Add auto-closing for JSX/TSX
      for _, bracket in pairs(brackets) do
        Rule(bracket[1] .. " ", " " .. bracket[2])
          :with_pair(function()
            return false
          end)
          :with_move(function(opts)
            return opts.char == bracket[2]
          end)
          :with_cr(function()
            return false
          end)
          :with_del(function()
            return false
          end)
          :use_key(bracket[2])
      end
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-ts-autotag").setup({
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
        filetypes = { 
          "html", "xml", "javascript", "typescript", "javascriptreact", 
          "typescriptreact", "svelte", "vue", "tsx", "jsx", "rescript", 
          "php", "markdown", "astro", "glimmer", "handlebars", "hbs", "templ"
        },
        skip_tags = {
          "area", "base", "br", "col", "command", "embed", "hr", "img", "slot",
          "input", "keygen", "link", "meta", "param", "source", "track", "wbr"
        },
      })
    end,
  },
}
