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
    vim.treesitter.language.register('tsx', 'typescriptreact')
    vim.treesitter.language.register('jsx', 'javascriptreact')

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
}
