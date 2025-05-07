-- lua/plugins/snacks.lua

-- Main snacks.nvim configuration
local dim_cfg = require("plugins.snacks.dim")

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 800,
  dependencies = {
    { "nvim-tree/nvim-web-devicons", lazy = false, priority = 950 },
    { "nvim-lua/plenary.nvim", lazy = false, priority = 900 },
  },
  opts = {
    dim = dim_cfg,
  },
  config = function(_, opts)
    require("snacks").setup(opts)
  end,
}
