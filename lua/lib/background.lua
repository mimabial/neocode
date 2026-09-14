-- Guarded 'background' writes.
-- Setting 'background' makes Neovim re-source the colorscheme named by
-- vim.g.colors_name. Snapshot and pywal definitions set that name to match a
-- lazy-managed plugin, so the re-source fires lazy's ColorSchemePre handler,
-- which loads the very plugin the definition exists to replace — along with
-- everything that plugin's setup pulls in. Drop the name across the write;
-- every caller applies its own highlights immediately after.
local M = {}

function M.set(background)
  local scheme = vim.g.colors_name
  vim.g.colors_name = nil
  vim.o.background = background
  vim.g.colors_name = scheme
end

return M
