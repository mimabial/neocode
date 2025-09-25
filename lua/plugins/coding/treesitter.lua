-- lua/plugins/treesitter.lua (fixed JSX parser)

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<C-space>", desc = "Increment selection" },
      { "<BS>",      mode = "x",                  desc = "Decrement selection" },
    },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
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
      local ft_to_parser = require("nvim-treesitter.parsers").filetype_to_parsername
      ft_to_parser.javascriptreact = "jsx"
      ft_to_parser.typescriptreact = "tsx"

      -- Main TS setup
      require("nvim-treesitter.configs").setup(opts)

      -- Add custom highlights for JSX
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- JSX highlights
          vim.api.nvim_set_hl(0, "@tag.jsx", { link = "@tag.tsx" })
          vim.api.nvim_set_hl(0, "@tag.delimiter.jsx", { link = "@tag.delimiter.tsx" })
          vim.api.nvim_set_hl(0, "@constructor.jsx", { link = "@constructor.tsx" })
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      max_lines = 8,
      separator = "─",
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)

      local function update_context_highlights()
        local colors = _G.get_ui_colors()
        vim.api.nvim_set_hl(0, "TreesitterContext", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = colors.border })
      end

      -- Initial setup
      update_context_highlights()

      -- Update highlights when colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Delay to ensure theme is fully applied
          vim.defer_fn(update_context_highlights, 100)
        end,
      })
    end,
  },
}
