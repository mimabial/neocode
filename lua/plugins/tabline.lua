return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  version = "*",
  opts = {
    options = {
      mode = "buffers",
      numbers = "none",
      close_command = "bdelete! %d",
      right_mouse_command = "bdelete! %d",
      left_mouse_command = "buffer %d",
      indicator = {
        icon = "▎",
        style = "icon",
      },
      buffer_close_icon = "",
      modified_icon = "●",
      close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",
      max_name_length = 30,
      diagnostics = "nvim_lsp",
      diagnostics_update_in_insert = false,
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "center",
          separator = true,
        },
        {
          filetype = "neo-tree",
          text = "File Explorer",
          text_align = "center",
          separator = true,
        },
        {
          filetype = "oil",
          text = "File Explorer",
          text_align = "center",
          separator = true,
        },
      },
      show_buffer_icons = true,
      show_buffer_close_icons = true,
      show_tab_indicators = true,
      separator_style = "thin",
      always_show_bufferline = false,
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)

    -- Theme-aware highlighting
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        local colors = _G.get_ui_colors and _G.get_ui_colors()
          or {
            bg = "#282828",
            fg = "#d4be98",
            blue = "#7daea3",
            green = "#89b482",
            red = "#ea6962",
            yellow = "#d8a657",
            gray = "#928374",
            border = "#665c54",
          }

        -- Set highlight groups
        vim.api.nvim_set_hl(0, "BufferLineBackground", { fg = colors.gray, bg = colors.bg })
        vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { fg = colors.fg, bg = colors.bg, bold = true })
        vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { fg = colors.fg, bg = colors.bg })
        vim.api.nvim_set_hl(0, "BufferLineModified", { fg = colors.green, bg = colors.bg })
        vim.api.nvim_set_hl(0, "BufferLineModifiedSelected", { fg = colors.green, bg = colors.bg })
        vim.api.nvim_set_hl(0, "BufferLineError", { fg = colors.red, bg = colors.bg })
        vim.api.nvim_set_hl(0, "BufferLineErrorSelected", { fg = colors.red, bg = colors.bg, bold = true })
        vim.api.nvim_set_hl(0, "BufferLineWarning", { fg = colors.yellow, bg = colors.bg })
        vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = colors.blue, bg = colors.bg })
        vim.api.nvim_set_hl(0, "BufferLineFill", { fg = colors.fg, bg = colors.bg })
      end,
    })

    -- Override buffer navigation with bufferline
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
    end

    -- Replace standard buffer navigation
    map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
    map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
    map("n", "<leader>bn", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
    map("n", "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
    map("n", "<leader>bf", "<cmd>BufferLineGoToBuffer 1<cr>", "First buffer")
    map("n", "<leader>bl", "<cmd>BufferLineGoToBuffer -1<cr>", "Last buffer")

    -- Add new functionality
    map("n", "<leader>bP", "<cmd>BufferLinePick<cr>", "Pick buffer")
    map("n", "<leader>b<", "<cmd>BufferLineMovePrev<cr>", "Move buffer left")
    map("n", "<leader>b>", "<cmd>BufferLineMoveNext<cr>", "Move buffer right")
    map("n", "<leader>b.", "<cmd>BufferLineSortByDirectory<cr>", "Sort by directory")
    map("n", "<leader>b,", "<cmd>BufferLineSortByExtension<cr>", "Sort by extension")

    -- Go to buffer by number
    for i = 1, 9 do
      map("n", "<leader>b" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", "Go to buffer " .. i)
    end
  end,
}
