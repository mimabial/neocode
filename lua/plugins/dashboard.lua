return {
  "echasnovski/mini.starter",
  version = false,
  event = function()
    -- Only load for empty buffers at startup
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
      local version = vim.version()
      local nvim_version = string.format("v%d.%d.%d", version.major, version.minor, version.patch)

      return table.concat({
        "",
        string.format("⚡ %d/%d plugins loaded in %.2fms", stats.loaded, stats.count, stats.startuptime),
        string.format("  Neovim %s", nvim_version),
        "",
        "Press 'q' to quit • Press '?' for help",
      }, "\n")
    end

    -- Build all items
    local function build_items()
      local all_items = {}

      -- Telescope items
      local telescope_items = {
        { action = "Telescope find_files", name = "Find Files", section = "Telescope" },
        { action = "Telescope live_grep", name = "Find Text", section = "Telescope" },
        { action = "Telescope oldfiles", name = "Recent Files", section = "Telescope" },
        { action = "Telescope buffers", name = "Buffers", section = "Telescope" },
        { action = "Telescope help_tags", name = "Help Tags", section = "Telescope" },
        { action = "Telescope commands", name = "Commands", section = "Telescope" },
        { action = "Telescope keymaps", name = "Keymaps", section = "Telescope" },
      }
      vim.list_extend(all_items, telescope_items)

      -- File items
      local file_items = {
        { action = "ene | startinsert", name = "New File", section = "Files" },
        { action = "Oil", name = "File Explorer", section = "Files" },
        { action = "e $MYVIMRC", name = "Edit Config", section = "Files" },
      }
      vim.list_extend(all_items, file_items)

      -- Session items
      local session_items = {
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
        { action = "LazyGit", name = "LazyGit", section = "Git" },
        { action = "Git status", name = "Git Status", section = "Git" },
        { action = "DiffviewOpen", name = "Diff View", section = "Git" },
      }
      vim.list_extend(all_items, git_items)

      -- System items
      local system_items = {
        { action = "Lazy", name = "Lazy Plugins", section = "System" },
        { action = "Mason", name = "Mason Packages", section = "System" },
        { action = "checkhealth", name = "Check Health", section = "System" },
        { action = "qa", name = "Quit Neovim", section = "System" },
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

        -- Add refresh keybinding
        vim.keymap.set("n", "R", refresh, { buffer = true, desc = "Refresh starter" })

        -- Add help
        vim.keymap.set("n", "?", function()
          vim.notify(
            [[
Mini Starter Help:
  
Navigation:
  j/k       - Move down/up (vim style)
  h/l       - Move left/right
  <CR>      - Execute action
  <Esc>     - Close starter
  q         - Quit Neovim
  R         - Refresh display
  
Quick selection:
  1-9       - Select items 1-9
  a-z       - Select items 10+
  
Tips:
  • Every item has a quick select key
  • All vim navigation keys work
  • Press the number/letter to jump directly
          ]],
            vim.log.levels.INFO,
            { title = "Mini Starter Help" }
          )
        end, { buffer = true, desc = "Show help" })

        -- Update highlights based on colorscheme
        local colors = _G.get_ui_colors and _G.get_ui_colors()
          or {
            blue = "#7daea3",
            green = "#89b482",
            yellow = "#d8a657",
            purple = "#d3869b",
            red = "#ea6962",
            orange = "#e78a4e",
            gray = "#928374",
            fg = "#d4be98",
          }

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
          local colors = _G.get_ui_colors and _G.get_ui_colors() or {}
          vim.api.nvim_set_hl(0, "MiniStarterHeader", { fg = colors.green or "#89b482", bold = true })
          vim.api.nvim_set_hl(0, "MiniStarterFooter", { fg = colors.gray or "#928374", italic = true })
          vim.api.nvim_set_hl(0, "MiniStarterSection", { fg = colors.yellow or "#d8a657", bold = true })
          vim.api.nvim_set_hl(0, "MiniStarterItemBullet", { fg = colors.blue or "#7daea3" })
          vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", { fg = colors.purple or "#d3869b" })
          vim.api.nvim_set_hl(0, "MiniStarterItem", { fg = colors.fg or "#d4be98" })
          vim.api.nvim_set_hl(0, "MiniStarterCurrent", { fg = colors.orange or "#e78a4e", bold = true })
          vim.api.nvim_set_hl(0, "MiniStarterQuery", { fg = colors.red or "#ea6962", bold = true })
        end
      end,
    })
  end,
}
