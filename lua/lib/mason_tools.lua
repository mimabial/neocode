local M = {}

local function is_available(package_name)
  return vim.fn.executable(package_name) == 1 or require("mason-registry").is_installed(package_name)
end

function M.ensure_available(package_names, on_available)
  on_available = on_available or function() end
  local missing = {}
  for _, package_name in ipairs(package_names) do
    if is_available(package_name) then
      on_available(package_name)
    else
      table.insert(missing, package_name)
    end
  end
  if #missing == 0 then
    return
  end

  local registry = require("mason-registry")
  registry.refresh(vim.schedule_wrap(function()
    for _, package_name in ipairs(missing) do
      registry.get_package(package_name):install({}, vim.schedule_wrap(function(installed)
        if installed then
          on_available(package_name)
        end
      end))
    end
  end))
end

return M
