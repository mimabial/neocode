-- lua/plugins/treesitter.lua
-- Treesitter, rainbow delimiters, autotag, and autopairs integrations
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build   = ":TSUpdate",
    event   = { "BufReadPost", "BufNewFile" },
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
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<C-space>", desc = "Increment selection" },
      { "<BS>", mode = "x", desc = "Decrement selection" },
    },
    opts = {
      ensure_installed = {
        "bash","c","cpp","css","diff","dockerfile","go","gomod","gosum","gowork",
        "graphql","html","javascript","jsdoc","json","jsonc","lua","luadoc","luap",
        "markdown","markdown_inline","prisma","python","query","regex","rust","scss",
        "sql","svelte","terraform","toml","tsx","typescript","vim","vimdoc","yaml",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection    = "<C-space>",
          node_incremental  = "<C-space>",
          scope_incremental = false,
          node_decremental  = "<BS>",
        },
      },
      textobjects = {
        select = {
          enable    = true,
          lookahead = true,
          keymaps   = {
            -- capture group-based selections
            af = "@function.outer", ["if"] = "@function.inner",
            ac = "@class.outer",    ic = "@class.inner",
            aP = "@parameter.outer", iP = "@parameter.inner",
            aa = "@assignment.outer", ia = "@assignment.inner",
            ai = "@conditional.outer", ii = "@conditional.inner",
            al = "@loop.outer",     il = "@loop.inner",
            ab = "@block.outer",    ib = "@block.inner",
            ar = "@return.outer",   ir = "@return.inner",
            aC = "@comment.outer",  iC = "@comment.inner",
          },
        },
        move = {
          enable    = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer", ["]c"] = "@class.outer",
            ["]i"] = "@conditional.outer", ["]l"] = "@loop.outer",
            ["]s"] = { query = "@scope",      query_group = "locals" },
            ["]z"] = { query = "@fold",       query_group = "folds" },
          },
          goto_next_end = {
            ["]F"] = "@function.outer", ["]C"] = "@class.outer",
            ["]I"] = "@conditional.outer", ["]L"] = "@loop.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer", ["[c"] = "@class.outer",
            ["[i"] = "@conditional.outer", ["[l"] = "@loop.outer",
            ["[s"] = { query = "@scope",      query_group = "locals" },
            ["[z"] = { query = "@fold",       query_group = "folds" },
          },
          goto_previous_end = {
            ["[F"] = "@function.outer", ["[C"] = "@class.outer",
            ["[I"] = "@conditional.outer", ["[L"] = "@loop.outer",
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
      -- remove duplicates in ensure_installed
      local seen = {}
      opts.ensure_installed = vim.tbl_filter(function(lang)
        if seen[lang] then return false end
        seen[lang] = true
        return true
      end, opts.ensure_installed)

      -- setup TS
      require("nvim-treesitter.configs").setup(opts)

      -- rainbow-delimiters
      vim.g.rainbow_delimiters = {
        strategy = { [""] = require("rainbow-delimiters.strategy").global, vim = require("rainbow-delimiters.strategy").local },
        query    = { [""] = "rainbow-delimiters", lua = "rainbow-blocks" },
        highlight = { "RainbowDelimiterRed","RainbowDelimiterYellow","RainbowDelimiterBlue" },
      }

      -- templ parser support
      local parsers = require("nvim-treesitter.parsers").get_parser_configs()
      if not parsers.templ then
        parsers.templ = {
          install_info = { url = "https://github.com/vrischmann/tree-sitter-templ.git", files = {"src/parser.c","src/scanner.c"} },
          filetype = "templ",
        }
      end
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = {"nvim-treesitter/nvim-treesitter", "hrsh7th/nvim-cmp"},
    opts = { check_ts = true, ts_config = { lua = {"string"}, javascript = {"template_string"} }, disable_filetype = {"TelescopePrompt"} },
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
      local cmp = require("cmp")
      local cmp_pairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_pairs.on_confirm_done())
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = {"nvim-treesitter/nvim-treesitter"},
    config = function()
      require("nvim-ts-autotag").setup({
        filetypes = {"html","xml","javascriptreact","typescriptreact","svelte","vue","jsx","tsx","templ"},
      })
    end,
  },
}
