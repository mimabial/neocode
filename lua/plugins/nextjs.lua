-- lua/plugins/nextjs.lua
-- Next.js and TypeScript development enhancements
return {

  -- JSON schema support
  { "b0o/SchemaStore.nvim",                   lazy = true,                       priority = 55 },

  -- Tailwind integration
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "css", "html", "javascript", "typescript", "javascriptreact", "typescriptreact" },
    opts = { user_default_options = { tailwind = true, mode = "background" } },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
    priority = 65,
  },
  { "roobert/tailwindcss-colorizer-cmp.nvim", opts = { color_square_width = 2 }, priority = 60 },

  -- Snippet loader for Next.js snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      -- Ensure paths is a list of strings
      require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
    end,
    priority = 70,
  },
}
