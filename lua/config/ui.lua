-- lua/config/ui.lua
-- Enhanced UI configuration with better theme integration

local M = {}

-- Get theme-consistent colors that adapt to the current colorscheme
M.get_colors = function()
  -- Try theme-specific color functions first
  local theme_colors = nil

  if vim.g.colors_name == "gruvbox-material" and _G.get_gruvbox_colors then
    theme_colors = _G.get_gruvbox_colors()
  elseif vim.g.colors_name == "everforest" and _G.get_everforest_colors then
    theme_colors = _G.get_everforest_colors()
  elseif vim.g.colors_name == "kanagawa" and _G.get_kanagawa_colors then
    theme_colors = _G.get_kanagawa_colors()
  elseif vim.g.colors_name == "nord" and _G.get_nord_colors then
    theme_colors = _G.get_nord_colors()
  elseif vim.g.colors_name == "rose-pine" and _G.get_rose_pine_colors then
    theme_colors = _G.get_rose_pine_colors()
  end

  -- If we got valid theme colors, return them
  if theme_colors and type(theme_colors) == "table" then
    return theme_colors
  end

  -- Fallback to extracting from highlight groups
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

  -- Base gruvbox-compatible palette as fallback
  return {
    bg = get_hl_color("Normal", "bg", "#282828"),
    bg1 = get_hl_color("CursorLine", "bg", "#32302f"),
    fg = get_hl_color("Normal", "fg", "#d4be98"),
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
    selection_bg = get_hl_color("PmenuSel", "bg", "#45403d"),
    selection_fg = get_hl_color("PmenuSel", "fg", "#d4be98"),
    -- Special AI colors
    copilot = "#6CC644",
    codeium = "#09B6A2",
  }
end

-- Global UI configuration
M.config = {
  -- Standard float window configuration - base for all UI elements
  float = {
    border = "single", -- Consistent border style
    padding = { 0, 1 }, -- Consistent padding
    max_width = 80, -- Reasonable max width
    max_height = 20, -- Reasonable max height
    win_options = {
      winblend = 0, -- No transparency
      cursorline = true, -- Highlight current line
      signcolumn = "no", -- No sign column in floats
      wrap = false, -- No wrapping by default
    },
  },
}

-- Setup consistent highlights across all menus
M.setup_highlights = function()
  local colors = M.get_colors()

  -- Float window highlights
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.popup_bg })

  -- Menu highlights
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = colors.selection_bg, fg = colors.selection_fg, bold = true })
  vim.api.nvim_set_hl(0, "Pmenu", { bg = colors.popup_bg })
  vim.api.nvim_set_hl(0, "PmenuThumb", { bg = colors.border })

  -- Completion menu
  vim.api.nvim_set_hl(0, "CmpNormal", { bg = colors.popup_bg })
  vim.api.nvim_set_hl(0, "CmpBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "CmpSel", { bg = colors.selection_bg, fg = colors.selection_fg, bold = true })
  vim.api.nvim_set_hl(0, "CmpGhostText", { fg = colors.gray, italic = true })

  -- AI integration highlights
  vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.copilot, bold = false })
  vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.codeium, bold = false })
  vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = colors.gray, italic = true })
  vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = colors.gray, italic = true })

  -- LSP and completion kinds with consistent colors
  vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = colors.blue, bold = true })
  vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = colors.green })
  vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = colors.yellow, bold = true })
  vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = colors.purple })
  vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = colors.orange, bold = true })

  -- Notification highlights
  vim.api.nvim_set_hl(0, "NotifyERROR", { fg = colors.red })
  vim.api.nvim_set_hl(0, "NotifyWARN", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "NotifyINFO", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "NotifyDEBUG", { fg = colors.gray })
  vim.api.nvim_set_hl(0, "NotifyTRACE", { fg = colors.purple })

  -- Stack-specific syntax highlights
  if vim.g.current_stack == "goth" or vim.g.current_stack == "goth+nextjs" then
    vim.api.nvim_set_hl(0, "@type.go", { fg = colors.yellow, bold = true })
    vim.api.nvim_set_hl(0, "@function.go", { fg = colors.blue })
    vim.api.nvim_set_hl(0, "@attribute.htmx", { fg = colors.green, italic = true, bold = true })
    vim.api.nvim_set_hl(0, "@tag.attribute.htmx", { fg = colors.green, italic = true, bold = true })
  end

  if vim.g.current_stack == "nextjs" or vim.g.current_stack == "goth+nextjs" then
    vim.api.nvim_set_hl(0, "@tag.tsx", { fg = colors.red })
    vim.api.nvim_set_hl(0, "@tag.jsx", { fg = colors.red }) -- Added JSX support
    vim.api.nvim_set_hl(0, "@tag.delimiter.tsx", { fg = colors.orange })
    vim.api.nvim_set_hl(0, "@tag.delimiter.jsx", { fg = colors.orange }) -- Added JSX support
    vim.api.nvim_set_hl(0, "@constructor.tsx", { fg = colors.purple })
    vim.api.nvim_set_hl(0, "@constructor.jsx", { fg = colors.purple }) -- Added JSX support
  end
end

-- Initialize module
M.setup = function()
  -- Set up colorscheme-sensitive highlight groups
  M.setup_highlights()

  -- Update highlights when colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      M.setup_highlights()

      -- Refresh UI components that need to update with theme
      pcall(function()
        if package.loaded["lualine"] then
          require("lualine").refresh()
        end

        if package.loaded["bufferline"] then
          require("bufferline").setup()
        end
      end)
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
