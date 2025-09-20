local M = {}

-- Universal color extraction from highlight groups
M.get_colors = function()
  local function get_hl_color(group, attr, fallback)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
    local val = ok and hl[attr]
    if not val then
      return fallback
    end
    if type(val) == "number" then
      return string.format("#%06x", val)
    end
    return tostring(val)
  end

  -- Extract colors from highlight groups
  return {
    bg = get_hl_color("Normal", "bg", "#1f1f28"),
    bg1 = get_hl_color("CursorLine", "bg", "#2a2a37"),
    fg = get_hl_color("Normal", "fg", "#dcd7ba"),
    red = get_hl_color("DiagnosticError", "fg", "#ea6962"),
    green = get_hl_color("DiagnosticOk", "fg", "#89b482"),
    yellow = get_hl_color("DiagnosticWarn", "fg", "#d8a657"),
    blue = get_hl_color("Function", "fg", "#7daea3"),
    purple = get_hl_color("Keyword", "fg", "#d3869b"),
    aqua = get_hl_color("Type", "fg", "#7daea3"),
    orange = get_hl_color("Number", "fg", "#e78a4e"),
    gray = get_hl_color("Comment", "fg", "#928374"),
    border = get_hl_color("FloatBorder", "fg", "#45403d"),
    -- Special UI colors
    popup_bg = get_hl_color("Pmenu", "bg", "#282828"),
    select_bg = get_hl_color("PmenuSel", "bg", "#45403d"),
    select_fg = get_hl_color("PmenuSel", "fg", "#d4be98"),
    -- Special AI colors
    copilot = "#6CC644",
    codeium = "#09B6A2",
  }
end

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

-- Global UI configuration
M.config = {
  -- Standard float window configuration - base for all UI elements
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

-- Setup consistent highlights across all menus
M.setup_highlights = function()
  local colors = M.get_colors()
  local bg_color = is_transparency_enabled() and "NONE" or colors.bg

  -- Float window highlights
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.popup_bg })

  -- Completion menu
  -- Basic UI elements
  vim.api.nvim_set_hl(0, "CmpNormal", { bg = colors.bg })
  vim.api.nvim_set_hl(0, "CmpBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "CmpSel", { bg = colors.select_bg, fg = colors.select_fg, bold = true })
  vim.api.nvim_set_hl(0, "CmpGhostText", { fg = colors.gray, italic = true })

  -- AI source highlighting
  vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.copilot })
  vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.codeium })
  vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = colors.gray, italic = true })
  vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = colors.gray, italic = true })

  -- Diagnostic highlights
  vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = colors.red, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = colors.yellow, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = colors.blue, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = colors.green, bg = "NONE" })

  -- Notification highlights
  -- Set notification highlights to match theme
  vim.api.nvim_set_hl(0, "NotifyERROR", { fg = colors.red })
  vim.api.nvim_set_hl(0, "NotifyWARN", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "NotifyINFO", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "NotifyDEBUG", { fg = colors.gray })
  vim.api.nvim_set_hl(0, "NotifyTRACE", { fg = colors.purple })
  vim.api.nvim_set_hl(0, "NotifyBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NotifyBackground", { bg = colors.bg })

  -- Trigger refresh event for other components
  vim.api.nvim_exec_autocmds("User", { pattern = "UIColorsChanged" })
end

-- Debounced update system to prevent excessive redraws
local update_timer = nil
local function debounced_update(fn, delay)
  if update_timer then
    update_timer:stop()
  end
  update_timer = vim.defer_fn(function()
    fn()
    update_timer = nil
  end, delay or 50)
end

-- Central highlight update that coordinates all UI components
M.update_all_highlights = function()
  M.setup_highlights()

  -- Refresh UI components
  pcall(function()
    if package.loaded["lualine"] then
      require("lualine").refresh()
    end
  end)

  pcall(function()
    if package.loaded["bufferline"] then
      require("bufferline").setup()
    end
  end)

  -- Trigger refresh event for other components
  vim.api.nvim_exec_autocmds("User", { pattern = "UIColorsChanged" })
end

-- Initialize module
M.setup = function()
  -- Set up colorscheme-sensitive highlight groups
  M.setup_highlights()

  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      -- Single 50ms delay for all UI updates
      debounced_update(M.update_all_highlights, 50)
    end,
  })

  -- Expose get_ui_config function globally for other plugins
  _G.get_ui_config = function()
    return M.config
  end

  -- Expose get_colors function globally for other plugins
  _G.get_ui_colors = M.get_colors
end

return M
