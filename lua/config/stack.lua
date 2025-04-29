-- Stack configuration and detection
local M = {}

--- Detect which project stack is in use: GOTH (Go+Templ+HTMX), Next.js, React
---@return string|nil "goth", "nextjs", "react", or nil
function M.detect_stack()
  -- Detect GOTH stack (Go, Templ)
  if vim.fn.glob("*.go") ~= "" or vim.fn.glob("go.mod") ~= "" then
    if vim.fn.glob("*.templ") ~= "" or vim.fn.glob("templates/*.templ") ~= "" then
      return "goth"
    end
    return "goth" -- Default to GOTH if Go present
  end

  -- Detect Next.js stack
  if vim.fn.glob("next.config.js") ~= "" or vim.fn.glob("next.config.mjs") ~= "" then
    return "nextjs"
  end

  -- Detect React in package.json
  if vim.fn.glob("package.json") ~= "" then
    local pkg = vim.fn.readfile("package.json")
    local content = table.concat(pkg, "\n")
    if content:find('"react"') then
      if content:find('"next"') then
        return "nextjs"
      end
      return "react"
    end
  end

  return nil
end

--- Configure the Neovim environment for the given stack
---@param stack_name string|nil
---@return string actual_stack
function M.configure_stack(stack_name)
  stack_name = stack_name or M.detect_stack() or ""
  vim.g.current_stack = stack_name

  if stack_name == "goth" then
    vim.notify("Stack focused on GOTH (Go/Templ/HTMX)", vim.log.levels.INFO)
    -- Invoke GOTH-specific LSP setup
    if vim.fn.exists(':LspGOTH') == 2 then vim.cmd("LspGOTH") end

  elseif stack_name == "nextjs" then
    vim.notify("Stack focused on Next.js", vim.log.levels.INFO)
    -- Invoke Next.js-specific LSP setup
    if vim.fn.exists(':LspNextJS') == 2 then vim.cmd("LspNextJS") end

  else
    vim.notify("No specific stack configured", vim.log.levels.INFO)
  end

  -- Ensure correct explorer opens at project root
  if vim.g.default_explorer == "oil" and vim.fn.exists(':Oil') == 2 then
    vim.cmd("Oil .")
  end

  return stack_name
end

--- Initial setup: detect and store stack on startup
function M.setup()
  if not vim.g.current_stack or vim.g.current_stack == "" then
    local st = M.detect_stack()
    if st then
      vim.g.current_stack = st
      vim.defer_fn(function()
        vim.notify("Detected project type: " .. st, vim.log.levels.INFO)
      end, 1000)
    end
  end
end

return M
