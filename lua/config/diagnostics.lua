local icons = require("lib.icons")

local M = { hover_enabled = true }

local default_options = {
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
      return icons.diagnostic_signs[diagnostic.severity] or ""
    end,
  },
  signs = { text = icons.diagnostic_signs },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
}

function M.reset()
  vim.diagnostic.config(vim.deepcopy(default_options))
end

function M.toggle_display()
  local current = vim.diagnostic.config() or {}
  local enabled = current.virtual_text ~= false or current.signs ~= false or current.underline ~= false
  local options = vim.deepcopy(default_options)
  if enabled then
    options.virtual_text = false
    options.signs = false
    options.underline = false
  end
  vim.diagnostic.config(options)
  vim.notify("Diagnostics " .. (enabled and "disabled" or "enabled"), vim.log.levels.INFO)
end

function M.toggle_hover()
  M.hover_enabled = not M.hover_enabled
  vim.notify("Diagnostics hover " .. (M.hover_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

function M.setup()
  M.reset()
  vim.api.nvim_create_user_command("DiagnosticsReset", function()
    M.reset()
    vim.notify("Diagnostics reset and reapplied", vim.log.levels.INFO)
  end, { desc = "Reset and reapply diagnostics" })
  vim.api.nvim_create_user_command("DiagnosticsToggle", M.toggle_display, { desc = "Toggle diagnostic display" })
end

return M
