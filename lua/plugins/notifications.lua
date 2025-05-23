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

      return {
        background_colour = "#000000",
        fps = 60,
        level = vim.log.levels.INFO,
        minimum_width = 30,
        timeout = notification_config.timeout or 2000,
        max_width = notification_config.max_width or 60,
        max_height = notification_config.max_height or 10,
        stages = notification_config.stages or "fade",
        render = "wrapped-compact",
        top_down = true,
        -- Use single border style
        on_open = function(win)
          -- Set border highlight and border style if possible
          pcall(function()
            vim.api.nvim_win_set_config(win, {
              border = "single",
            })
            -- Set border highlight to match the theme
            vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:NotifyBackground,FloatBorder:NotifyBorder")
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

      -- Setup with error handling
      local setup_ok, err = pcall(function()
        notify.setup(opts)
        -- Override vim.notify with plugin's notification function
        vim.notify = notify
      end)

      if not setup_ok then
        vim.notify("[ERROR] Failed to setup notify: " .. tostring(err), vim.log.levels.ERROR)
        return
      end

      -- Set up colorscheme-dependent highlighting
      local function update_notify_highlights()
        -- Wait for colorscheme to be ready
        if not vim.g.colors_name then
          vim.defer_fn(update_notify_highlights, 50)
          return
        end

        -- Get current theme colors
        local colors = _G.get_ui_colors and _G.get_ui_colors()
          or {
            bg = "#282828",
            red = "#ea6962",
            yellow = "#d8a657",
            blue = "#7daea3",
            green = "#89b482",
            purple = "#d3869b",
            border = "#665c54",
            gray = "#928374",
          }

        -- Set notification highlights to match theme
        vim.api.nvim_set_hl(0, "NotifyERROR", { fg = colors.red })
        vim.api.nvim_set_hl(0, "NotifyWARN", { fg = colors.yellow })
        vim.api.nvim_set_hl(0, "NotifyINFO", { fg = colors.blue })
        vim.api.nvim_set_hl(0, "NotifyDEBUG", { fg = colors.gray })
        vim.api.nvim_set_hl(0, "NotifyTRACE", { fg = colors.purple })
        vim.api.nvim_set_hl(0, "NotifyBorder", { fg = colors.border })
        vim.api.nvim_set_hl(0, "NotifyBackground", { bg = colors.bg })

        -- Make sure notification title and background match theme too
        vim.api.nvim_set_hl(0, "NotifyERRORTitle", { fg = colors.red, bg = colors.bg })
        vim.api.nvim_set_hl(0, "NotifyWARNTitle", { fg = colors.yellow, bg = colors.bg })
        vim.api.nvim_set_hl(0, "NotifyINFOTitle", { fg = colors.blue, bg = colors.bg })
        vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { fg = colors.gray, bg = colors.bg })
        vim.api.nvim_set_hl(0, "NotifyTRACETitle", { fg = colors.purple, bg = colors.bg })

        -- Set notification content background
        vim.api.nvim_set_hl(0, "NotifyERRORBody", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "NotifyWARNBody", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "NotifyINFOBody", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "NotifyDEBUGBody", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "NotifyTRACEBody", { bg = colors.bg })

        -- Update borders for existing notification windows
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "notify" then
              vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:NotifyBackground,FloatBorder:NotifyBorder")
            end
          end
        end
      end

      -- Delay initial highlight setup to ensure colorscheme is loaded
      vim.defer_fn(update_notify_highlights, 50)

      -- Update highlights when colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.defer_fn(update_notify_highlights, 10)
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
    priority = 400, -- Lower than notify
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

      -- Ensure consistent single border
      local border = "single"
      local float_config = vim.tbl_deep_extend("force", {
        border = border,
        padding = { 0, 1 },
        max_width = 80,
        max_height = 20,
      }, ui_config.float or {})

      -- Make sure border is always single
      float_config.border = border

      return {
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
            cmdline = { pattern = "^:", icon = ":", lang = "vim", title = "" },
            search_down = { kind = "search", pattern = "^/", icon = "/", lang = "regex", title = "" },
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
        if opts.messages and opts.messages.view then
          opts.messages.view_history = "messages"
          opts.messages.view_search = "virtualtext"
        end

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

      -- Update highlights for Noice elements
      local function update_noice_highlights()
        -- Wait for colorscheme to be ready
        if not vim.g.colors_name then
          vim.defer_fn(update_noice_highlights, 50)
          return
        end

        -- Get colors from central UI config if available
        local colors = _G.get_ui_colors and _G.get_ui_colors()
          or {
            bg = "#282828",
            red = "#ea6962",
            yellow = "#d8a657",
            blue = "#7daea3",
            border = "#665c54",
          }

        -- Set highlights directly
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = colors.border })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = colors.blue, bold = true })
        vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = colors.border })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", { fg = colors.border })
        vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch", { fg = colors.yellow })

        -- Notification type highlights
        vim.api.nvim_set_hl(0, "NoiceError", { fg = colors.red })
        vim.api.nvim_set_hl(0, "NoiceErrorTitle", { fg = colors.red, bold = true })
        vim.api.nvim_set_hl(0, "NoiceWarning", { fg = colors.yellow })
        vim.api.nvim_set_hl(0, "NoiceWarningTitle", { fg = colors.yellow, bold = true })
        vim.api.nvim_set_hl(0, "NoiceInfo", { fg = colors.blue })
        vim.api.nvim_set_hl(0, "NoiceInfoTitle", { fg = colors.blue, bold = true })

        -- Ensure popup background matches theme
        vim.api.nvim_set_hl(0, "NoicePopup", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "NoicePopupmenu", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "NoicePopupBorder", { fg = colors.border })
        vim.api.nvim_set_hl(0, "NoicePopupTitle", { fg = colors.blue, bold = true })
      end

      -- Delay initial highlight setup to ensure colorscheme is loaded
      vim.defer_fn(update_noice_highlights, 75)

      -- Update highlights when colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.defer_fn(update_noice_highlights, 10)
        end,
      })
    end,
  },
}
