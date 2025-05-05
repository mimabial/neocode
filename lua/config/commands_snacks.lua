local M = {}

function M.setup()
  vim.api.nvim_create_user_command("SnacksPicker", function()
    require("snacks.picker").files()
  end, { desc = "Open Snacks file picker" })
end

return M
