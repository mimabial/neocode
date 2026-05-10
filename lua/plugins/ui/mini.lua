return {
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
    end,
  },
  {
    "echasnovski/mini.icons",
    lazy = true,
    config = function()
      require("mini.icons").setup()

      local function update_icon_colors()
        local colors = require("config.ui").get_colors()
        local icon_hl_groups = {
          MiniIconsDevicons = { fg = colors.blue },
          MiniIconsFiletype = { fg = colors.purple },
          MiniIconsSpinner = { fg = colors.green },
          MiniIconsFolder = { fg = colors.yellow },
          MiniIconsGit = { fg = colors.orange },
          MiniIconsConceal = { fg = colors.blue },
        }
        for group, attrs in pairs(icon_hl_groups) do
          vim.api.nvim_set_hl(0, group, attrs)
        end
      end

      vim.api.nvim_create_autocmd("ColorScheme", { callback = update_icon_colors })
      update_icon_colors()
    end,
  },
  {
    "echasnovski/mini.starter",
    version = false,
    event = function()
      if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
        return "VimEnter"
      end
    end,
    cmd = "Starter",
    enabled = true,
    opts = function()
      local function header()
        local hour = tonumber(os.date("%H"))
        local greeting = hour < 12 and "Good morning" or hour < 18 and "Good afternoon" or "Good evening"
        return table.concat({
          greeting .. ", " .. vim.fn.expand("$USER"),
          "",
        }, "\n")
      end

      local function footer()
        local stats = require("lazy").stats()
        local v = vim.version()
        return table.concat({
          "",
          string.format("⚡ %d/%d plugins loaded in %.2fms", stats.loaded, stats.count, stats.startuptime),
          string.format("Neovim v%d.%d.%d", v.major, v.minor, v.patch),
          "",
          "Press 'q' to quit • Press '?' for help",
        }, "\n")
      end

      local function build_items()
        local all_items = {}

        vim.list_extend(all_items, {
          { action = "Telescope find_files", name = "Find Files",   section = "Telescope" },
          { action = "Telescope live_grep",  name = "Find Text",    section = "Telescope" },
          { action = "Telescope oldfiles",   name = "Recent Files", section = "Telescope" },
          { action = "Telescope buffers",    name = "Buffers",      section = "Telescope" },
          { action = "Telescope help_tags",  name = "Help Tags",    section = "Telescope" },
          { action = "Telescope commands",   name = "Commands",     section = "Telescope" },
          { action = "Telescope keymaps",    name = "Keymaps",      section = "Telescope" },
        })

        vim.list_extend(all_items, {
          { action = "ene | startinsert", name = "New File",      section = "Files" },
          { action = "Oil",               name = "File Explorer", section = "Files" },
          { action = "e $MYVIMRC",        name = "Edit Config",   section = "Files" },
        })

        vim.list_extend(all_items, {
          ---@diagnostic disable-next-line: different-requires
          {
            action = function()
              require("persistence").load()
            end,
            name = "Restore Session",
            section = "Sessions",
          },
          {
            action = function()
              require("persistence").load({ last = true })
            end,
            name = "Last Session",
            section = "Sessions",
          },
        })

        vim.list_extend(all_items, {
          { action = "LazyGit",      name = "LazyGit",    section = "Git" },
          { action = "Git status",   name = "Git Status", section = "Git" },
          { action = "DiffviewOpen", name = "Diff View",  section = "Git" },
        })

        vim.list_extend(all_items, {
          { action = "Lazy",        name = "Lazy Plugins",   section = "System" },
          { action = "Mason",       name = "Mason Packages", section = "System" },
          { action = "checkhealth", name = "Check Health",   section = "System" },
          { action = "qa",          name = "Quit Neovim",    section = "System" },
        })

        local items = {}
        for i, item in ipairs(all_items) do
          table.insert(items, {
            action = item.action,
            name = string.format("%d. %s", i, item.name),
            section = item.section,
          })
        end
        return items
      end

      return {
        header = header(),
        items = build_items(),
        footer = footer(),
      }
    end,

    config = function(_, opts)
      local starter = require("mini.starter")
      starter.setup(opts)

      local function set_starter_highlights()
        local colors = require("config.ui").get_colors()
        vim.api.nvim_set_hl(0, "MiniStarterHeader", { fg = colors.green, bold = true })
        vim.api.nvim_set_hl(0, "MiniStarterFooter", { fg = colors.gray, italic = true })
        vim.api.nvim_set_hl(0, "MiniStarterSection", { fg = colors.yellow, bold = true })
        vim.api.nvim_set_hl(0, "MiniStarterItemBullet", { fg = colors.blue })
        vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", { fg = colors.purple })
        vim.api.nvim_set_hl(0, "MiniStarterItem", { fg = colors.fg })
        vim.api.nvim_set_hl(0, "MiniStarterCurrent", { fg = colors.orange, bold = true })
        vim.api.nvim_set_hl(0, "MiniStarterQuery", { fg = colors.red, bold = true })
      end

      local function get_section_starts()
        local items = starter.config.items or opts.items or {}
        local starts = {}
        local previous_section = nil
        for idx, item in ipairs(items) do
          if item.section ~= previous_section then
            table.insert(starts, idx)
            previous_section = item.section
          end
        end
        return starts
      end

      vim.api.nvim_create_user_command("Starter", function()
        starter.open()
      end, { desc = "Open Mini Starter" })
      vim.keymap.set("n", "<leader>d", "<cmd>Starter<cr>", { desc = "Open Dashboard" })

      local function refresh()
        local stats = require("lazy").stats()
        local v = vim.version()
        starter.config.footer = table.concat({
          "",
          string.format("⚡ %d/%d plugins loaded in %.2fms", stats.loaded, stats.count, stats.startuptime),
          string.format("Neovim v%d.%d.%d", v.major, v.minor, v.patch),
          "",
          "Press 'q' to quit • Press '?' for help",
        }, "\n")
        starter.refresh()
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniStarterOpened",
        callback = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.signcolumn = "no"
          vim.opt_local.foldcolumn = "0"
          vim.opt_local.winbar = ""
          vim.opt_local.statuscolumn = ""

          vim.keymap.set("n", "j", function()
            require("mini.starter").update_current_item("next")
          end, { buffer = true, desc = "Next item" })

          vim.keymap.set("n", "k", function()
            require("mini.starter").update_current_item("prev")
          end, { buffer = true, desc = "Previous item" })

          vim.keymap.set("n", "<C-f>", function()
            local section_starts = get_section_starts()
            local current_idx = vim.b.ministarter_current or 1
            for _, start_idx in ipairs(section_starts) do
              if start_idx > current_idx then
                for _ = 1, start_idx - current_idx do
                  starter.update_current_item("next")
                end
                return
              end
            end
            starter.update_current_item("last")
          end, { buffer = true, desc = "Next section" })

          vim.keymap.set("n", "<C-b>", function()
            local section_starts = get_section_starts()
            local current_idx = vim.b.ministarter_current or 1
            local prev_start = 1
            for _, start_idx in ipairs(section_starts) do
              if start_idx >= current_idx then
                break
              end
              prev_start = start_idx
            end
            if prev_start < current_idx then
              for _ = 1, current_idx - prev_start do
                starter.update_current_item("prev")
              end
            else
              starter.update_current_item("first")
            end
          end, { buffer = true, desc = "Previous section" })

          -- Sections vary 2-7 items, so 4 reliably crosses most boundaries.
          vim.keymap.set("n", "<C-d>", function()
            for _ = 1, 4 do
              starter.update_current_item("next")
            end
          end, { buffer = true, desc = "Half page down" })

          vim.keymap.set("n", "<C-u>", function()
            for _ = 1, 4 do
              starter.update_current_item("prev")
            end
          end, { buffer = true, desc = "Half page up" })

          vim.keymap.set("n", "gg", function()
            starter.update_current_item("first")
          end, { buffer = true, desc = "First item" })

          vim.keymap.set("n", "G", function()
            starter.update_current_item("last")
          end, { buffer = true, desc = "Last item" })

          vim.keymap.set("n", "R", refresh, { buffer = true, desc = "Refresh starter" })
          vim.keymap.set("n", "q", "<cmd>qa<cr>", { buffer = true, desc = "Quit Neovim" })

          vim.keymap.set("n", "<Esc>", function()
            local buffers = vim.fn.getbufinfo({ buflisted = 1 })
            local normal_buffers = vim.tbl_filter(function(buf)
              return buf.name ~= "" and vim.bo[buf.bufnr].filetype ~= "starter"
            end, buffers)
            if #normal_buffers > 0 then
              vim.cmd("buffer " .. normal_buffers[1].bufnr)
            else
              vim.cmd("enew")
            end
          end, { buffer = true, desc = "Close starter" })

          vim.keymap.set("n", "?", function()
            local colors = require("config.ui").get_colors()
            vim.api.nvim_set_hl(0, "StarterHelpNormal", { bg = colors.bg, fg = colors.fg })
            vim.api.nvim_set_hl(0, "StarterHelpBorder", { fg = colors.border })
            vim.api.nvim_set_hl(0, "StarterHelpTitle", { fg = colors.blue, bold = true })
            vim.api.nvim_set_hl(0, "StarterHelpHeader", { fg = colors.yellow, bold = true })
            vim.api.nvim_set_hl(0, "StarterHelpBullet", { fg = colors.purple })
            vim.api.nvim_set_hl(0, "StarterHelpKey", { fg = colors.purple })
            vim.api.nvim_set_hl(0, "StarterHelpAngleBracket", { fg = colors.purple })

            local help_text = {
              "  Navigation:",
              "    j/k       - Move down/up",
              "    gg/G      - Move to first/last",
              "    <C-f>     - Next section",
              "    <C-b>     - Previous section",
              "    <C-d>     - Half page down (4 items)",
              "    <C-u>     - Half page up (4 items)",
              "",
              "  Actions:",
              "    <CR>      - Execute action",
              "    <Esc>     - Close starter",
              "    q         - Quit Neovim",
              "    R         - Refresh display",
              "",
              "  Tips:",
              "    • Every item has a quick select key",
              "    • All vim navigation keys work",
              "    • Press the number to jump directly",
              "",
              "  Press 'q' to close...",
            }

            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_text)
            vim.bo[buf].modifiable = false
            vim.bo[buf].readonly = true

            vim.api.nvim_buf_call(buf, function()
              vim.cmd([[syntax match StarterHelpHeader /^  \w\+:$/]])
              vim.cmd([[syntax match StarterHelpBullet /•/]])
              vim.cmd([[syntax match StarterHelpKey /\s\+\zs[^-]\+\ze\s\+-/]])
              vim.cmd([[syntax match StarterHelpAngleBracket /<[^>]*>/]])
            end)

            local width = 45
            local height = #help_text + 2
            local win = vim.api.nvim_open_win(buf, true, {
              relative = "editor",
              width = width,
              height = height,
              col = (vim.o.columns - width) / 2,
              row = (vim.o.lines - height) / 2,
              border = "single",
              title = " Mini Starter Help ",
              title_pos = "right",
              style = "minimal",
            })

            vim.wo[win].winhighlight = "Normal:StarterHelpNormal,FloatBorder:StarterHelpBorder,FloatTitle:StarterHelpTitle"

            for _, key in ipairs({ "<CR>", "<Esc>", "q" }) do
              vim.keymap.set("n", key, function()
                vim.api.nvim_win_close(win, true)
              end, { buffer = buf })
            end

            vim.api.nvim_create_autocmd("BufLeave", {
              buffer = buf,
              once = true,
              callback = function()
                if vim.api.nvim_win_is_valid(win) then
                  vim.api.nvim_win_close(win, true)
                end
              end,
            })
          end, { buffer = true, desc = "Show help" })

          set_starter_highlights()
          vim.opt_local.showtabline = 0
          vim.opt_local.timeout = true
          vim.opt_local.timeoutlen = 300

          vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>",
            { buffer = true, desc = "Find files from Dashboard" })
          vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",
            { buffer = true, desc = "Grep in files from Dashboard" })
        end,
      })

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          if vim.bo.filetype == "starter" then
            set_starter_highlights()
          end
        end,
      })
    end,
  },
}
