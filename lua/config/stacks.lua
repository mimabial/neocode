-- lua/config/stack.lua
-- Project stack detection and configuration (GOTH, Next.js, React)
local M = {}

local fn = vim.fn
local api = vim.api

--- Checks if any file matching patterns exists in cwd
-- @param patterns string|table  file pattern(s) to check
-- @return boolean
local function exists(patterns)
  if type(patterns) == "string" then
    return fn.glob(patterns) ~= ""
  end
  for _, pat in ipairs(patterns) do
    if fn.glob(pat) ~= "" then
      return true
    end
  end
  return false
end

--- Detect current project stack
-- @return string|nil  "goth", "nextjs", "react" or nil
function M.detect_stack()
  -- GOTH stack with multiple indicators
  if exists({ "*.go", "go.mod", "go.sum" }) then
    if exists({ "*.templ", "*htmx*", "*components*" }) then
      return "goth"
    end

    -- Check Go files for HTMX/Templ imports
    local gofiles = fn.glob("*.go", false, true)
    for _, file in ipairs(gofiles) do
      local content = table.concat(fn.readfile(file, "", 50), "\n")
      if content:match("html/template") or content:match("htmx") then
        return "goth"
      end
    end

    return "goth" -- Fallback - Go files present
  end

  -- Next.js detection with multiple checks
  if exists({ "next.config.js", "next.config.mjs" }) then
    return "nextjs"
  end

  if exists("pages") and exists("pages/api") then
    return "nextjs"
  end

  -- React (fallback if package.json contains React)
  if exists("package.json") then
    local lines = fn.readfile("package.json")
    local content = table.concat(lines, " ")
    if content:match([[
      "react"  -- simple substring, catches dependencies
    ]]) then
      -- if Next.js is also present, prefer nextjs
      if content:match([[
        "next"
      ]]) then
        return "nextjs"
      end
      return "react"
    end
  end

  return nil
end

--- Apply configuration for a given stack
-- @param stack_name string|nil
-- @return string  actual stack set ("goth", "nextjs", "react", or "")
function M.configure_stack(stack_name)
  local stack = stack_name or M.detect_stack() or ""
  vim.g.current_stack = stack

  if stack == "goth" then
    api.nvim_notify("Stack focused on GOTH (Go/Templ/HTMX)", vim.log.levels.INFO, { title = "Stack" })
    if fn.exists(":LspGOTH") == 2 then
      api.nvim_command("LspGOTH")
    end
  elseif stack == "nextjs" then
    api.nvim_notify("Stack focused on Next.js", vim.log.levels.INFO, { title = "Stack" })
    if fn.exists(":LspNextJS") == 2 then
      api.nvim_command("LspNextJS")
    end
  else
    api.nvim_notify("No specific stack configured", vim.log.levels.INFO, { title = "Stack" })
  end

  -- Open project explorer at root via configured command
  if vim.g.default_explorer then
    api.nvim_command("ExplorerToggle " .. vim.g.default_explorer)
  end

  return vim.g.current_stack
end

--- Initial setup on startup: detect stack and notify
function M.setup()
  if not vim.g.current_stack or vim.g.current_stack == "" then
    local st = M.detect_stack()
    if st then
      vim.g.current_stack = st
      vim.defer_fn(function()
        api.nvim_notify("Detected project type: " .. st, vim.log.levels.INFO, { title = "Stack" })
      end, 500)
    end
  end
end

return M
