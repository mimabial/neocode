local M = {}

-- Gets the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
function M.get_root()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws)
        return vim.uri_to_fname(ws.uri)
      end, workspace) or client.config.root_dir and { client.config.root_dir } or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if path:find(r, 1, true) then
          roots[#roots + 1] = r
        end
      end
    end
  end
  table.sort(roots, function(a, b)
    return #a > #b
  end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find({ ".git", "lua" }, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end

-- Returns the color value or fallback value from a highlight name
---@param hl_name string name of the highlight group
---@param attr string attribute like "fg" or "bg"
---@param fallback string fallback hex color value
function M.get_hl_color(hl_name, attr, fallback)
  local color = vim.api.nvim_get_hl(0, { name = hl_name })[attr]
  if not color then
    return fallback
  end

  -- Convert to hex
  if type(color) == "number" then
    color = string.format("#%06x", color)
  end

  return color or fallback
end

-- This function returns a string for a statusline component
-- that shows the current working directory in a limited space
function M.cwd()
  local cwd = vim.fn.getcwd()
  local home = os.getenv("HOME")
  if cwd:find(home, 1, true) == 1 then
    cwd = "~" .. cwd:sub(#home + 1)
  end
  return vim.fn.pathshorten(cwd)
end

-- Toggles between normal buffers and terminal
function M.toggle_term()
  local term_buffers = {}

  -- Find terminal buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].buftype == "terminal" then
      table.insert(term_buffers, bufnr)
    end
  end

  if #term_buffers == 0 then
    -- No terminal buffers exist, create one
    vim.cmd("terminal")
  else
    local current_bufnr = vim.api.nvim_get_current_buf()

    if vim.bo[current_bufnr].buftype == "terminal" then
      -- Currently in a terminal buffer, go back to previous
      vim.cmd("b#")
    else
      -- Switch to the first terminal buffer
      vim.cmd("buffer " .. term_buffers[1])
    end
  end
end

return M
