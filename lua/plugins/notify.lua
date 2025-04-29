return {
  "rcarriga/nvim-notify",
  event = "VeryLazy", -- Load earlier to ensure it's available for plugins that need it
  priority = 90,      -- High priority to ensure it loads before depending plugins
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
    render = "default", -- Options: default, minimal, simple, compact
    stages = "fade", -- Options: fade, slide, fade_in_slide_out, static
    top_down = true,
    background_colour = "#000000",
    icons = {
      ERROR = "",
      WARN = "",
      INFO = "",
      DEBUG = "",
      TRACE = "✎",
    },
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 100 })
      -- Set window options for better look in gruvbox-material
      vim.api.nvim_win_set_option(win, "winhighlight", "Normal:NotifyBackground,FloatBorder:NotifyBorder")
      
      -- Prevent closing notifications with ESC when in insert mode
      if vim.fn.mode() == "i" then
        vim.keymap.set("n", "<Esc>", function() end, { buffer = vim.fn.bufnr(), noremap = true, silent = true, nowait = true })
      end
    end,
    on_close = function() end,
  },
  init = function()
    -- When noice is not enabled, install notify on VeryLazy
    if not require("lazy.core.config").spec.plugins["noice.nvim"] then
      require("lazy").load({ plugins = { "nvim-notify" } })
    end
    
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
        
        -- Create better looking notifications with gruvbox colors
        vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#1d2021" })
        vim.api.nvim_set_hl(0, "NotifyBorder", { fg = "#504945" })
        
        -- Error notifications
        vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = error_bg })
        vim.api.nvim_set_hl(0, "NotifyERRORIcon", { fg = error_bg })
        vim.api.nvim_set_hl(0, "NotifyERRORTitle", { fg = error_bg })
        
        -- Warning notifications
        vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = warn_bg })
        vim.api.nvim_set_hl(0, "NotifyWARNIcon", { fg = warn_bg })
        vim.api.nvim_set_hl(0, "NotifyWARNTitle", { fg = warn_bg })
        
        -- Info notifications
        vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = info_bg })
        vim.api.nvim_set_hl(0, "NotifyINFOIcon", { fg = info_bg })
        vim.api.nvim_set_hl(0, "NotifyINFOTitle", { fg = info_bg })
        
        -- Debug notifications
        vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = debug_bg })
        vim.api.nvim_set_hl(0, "NotifyDEBUGIcon", { fg = debug_bg })
        vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { fg = debug_bg })
        
        -- Trace notifications
        vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = trace_bg })
        vim.api.nvim_set_hl(0, "NotifyTRACEIcon", { fg = trace_bg })
        vim.api.nvim_set_hl(0, "NotifyTRACETitle", { fg = trace_bg })
      end,
    })
  end,
  config = function(_, opts)
    local notify = require("notify")
    notify.setup(opts)
    vim.notify = notify
    
    -- Create special utility functions for notifications
    local utils = {}
    
    -- Custom notification function with title support
    utils.notify = function(message, level, opts)
      opts = opts or {}
      level = level or vim.log.levels.INFO
      
      -- Allow passing a table of messages
      if type(message) == "table" then
        message = table.concat(message, "\n")
      end
      
      -- Create a title if specified
      local title = opts.title
      if title then
        message = title .. "\n" .. message
      end
      
      -- Set timeout from opts
      local timeout = opts.timeout or 3000
      
      -- Show notification
      notify(message, level, {
        title = opts.title,
        timeout = timeout,
        icon = opts.icon,
      })
    end
    
    -- Helper functions for different notification types
    utils.info = function(message, opts)
      utils.notify(message, vim.log.levels.INFO, opts)
    end
    
    utils.warn = function(message, opts)
      utils.notify(message, vim.log.levels.WARN, opts)
    end
    
    utils.error = function(message, opts)
      utils.notify(message, vim.log.levels.ERROR, opts)
    end
    
    utils.debug = function(message, opts)
      utils.notify(message, vim.log.levels.DEBUG, opts)
    end
    
    -- Make these functions globally available
    _G.NotifyUtils = utils
  end,
}
