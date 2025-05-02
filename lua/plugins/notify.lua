-- lua/plugins/notify.lua
-- Refactored nvim-notify plugin specification with streamlined setup and utility API
return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  priority = 90,
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
    top_down = true,
    background_colour = "#000000",
    icons = { ERROR = "", WARN = "", INFO = "", DEBUG = "", TRACE = "✎" },
    on_open = function(win)
      -- ensure on top
      vim.api.nvim_win_set_config(win, { zindex = 100 })
      -- apply highlights
      vim.api.nvim_win_set_option(win, "winhighlight", "Normal:NotifyBackground,FloatBorder:NotifyBorder")
      -- block ESC in insert mode
      if vim.fn.mode() == "i" then
        local buf = vim.api.nvim_win_get_buf(win)
        vim.keymap.set("n", "<Esc>", function() end, { buffer = buf, silent = true, nowait = true })
      end
    end,
    on_close = nil,
  },
  init = function()
    -- ensure notify is loaded if noice.nvim isn't used
    if not require("lazy.core.config").spec.plugins["noice.nvim"] then
      require("lazy").load({ plugins = { "nvim-notify" } })
    end
    -- recolor on colorscheme
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("NotifyHighlight", { clear = true }),
      callback = function()
        -- map severities to Gruvbox groups
        local map = {
          Error = "GruvboxRed",
          Warn = "GruvboxYellow",
          Info = "GruvboxBlue",
          Debug = "GruvboxPurple",
          Trace = "GruvboxAqua",
        }
        -- base highlights
        vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#1d2021" })
        vim.api.nvim_set_hl(0, "NotifyBorder", { fg = "#504945" })
        -- severity highlights
        for sev, grp in pairs(map) do
          -- use nvim_get_hl with name to get highlight table
          local ok, sg = pcall(vim.api.nvim_get_hl, 0, { name = grp })
          local col = "#ffffff"
          if ok and sg and sg.foreground then
            col = string.format("#%06x", sg.foreground)
          end
          for _, t in ipairs({ "Border", "Icon", "Title" }) do
            vim.api.nvim_set_hl(0, "Notify" .. sev .. t, { fg = col })
          end
        end
      end,
    })
  end,
  config = function(_, opts)
    local notify = require("notify")
    notify.setup(opts)
    vim.notify = notify

    -- Global notification utilities
    local N = {}
    N.dismiss = function()
      notify.dismiss({ silent = true, pending = true })
    end
    N.notify = function(msg, level, cfg)
      cfg = cfg or {}
      if type(msg) == "table" then
        msg = table.concat(msg, "\n")
      end
      notify(msg, level or vim.log.levels.INFO, cfg)
    end
    for _, lvl in ipairs({ "info", "warn", "error", "debug", "trace" }) do
      N[lvl] = function(msg, cfg)
        N.notify(msg, vim.log.levels[string.upper(lvl)], cfg)
      end
    end
    _G.N = N
  end,
}
