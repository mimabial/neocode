return {
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      background_colour = "#000000",
      timeout = 1000,
      stages = "fade",
      render = "wrapped-compact",
      minimum_width = 30,
      max_width = 80,
      max_height = 20,
      top_down = true,
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "",
      },
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100, border = "single" })
      end,
    },
    init = function()
      local notify = require("notify")
      -- Filter Codeium network errors
      vim.notify = function(msg, level, opts)
        if type(msg) == "string" and msg:match("Codeium.*request failed") then
          return
        end
        notify(msg, level, opts)
      end
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },

    keys = {
      {
        "<leader>nl",
        "<cmd>Noice last<cr>",
        desc = "Noice Last Message",
      },
      {
        "<leader>nh",
        "<cmd>Noice history<cr>",
        desc = "Noice History",
      },
      {
        "<leader>na",
        "<cmd>Noice<cr>",
        desc = "Noice All Messages",
      },
      {
        "<leader>nd",
        "<cmd>Noice dismiss<cr>",
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
      commands = {
        history = {
          view = "popup",
          opts = { enter = true, format = "details" },
        },
        last = {
          view = "popup",
          opts = { enter = true, format = "details" },
        },
        all = {
          view = "popup",
          opts = { enter = true, format = "details" },
        },
      },
      cmdline = {
        opts = {
          border = {
            style = "single",
            padding = { 0, 1 },
          },
          position = { row = "30%", col = "50%" },
          size = { width = 60, height = "auto" },
        },
        format = {
          cmdline = { pattern = "^:", icon = ":", lang = "vim", title = "" },
          search_down = { kind = "search", pattern = "^/", icon = "/", lang = "regex", title = "" },
          search_up = { kind = "search", pattern = "^%?", icon = "?", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "!", lang = "bash" },
          help = { pattern = "^:%s*he?l?p?", icon = "??" },
        },
        mappings = {
          n = {
            ["<Esc>"] = "close",
          },
        },
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = {
          opts = { border = "single" },
        },
        signature = {
          opts = { border = "single" },
        },
        message = {
          opts = { border = "single" },
        },
        documentation = {
          view = "hover",
          opts = {
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
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
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
        popup = {
          position = {
            row = "100%",
            col = "50%",
          },
          size = {
            width = "95%",
            height = "50%",
          },
          border = {
            style = "single",
          },
          win_options = {
            wrap = true,
            linebreak = true,
          },
        },
      },
    },

    config = function(_, opts)
      require("noice").setup(opts)

      -- Note: Auto-close is handled by lib/autoclose.lua

      local function update_highlights()
        local colors = require("config.ui").get_colors()
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
