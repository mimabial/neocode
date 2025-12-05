return {
  -- Text objects
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
      local icons = require("mini.icons")
      icons.setup()

      -- Update icons with theme colors
      local function update_icon_colors()
        local colors = require("config.ui").get_colors()

        -- Apply colors to icon groups
        local icon_hl_groups = {
          MiniIconsDevicons = { fg = colors.blue },
          MiniIconsFiletype = { fg = colors.purple },
          MiniIconsSpinner = { fg = colors.green },
          MiniIconsFolder = { fg = colors.yellow },
          MiniIconsGit = { fg = colors.orange },
          MiniIconsConceal = { fg = colors.blue },
        }

        -- Set highlight groups
        for group, attrs in pairs(icon_hl_groups) do
          vim.api.nvim_set_hl(0, group, attrs)
        end
      end

      -- Update on theme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = update_icon_colors,
      })

      -- Initial color setup
      update_icon_colors()
    end,
  },
  {
    "echasnovski/mini.starter",
    version = false,
    event = function()
      -- Load for empty buffers at startup
      if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
        return "VimEnter"
      end
    end,
    cmd = "Starter", -- Also load on command
    enabled = true,
    opts = function()
      -- Helper to make header
      local function header()
        return table.concat({
          "Good morning, " .. vim.fn.expand("$USER"),
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

      -- Build all items
      local function build_items()
        local all_items = {}

        -- Telescope items
        local telescope_items = {
          { action = "Telescope find_files", name = "Find Files",   section = "Telescope" },
          { action = "Telescope live_grep",  name = "Find Text",    section = "Telescope" },
          { action = "Telescope oldfiles",   name = "Recent Files", section = "Telescope" },
          { action = "Telescope buffers",    name = "Buffers",      section = "Telescope" },
          { action = "Telescope help_tags",  name = "Help Tags",    section = "Telescope" },
          { action = "Telescope commands",   name = "Commands",     section = "Telescope" },
          { action = "Telescope keymaps",    name = "Keymaps",      section = "Telescope" },
        }
        vim.list_extend(all_items, telescope_items)

        -- File items
        local file_items = {
          { action = "ene | startinsert", name = "New File",      section = "Files" },
          { action = "Oil",               name = "File Explorer", section = "Files" },
          { action = "e $MYVIMRC",        name = "Edit Config",   section = "Files" },
        }
        vim.list_extend(all_items, file_items)

        -- Session items
        local session_items = {
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
        }
        vim.list_extend(all_items, session_items)

        -- Git items
        local git_items = {
          { action = "LazyGit",      name = "LazyGit",    section = "Git" },
          { action = "Git status",   name = "Git Status", section = "Git" },
          { action = "DiffviewOpen", name = "Diff View",  section = "Git" },
        }
        vim.list_extend(all_items, git_items)

        -- System items
        local system_items = {
          { action = "Lazy",        name = "Lazy Plugins",   section = "System" },
          { action = "Mason",       name = "Mason Packages", section = "System" },
          { action = "checkhealth", name = "Check Health",   section = "System" },
          { action = "qa",          name = "Quit Neovim",    section = "System" },
        }
        vim.list_extend(all_items, system_items)

        local items = {}
        for i, item in ipairs(all_items) do
          local prefix = string.format("%d", i)
          local formatted_item = {
            action = item.action,
            name = string.format("%s. %s", prefix, item.name),
            section = item.section,
          }
          table.insert(items, formatted_item)
        end

        return items
      end

      return {
        header = header(),
        items = build_items(),
        footer = footer(),
      }
    end,

    -- Apply configuration and set up behavior
    config = function(_, opts)
      local starter = require("mini.starter")
      starter.setup(opts)

      -- Create :Starter command and <leader>d mapping
      vim.api.nvim_create_user_command("Starter", function()
        starter.open()
      end, { desc = "Open Mini Starter" })
      vim.keymap.set("n", "<leader>d", "<cmd>Starter<cr>", { desc = "Open Dashboard" })

      -- Refresh stats in footer
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

      -- When dashboard opens
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniStarterOpened",
        callback = function()
          -- Set buffer options
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

          -- Page navigation (section-based)
          vim.keymap.set("n", "<C-f>", function()
            -- Jump to next section based on known section boundaries
            -- Telescope: 1-7, Files: 8-10, Sessions: 11-12, Git: 13-15, System: 16-19
            local section_starts = { 1, 8, 11, 13, 16 }

            -- Get current item index (Mini.starter uses 1-based indexing)
            local current_idx = vim.b.ministarter_current or 1

            -- Find next section start
            for _, start_idx in ipairs(section_starts) do
              if start_idx > current_idx then
                -- Jump to this section start
                local jumps = start_idx - current_idx
                for _ = 1, jumps do
                  starter.update_current_item("next")
                end
                return
              end
            end

            -- If no next section, go to last item
            starter.update_current_item("last")
          end, { buffer = true, desc = "Next section" })

          vim.keymap.set("n", "<C-b>", function()
            -- Jump to previous section based on known section boundaries
            local section_starts = { 1, 8, 11, 13, 16 }

            -- Get current item index
            local current_idx = vim.b.ministarter_current or 1

            -- Find previous section start
            local prev_start = 1
            for _, start_idx in ipairs(section_starts) do
              if start_idx >= current_idx then
                break
              end
              prev_start = start_idx
            end

            -- Jump to previous section start
            if prev_start < current_idx then
              local jumps = current_idx - prev_start
              for _ = 1, jumps do
                starter.update_current_item("prev")
              end
            else
              -- If already at first section, go to first item
              starter.update_current_item("first")
            end
          end, { buffer = true, desc = "Previous section" })

          -- Since sections vary from 2-7 items,
          -- jumping by 4 items will reliably
          -- cross most section boundaries

          vim.keymap.set("n", "<C-d>", function()
            -- Jump forward by 4 items
            for _ = 1, 4 do
              starter.update_current_item("next")
            end
          end, { buffer = true, desc = "Half page down" })

          vim.keymap.set("n", "<C-u>", function()
            -- Jump backward by 4 items
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
            -- Close starter and return to previous buffer or quit if none
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
            -- Get current theme colors
            local colors = require("config.ui").get_colors()

            -- Create help highlight groups
            vim.api.nvim_set_hl(0, "StarterHelpNormal", { bg = colors.bg, fg = colors.fg })
            vim.api.nvim_set_hl(0, "StarterHelpBorder", { fg = colors.border })
            vim.api.nvim_set_hl(0, "StarterHelpTitle", { fg = colors.blue, bold = true })
            vim.api.nvim_set_hl(0, "StarterHelpHeader", { fg = colors.yellow, bold = true })
            vim.api.nvim_set_hl(0, "StarterHelpBullet", { fg = colors.purple })
            vim.api.nvim_set_hl(0, "StarterHelpKey", { fg = colors.purple })
            vim.api.nvim_set_hl(0, "StarterHelpAngleBracket", { fg = colors.purple })

            -- Create a temporary buffer for help display
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

            -- Create help popup
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_text)
            vim.bo[buf].modifiable = false
            vim.bo[buf].readonly = true

            -- Set up syntax highlighting for the help text
            vim.api.nvim_buf_call(buf, function()
              -- Headers (lines ending with :)
              vim.cmd([[syntax match StarterHelpHeader /^  \w\+:$/]])
              -- Bullet points (•)
              vim.cmd([[syntax match StarterHelpBullet /•/]])
              -- Keys/commands (everything before " - ")
              vim.cmd([[syntax match StarterHelpKey /\s\+\zs[^-]\+\ze\s\+-/]])
              -- Angle bracket keys like <C-f>, <CR>, <Esc>
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

            vim.api.nvim_win_set_option(
              win,
              "winhighlight",
              "Normal:StarterHelpNormal,FloatBorder:StarterHelpBorder,FloatTitle:StarterHelpTitle"
            )

            -- Close on any key
            vim.keymap.set("n", "<CR>", function()
              vim.api.nvim_win_close(win, true)
            end, { buffer = buf })
            vim.keymap.set("n", "<Esc>", function()
              vim.api.nvim_win_close(win, true)
            end, { buffer = buf })
            vim.keymap.set("n", "q", function()
              vim.api.nvim_win_close(win, true)
            end, { buffer = buf })

            -- Auto-close on any key
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

          -- Update highlights based on colorscheme
          local colors = require("config.ui").get_colors()

          -- Set highlight groups
          vim.api.nvim_set_hl(0, "MiniStarterHeader", { fg = colors.green, bold = true })
          vim.api.nvim_set_hl(0, "MiniStarterFooter", { fg = colors.gray, italic = true })
          vim.api.nvim_set_hl(0, "MiniStarterSection", { fg = colors.yellow, bold = true })
          vim.api.nvim_set_hl(0, "MiniStarterItemBullet", { fg = colors.blue })
          vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", { fg = colors.purple })
          vim.api.nvim_set_hl(0, "MiniStarterItem", { fg = colors.fg })
          vim.api.nvim_set_hl(0, "MiniStarterCurrent", { fg = colors.orange, bold = true })
          vim.api.nvim_set_hl(0, "MiniStarterQuery", { fg = colors.red, bold = true })

          -- Clean up tabline
          vim.opt_local.showtabline = 0

          -- Re-enable multi-key sequences in dashboard
          vim.opt_local.timeout = true
          vim.opt_local.timeoutlen = 300

          -- Buffer-local <leader> mappings
          vim.keymap.set(
            "n",
            "<leader>ff",
            "<cmd>Telescope find_files<cr>",
            { buffer = true, desc = "Find files from Dashboard" }
          )
          vim.keymap.set(
            "n",
            "<leader>fg",
            "<cmd>Telescope live_grep<cr>",
            { buffer = true, desc = "Grep in files from Dashboard" }
          )
        end,
      })

      -- Update colors on colorscheme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          if vim.bo.filetype == "starter" then
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
        end,
      })
    end,
  } }
