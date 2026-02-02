local M = {}
local colors_lib = require("lib.colors")

M.config = {
  float = {
    border = "single",   -- Consistent border style
    padding = { 0, 1 },  -- Consistent padding
    max_width = 80,      -- Reasonable max width
    max_height = 20,     -- Reasonable max height
    win_options = {
      winblend = 0,      -- No transparency
      cursorline = true, -- Highlight current line
      signcolumn = "no", -- No sign column in floats
      wrap = false,      -- No wrapping by default
    },
  },
}

local function setup_highlights()
  local colors = colors_lib.extract_all()

  -- Float window
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.bg })

  -- Winbar highlights
  vim.api.nvim_set_hl(0, "WinBar", { bg = colors.bg, fg = colors.fg })
  vim.api.nvim_set_hl(0, "WinBarNC", { bg = colors.bg, fg = colors.gray })

  -- Window separators
  vim.api.nvim_set_hl(0, "StatusLine", { fg = colors.bg, bg = colors.bg })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = colors.gray, bg = colors.bg })

  -- Completion menu
  vim.api.nvim_set_hl(0, "CmpNormal", { bg = colors.bg })
  vim.api.nvim_set_hl(0, "CmpBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "CmpSel", { fg = colors.blue })
  -- Menu appearance for non-selected items
  vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.gray, italic = true })
  -- Create special highlights for matching items
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.purple })
  -- AI source highlighting
  vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.green })

  -- Bufferline highlights
  vim.api.nvim_set_hl(0, "BufferLineBackground", { fg = colors.gray, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { fg = colors.fg, bg = colors.bg, bold = true })
  vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { fg = colors.fg, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineModified", { fg = colors.green, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineModifiedSelected", { fg = colors.green, bg = colors.bg })

  -- Close button highlights
  vim.api.nvim_set_hl(0, "BufferLineCloseButton", { fg = colors.gray, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineCloseButtonSelected", { fg = colors.red, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineCloseButtonVisible", { fg = colors.gray, bg = colors.bg })

  -- Separator highlights
  vim.api.nvim_set_hl(0, "BufferLineSeparator", { fg = colors.bg, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineSeparatorSelected", { fg = colors.bg, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineSeparatorVisible", { fg = colors.bg, bg = colors.bg })

  -- Icon highlights
  vim.api.nvim_set_hl(0, "BufferLineIcon", { fg = colors.blue, bg = colors.blue })
  vim.api.nvim_set_hl(0, "BufferLineIconSelected", { fg = colors.blue, bg = colors.blue })
  vim.api.nvim_set_hl(0, "BufferLineIconVisible", { fg = colors.blue, bg = colors.blue })

  -- Indicator highlights
  vim.api.nvim_set_hl(0, "BufferLineIndicator", { fg = colors.border, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = colors.blue, bg = colors.bg, underline = true })

  vim.api.nvim_set_hl(0, "BufferLineError", { fg = colors.red, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineErrorSelected", { fg = colors.red, bg = colors.bg, bold = true })
  vim.api.nvim_set_hl(0, "BufferLineWarning", { fg = colors.yellow, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineFill", { fg = colors.fg, bg = colors.bg })

  -- Bufferline offset highlights (for nvim-tree/oil sections)
  vim.api.nvim_set_hl(0, "BufferLineOffsetSeparator", { fg = colors.bg, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineOffset", { fg = colors.fg, bg = colors.bg })

  -- Floating window highlights
  vim.api.nvim_set_hl(0, "FloatTitle", { fg = colors.red, bg = colors.bg, bold = true })

  -- notification highlights
  vim.api.nvim_set_hl(0, "NotifyBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NotifyBackground", { bg = colors.bg })

  -- nvimtree highlights
  vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = colors.bg, fg = colors.fg })
  vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = colors.bg, fg = colors.bg })
  vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName", { fg = colors.red })
  vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = colors.gray }) -- or any color you prefer

  -- illuminate highlights
  vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = colors.bg, underline = true })
  vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = colors.bg, underline = true })
  vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = colors.bg, underline = true, bold = true })

  -- Telescope highlights
  vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.purple })
end

function M.setup()
  setup_highlights()

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      -- Schedule to run after colorscheme has fully applied highlights
      vim.schedule(setup_highlights)
    end,
  })
end

-- Export functions as module methods (no global pollution)
M.get_colors = colors_lib.extract_all
M.get_config = function()
  return M.config
end

return M
