-- lua/config/stacks.lua
-- Enhanced project stack detection and configuration

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

--- Detect current project stack with more accurate heuristics
-- @return string  "goth", "nextjs", or nil
function M.detect_stack()
  -- GOTH stack indicators
  if exists({ "*.go", "go.mod", "go.sum" }) then
    if exists({ "*.templ", "**/components/*.templ", "**/templates/*.templ" }) then
      return "goth"
    end

    -- Check Go files for HTMX/Templ imports or usage
    local gofiles = fn.glob("**/*.go", false, true)
    for _, file in ipairs(gofiles) do
      local content = table.concat(fn.readfile(file, "", 50), "\n")
      if content:match("html/template") or content:match("htmx") or content:match("templ") then
        return "goth"
      end
    end

    -- Look for HTMX in the project
    if exists({ "**/htmx*.js", "**/static/**/htmx*.js" }) then
      return "goth"
    end

    -- Default for Go projects without strong indicators
    return "goth"
  end

  -- Next.js detection
  if exists({ "next.config.js", "next.config.mjs", "next.config.ts" }) then
    return "nextjs"
  end

  -- App directory structure for newer Next.js
  if exists("app") and exists({ "app/layout.tsx", "app/page.tsx" }) then
    return "nextjs"
  end

  -- Pages directory structure for traditional Next.js
  if exists("pages") and exists({ "pages/index.tsx", "pages/index.jsx", "pages/_app.tsx" }) then
    return "nextjs"
  end

  -- Check package.json for Next.js dependency
  if exists("package.json") then
    local lines = fn.readfile("package.json")
    local content = table.concat(lines, " ")
    if content:match([["next"]]) then
      return "nextjs"
    end
  end

  return nil
end

--- Apply configuration for a given stack
-- @param stack_name string|nil  Stack name or nil to auto-detect
function M.configure_stack(stack_name)
  local stack = stack_name or M.detect_stack() or ""

  -- Store globally for access by other modules
  vim.g.current_stack = stack

  -- Configure for GOTH stack
  if stack == "goth" then
    -- Load GOTH-specific LSP and tools
    api.nvim_notify("Stack focused on GOTH (Go/Templ/HTMX)", vim.log.levels.INFO, { title = "Stack" })

    -- Ensure gopls is configured optimally
    local lspconfig = require("lspconfig")
    if lspconfig.gopls then
      lspconfig.gopls.setup({
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
              fieldalignment = true,
            },
            staticcheck = true,
            gofumpt = true,
            usePlaceholders = true,
            completeUnimported = true,
          },
        },
      })
    end

    -- Set Templ LSP if available
    if lspconfig.templ then
      lspconfig.templ.setup({})
    end

    -- Configure formatters for Go/Templ
    pcall(function()
      require("conform").setup({
        formatters_by_ft = {
          go = { "gofumpt", "goimports" },
          templ = { "templ" },
        },
      })
    end)

  -- Configure for Next.js stack
  elseif stack == "nextjs" then
    api.nvim_notify("Stack focused on Next.js", vim.log.levels.INFO, { title = "Stack" })

    -- Configure TypeScript LSP with optimal settings
    local lspconfig = require("lspconfig")
    if lspconfig.tsserver then
      lspconfig.tsserver.setup({
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })
    end

    -- Setup ESLint if available
    if lspconfig.eslint then
      lspconfig.eslint.setup({})
    end

    -- Configure formatters for JS/TS
    pcall(function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettierd", "prettier" },
          typescript = { "prettierd", "prettier" },
          javascriptreact = { "prettierd", "prettier" },
          typescriptreact = { "prettierd", "prettier" },
          css = { "prettierd", "prettier" },
          html = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          yaml = { "prettierd", "prettier" },
        },
      })
    end)
  else
    api.nvim_notify("No specific stack detected", vim.log.levels.INFO, { title = "Stack" })
  end

  -- Return the configured stack
  return stack
end

--- Initial setup on startup: detect stack and notify
function M.setup()
  if not vim.g.current_stack or vim.g.current_stack == "" then
    local st = M.detect_stack()
    if st then
      vim.g.current_stack = st
      vim.defer_fn(function()
        api.nvim_notify("Detected project stack: " .. st, vim.log.levels.INFO, { title = "Stack" })
      end, 500)
    end
  end

  -- Add command for stack switching
  vim.api.nvim_create_user_command("StackFocus", function(opts)
    M.configure_stack(opts.args)
  end, {
    nargs = "?",
    desc = "Focus on a specific tech stack",
    complete = function()
      return { "goth", "nextjs" }
    end,
  })

  -- Add keybindings for stack switching
  vim.keymap.set("n", "<leader>usg", function()
    M.configure_stack("goth")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, { desc = "Focus GOTH Stack + Dashboard" })

  vim.keymap.set("n", "<leader>usn", function()
    M.configure_stack("nextjs")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, { desc = "Focus Next.js Stack + Dashboard" })
end

return M
