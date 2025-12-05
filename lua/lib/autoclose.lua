-- Smart Auto-close Module
-- Automatically closes Neovim when only special windows remain
local M = {}

-- List of filetypes/buffers that should trigger auto-close when they're the only ones left
M.special_filetypes = {
  "NvimTree",
  "noice",
  "notify",
  "TelescopePrompt",
  "TelescopeResults",
  "TelescopePreview",
}

-- Check if Neovim should auto-close
local function should_auto_close()
  local wins = vim.api.nvim_list_wins()
  local normal_wins = 0
  local special_wins = 0

  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      local config = vim.api.nvim_win_get_config(win)

      -- Skip floating windows
      if config.relative == "" then
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype

        if vim.tbl_contains(M.special_filetypes, ft) then
          special_wins = special_wins + 1
        else
          normal_wins = normal_wins + 1
        end
      end
    end
  end

  -- Auto-close if only special windows remain (no normal windows)
  return normal_wins == 0 and special_wins > 0
end

-- Setup auto-close functionality
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
