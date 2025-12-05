-- Color Extraction Utility
-- Shared module for extracting highlight group colors
local M = {}

-- Extract a specific attribute from a highlight group
local function hl_color(group, attr, fallback)
  local hl = vim.api.nvim_get_hl(0, { name = group })
  local val = hl[attr]
  if not val then
    return fallback
  end
  return type(val) == "number" and string.format("#%06x", val) or tostring(val)
end

-- Extract all theme colors from current colorscheme
function M.extract_all()
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

-- Extract only background and foreground (for terminal sync)
function M.extract_basic()
  return {
    bg = hl_color("Normal", "bg", "#1f1f28"),
    fg = hl_color("Normal", "fg", "#dcd7ba"),
  }
end

return M
