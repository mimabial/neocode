-- lua/config/ui.lua
-- Enhanced UI configuration with better theme integration

local M = {}

-- Get theme-consistent colors that adapt to the current colorscheme
M.get_colors = function()
  -- Use centralized color function from theme manager
  return _G.get_ui_colors and _G.get_ui_colors()
    or {
      -- Fallback values if theme manager isn't loaded yet
      bg = "#282828",
      bg1 = "#32302f",
      fg = "#d4be98",
      red = "#ea6962",
      green = "#89b482",
      yellow = "#d8a657",
      blue = "#7daea3",
      purple = "#d3869b",
      aqua = "#7daea3",
      orange = "#e78a4e",
      gray = "#928374",
      border = "#665c54",
    }
end

-- Global UI configuration
M.config = {
  -- Standard float window configuration - base for all UI elements
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

  -- Menu-specific configurations
  menu = {
    border = "single",
    selected_item_icon = "●",
    unselected_item_icon = "○",
  },

  -- Notification configuration
  notification = {
    border = "single",
    timeout = 3000,
    max_width = 60,
    max_height = 20,
    stages = "fade",
  },

  -- Consistent icons across UI
  icons = {
    diagnostics = {
      Error = " ",
      Warn = " ",
      Info = " ",
      Hint = " ",
    },
    git = {
      added = "",
      modified = "",
      removed = "",
    },
    kinds = {
      -- LSP kinds
      Class = "󰠱",
      Color = "󰏘",
      Constant = "󰏿",
      Constructor = "󰆧",
      Enum = "󰒻",
      EnumMember = "󰒻",
      Event = "󰉁",
      Field = "󰜢",
      File = "󰈙",
      Folder = "󰉋",
      Function = "󰊕",
      Interface = "󰕘",
      Keyword = "󰌋",
      Method = "󰆧",
      Module = "󰏗",
      Operator = "󰆕",
      Property = "󰜢",
      Reference = "󰈇",
      Snippet = "󰅪",
      Struct = "󰙅",
      Text = "󰉿",
      TypeParameter = "󰅲",
      Unit = "󰑭",
      Value = "󰎠",
      Variable = "󰀫",
      -- AI completion
      Copilot = "",
      Codeium = "󰚩",
    },
    stack = {
      goth = " ",
      nextjs = " ",
      ["goth+nextjs"] = " ",
    },
  },
}

-- Setup consistent highlights across all menus
M.setup_highlights = function()
  local colors = M.get_colors()

  -- Float window highlights
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.popup_bg or colors.bg })

  -- Menu highlights
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = colors.selection_bg, fg = colors.selection_fg, bold = true })
  vim.api.nvim_set_hl(0, "Pmenu", { bg = colors.popup_bg or colors.bg })
  vim.api.nvim_set_hl(0, "PmenuThumb", { bg = colors.border })

  -- Completion menu
  vim.api.nvim_set_hl(0, "CmpNormal", { bg = colors.popup_bg or colors.bg })
  vim.api.nvim_set_hl(0, "CmpBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "CmpSel", { bg = colors.selection_bg, fg = colors.selection_fg, bold = true })

  -- AI integration highlights
  vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.copilot or colors.green, bold = false })
  vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.codeium or colors.aqua, bold = false })

  -- LSP and completion kinds with consistent colors
  vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = colors.blue, bold = true })
  vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = colors.green })
  vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = colors.yellow, bold = true })
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
    end,
  })

  -- Expose get_ui_config function globally for other plugins
  _G.get_ui_config = function()
    return M.config
  end
end

return M
