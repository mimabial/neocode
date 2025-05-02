-- lua/config/diagnostics.lua
-- Module to configure Neovim diagnostics settings with organized autocmds and customizable highlights
local M = {}

--- Configure global diagnostics settings and handlers
function M.setup()
  -- 1) Define diagnostic signs
  local signs = { Error = "", Warn = "", Info = "", Hint = "" }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- 2) Diagnostic display configuration
  vim.diagnostic.config({
    virtual_text = {
      prefix = "●",
      spacing = 4,
      severity = { min = vim.diagnostic.severity.HINT },
      source = "if_many",
    },
    float = {
      border = "rounded",
      severity_sort = true,
      source = true,
      header = "",
      prefix = function(diagnostic)
        -- Use a space icon per severity
        local icons = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = " ",
        }
        return icons[diagnostic.severity] or "", ""
      end,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- 3) Autocmd group for diagnostics events
  local diag_grp = vim.api.nvim_create_augroup("DiagnosticEvents", { clear = true })

  -- Show diagnostic float on CursorHold
  vim.api.nvim_create_autocmd("CursorHold", {
    group = diag_grp,
    desc = "Show diagnostics popup on cursor hold",
    callback = function()
      vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "always",
        prefix = " ",
        scope = "cursor",
      })
    end,
  })

  -- Adjust highlighting when colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = diag_grp,
    desc = "Customize diagnostic highlight colors for gruvbox-material",
    callback = function()
      if vim.g.colors_name == "gruvbox-material" then
        -- Attempt to fetch gruvbox colors, fallback to defaults
        local colors = (_G.get_gruvbox_colors and _G.get_gruvbox_colors())
          or {
            red = "#ea6962",
            orange = "#e78a4e",
            yellow = "#d8a657",
            green = "#89b482",
            aqua = "#7daea3",
          }
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = colors.red })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = colors.yellow })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = colors.aqua })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = colors.green })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = colors.red })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = colors.yellow })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = colors.aqua })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = colors.green })
      end
    end,
  })
end

return M
