local M = {}

function M.setup()
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
          [vim.diagnostic.severity.ERROR] = " ", -- nf-fa-times_circle
          [vim.diagnostic.severity.WARN] = " ",  -- nf-fa-exclamation_triangle
          [vim.diagnostic.severity.INFO] = " ",  -- nf-fa-info_circle
          [vim.diagnostic.severity.HINT] = " ",  -- nf-mdi-lightbulb_outline
        }
        return icons[diagnostic.severity] or ""
      end,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "",
      }
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- Create diagnostic events group
  local diag_grp = vim.api.nvim_create_augroup("DiagnosticEvents", { clear = true })

  -- Show diagnostic float on cursor hold
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

  -- Add a command to reset diagnostics if needed
  vim.api.nvim_create_user_command("DiagnosticsReset", function()
    vim.diagnostic.config(vim.diagnostic.config())
    vim.notify("Diagnostics reset and reapplied", vim.log.levels.INFO)
  end, { desc = "Reset and reapply diagnostics" })
end

return M
