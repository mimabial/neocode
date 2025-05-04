-- lua/config/utils_extras.lua
-- Additional utility functions extracted from previous config

local M = {}
local fn = vim.fn

--- Get the current file name or fallback
---@return string
function M.filename()
  local f = fn.expand("%:t")
  return (f ~= "" and f) or "[No Name]"
end

--- Return fileformat and encoding
---@return string
function M.fileinfo()
  local fmt = vim.bo.fileformat or vim.o.fileformat
  local enc = vim.bo.fileencoding or vim.o.encoding
  return fmt .. " | " .. enc
end

--- Count search hits for statusline
---@return string
function M.search_count()
  local sc = fn.searchcount({ maxcount = 999, timeout = 500 })
  if vim.v.hlsearch == 1 and sc.total > 0 then
    return string.format("[%d/%d]", sc.current, sc.total)
  end
  return ""
end

--- Get current Git branch (prefixed)
---@return string
function M.git_branch()
  local branch = fn.systemlist("git rev-parse --abbrev-ref HEAD")[1] or ""
  return (branch ~= "" and " " .. branch) or ""
end

--- Execute a shell command and trim whitespace
---@param cmd string
---@return string
function M.exec_cmd(cmd)
  local ok, out = pcall(fn.system, cmd)
  if not ok then
    return ""
  end
  return out and out:gsub("^%s*(.-)%s*$", "%1") or ""
end

--- Check if a file or directory exists
---@param path string
---@return boolean
function M.file_exists(path)
  return vim.loop.fs_stat(path) ~= nil
end

--- Join paths with '/'
---@param ... string
---@return string
function M.join_paths(...)
  return table.concat({ ... }, "/")
end

--- Get current date in YYYY-MM-DD format
---@return string
function M.get_date()
  -- os.date may return a table (if you pass "*t") or string, so force a string
  local d = os.date("%Y-%m-%d")
  if type(d) == "string" then
    return d
  end
  return ""
end

--- Get visual selection text
---@return string
function M.get_visual_selection()
  local save_reg, save_type = fn.getreg("v"), fn.getregtype("v")
  vim.cmd('noau normal! gv"vy')
  local txt = fn.getreg("v") or ""
  fn.setreg("v", save_reg, save_type)
  -- gsub returns multiple values; capture only the transformed string
  local res = txt:gsub("\r?\n?%s*$", "")
  return res
end

return M
