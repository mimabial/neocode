-- lua/config/diagnostics.lua
-- Module to configure Neovim diagnostics settings
local M = {}

--- Configure global diagnostics settings
function M.setup()
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
        local signs = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = " ",
        }
        -- Return the icon prefix and default highlight
        return signs[d.severity] or "", ""
      end,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "",
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })
end

return M
