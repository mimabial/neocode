-- lua/plugins/devicons.lua
return {
  "nvim-tree/nvim-web-devicons",
  lazy = false,
  priority = 100,
  opts = function()
    return {
      -- Override some default icons
      override_by_extension = {
        -- Common files
        -- GOTH stack
        -- Next.js stack
        -- API & data
      },

      override_by_filename = {
        -- Stack-specific files
        -- Next.js files
        -- Common config files
        -- Go & HTMX files
        -- Other important files
      },

      default = true,
    }
  end,
  config = function(_, opts)
    require("nvim-web-devicons").setup(opts)
    -- Force refresh icons
    vim.defer_fn(function()
      require("nvim-web-devicons").refresh()
    end, 100)
  end,
}
