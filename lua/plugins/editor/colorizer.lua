return {
  -- Tailwind and CSS color preview
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    keys = {
      { "<leader>uc", "<cmd>ColorizerToggle<cr>", desc = "Toggle Colorizer" },
    },
    opts = {
      filetypes = {
        "*", -- Highlight all files
        "php",
        -- Exclude specific filetypes if needed
        "!lazy",
        "!mason",
        "!bigfile",
      },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = true,
        virtualtext = "■",
      },
    },
  },

  -- Tailwind colorizer for completion menu
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    opts = { color_square_width = 2 },
  },
}
