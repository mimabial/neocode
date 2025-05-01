-- Main snacks.nvim configuration

local dashboard_cfg = require("plugins.snacks.dashboard").dashboard
local dim_cfg = require("plugins.snacks.dim").dim
local input_cfg = require("plugins.snacks.input")
local notifier_cfg = require("plugins.snacks.notifier")
local picker_cfg = require("plugins.snacks.picker")

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 800,
  dependencies = {
    { "nvim-tree/nvim-web-devicons", lazy = false, priority = 950 },
    { "nvim-lua/plenary.nvim", lazy = false, priority = 900 },
  },
  -- Import each component's configuration
  opts = {
    dashboard = dashboard_cfg,
    dim = dim_cfg,
    input = input_cfg,
    notifier = notifier_cfg,
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
    -- Set up snacks with all modules
    require("snacks").setup(opts)

    -- Replace built-in vim.ui.input with snacks.input if enabled
    if opts.input and opts.input.enabled then
      vim.ui.input = require("snacks.input").input
    end

    -- Replace built-in vim.notify with snacks.notifier if enabled
    if opts.notifier and opts.notifier.enabled then
      vim.notify = require("snacks.notifier").notify
    end

    -- Create command to open dashboard
    vim.api.nvim_create_user_command("Dashboard", function()
      require("snacks.dashboard").open()
    end, { desc = "Open Snacks Dashboard" })

    -- When opening a directory, show dashboard instead of oil
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if vim.fn.isdirectory(bufname) == 1 then
          -- Cancel any further handling (including oil opening)
          vim.cmd("autocmd! BufEnter")
          -- Open dashboard instead
          vim.schedule(function()
            require("snacks.dashboard").open()
          end)
        end
      end,
      desc = "Open dashboard for directories instead of oil",
    })
  end,
}
