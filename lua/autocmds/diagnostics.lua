-- lua/autocmds/diagnostics.lua
local M = {}

-- Apply diagnostic highlights with current colors
local function apply_diagnostic_highlights()
  local colors = _G.get_ui_colors and _G.get_ui_colors()
    or {
      red = "#ea6962",
      yellow = "#d8a657",
      blue = "#7daea3",
      green = "#89b482",
    }

  -- Set all diagnostic highlight groups
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
end

function M.setup()
  -- 1) Define diagnostic signs with clear icons
  local signs = { Error = "", Warn = "", Info = "", Hint = "" }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- 2) Comprehensive diagnostic display configuration
  vim.diagnostic.config({
    virtual_text = {
      prefix = " ",
      spacing = 4,
      source = "if_many",
    },
    float = {
      border = "single",
      severity_sort = true,
      source = true,
      header = "",
      prefix = function(diagnostic)
        local icons = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = " ",
        }
        return icons[diagnostic.severity] or ""
      end,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- 3) Create diagnostic events group
  local diag_grp = vim.api.nvim_create_augroup("DiagnosticEvents", { clear = true })

  -- 4) Show diagnostic float on cursor hold
  vim.api.nvim_create_autocmd("CursorHold", {
    group = diag_grp,
    desc = "Show diagnostics popup on cursor hold",
    callback = function()
      vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "single",
        source = "always",
        prefix = " ",
        scope = "cursor",
      })
    end,
  })

  -- 5) Set up colorscheme-specific highlights
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = diag_grp,
    desc = "Update diagnostic highlights for current colorscheme",
    callback = apply_diagnostic_highlights,
  })

  -- 6) Apply highlights immediately at startup
  apply_diagnostic_highlights()
end

return M
