-- lua/config/stacks.lua
-- Enhanced and fail-safe stack detection for GOTH and Next.js

local M = {}

local fn = vim.fn
local api = vim.api

--- Safely load a module
local function safe_require(mod)
  local ok, result = pcall(require, mod)
  if not ok then
    return nil
  end
  return result
end

-- Modified icons for consistent appearance
local stack_icons = {
  ["goth"] = "󰟓 ",
  ["nextjs"] = " ",
  ["both"] = "󰡄 ",
}

--- Checks if any file matching patterns exists in cwd
-- @param patterns string|table file pattern(s) to check
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

--- Search file contents for pattern
-- @param file string file path
-- @param pattern string pattern to search for
-- @param max_lines number max lines to check
-- @return boolean
local function file_contains(file, pattern, max_lines)
  max_lines = max_lines or 100
  if fn.filereadable(file) == 0 then
    return false
  end

  local lines = fn.readfile(file, "", max_lines)
  local content = table.concat(lines, "\n")
  return content:match(pattern) ~= nil
end

--- Detect current project stack with more accurate heuristics
-- @return string "goth", "nextjs", "both" or nil
function M.detect_stack()
  local stacks = {}

  -- GOTH stack indicators
  local goth_score = 0

  -- Check for Go files
  if exists({ "*.go", "go.mod", "go.sum" }) then
    goth_score = goth_score + 2
  end

  -- Check for Templ files
  if exists({ "*.templ", "**/components/*.templ", "**/templates/*.templ" }) then
    goth_score = goth_score + 3
  end

  -- Check for HTMX usage
  if exists({ "**/htmx*.js", "**/static/**/htmx*.js" }) then
    goth_score = goth_score + 2
  end

  -- Check Go imports/usage related to HTMX/Templ
  local gofiles = fn.glob("**/*.go", false, true)
  for _, file in ipairs(gofiles) do
    if file_contains(file, "html/template") or file_contains(file, "htmx") or file_contains(file, "templ") then
      goth_score = goth_score + 2
      break
    end
  end

  -- Check HTML files for HTMX attributes
  local htmlfiles = fn.glob("**/*.html", false, true)
  for _, file in ipairs(htmlfiles) do
    if file_contains(file, "hx%-") then
      goth_score = goth_score + 2
      break
    end
  end

  -- Next.js detection
  local nextjs_score = 0

  -- Direct Next.js indicators
  if exists({ "next.config.js", "next.config.mjs", "next.config.ts" }) then
    nextjs_score = nextjs_score + 3
  end

  -- App directory structure for newer Next.js
  if exists("app") and exists({ "app/layout.tsx", "app/page.tsx" }) then
    nextjs_score = nextjs_score + 3
  end

  -- Pages directory structure for traditional Next.js
  if exists("pages") and exists({ "pages/index.tsx", "pages/index.jsx", "pages/_app.tsx" }) then
    nextjs_score = nextjs_score + 3
  end

  -- Check package.json for Next.js dependency
  if exists("package.json") then
    if file_contains("package.json", [["next"]]) then
      nextjs_score = nextjs_score + 3
    end
  end

  -- Check for React components
  if exists({ "**/*.tsx", "**/*.jsx" }) then
    nextjs_score = nextjs_score + 1
  end

  -- Check for TypeScript configuration
  if exists({ "tsconfig.json" }) then
    nextjs_score = nextjs_score + 1
  end

  -- Check for Tailwind usage
  if exists({ "tailwind.config.js" }) or file_contains("package.json", "tailwindcss") then
    nextjs_score = nextjs_score + 1
  end

  -- Determine the result based on scores
  if goth_score >= 4 and nextjs_score >= 4 then
    return "both"
  elseif goth_score >= 4 then
    return "goth"
  elseif nextjs_score >= 4 then
    return "nextjs"
  end

  -- Default to nil if no clear stack detected
  return nil
end

