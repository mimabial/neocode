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

    -- Check if transparency is enabled
    local function is_transparency_enabled()
      local cache_dir = vim.fn.stdpath("cache")
      local settings_file = cache_dir .. "/theme_settings.json"

      if vim.fn.filereadable(settings_file) == 0 then
        return false
      end

      local content = vim.fn.readfile(settings_file)
      if #content == 0 then
        return false
      end

      local ok, parsed = pcall(vim.fn.json_decode, table.concat(content, ""))
      return ok and parsed and parsed.transparency or false
    end

    -- Update bufferline highlights
    local function update_bufferline_highlights()
      local colors = _G.get_ui_colors()

      -- Use transparent background if enabled
      local bg_color = is_transparency_enabled() and "NONE" or colors.bg

      -- Set highlight groups
      vim.api.nvim_set_hl(0, "BufferLineBackground", { fg = colors.gray, bg = bg_color })
      vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { fg = colors.fg, bg = bg_color, bold = true })
      vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { fg = colors.fg, bg = bg_color })
      vim.api.nvim_set_hl(0, "BufferLineModified", { fg = colors.green, bg = bg_color })
      vim.api.nvim_set_hl(0, "BufferLineModifiedSelected", { fg = colors.green, bg = bg_color })
      vim.api.nvim_set_hl(0, "BufferLineError", { fg = colors.red, bg = bg_color })
      vim.api.nvim_set_hl(0, "BufferLineErrorSelected", { fg = colors.red, bg = bg_color, bold = true })
      vim.api.nvim_set_hl(0, "BufferLineWarning", { fg = colors.yellow, bg = bg_color })
      vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = colors.blue, bg = bg_color })
      vim.api.nvim_set_hl(0, "BufferLineFill", { fg = colors.fg, bg = bg_color })
    end

    -- Apply highlights on colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = update_bufferline_highlights,
    })

    -- Also update when UI colors change (custom event)
    vim.api.nvim_create_autocmd("User", {
      pattern = "UIColorsChanged",
      callback = update_bufferline_highlights,
    })

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

    -- Apply initial highlights
    update_bufferline_highlights()
  end,
}
