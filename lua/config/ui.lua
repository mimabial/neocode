local M = {}
local colors_lib = require("lib.colors")

M.config = {
  float = {
    border = "single",
    padding = { 0, 1 },
    max_width = 80,
    max_height = 20,
    win_options = {
      winblend = 0,
      cursorline = true,
      signcolumn = "no",
      wrap = false,
    },
  },
}

local function setup_highlights()
  local colors = colors_lib.extract_all()
  -- Bar chrome (statusline, winbar, bufferline) follows the global transparency flag.
  -- Floats/popups/tree are intentionally left opaque for readability.
  local bar_bg = require("lib.theme_manager").bar_bg(colors.bg)

  vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.bg })

  vim.api.nvim_set_hl(0, "WinBar", { bg = bar_bg, fg = colors.fg })
  vim.api.nvim_set_hl(0, "WinBarNC", { bg = bar_bg, fg = colors.gray })

  vim.api.nvim_set_hl(0, "StatusLine", { fg = bar_bg, bg = bar_bg })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = colors.gray, bg = bar_bg })

  vim.api.nvim_set_hl(0, "CmpNormal", { bg = colors.bg })
  vim.api.nvim_set_hl(0, "CmpBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "CmpSel", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.gray, italic = true })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.purple })
  vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.green })

  vim.api.nvim_set_hl(0, "BufferLineBackground", { fg = colors.gray, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { fg = colors.fg, bg = bar_bg, bold = true })
  vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { fg = colors.fg, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineModified", { fg = colors.green, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineModifiedSelected", { fg = colors.green, bg = bar_bg })

  vim.api.nvim_set_hl(0, "BufferLineCloseButton", { fg = colors.gray, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineCloseButtonSelected", { fg = colors.red, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineCloseButtonVisible", { fg = colors.gray, bg = bar_bg })

  vim.api.nvim_set_hl(0, "BufferLineSeparator", { fg = bar_bg, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineSeparatorSelected", { fg = bar_bg, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineSeparatorVisible", { fg = bar_bg, bg = bar_bg })

  vim.api.nvim_set_hl(0, "BufferLineIcon", { fg = colors.blue, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineIconSelected", { fg = colors.blue, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineIconVisible", { fg = colors.blue, bg = bar_bg })

  vim.api.nvim_set_hl(0, "BufferLineIndicator", { fg = colors.border, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = colors.blue, bg = bar_bg, underline = true })

  vim.api.nvim_set_hl(0, "BufferLineError", { fg = colors.red, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineErrorSelected", { fg = colors.red, bg = bar_bg, bold = true })
  vim.api.nvim_set_hl(0, "BufferLineWarning", { fg = colors.yellow, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineFill", { fg = colors.fg, bg = bar_bg })

  vim.api.nvim_set_hl(0, "BufferLineOffsetSeparator", { fg = bar_bg, bg = bar_bg })
  vim.api.nvim_set_hl(0, "BufferLineOffset", { fg = colors.fg, bg = bar_bg })

  vim.api.nvim_set_hl(0, "FloatTitle", { fg = colors.red, bg = colors.bg, bold = true })

  vim.api.nvim_set_hl(0, "NotifyBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NotifyBackground", { bg = colors.bg })

  vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = colors.bg, fg = colors.fg })
  vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = colors.bg, fg = colors.bg })
  vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName", { fg = colors.red })
  vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = colors.gray })

  vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = colors.bg, underline = true })
  vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = colors.bg, underline = true })
  vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = colors.bg, underline = true, bold = true })

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
      vim.schedule(setup_highlights)
    end,
  })
end

M.get_colors = colors_lib.extract_all
M.get_config = function()
  return M.config
end

return M
