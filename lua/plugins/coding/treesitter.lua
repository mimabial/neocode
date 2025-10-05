return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  keys = {
    { "<C-space>", desc = "Increment selection" },
    { "<BS>",      mode = "x",                  desc = "Decrement selection" },
  },
  opts = {
    ensure_installed = {
      "bash",
      "css",
      "html",
      "hyprlang",
      "javascript",
      "json",
      "lua",
      "markdown",
      "yaml",
      "vim",
      "vimdoc",
      "tsx",
      "typescript",
    },
    highlight = {
      enable = true,
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
        lookahead = true, -- Jump forward to next text object
        keymaps = {
          -- Functions
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          -- Blocks
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          -- Parameters
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]a"] = "@parameter.inner",
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]C"] = "@class.outer",
          ["]A"] = "@parameter.inner",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[a"] = "@parameter.inner",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[C"] = "@class.outer",
          ["[A"] = "@parameter.inner",
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

    -- Register filetypes to parsers mapping
    vim.treesitter.language.register('tsx', 'typescriptreact')
    vim.treesitter.language.register('jsx', 'javascriptreact')

    -- Main TS setup
    require("nvim-treesitter.configs").setup(opts)
  end,
}
