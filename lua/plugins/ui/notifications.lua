return {
  -- Base notification system
  {
    "rcarriga/nvim-notify",
    lazy = false,
    priority = 500,
    event = "VeryLazy",
    opts = function()
      return {
        background_colour = "#000000",
        fps = 60,
        level = vim.log.levels.INFO,
        minimum_width = 30,
        max_width = 80,
        max_height = 20,
        timeout = 300,
        stages = "fade",
        render = "wrapped-compact",
        top_down = true,
        on_open = function(win)
          vim.api.nvim_win_set_config(win, { border = "single" })
          vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:NotifyBackground,FloatBorder:NotifyBorder")
        end,
        icons = {
          DEBUG = "",
          ERROR = "",
          INFO = "",
          TRACE = "✎",
          WARN = "",
        },
      }
    end,
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  -- Advanced notification and UI system
  {
    "folke/noice.nvim",
    enabled = function()
      return not vim.g.use_snacks_ui
    end,
    event = "VeryLazy",
    priority = 400, -- Lower than notify
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },

    keys = {
      {
        "<leader>nl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Noice Last Message",
      },
      {
        "<leader>nh",
        function()
          require("noice").cmd("history")
        end,
        desc = "Noice History",
      },
      {
        "<leader>na",
        function()
          require("noice").cmd("all")
        end,
        desc = "Noice All Messages",
      },
      {
        "<leader>nd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Dismiss All Messages",
      },
      {
        "<C-f>",
        function()
          local ok, lsp = pcall(require, "noice.lsp")
          if ok and lsp.scroll(4) then
            return
          end
          return "<C-f>"
        end,
        expr = true,
        silent = true,
        desc = "Scroll forward in Noice or fallback",
        mode = { "i", "n", "s" },
      },
      {
        "<C-b>",
        function()
          local ok, lsp = pcall(require, "noice.lsp")
          if ok and lsp.scroll(-4) then
            return
          end
          return "<C-b>"
        end,
        expr = true,
        silent = true,
        desc = "Scroll backward in Noice or fallback",
        mode = { "i", "n", "s" },
      },
    },

    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        opts = {
          position = { row = "30%", col = "50%" },
          size = { width = 60, height = "auto" },
          border = {
            style = "single",
            padding = { 0, 1 },
          },
        },
        format = {
          cmdline = { pattern = "^:", icon = ":", lang = "vim", title = "" },
          search_down = { kind = "search", pattern = "^/", icon = "/", lang = "regex", title = "" },
          search_up = { kind = "search", pattern = "^%?", icon = "? ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "!", lang = "bash" },
          lua = { pattern = { "^:%s*lua" }, icon = "λ", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?", icon = "?" },
        },
      },
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
        kind_icons = {},
      },
      redirect = { view = "popup", filter = { event = "msg_show" } },
      lsp = {
        progress = {
          enabled = true,
          view = "mini",
          throttle = 1000 / 30,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        hover = {
          enabled = true,
          opts = { border = "single" },
        },
        signature = {
          enabled = true,
          auto_open = { enabled = true },
          opts = { border = "single" },
        },
        message = {
          enabled = true,
          view = "notify",
          opts = { border = "single" },
        },
        documentation = {
          view = "hover",
          opts = {
            lang = "markdown",
            replace = true,
            render = "plain",
            border = "single",
          },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
      routes = {
        { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
        { filter = { event = "msg_show", kind = "search_count" },       opts = { view = "virtualtext" } },
      },
      views = {
        cmdline_popup = {
          position = { row = 5, col = "50%" },
          size = { width = 60, height = "auto" },
          border = { style = "single" },
        },
        hover = {
          border = { style = "single" },
          position = { row = 2, col = 0 },
          size = { width = "auto", height = "auto" },
        },
      },
    },

    config = function(_, opts)
      require("noice").setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "neo-tree", "lazy" },
        callback = function() vim.b.noice_disable = true end,
      })

      local function update_highlights()
        local colors = _G.get_ui_colors()
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = colors.border })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = colors.blue, bold = true })
        vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = colors.border })
        vim.api.nvim_set_hl(0, "NoicePopupBorder", { fg = colors.border })
      end

      update_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = update_highlights })
    end,
  },
}
