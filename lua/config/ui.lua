local M = {}

local function extract_colors()
  local function hl_color(group, attr, fallback)
    local hl = vim.api.nvim_get_hl(0, { name = group })
    local val = hl[attr]
    if not val then return fallback end
    return type(val) == "number" and string.format("#%06x", val) or tostring(val)
  end
  local bg = hl_color("Normal", "bg", "#1f1f28")
  local fg = hl_color("Normal", "fg", "#dcd7ba")
  return {
    bg = bg,
    fg = fg,

    red = hl_color("DiagnosticError", "fg", "#ea6962"),
    green = hl_color("DiagnosticOk", "fg", "#89b482"),
    yellow = hl_color("DiagnosticWarn", "fg", "#d8a657"),
    blue = hl_color("Function", "fg", "#7daea3"),
    purple = hl_color("Keyword", "fg", "#d3869b"),
    orange = hl_color("Number", "fg", "#e78a4e"),
    gray = hl_color("Comment", "fg", "#928374"),
    border = hl_color("FloatBorder", "fg", "#45403d"),

    select_bg = hl_color("PmenuSel", "bg", "#45403d"),
    select_fg = hl_color("PmenuSel", "fg", "#dcd7ba"),
    popup_bg = hl_color("Pmenu", "bg", bg),

    codeium = "#09B6A2",
  }
end

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
  local colors = extract_colors()

  -- Float window
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.popup_bg })

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

  vim.api.nvim_set_hl(0, "BufferLineError", { fg = colors.red, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineErrorSelected", { fg = colors.red, bg = colors.bg, bold = true })
  vim.api.nvim_set_hl(0, "BufferLineWarning", { fg = colors.yellow, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = colors.blue, bg = colors.bg })
  vim.api.nvim_set_hl(0, "BufferLineFill", { fg = colors.fg, bg = colors.bg })

  -- diagnostic highlights

  -- Telescope highlights
  vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.purple })
end

function M.setup()
  setup_highlights()

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = setup_highlights,
  })

  -- Export functions globally
  _G.get_ui_config = function() return M.config end
  _G.get_ui_colors = extract_colors
end

return M
