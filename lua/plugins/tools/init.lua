--------------------------------------------------------------------------------
-- Development Tools
--------------------------------------------------------------------------------
--
-- This module loads all development tools including:
-- 1. Debugging (debug.lua)
-- 2. Git integration (git.lua)
-- 3. Terminal integration (terminal.lua)
-- 4. Database tools (database.lua)
--
-- These tools enhance the development workflow by providing integrated
-- access to common development utilities.
--------------------------------------------------------------------------------

return {
  -- Import all tool modules
  { import = "plugins.tools.debug" }, -- Already configured
  { import = "plugins.tools.git" }, -- Git integration
  { import = "plugins.tools.terminal" }, -- Terminal integration
  { import = "plugins.tools.database" }, -- Database tools
}
