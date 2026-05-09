return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  version = "*",
  opts = function()
    local colors = require("config.ui").get_colors()
    local bar_bg = require("lib.theme_manager").bar_bg(colors.bg)

    local function hl(fg, extras)
      local h = { fg = fg, bg = bar_bg }
      if extras then
        for k, v in pairs(extras) do h[k] = v end
      end
      return h
    end

    return {
      options = {
        mode = "buffers",
        themable = true,
        numbers = "none",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        indicator = {
          icon = "│",
          style = "icon",
        },
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 30,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and "" or ""
          return " " .. icon .. count
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "",
            text_align = "center",
            separator = true,
          },
          {
            filetype = "oil",
            text = "",
            text_align = "center",
            separator = true,
          },
        },
        show_buffer_icons = false,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        separator_style = "thin",
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
      },
      highlights = {
        fill = hl(colors.fg),
        background = hl(colors.gray),
        buffer_visible = hl(colors.fg),
        buffer_selected = hl(colors.fg, { bold = true }),
        close_button = hl(colors.gray),
        close_button_visible = hl(colors.gray),
        close_button_selected = hl(colors.red),
        modified = hl(colors.green),
        modified_visible = hl(colors.green),
        modified_selected = hl(colors.green),
        separator = hl(bar_bg),
        separator_visible = hl(bar_bg),
        separator_selected = hl(bar_bg),
        offset_separator = hl(bar_bg),
        indicator_visible = hl(colors.border),
        indicator_selected = hl(colors.blue, { underline = true }),
        tab = hl(colors.fg),
        tab_selected = hl(colors.fg, { bold = true }),
        tab_close = hl(colors.red),
        error = hl(colors.red),
        error_visible = hl(colors.red),
        error_selected = hl(colors.red, { bold = true }),
        warning = hl(colors.yellow),
        warning_visible = hl(colors.yellow),
        warning_selected = hl(colors.yellow),
      },
    }
  end,
  config = function(_, opts)
    require("bufferline").setup(opts)

    -- Refresh bufferline on colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.schedule(function()
          local new_opts = require("plugins.ui.tabline").opts()
          require("bufferline").setup(new_opts)
        end)
      end,
    })

    -- Buffer navigation keymaps
    -- Owner of <leader>b* namespace (shared with core keymaps.lua)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
    end

    -- Quick navigation (Shift+h/l)
    map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
    map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next buffer")

    -- Buffer navigation
    map("n", "<leader>b]", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
    map("n", "<leader>b[", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
    map("n", "<leader>bf", "<cmd>BufferLineGoToBuffer 1<cr>", "First buffer")
    map("n", "<leader>bl", "<cmd>BufferLineGoToBuffer -1<cr>", "Last buffer")

    -- Buffer management
    map("n", "<leader>bp", "<cmd>BufferLinePick<cr>", "Pick buffer")
    map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", "Delete buffer (others)")
    map("n", "<leader>bc", "<cmd>BufferLinePickClose<cr>", "Delete buffer (pick)")
    map("n", "<leader>b<", "<cmd>BufferLineMovePrev<cr>", "Move buffer left")
    map("n", "<leader>b>", "<cmd>BufferLineMoveNext<cr>", "Move buffer right")

    -- Buffer sorting
    map("n", "<leader>b.", "<cmd>BufferLineSortByDirectory<cr>", "Sort by directory")
    map("n", "<leader>b,", "<cmd>BufferLineSortByExtension<cr>", "Sort by extension")

    -- Go to buffer by number
    for i = 1, 9 do
      map("n", "<leader>b" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", "Go to buffer " .. i)
    end
  end,
}
