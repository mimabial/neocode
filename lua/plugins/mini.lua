return {
  -- Text objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
    end,
  },
  {
    "echasnovski/mini.icons",
    lazy = true,
    config = function()
      local icons = require("mini.icons")
      icons.setup()

      -- Update icons with theme colors
      local function update_icon_colors()
        local colors = _G.get_ui_colors()

        -- Apply colors to icon groups
        local icon_hl_groups = {
          MiniIconsDevicons = { fg = colors.blue },
          MiniIconsFiletype = { fg = colors.purple },
          MiniIconsSpinner = { fg = colors.green },
          MiniIconsFolder = { fg = colors.yellow },
          MiniIconsGit = { fg = colors.orange },
          MiniIconsConceal = { fg = colors.blue },
        }

        -- Set highlight groups
        for group, attrs in pairs(icon_hl_groups) do
          vim.api.nvim_set_hl(0, group, attrs)
        end
      end

      -- Update on theme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = update_icon_colors,
      })

      -- Initial color setup
      update_icon_colors()
    end,
  },
}
