local M = {}

M.get_colors = function()
  -- Try theme-specific color functions first
  local theme_colors = nil

  if vim.g.colors_name == "gruvbox" and _G.get_gruvbox_colors then
    theme_colors = _G.get_gruvbox_colors()
  elseif vim.g.colors_name == "gruvbox-material" and _G.get_gruvbox_colors then
    theme_colors = _G.get_gruvbox_colors()
  elseif vim.g.colors_name == "everforest" and _G.get_everforest_colors then
    theme_colors = _G.get_everforest_colors()
  elseif vim.g.colors_name == "kanagawa" and _G.get_kanagawa_colors then
    theme_colors = _G.get_kanagawa_colors()
  elseif vim.g.colors_name == "nord" and _G.get_nord_colors then
    theme_colors = _G.get_nord_colors()
  elseif vim.g.colors_name == "rose-pine" and _G.get_rose_pine_colors then
    theme_colors = _G.get_rose_pine_colors()
  elseif vim.g.colors_name == "solarized-osaka" then
    -- Determine which solarized variant based on settings and background
    local cache_dir = vim.fn.stdpath("cache")
    local settings_file = cache_dir .. "/theme_settings.json"
    local variant = "osaka" -- default
    -- Try to read the saved variant
    if vim.fn.filereadable(settings_file) == 1 then
      local content = vim.fn.readfile(settings_file)
      if #content > 0 then
        local ok, parsed = pcall(vim.fn.json_decode, content[1])
        if ok and parsed and parsed.theme == "solarized" and parsed.variant then
          variant = parsed.variant
        end
      end
    end
    -- Use appropriate color function based on variant
    if variant == "light" and _G.get_solarized_light_colors then
      theme_colors = _G.get_solarized_light_colors()
    elseif variant == "dark" and _G.get_solarized_dark_colors then
      theme_colors = _G.get_solarized_dark_colors()
    elseif variant == "osaka" and _G.get_solarized_osaka_colors then
      theme_colors = _G.get_solarized_osaka_colors()
    end
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

  -- Menu highlights
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = colors.selection_bg, fg = colors.selection_fg, bold = true })
  vim.api.nvim_set_hl(0, "Pmenu", { bg = colors.popup_bg })
  vim.api.nvim_set_hl(0, "PmenuThumb", { bg = colors.border })

  -- Bufferline highlights
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

  -- Completion menu
  -- Basic UI elements
  vim.api.nvim_set_hl(0, "CmpNormal", { bg = colors.bg })
  vim.api.nvim_set_hl(0, "CmpBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "CmpSel", { bg = colors.select_bg, fg = colors.select_fg, bold = true })
  vim.api.nvim_set_hl(0, "CmpGhostText", { fg = colors.gray, italic = true })

  -- AI source highlighting
  vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.copilot })
  vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.codeium })

  -- LSP kinds with subtle color variations
  vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = colors.blue, bold = true })
  vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = colors.green })
  vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = colors.yellow, bold = true })
  vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = colors.purple })
  vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = colors.orange, bold = true })

  -- Other sources with distinctive colors
  vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = colors.green, italic = true })
  vim.api.nvim_set_hl(0, "CmpItemKindBuffer", { fg = colors.gray })
  vim.api.nvim_set_hl(0, "CmpItemKindPath", { fg = colors.orange })

  -- Enhanced highlight groups for selected items
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.green, bold = true })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.green, bold = true })

  -- Create distinct highlighting for selected items
  vim.api.nvim_set_hl(0, "CmpSel", { bg = colors.select_bg, fg = colors.select_fg, bold = true })
  vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = colors.gray, strikethrough = true })

  -- Create special highlights for selected items
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.green, bold = true })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.green, bold = true })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatchSelected", { fg = colors.yellow, bg = colors.select_bg, bold = true })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzySelected", { fg = colors.yellow, bg = colors.select_bg, bold = true })

  -- Menu appearance for selected vs non-selected items
  vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.gray, italic = true })
  vim.api.nvim_set_hl(0, "CmpItemMenuSelected", { fg = colors.fg, bg = colors.select_bg, italic = true, bold = true })

  -- Diagnostic highlights
  vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = colors.red, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = colors.yellow, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = colors.blue, bg = "NONE" })
  vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = colors.green, bg = "NONE" })

  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = colors.red })
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = colors.green })

  vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = colors.red })
  vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = colors.green })

  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = colors.red })
  vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = colors.green })

  -- AI integration highlights
  vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.copilot, bold = false })
  vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.codeium, bold = false })
  vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = colors.gray, italic = true })
  vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = colors.gray, italic = true })

  -- Notification highlights
  -- Set notification highlights to match theme
  vim.api.nvim_set_hl(0, "NotifyERROR", { fg = colors.red })
  vim.api.nvim_set_hl(0, "NotifyWARN", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "NotifyINFO", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "NotifyDEBUG", { fg = colors.gray })
  vim.api.nvim_set_hl(0, "NotifyTRACE", { fg = colors.purple })
  vim.api.nvim_set_hl(0, "NotifyBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NotifyBackground", { bg = colors.bg })

  -- Make sure notification title and background match theme too
  vim.api.nvim_set_hl(0, "NotifyERRORTitle", { fg = colors.red, bg = colors.bg })
  vim.api.nvim_set_hl(0, "NotifyWARNTitle", { fg = colors.yellow, bg = colors.bg })
  vim.api.nvim_set_hl(0, "NotifyINFOTitle", { fg = colors.blue, bg = colors.bg })
  vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { fg = colors.gray, bg = colors.bg })
  vim.api.nvim_set_hl(0, "NotifyTRACETitle", { fg = colors.purple, bg = colors.bg })

  -- Set notification content background
  vim.api.nvim_set_hl(0, "NotifyERRORBody", { bg = colors.bg })
  vim.api.nvim_set_hl(0, "NotifyWARNBody", { bg = colors.bg })
  vim.api.nvim_set_hl(0, "NotifyINFOBody", { bg = colors.bg })
  vim.api.nvim_set_hl(0, "NotifyDEBUGBody", { bg = colors.bg })
  vim.api.nvim_set_hl(0, "NotifyTRACEBody", { bg = colors.bg })

  -- Telescope highlights
  vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.blue, bold = true })
  vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.blue })

  -- Stack-specific syntax highlights
  if vim.g.current_stack == "goth" then
    vim.api.nvim_set_hl(0, "@type.go", { fg = colors.yellow, bold = true })
    vim.api.nvim_set_hl(0, "@function.go", { fg = colors.blue })
    vim.api.nvim_set_hl(0, "@attribute.htmx", { fg = colors.green, italic = true, bold = true })
    vim.api.nvim_set_hl(0, "@tag.attribute.htmx", { fg = colors.green, italic = true, bold = true })
  end

  if vim.g.current_stack == "nextjs" then
    vim.api.nvim_set_hl(0, "@tag.tsx", { fg = colors.red })
    vim.api.nvim_set_hl(0, "@tag.jsx", { fg = colors.red })              -- Added JSX support
    vim.api.nvim_set_hl(0, "@tag.delimiter.tsx", { fg = colors.orange })
    vim.api.nvim_set_hl(0, "@tag.delimiter.jsx", { fg = colors.orange }) -- Added JSX support
    vim.api.nvim_set_hl(0, "@constructor.tsx", { fg = colors.purple })
    vim.api.nvim_set_hl(0, "@constructor.jsx", { fg = colors.purple })   -- Added JSX support
  end

  -- Trigger refresh event for other components
  vim.api.nvim_exec_autocmds("User", { pattern = "UIColorsChanged" })
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
