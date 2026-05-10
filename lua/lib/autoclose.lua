-- Quit Neovim automatically when the only remaining (non-floating) windows
-- belong to filetypes in M.special_filetypes.

local M = {}

M.special_filetypes = {
  "NvimTree",
  "noice",
  "notify",
  "TelescopePrompt",
  "TelescopeResults",
  "TelescopePreview",
}

local function should_auto_close()
  local normal_wins = 0
  local special_wins = 0

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
      local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
      if vim.tbl_contains(M.special_filetypes, ft) then
        special_wins = special_wins + 1
      else
        normal_wins = normal_wins + 1
      end
    end
  end

  return normal_wins == 0 and special_wins > 0
end

function M.setup()
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("SmartAutoClose", { clear = true }),
    callback = function()
      if should_auto_close() then
        vim.cmd("silent! quit")
      end
    end,
    desc = "Auto-close Neovim when only special windows remain",
  })
end

return M
