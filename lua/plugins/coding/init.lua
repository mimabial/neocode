--------------------------------------------------------------------------------
-- Coding Enhancements
--------------------------------------------------------------------------------
--
-- This module loads all code-related enhancement plugins including:
-- 1. Completion (completions.lua)
-- 2. Snippets configuration (snippets.lua)
-- 3. AI assistance (ai.lua)
-- 4. Code refactoring tools (refactoring.lua)
--
-- These plugins work together to create a seamless coding experience with
-- intelligent suggestions, snippets, and AI assistance.
--------------------------------------------------------------------------------

return {
  -- Import all coding-related modules
  { import = "plugins.coding.completions" },
  { import = "plugins.coding.snippets" },
  { import = "plugins.coding.ai" },
  { import = "plugins.coding.refactoring" },
}
