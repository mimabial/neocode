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
        reveal = { 'close' }
      },
    },
  },
  config = function(_, opts)
    require("mini.icons").setup()
    require("bufferline").setup(opts)

    -- Buffer navigation keymaps
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
    end

    map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
    map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
    map("n", "<leader>bn", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
    map("n", "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
    map("n", "<leader>bf", "<cmd>BufferLineGoToBuffer 1<cr>", "First buffer")
    map("n", "<leader>bl", "<cmd>BufferLineGoToBuffer -1<cr>", "Last buffer")
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
