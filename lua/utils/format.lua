local M = {}

function M.check_templ_supports_stdin()
  local handle = io.popen("templ version 2>&1")
  if not handle then
    return false
  end
  local result = handle:read("*a")
  handle:close()

  local major, minor = result:match("v(%d+)%.(%d+)")
  if major and minor then
    return tonumber(major) > 0 or (tonumber(major) == 0 and tonumber(minor) >= 2)
  end
  return false
end

return M
