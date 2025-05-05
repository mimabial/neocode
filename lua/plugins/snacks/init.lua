-- lua/plugins/snacks/init.lua (UPDATED)

-- Main snacks.nvim configuration with added safeguards
local dashboard_cfg = require("plugins.snacks.dashboard")
local dim_cfg = require("plugins.snacks.dim")
local input_cfg = require("plugins.snacks.input")
local picker_cfg = require("plugins.snacks.picker")

return {
  "folke/snacks.nvim",
  lazy = false, -- Load immediately
  priority = 900, -- Higher priority
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
        -- Add pcall for safety
        pcall(function()
          require("snacks.dashboard").open()
        end)
      end,
      desc = "Open Dashboard",
    },
  },
  config = function(_, opts)
    -- Safe initialization with error handling
    local ok, snacks = pcall(require, "snacks")
    if not ok then
      vim.notify("Failed to load snacks.nvim: " .. tostring(snacks), vim.log.levels.ERROR)
      return
    end

    -- Setup with error handling
    local setup_ok, setup_err = pcall(function()
      snacks.setup(opts)
    end)

    if not setup_ok then
      vim.notify("Error setting up snacks.nvim: " .. tostring(setup_err), vim.log.levels.ERROR)
      return
    end

    -- Only set ui.input if snacks.input is available
    if opts.input.enabled and snacks.input then
      vim.ui.input = snacks.input
    end

    -- Create dashboard command with error handling
    vim.api.nvim_create_user_command("Dashboard", function()
      pcall(function()
        require("snacks.dashboard").open()
      end)
    end, { desc = "Open Snacks Dashboard" })
  end,
}