--- Apply configuration for a given stack
-- @param stack_name string|nil Stack name or nil to auto-detect
function M.configure_stack(stack_name)
  local stack = stack_name or M.detect_stack() or ""
  local notify_icon = ""

  -- Store globally for access by other modules
  if stack == "both" then
    vim.g.current_stack = "goth+nextjs"
    notify_icon = "󰡄 "
  else
    vim.g.current_stack = stack
    if stack == "goth" then
      notify_icon = "󰟓 "
    elseif stack == "nextjs" then
      notify_icon = " "
    end
  end

  -- Configure for GOTH stack
  if stack == "goth" or stack == "both" then
    -- Load GOTH-specific LSP and tools
    api.nvim_notify(notify_icon .. "Stack focused on GOTH (Go/Templ/HTMX)", vim.log.levels.INFO, { title = "Stack" })

    -- Ensure gopls is configured optimally
    local lspconfig = safe_require("lspconfig")
    if lspconfig and lspconfig.gopls then
      lspconfig.gopls.setup({
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
              fieldalignment = true,
              nilness = true,
              unusedwrite = true,
              useany = true,
            },
            staticcheck = true,
            gofumpt = true,
            usePlaceholders = true,
            completeUnimported = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-node_modules" },
            semanticTokens = true,
            codelenses = {
              gc_details = true,
              generate = true,
              regenerate_cgo = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })
    end

    -- Set Templ LSP if available
    if lspconfig and lspconfig.templ then
      lspconfig.templ.setup({})
    end

    -- Configure formatters for Go/Templ
    pcall(function()
      local conform = safe_require("conform")
      if conform then
        conform.setup({
          formatters_by_ft = {
            go = { "gofumpt", "goimports" },
            templ = { "templ" },
          },
        })
      end
    end)
  end

  -- Configure for Next.js stack
  if stack == "nextjs" or stack == "both" then
    api.nvim_notify(notify_icon .. "Stack focused on Next.js", vim.log.levels.INFO, { title = "Stack" })

    -- Configure TypeScript LSP with optimal settings
    local lspconfig = safe_require("lspconfig")
    if lspconfig then
      -- Prefer typescript-tools over tsserver if available
      local has_ts_tools = pcall(require, "typescript-tools")

      if has_ts_tools then
        -- Use typescript-tools.nvim
        pcall(function()
          require("typescript-tools").setup({
            settings = {
              tsserver_plugins = { "@styled/typescript-styled-plugin" },
              tsserver_file_preferences = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          })
        end)
      elseif lspconfig.tsserver then
        -- Fallback to basic tsserver
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
              suggest = {
                completeFunctionCalls = true,
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
              suggest = {
                completeFunctionCalls = true,
              },
            },
          },
        })
      end

      -- Setup Tailwind CSS
      if lspconfig.tailwindcss then
        lspconfig.tailwindcss.setup({
          filetypes = {
            "html",
            "css",
            "scss",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "templ", -- Also for templ files
          },
          init_options = {
            userLanguages = { templ = "html" }, -- Treat templ as HTML
          },
        })
      end

      -- Setup ESLint if available
      if lspconfig.eslint then
        lspconfig.eslint.setup({})
      end
    end

    -- Configure formatters for JS/TS
    pcall(function()
      local conform = safe_require("conform")
      if conform then
        conform.setup({
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
      end
    end)
  end

  -- Return the configured stack
  return stack
end

--- Initial setup on startup: detect stack and notify
function M.setup()
  if not vim.g.current_stack or vim.g.current_stack == "" then
    local st = M.detect_stack()
    if st then
      if st == "both" then
        vim.g.current_stack = "goth+nextjs"
      else
        vim.g.current_stack = st
      end

      vim.defer_fn(function()
        local icon = ""
        if st == "goth" then
          icon = "󰟓 "
        elseif st == "nextjs" then
          icon = " "
        elseif st == "both" then
          icon = "󰡄 "
        end

        api.nvim_notify(
          icon .. "Detected project stack: " .. (st == "both" and "GOTH+Next.js" or st),
          vim.log.levels.INFO,
          { title = "Stack" }
        )
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
      return { "goth", "nextjs", "both" }
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

  vim.keymap.set("n", "<leader>usb", function()
    M.configure_stack("both")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, { desc = "Focus Both Stacks + Dashboard" })
end

return M
