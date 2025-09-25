local M = {}

local function extract_colors()
  local function hl_color(group, attr, fallback)
    local hl = vim.api.nvim_get_hl(0, { name = group })
    local val = hl[attr]
    if not val then return fallback end
    return type(val) == "number" and string.format("#%06x", val) or tostring(val)
  end

  return {
    bg = hl_color("Normal", "bg", "#1f1f28"),
    fg = hl_color("Normal", "fg", "#dcd7ba"),
    red = hl_color("DiagnosticError", "fg", "#ea6962"),
    green = hl_color("DiagnosticOk", "fg", "#89b482"),
    yellow = hl_color("DiagnosticWarn", "fg", "#d8a657"),
    blue = hl_color("Function", "fg", "#7daea3"),
    purple = hl_color("Keyword", "fg", "#d3869b"),
    orange = hl_color("Number", "fg", "#e78a4e"),
    gray = hl_color("Comment", "fg", "#928374"),
    border = hl_color("FloatBorder", "fg", "#45403d"),
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

  -- Float window highlights
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.popup_bg })

  -- Completion menu
  -- Basic UI elements
  vim.api.nvim_set_hl(0, "CmpNormal", { bg = colors.bg })
  vim.api.nvim_set_hl(0, "CmpBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "CmpSel", { bg = colors.select_bg, fg = colors.select_fg, bold = true })

  -- AI source highlighting
  vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.codeium })

  -- Diagnostic highlights
  vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = colors.red, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = colors.yellow, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = colors.blue, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = colors.green, bg = "NONE" })

  -- Notification highlights
  vim.api.nvim_set_hl(0, "NotifyBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NotifyBackground", { bg = colors.bg })

  -- Telescope highlights
  vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.blue, bold = true })
  vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.blue })
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
