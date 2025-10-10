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

      -- Close Neovim if only Noice windows remain
      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        callback = function()
          local wins = vim.api.nvim_list_wins()
          local normal_wins = 0

          for _, win in ipairs(wins) do
            if vim.api.nvim_win_is_valid(win) then
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.bo[buf].filetype
              local config = vim.api.nvim_win_get_config(win)

              -- Count only normal (non-floating, non-special) windows
              if config.relative == "" and not vim.tbl_contains(
                    { "noice", "notify", "TelescopePrompt", "TelescopeResults" }, ft
                  ) then
                normal_wins = normal_wins + 1
              end
            end
          end

          -- If no normal windows remain, quit
          if normal_wins == 0 then
            vim.cmd("quit")
          end
        end,
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
  }
}
