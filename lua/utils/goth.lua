local M = {}

-- Utility functions for GOTH commands
local function find_main_go()
  local main_file = vim.fn.findfile("main.go", vim.fn.getcwd() .. "/**")
  if main_file == "" then
    vim.notify("Could not find main.go file", vim.log.levels.ERROR)
    return nil
  end
  return main_file
end

local function run_templ_generate()
  local result = vim.fn.system("templ generate")
  if vim.v.shell_error ~= 0 then
    vim.notify("Error generating templ files: " .. result, vim.log.levels.ERROR)
    return false
  end
  return true
end

return M
