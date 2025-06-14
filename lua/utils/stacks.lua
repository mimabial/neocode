local M = {}

local fn = vim.fn

-- Safely load a module with error handling
local function safe_require(mod)
  local ok, result = pcall(require, mod)
  if not ok then
    return nil
  end
  return result
end

-- Stack icons for notifications
local stack_icons = {
  ["goth"] = "󰟓 ",
  ["nextjs"] = " ",
}

-- Check if any file matching patterns exists in cwd
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

-- Search file contents for pattern with error handling
local function file_contains(file, pattern, max_lines)
  max_lines = max_lines or 100
  
  if fn.filereadable(file) == 0 then
    return false
  end

  local lines = fn.readfile(file, "", max_lines)
  if type(lines) ~= "table" then
    return false
  end

  local content = table.concat(lines, "\n")
  return content:match(pattern) ~= nil
end

-- Detect current project stack with robust error handling
function M.detect_stack()
  -- Safety wrapper around detection logic
  local ok, result = pcall(function()
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
    local gofiles = {}
    pcall(function()
      gofiles = fn.glob("**/*.go", false, true)
    end)

    for _, file in ipairs(gofiles) do
      if file_contains(file, "html/template") or file_contains(file, "htmx") or file_contains(file, "templ") then
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

    -- Pages directory for older Next.js projects
    if exists("pages") and (exists("pages/*.tsx") or exists("pages/*.jsx")) then
      nextjs_score = nextjs_score + 2
    end

    -- Package.json with next dependency
    if exists("package.json") then
      if file_contains("package.json", '"next":', 30) then
        nextjs_score = nextjs_score + 3
      end
    end

    -- Determine the result based on scores
    if goth_score >= 4 and nextjs_score >= 4 then
      return "goth+nextjs" -- Both stacks detected
    elseif goth_score >= 4 then
      return "goth"
    elseif nextjs_score >= 4 then
      return "nextjs"
    end

    -- Default to nil if no clear stack detected
    return nil
  end)

  -- If detection fails, provide a fallback with basic checks
  if not ok or not result then
    -- Log error but don't expose it to user
    vim.schedule(function()
      vim.notify("Stack detection encountered an error, falling back to basic detection", vim.log.levels.DEBUG)
    end)

    -- Check for some very basic indicators
    if fn.filereadable("go.mod") == 1 then
      return "goth"
    elseif fn.filereadable("next.config.js") == 1 or fn.filereadable("package.json") == 1 then
      return "nextjs"
    end
  end

  return result
end

-- Apply configuration for a given stack
function M.configure_stack(stack_name)
  local stack = stack_name or M.detect_stack() or ""
  local notify_icon = ""

  -- Store globally for access by other modules
  vim.g.current_stack = stack

  -- Set stack icon for notification
  if stack == "goth" then
    notify_icon = stack_icons["goth"] or "󰟓 "
  elseif stack == "nextjs" then
    notify_icon = stack_icons["nextjs"] or " "
  elseif stack == "goth+nextjs" then
    notify_icon = stack_icons["goth"] or "󰟓 " .. " + " .. stack_icons["nextjs"] or " "
  end

  -- Configure for GOTH stack
  if stack == "goth" or stack == "goth+nextjs" then
    -- Notify user
    vim.notify(notify_icon .. "Stack focused on GOTH (Go/Templ/HTMX)", vim.log.levels.INFO, { title = "Stack" })

    -- Ensure gopls is configured optimally
    local lspconfig = safe_require("lspconfig")
    if lspconfig and lspconfig.gopls then
      pcall(lspconfig.gopls.setup, {
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
      pcall(lspconfig.templ.setup, {})
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

    -- Add GOTH-specific commands safely
    vim.api.nvim_create_user_command("TemplGenerate", function()
      if fn.executable("templ") ~= 1 then
        vim.notify(
          "templ command not found. Install with 'go install github.com/a-h/templ/cmd/templ@latest'",
          vim.log.levels.ERROR
        )
        return
      end

      vim.notify("Generating Templ files...", vim.log.levels.INFO)
      fn.jobstart("templ generate", {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("Successfully generated Templ files", vim.log.levels.INFO)
          else
            vim.notify("Error generating Templ files", vim.log.levels.ERROR)
          end
        end,
      })
    end, { desc = "Generate Templ files" })
  end

  -- Configure for Next.js stack
  if stack == "nextjs" or stack == "goth+nextjs" then
    vim.notify(notify_icon .. "Stack focused on Next.js", vim.log.levels.INFO, { title = "Stack" })

    -- Configure TypeScript LSP with optimal settings
    local lspconfig = safe_require("lspconfig")
    if lspconfig then
      -- Try typescript-tools first
      local ts_tools_ok = pcall(require, "typescript-tools")

      if ts_tools_ok then
        -- Use typescript-tools.nvim with error handling
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
      elseif lspconfig.ts_ls then
        -- Fallback to basic tsserver with error handling
        pcall(lspconfig.ts_ls.setup, {
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

      -- Setup Tailwind CSS with error handling
      if lspconfig.tailwindcss then
        pcall(lspconfig.tailwindcss.setup, {
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
        pcall(lspconfig.eslint.setup, {})
      end
    end

    -- Configure formatters for JS/TS with error handling
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

  -- Update UI based on stack
  pcall(function()
    local colors_name = vim.g.colors_name
    if colors_name then
      -- Re-trigger colorscheme to apply stack-specific highlights
      vim.cmd("colorscheme " .. colors_name)
    end
  end)

  -- Return the configured stack
  return stack
end

-- Find main.go file for debugging
function M.find_main_go()
  local main_file = fn.findfile("main.go", fn.getcwd() .. "/**")
  if main_file == "" then
    vim.notify("Could not find main.go file", vim.log.levels.ERROR)
    return nil
  end
  return main_file
end

-- Run templ generate with error handling
function M.run_templ_generate()
  if fn.executable("templ") ~= 1 then
    vim.notify("templ command not found. Install templ first.", vim.log.levels.ERROR)
    return false
  end

  local result = fn.system("templ generate")
  if vim.v.shell_error ~= 0 then
    vim.notify("Error generating templ files: " .. result, vim.log.levels.ERROR)
    return false
  end
  return true
end

-- Initial setup on startup: detect stack and notify
function M.setup()
  if not vim.g.current_stack or vim.g.current_stack == "" then
    local st = M.detect_stack()
    if st then
      -- Set global stack variable
      vim.g.current_stack = st

      -- Notify user of detected stack with a short delay to avoid startup clutter
      vim.defer_fn(function()
        local icon = st == "goth" and stack_icons["goth"] or stack_icons["nextjs"]
        vim.notify(icon .. "Detected project stack: " .. st, vim.log.levels.INFO, { title = "Stack" })
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
      return { "goth", "nextjs", "goth+nextjs" }
    end,
  })
end

return M
