-- lua/config/commands.lua
-- Re-export user commands from commands.init

local M = {}

-- Get commands from the correct location
local commands_ok, commands = pcall(require, "commands.init")

-- Re-export all functions from utils.init
for k, v in pairs(commands) do
  M[k] = v
end

-- Export the module
return M
