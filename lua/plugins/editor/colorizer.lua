return {
  -- Tailwind and CSS color preview
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "css", "html", "javascript", "typescript", "javascriptreact", "typescriptreact" },
    opts = {
      user_default_options = {
        tailwind = true,
        mode = "background",
        css = true,
        css_fn = true,
      }
    },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
  },

  -- Tailwind colorizer for completion menu
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    config = function()
      require("tailwindcss-colorizer-cmp").setup({ color_square_width = 2 })
    end,
  },
}
