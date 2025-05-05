-- lua/config/utils.lua
-- Re-export utility functions from utils.init

local M = {}

-- Get utils from the correct location
local utils_ok, utils = pcall(require, "utils.utils")
if not utils_ok then
  vim.notify("Failed to load utils.utils module. Some features may not work.", vim.log.levels.WARN)
  -- Fallback implementations for critical functions

  -- Fallback for get_hl_color (used by lualine)
  M.get_hl_color = function(group, attr, fallback)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
    local val = ok and hl[attr]
    if not val then
      return fallback
    end
    if type(val) == "number" then
      return string.format("#%06x", val)
    end
    return tostring(val)
  end

  -- Other fallback utility functions
  M.cwd = function()
    local cwd = vim.fn.getcwd()
    local home = os.getenv("HOME") or ""
    if home ~= "" and cwd:sub(1, #home) == home then
      return "~" .. cwd:sub(#home + 1)
    end
    return vim.fn.pathshorten(cwd)
  end

  M.search_count = function()
    local sc = vim.fn.searchcount({ maxcount = 999, timeout = 500 })
    if vim.v.hlsearch == 1 and sc.total > 0 then
      return string.format("[%d/%d]", sc.current, sc.total)
    end
    return ""
  end

  return M
end

-- Re-export all functions from utils.utils
for k, v in pairs(utils) do
  M[k] = v
end

-- Export the module
return M
