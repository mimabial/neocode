return {
  "folke/tokyonight.nvim",
  lazy = true,
  priority = 900, -- Load before other plugins but after gruvbox-material
  opts = {
    style = "storm", -- Options: storm, moon, night, day
    light_style = "day",
    transparent = false,
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      sidebars = "dark",
      floats = "dark",
    },
    sidebars = { "qf", "help", "terminal", "packer", "neo-tree" },
    day_brightness = 0.3,
    hide_inactive_statusline = false,
    dim_inactive = false,
    lualine_bold = false,
    on_colors = function(colors) end,
    on_highlights = function(highlights, colors) end,
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    
    -- Add a command to switch between themes
    vim.api.nvim_create_user_command("ColorSchemeToggle", function()
      local current = vim.g.colors_name
      if current == "gruvbox-material" then
        vim.cmd("colorscheme tokyonight")
        vim.notify("Switched to TokyoNight theme", vim.log.levels.INFO)
      else
        vim.cmd("colorscheme gruvbox-material")
        vim.notify("Switched to Gruvbox Material theme", vim.log.levels.INFO)
      end
    end, { desc = "Toggle between Gruvbox Material and TokyoNight" })
    
    -- Add a keymap to toggle themes
    vim.keymap.set("n", "<leader>ut", "<cmd>ColorSchemeToggle<cr>", { desc = "Toggle Colorscheme" })
  end,
}
