-- lua/utils/goth.lua
local M = {}

function M.find_main_go()
  local main_file = vim.fn.findfile("main.go", vim.fn.getcwd() .. "/**")
  if main_file == "" then
    vim.notify("Could not find main.go file", vim.log.levels.ERROR)
    return nil
  end
  return main_file
end

function M.run_templ_generate()
  if vim.fn.executable("templ") ~= 1 then
    vim.notify("templ command not found. Install templ first.", vim.log.levels.ERROR)
    return false
  end

  local result = vim.fn.system("templ generate")
  if vim.v.shell_error ~= 0 then
    vim.notify("Error generating templ files: " .. result, vim.log.levels.ERROR)
    return false
  end
  return true
end

return M
