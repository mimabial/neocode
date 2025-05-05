-- lua/plugins/snacks.lua

-- Main snacks.nvim configuration
local dashboard_cfg = require("plugins.snacks.dashboard")
local dim_cfg = require("plugins.snacks.dim")
local input_cfg = require("plugins.snacks.input")
local picker_cfg = require("plugins.snacks.picker")

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 800,
  dependencies = {
    { "nvim-tree/nvim-web-devicons", lazy = false, priority = 950 },
    { "nvim-lua/plenary.nvim", lazy = false, priority = 900 },
  },
  opts = {
    dashboard = dashboard_cfg,
    dim = dim_cfg,
    input = input_cfg,
    picker = picker_cfg,
  },
  keys = {
    {
      "<leader>ud",
      function()
        require("snacks.dashboard").open()
      end,
      desc = "Open Dashboard",
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    if opts.input.enabled then
      vim.ui.input = require("snacks.input").input
    end

    vim.api.nvim_create_user_command("Dashboard", function()
      require("snacks.dashboard").open()
    end, { desc = "Open Snacks Dashboard" })
  end,
}
