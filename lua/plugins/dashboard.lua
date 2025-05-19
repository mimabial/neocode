-- lua/plugins/alpha.lua
return {
  "goolord/alpha-nvim",
  event = function()
    -- Only load for empty buffers at startup
    if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
      return "VimEnter"
    end
  end,
  cmd = "Alpha", -- Also load on command
  enabled = true,
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Set header
    dashboard.section.header.val = {
      "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
      "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
      "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
      "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
      "",
      "   FullStack Developer Edition",
    }

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find File", ":Telescope find_files <CR>"),
      dashboard.button("e", "  New File", ":ene <BAR> startinsert <CR>"),
      dashboard.button("r", "  Recent Files", ":Telescope oldfiles <CR>"),
      dashboard.button("t", "  Find Text", ":Telescope live_grep <CR>"),
      dashboard.button("g", "  GOTH Stack", ":StackFocus goth<CR>"),
      dashboard.button("n", "  Next.js Stack", ":StackFocus nextjs<CR>"),
      dashboard.button("s", "  Settings", ":e $MYVIMRC <CR>"),
      dashboard.button("l", "  Lazy", ":Lazy<CR>"),
      dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
    }

    -- Add current stack indication
    local stack_section = {
      type = "text",
      val = function()
        local stack = vim.g.current_stack or "Not Selected"
        local icon = "⚒️"

        if stack == "goth" then
          icon = "󰟓 "
          stack = "GOTH Stack (Go/Templ/HTMX)"
        elseif stack == "nextjs" then
          icon = " "
          stack = "Next.js Stack (React/TypeScript)"
        end

        return icon .. " Current Stack: " .. stack
      end,
      opts = {
        position = "center",
        hl = function()
          local stack = vim.g.current_stack or ""
          if stack == "goth" then
            return "String"
          elseif stack == "nextjs" then
            return "Function"
          else
            return "Comment"
          end
        end,
      },
    }

    -- Add stats section
    local stats_section = {
      type = "text",
      val = function()
        local stats = require("lazy").stats()
        return "⚡ "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins loaded in "
          .. (math.floor(stats.startuptime * 100 + 0.5) / 100)
          .. "ms"
      end,
      opts = {
        position = "center",
        hl = "Comment",
      },
    }

    -- Insert stack and stats sections
    table.insert(dashboard.config.layout, { type = "padding", val = 1 })
    table.insert(dashboard.config.layout, stack_section)
    table.insert(dashboard.config.layout, { type = "padding", val = 1 })
    table.insert(dashboard.config.layout, stats_section)

    -- Set footer
    dashboard.section.footer.val = "Press q to close"
    dashboard.section.footer.opts.hl = "NonText"

    -- Set colors based on theme
    local function get_colors()
      local ok, colors = pcall(function()
        if _G.get_ui_colors then
          return _G.get_ui_colors()
        end
        return {
          blue = "#7daea3",
          green = "#89b482",
          purple = "#d3869b",
          red = "#ea6962",
          yellow = "#d8a657",
        }
      end)
      return ok and colors or {}
    end

    local colors = get_colors()

    dashboard.section.header.opts.hl = "Title"
    dashboard.section.buttons.opts.hl = "Function"

    alpha.setup(dashboard.config)

    -- Add keymap for dashboard
    vim.keymap.set("n", "<leader>d", ":Alpha<CR>", { desc = "Open Dashboard" })

    -- Set up autocommand to keep dashboard visible
    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = function()
        vim.cmd("set showtabline=0")
        -- Clean up empty buffers
        vim.api.nvim_create_autocmd("BufUnload", {
          buffer = 0,
          once = true,
          callback = function()
            vim.cmd("set showtabline=2")
          end,
        })
      end,
    })
  end,
}
