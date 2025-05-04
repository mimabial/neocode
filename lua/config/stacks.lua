-- lua/config/stacks.lua
-- Improve the detect_stack function to be more resilient

local M = {}

-- Safely check for file existence with error handling
local function exists(patterns)
  local success, result = pcall(function()
    if type(patterns) == "string" then
      return vim.fn.glob(patterns) ~= ""
    end
    for _, pat in ipairs(patterns) do
      if vim.fn.glob(pat) ~= "" then
        return true
      end
    end
    return false
  end)

  if not success then
    vim.notify("[Stack Detection] Error checking for patterns: " .. vim.inspect(patterns), vim.log.levels.WARN)
    return false
  end

  return result
end

-- Enhanced stack detection with proper error handling
function M.detect_stack()
  -- Add error handling wrapper
  local ok, result = pcall(function()
    -- Check for GOTH stack
    local goth_detected = exists("*.go") or exists("go.mod") or exists("*.templ") or exists("**/components/*.templ")

    -- Check for Next.js stack
    local nextjs_detected = exists("next.config.js")
      or exists("next.config.mjs")
      or (exists("app") and exists("app/page.tsx"))
      or (exists("pages") and (exists("pages/*.tsx") or exists("pages/*.jsx")))

    -- Determine stack based on detections
    if goth_detected and nextjs_detected then
      return "both"
    elseif goth_detected then
      return "goth"
    elseif nextjs_detected then
      return "nextjs"
    end

    -- Default if no stack detected
    vim.notify("[Stack Detection] No specific stack detected, defaulting to generic mode", vim.log.levels.INFO)
    return "generic"
  end)

  if not ok then
    vim.notify(
      "[Stack Detection] Error: " .. tostring(result) .. ". Falling back to generic mode.",
      vim.log.levels.WARN
    )
    return "generic"
  end

  return result
end

-- Configure stack with improved error handling
function M.configure_stack(stack_name)
  -- Get stack name or auto-detect with fallback
  local stack = stack_name or M.detect_stack() or "generic"

  -- Set global for other modules
  if stack == "both" then
    vim.g.current_stack = "goth+nextjs"
  else
    vim.g.current_stack = stack
  end

  -- Stack-specific configuration
  -- (minimized for robustness - detailed config can go here)
  vim.notify("Stack configured: " .. stack, vim.log.levels.INFO)

  return stack
end

-- Initialize with basic error handling
function M.setup()
  local ok, stack = pcall(M.detect_stack)
  if ok and stack then
    pcall(M.configure_stack, stack)
  else
    -- Fallback to ensure we have a default stack
    vim.g.current_stack = "generic"
    vim.notify("[Stack] Detection failed, using generic configuration", vim.log.levels.WARN)
  end
end

return M
