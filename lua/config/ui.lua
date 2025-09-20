local M = {}

local function extract_colors()
  local function hl_color(group, attr)
    local hl = vim.api.nvim_get_hl(0, { name = group })
    local val = hl[attr]
    return val and (type(val) == "number" and string.format("#%06x", val) or tostring(val))
  end

  return {
    bg = hl_color("Normal", "bg") or "#1f1f28",
    fg = hl_color("Normal", "fg") or "#dcd7ba",
    red = hl_color("DiagnosticError", "fg") or "#ea6962",
    green = hl_color("DiagnosticOk", "fg") or "#89b482",
    yellow = hl_color("DiagnosticWarn", "fg") or "#d8a657",
    blue = hl_color("Function", "fg") or "#7daea3",
    purple = hl_color("Keyword", "fg") or "#d3869b",
    orange = hl_color("Number", "fg") or "#e78a4e",
    gray = hl_color("Comment", "fg") or "#928374",
    border = hl_color("FloatBorder", "fg") or "#45403d",
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
  vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.copilot })
  vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.codeium })

  -- Diagnostic highlights
  vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = colors.red, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = colors.yellow, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = colors.blue, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = colors.green, bg = "NONE" })

  -- Notification highlights
  vim.api.nvim_set_hl(0, "NotifyBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NotifyBackground", { bg = colors.bg })
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
