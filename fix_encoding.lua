-- fix_encoding.lua
-- This script finds and replaces common encoding errors in Neovim config files

local function fix_encoding_in_file(file_path, replacements)
  local f = io.open(file_path, "r")
  if not f then
    print("Could not open file: " .. file_path)
    return false
  end

  local content = f:read("*all")
  f:close()

  local modified = false
  for from, to in pairs(replacements) do
    if content:find(from) then
      content = content:gsub(from, to)
      modified = true
    end
  end

  if modified then
    f = io.open(file_path, "w")
    if not f then
      print("Could not write to file: " .. file_path)
      return false
    end
    f:write(content)
    f:close()
    print("Fixed encoding issues in: " .. file_path)
    return true
  end

  return false
end

-- Common encoding fixes
local replacements = {
  ["Auvergne%-RhÃ´ne%-Alpes"] = "Auvergne-Rhône-Alpes",
}

-- Files to check
local files_to_check = {
  vim.fn.stdpath("config") .. "/init.lua",
  vim.fn.stdpath("config") .. "/lua/plugins/statusline.lua",
  vim.fn.stdpath("config") .. "/lua/config/options.lua",
}

-- Additional files that might contain web search or user location settings
for _, pattern in ipairs({ "**/search*.lua", "**/web*.lua", "**/location*.lua" }) do
  local found_files = vim.fn.glob(vim.fn.stdpath("config") .. "/" .. pattern, false, true)
  for _, file in ipairs(found_files) do
    table.insert(files_to_check, file)
  end
end

local fixed_any = false
for _, file in ipairs(files_to_check) do
  if fix_encoding_in_file(file, replacements) then
    fixed_any = true
  end
end

if not fixed_any then
  print("No encoding issues found in standard configuration files.")
  print("The issue might be in a plugin or extension file not checked.")
end
