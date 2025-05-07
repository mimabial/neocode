-- lua/plugins/notifications.lua
-- Enhanced notifications with consistent styling across all themes

return {
  -- Base notification system
  {
    "rcarriga/nvim-notify",
    lazy = false,
    priority = 500,
    event = "VeryLazy",
    opts = function()
      -- Get UI config if available
      local ui_config = _G.get_ui_config and _G.get_ui_config() or {}
      local notification_config = ui_config.notification or {}

      -- Get colors from UI module
      local colors = _G.get_ui_colors and _G.get_ui_colors()
        or {
          bg = "#000000",
          border = "#665c54",
        }

      return {
        background_colour = colors.bg, -- Use theme background color
        fps = 60,
        level = vim.log.levels.INFO,
        minimum_width = 30,
        timeout = notification_config.timeout or 3000,
        max_width = notification_config.max_width or 60,
        max_height = notification_config.max_height or 10,
        stages = notification_config.stages or "fade",
        render = "wrapped-compact",
        top_down = true,
        -- Use single border style
        on_open = function(win)
          -- Set border highlight and border style if possible
          local success, _ = pcall(function()
            vim.api.nvim_win_set_config(win, {
              border = "single",
            })
            -- Set border highlight to match the theme
            local buf = vim.api.nvim_win_get_buf(win)
            pcall(vim.api.nvim_buf_set_option, buf, "winhl", "FloatBorder:NotifyBorder")
          end)
        end,
        icons = {
          DEBUG = (ui_config.icons and ui_config.icons.diagnostics and ui_config.icons.diagnostics.Hint) or "",
          ERROR = (ui_config.icons and ui_config.icons.diagnostics and ui_config.icons.diagnostics.Error) or "",
          INFO = (ui_config.icons and ui_config.icons.diagnostics and ui_config.icons.diagnostics.Info) or "",
          TRACE = (ui_config.icons and ui_config.icons.diagnostics and ui_config.icons.diagnostics.Info) or "✎",
          WARN = (ui_config.icons and ui_config.icons.diagnostics and ui_config.icons.diagnostics.Warn) or "",
        },
      }
    end,
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify

      -- Set up colorscheme-dependent highlighting
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Get current theme colors using direct color retrieval instead of going through setup
          local colors = _G.get_ui_colors and _G.get_ui_colors()
            or {
              red = "#ea6962",
              yellow = "#d8a657",
              blue = "#7daea3",
              green = "#89b482",
              purple = "#d3869b",
              border = "#665c54",
              gray = "#928374",
            }

          -- Set notification highlights to match theme directly without triggering additional events
          vim.api.nvim_set_hl(0, "NotifyERROR", { fg = colors.red })
          vim.api.nvim_set_hl(0, "NotifyWARN", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "NotifyINFO", { fg = colors.blue })
          vim.api.nvim_set_hl(0, "NotifyDEBUG", { fg = colors.gray or "#928374" })
          vim.api.nvim_set_hl(0, "NotifyTRACE", { fg = colors.purple })
          vim.api.nvim_set_hl(0, "NotifyBorder", { fg = colors.border })

          -- Update borders for existing notification windows without triggering additional events
          pcall(function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == "notify" then
                pcall(vim.api.nvim_win_set_config, win, { border = "single" })
                pcall(vim.api.nvim_buf_set_option, buf, "winhl", "FloatBorder:NotifyBorder")
              end
            end
          end)
        end,
      })
    end,
  },

  -- Advanced notification and UI system
  {
    "folke/noice.nvim",
    enabled = function()
      return not vim.g.use_snacks_ui
    end,
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },

    -- Key mappings for Noice commands and scrolling
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

    -- Plugin-specific options
    opts = function()
      -- Get UI config if available
      local ui_config = _G.get_ui_config and _G.get_ui_config() or {}
      local notification_config = ui_config.notification or {}

      -- Get colors from centralized theme function
      local colors = _G.get_ui_colors and _G.get_ui_colors()
        or {
          bg = "#282828",
          border = "#665c54",
        }

      -- Ensure consistent single border
      local border = "single"
      local float_config = vim.tbl_deep_extend("force", {
        border = border,
        padding = { 0, 1 },
        max_width = 80,
        max_height = 20,
      }, ui_config.float or {})

      return {
        background_colour = colors.bg,
        fps = 60,
        level = vim.log.levels.INFO,
        minimum_width = 30,
        timeout = notification_config.timeout or 3000,
        max_width = notification_config.max_width or 60,
        max_height = notification_config.max_height or 10,
        stages = notification_config.stages or "fade",
        render = "wrapped-compact",

        top_down = true,
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
          opts = {
            position = { row = "30%", col = "50%" },
            size = { width = math.min(60, float_config.max_width or 60), height = "auto" },
            border = {
              style = border,
              padding = float_config.padding or { 0, 1 },
            },
          },
          format = {
            cmdline = { pattern = "^:", icon = " ", lang = "vim", title = "" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex", title = "" },
            search_up = { kind = "search", pattern = "^%?", icon = "? ", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "!", lang = "bash" },
            lua = { pattern = { "^:%s*lua" }, icon = "λ", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?", icon = "?" },
          },
          routes = {
            { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
            { filter = { event = "msg_show", kind = "search_count" }, opts = { view = "virtualtext" } },
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
        commands = {
          history = {
            view = "split",
            opts = { enter = true, format = "details" },
            filter = { any = { { event = "notify" }, { error = true } } },
          },
          last = {
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = { any = { { event = "notify" }, { error = true } } },
            filter_opts = { count = 1 },
          },
          errors = {
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = { error = true },
            filter_opts = { reverse = true },
          },
        },
        notify = {
          enabled = true,
          view = "notify",
        },
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
            silent = false,
            view = nil, -- Use the default options
            opts = { border = border },
          },
          signature = {
            enabled = true,
            auto_open = { enabled = true, trigger = true, luasnip = true, throttle = 50 },
            opts = { border = border },
          },
          message = {
            enabled = true,
            view = "notify",
            opts = { border = border },
          },
          documentation = {
            view = "hover",
            opts = {
              lang = "markdown",
              replace = true,
              render = "plain",
              border = border,
              position = { row = 2, col = 0 },
            },
          },
        },
        markdown = {
          hover = {
            ["|(%S-)|"] = vim.cmd.help,
            ["%[.-%]%((%S-)%)"] = function(url)
              -- Safe fallback if noice.util is not available
              local ok, util = pcall(require, "noice.util")
              if ok and util and util.open then
                return util.open(url)
              else
                -- Fallback: try basic URL opening with system command
                vim.fn.system(string.format("xdg-open %s || open %s", url, url))
                return true
              end
            end,
          },
          highlights = {
            ["|%S-|"] = "@text.reference",
            ["@%S+"] = "@parameter",
            ["^%s*(Parameters:)"] = "@text.title",
          },
        },
        override = {
          ["vim.diagnostic.goto_next"] = false,
          ["vim.diagnostic.goto_prev"] = false,
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          lsp_doc_border = true,
        },
        smart_move = {
          enabled = true,
          excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
        },
        throttle = 1000 / 30,
        views = {
          cmdline_popup = {
            position = { row = 5, col = "50%" },
            size = { width = math.min(60, float_config.max_width or 60), height = "auto" },
            border = { style = border },
          },
          popupmenu = {
            relative = "editor",
            position = { row = 8, col = "50%" },
            size = { width = math.min(60, float_config.max_width or 60), height = 10 },
            border = { style = border, padding = float_config.padding or { 0, 1 } },
          },
          hover = {
            border = { style = border },
            position = { row = 2, col = 0 },
            size = { width = "auto", height = "auto" },
          },
          mini = {
            win_options = {
              winblend = 0,
            },
          },
        },
        routes = {
          { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
          { filter = { event = "msg_show", kind = "search_count" }, opts = { view = "virtualtext" } },
        },
      }
    end,

    -- Setup and custom autocmds
    config = function(_, opts)
      -- stash the current lazyredraw setting
      local was_lazy = vim.opt.lazyredraw:get()

      -- turn off lazyredraw so Noice can render correctly
      vim.opt.lazyredraw = false

      -- Safe loading of noice
      local ok, noice = pcall(require, "noice")
      if not ok then
        vim.notify("[ERROR] Failed to load noice.nvim: " .. tostring(noice), vim.log.levels.ERROR)
        -- restore lazyredraw before bailing
        vim.opt.lazyredraw = was_lazy
        return
      end

      -- Setup noice with error handling
      local setup_ok, err = pcall(function()
        noice.setup(opts)
      end)
      if not setup_ok then
        vim.notify("[ERROR] Failed to setup noice.nvim: " .. tostring(err), vim.log.levels.ERROR)
        vim.opt.lazyredraw = was_lazy
        return
      end

      -- restore the original lazyredraw value
      vim.opt.lazyredraw = was_lazy

      -- Hide Noice for certain filetypes
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("NoiceDisable", { clear = true }),
        pattern = { "neo-tree", "dashboard", "alpha", "lazy" },
        callback = function()
          vim.b.noice_disable = true
        end,
      })

      -- Get colors from central UI config if available
      local get_colors = _G.get_ui_colors
        or function()
          -- Default gruvbox-compatible colors
          return {
            red = "#ea6962",
            yellow = "#d8a657",
            blue = "#7daea3",
            green = "#89b482",
            purple = "#d3869b",
            gray = "#928374",
            border = "#665c54",
          }
        end

      -- Apply consistent highlighting - Direct approach without causing additional events
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local colors = get_colors()

          -- Set highlights directly without any additional setup calls that might trigger events
          vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = colors.border })
          vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = colors.blue, bold = true })
          vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = colors.border })

          -- Notification type highlights
          vim.api.nvim_set_hl(0, "NoiceError", { fg = colors.red })
          vim.api.nvim_set_hl(0, "NoiceWarning", { fg = colors.yellow })
        end,
      })
    end,
  },
}
