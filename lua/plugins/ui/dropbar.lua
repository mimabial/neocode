return {
  "Bekaboo/dropbar.nvim",
  event = "VeryLazy",
  opts = {
    bar = {
      enable = function(buf, win, _)
        -- Skip for certain filetypes
        local ft = vim.bo[buf].filetype
        if vim.tbl_contains({ "oil", "NvimTree", "neo-tree", "Trouble", "lazy", "mason", "TelescopePrompt", "terminal" }, ft) then
          return false
        end

        return vim.api.nvim_buf_is_valid(buf)
            and vim.api.nvim_win_is_valid(win)
            and vim.fn.win_gettype(win) == ''
            and vim.wo[win].winbar == ''
            and vim.bo[buf].buftype == ''
      end,
      sources = function(buf, _)
        local sources = require('dropbar.sources')
        local utils = require('dropbar.utils')

        return {
          utils.source.fallback({
            sources.lsp,
            sources.treesitter,
          }),
        }
      end,
    },
    menu = {
      -- Disable quick navigation to keep it simple
      quick_navigation = false,
      entry = {
        padding = {
          left = 1,
          right = 1,
        },
      },
      -- Simple keymaps
      keymaps = {
        ['<LeftMouse>'] = function()
          local menu = require('dropbar.utils').menu.get_current()
          if not menu then
            return
          end
          local mouse = vim.fn.getmousepos()
          menu:click_at({ mouse.line, mouse.column - 1 })
        end,
        ['<CR>'] = function()
          local menu = require('dropbar.utils').menu.get_current()
          if menu then
            local cursor = vim.api.nvim_win_get_cursor(menu.win)
            menu:click_at(cursor)
          end
        end,
        ['q'] = function()
          require('dropbar.utils').menu.exec('close')
        end,
        ['<Esc>'] = function()
          require('dropbar.utils').menu.exec('close')
        end,
      },
    },
    icons = {
      enable = true,
      kinds = {
        symbols = {
          File = ' ',
          Module = ' ',
          Namespace = ' ',
          Package = ' ',
          Class = ' ',
          Method = ' ',
          Property = ' ',
          Field = ' ',
          Constructor = ' ',
          Enum = ' ',
          Interface = ' ',
          Function = ' ',
          Variable = ' ',
          Constant = ' ',
          String = ' ',
          Number = ' ',
          Boolean = ' ',
          Array = ' ',
          Object = ' ',
          Key = ' ',
          Null = ' ',
          EnumMember = ' ',
          Struct = ' ',
          Event = ' ',
          Operator = ' ',
          TypeParameter = ' ',
        },
      },
    },
  },
  config = function(_, opts)
    require('dropbar').setup(opts)

    -- Setup highlights
    local function setup_highlights()
      local colors = _G.get_ui_colors()

      vim.api.nvim_set_hl(0, "DropBarIconUISeparator", { fg = colors.border, bg = colors.bg })
      vim.api.nvim_set_hl(0, "DropBarIconUIIndicator", { fg = colors.blue, bg = colors.bg })
      vim.api.nvim_set_hl(0, "DropBarIconUIPickPivot", { fg = colors.orange, bg = colors.bg })
      vim.api.nvim_set_hl(0, "DropBarMenuCurrentContext", { fg = colors.blue, bg = colors.bg, bold = true })
      vim.api.nvim_set_hl(0, "DropBarMenuNormalFloat", { bg = colors.bg })
      vim.api.nvim_set_hl(0, "DropBarMenuFloatBorder", { fg = colors.border, bg = colors.bg })
    end

    setup_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })

    -- Toggle command
    vim.api.nvim_create_user_command("DropbarToggle", function()
      local winid = vim.api.nvim_get_current_win()
      if vim.wo[winid].winbar and vim.wo[winid].winbar ~= "" then
        vim.wo[winid].winbar = ""
        vim.notify("Dropbar disabled", vim.log.levels.INFO)
      else
        -- Force re-enable for current window
        require('dropbar.api').get_dropbar_str()
        vim.notify("Dropbar enabled", vim.log.levels.INFO)
      end
    end, { desc = "Toggle dropbar in current window" })
  end,
}
