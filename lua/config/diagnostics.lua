-- lua/config/diagnostics.lua
-- Module to configure Neovim diagnostics settings
local M = {}

--- Configure global diagnostics settings
function M.setup()
  -- Define diagnostic signs
  local signs = { Error = "", Warn = "", Info = "", Hint = "" }

  -- Apply the signs
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- Configure diagnostics display
  vim.diagnostic.config({
    virtual_text = {
      prefix = "●",
      severity = { min = vim.diagnostic.severity.HINT },
      source = "if_many",
      spacing = 4,
    },
    float = {
      border = "rounded",
      severity_sort = true,
      source = true,
      header = "",
      prefix = function(d)
        local icons = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = " ",
        }
        -- Return the icon prefix and default highlight
        return icons[d.severity] or "", ""
      end,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- Make hover diagnostic window borders rounded
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

  -- Apply the same to signature help
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

  -- Create autocmd to show diagnostic float on cursor hold
  vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
      local float_opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "always",
        prefix = " ",
        scope = "cursor",
      }
      vim.diagnostic.open_float(nil, float_opts)
    end,
  })

  -- Integrate with gruvbox-material for better colors
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      if vim.g.colors_name == "gruvbox-material" then
        local colors = _G.get_gruvbox_colors and _G.get_gruvbox_colors()
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
