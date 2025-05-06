-- lua/config/autocmds.lua
-- Re-export Autocmds from autocmds.init

local M = {}

-- Get autocmds from the correct location
local autocmds_ok, autocmds = pcall(require, "autocmds.init")

-- Re-export all functions from autocmds.init
for k, v in pairs(autocmds) do
  M[k] = v
end

-- Export the module
return M
