return {
  "rcarriga/nvim-notify",
  keys = {
    {
      "<leader>un",
      function()
        require("notify").dismiss({ silent = true, pending = true })
      end,
      desc = "Dismiss all notifications",
    },
  },
  opts = {
    timeout = 3000,
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.75)
    end,
    render = "default",
    stages = "fade",
    background_colour = "#000000",
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 100 })
    end,
  },
  init = function()
    -- Set the highlight colors for notifications to match gruvbox-material
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        -- Set color scheme specific highlight groups for notify
        local success_bg = vim.api.nvim_get_hl(0, { name = "GruvboxGreen" }).fg or "#89b482"
        local error_bg = vim.api.nvim_get_hl(0, { name = "GruvboxRed" }).fg or "#ea6962"
        local warn_bg = vim.api.nvim_get_hl(0, { name = "GruvboxYellow" }).fg or "#d8a657"
        local info_bg = vim.api.nvim_get_hl(0, { name = "GruvboxBlue" }).fg or "#7daea3"
        local debug_bg = vim.api.nvim_get_hl(0, { name = "GruvboxPurple" }).fg or "#d3869b"
        local trace_bg = vim.api.nvim_get_hl(0, { name = "GruvboxAqua" }).fg or "#89b482"

        vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = error_bg })
        vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = warn_bg })
        vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = info_bg })
        vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = debug_bg })
        vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = trace_bg })
        vim.api.nvim_set_hl(0, "NotifyERRORIcon", { fg = error_bg })
        vim.api.nvim_set_hl(0, "NotifyWARNIcon", { fg = warn_bg })
        vim.api.nvim_set_hl(0, "NotifyINFOIcon", { fg = info_bg })
        vim.api.nvim_set_hl(0, "NotifyDEBUGIcon", { fg = debug_bg })
        vim.api.nvim_set_hl(0, "NotifyTRACEIcon", { fg = trace_bg })
        vim.api.nvim_set_hl(0, "NotifyERRORTitle", { fg = error_bg })
        vim.api.nvim_set_hl(0, "NotifyWARNTitle", { fg = warn_bg })
        vim.api.nvim_set_hl(0, "NotifyINFOTitle", { fg = info_bg })
        vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { fg = debug_bg })
        vim.api.nvim_set_hl(0, "NotifyTRACETitle", { fg = trace_bg })
      end,
    })
  end,
  config = function(_, opts)
    require("notify").setup(opts)
    vim.notify = require("notify")
  end,
}
