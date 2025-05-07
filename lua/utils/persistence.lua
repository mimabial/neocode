-- lua/utils/persistence.lua
-- Utility functions for persisting settings between Neovim sessions

local M = {}

-- Get the path to the cache directory
function M.get_cache_dir()
  return vim.fn.stdpath("cache")
end

-- Save data to a JSON file
function M.save_json(filename, data)
  local path = M.get_cache_dir() .. "/" .. filename
  local file = io.open(path, "w")
  if not file then
    vim.notify("Failed to write to " .. path, vim.log.levels.ERROR)
    return false
  end

  local ok, json = pcall(vim.fn.json_encode, data)
  if not ok then
    file:close()
    vim.notify("Failed to encode JSON data", vim.log.levels.ERROR)
    return false
  end

  file:write(json)
  file:close()
  return true
end

-- Load data from a JSON file
function M.load_json(filename, default)
  local path = M.get_cache_dir() .. "/" .. filename
  local file = io.open(path, "r")
  if not file then
    return default
  end

  local content = file:read("*all")
  file:close()

  if content == "" then
    return default
  end

  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok then
    vim.notify("Failed to decode JSON data from " .. path, vim.log.levels.WARN)
    return default
  end

  return data
end

-- Theme-specific functions
local theme_settings_file = "theme_settings.json"

-- Save theme settings
function M.save_theme_settings(settings)
  return M.save_json(theme_settings_file, settings)
end

-- Load theme settings
function M.load_theme_settings()
  local default_settings = {
    theme = "gruvbox-material",
    variant = "medium",
    transparency = false,
  }

  return M.load_json(theme_settings_file, default_settings)
end

return M
