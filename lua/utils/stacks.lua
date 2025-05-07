-- lua/utils/stacks.lua
-- Enhanced fail-safe stack detection and configuration for GOTH and Next.js

local M = {}

local fn = vim.fn
local api = vim.api

-- Safely load a module with basic error handling
local function safe_require(mod)
  local ok, result = pcall(require, mod)
  if not ok then
    return nil
  end
  return result
end

-- Icons for stack indicators
local stack_icons = {
  ["goth"] = "󰟓 ",
  ["nextjs"] = " ",
  ["both"] = "󰡄 ",
}

-- Check if any file matching patterns exists in cwd with robust error handling
local function exists(patterns)
  local ok, result = pcall(function()
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

  return ok and result or false
end

-- Search file contents for pattern with enhanced safety
local function file_contains(file, pattern, max_lines)
  local ok, result = pcall(function()
    max_lines = max_lines or 100
    if vim.fn.filereadable(file) == 0 then
      return false
    end

    local lines
    -- Handle read errors gracefully
    local read_ok, read_result = pcall(vim.fn.readfile, file, "", max_lines)
    if not read_ok or type(read_result) ~= "table" then
      return false
    end

    lines = read_result
    local content = table.concat(lines, "\n")
    return content:match(pattern) ~= nil
  end)

  return ok and result or false
end

-- Detect current project stack with enhanced error handling
function M.detect_stack()
  -- Add safety wrapper around the entire function
  local ok, result = pcall(function()
    -- GOTH stack indicators with improved error handling
    local goth_score = 0

    -- Check safely for Go files
    if exists({ "*.go", "go.mod", "go.sum" }) then
      goth_score = goth_score + 2
    end

    -- Check safely for Templ files
    if exists({ "*.templ", "**/components/*.templ", "**/templates/*.templ" }) then
      goth_score = goth_score + 3
    end

    -- Check for HTMX usage
    if exists({ "**/htmx*.js", "**/static/**/htmx*.js" }) then
      goth_score = goth_score + 2
    end

    -- Check Go imports/usage related to HTMX/Templ with safety checks
    local gofiles = {}
    local glob_ok, glob_result = pcall(fn.glob, "**/*.go", false, true)
    if glob_ok and type(glob_result) == "table" then
      gofiles = glob_result
    end

    for _, file in ipairs(gofiles) do
      if file_contains(file, "html/template") or file_contains(file, "htmx") or file_contains(file, "templ") then
        goth_score = goth_score + 2
        break
      end
    end

    -- Next.js detection with similar safety enhancements
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
      return "both"
    elseif goth_score >= 4 then
      return "goth"
    elseif nextjs_score >= 4 then
      return "nextjs"
    end

    -- Default to nil if no clear stack detected
    return nil
  end)

  -- If detection fails, provide a fallback with basic checks
  if not ok then
    -- Log error but don't expose it to user
    vim.schedule(function()
      vim.notify("Stack detection encountered an error, falling back to basic detection", vim.log.levels.DEBUG)
    end)

    -- Check for some very basic indicators
    if vim.fn.filereadable("go.mod") == 1 then
      return "goth"
    elseif vim.fn.filereadable("next.config.js") == 1 or vim.fn.filereadable("package.json") == 1 then
      return "nextjs"
    end
  end

  return result
end

-- Apply configuration for a given stack with enhanced fail-safety
function M.configure_stack(stack_name)
  local stack = stack_name or M.detect_stack() or ""
  local notify_icon = ""

  -- Store globally for access by other modules
  if stack == "both" then
    vim.g.current_stack = "goth+nextjs"
    notify_icon = stack_icons["both"] or "󰡄 "
  else
    vim.g.current_stack = stack
    if stack == "goth" then
      notify_icon = stack_icons["goth"] or "󰟓 "
    elseif stack == "nextjs" then
      notify_icon = stack_icons["nextjs"] or " "
    end
  end

  -- Configure for GOTH stack
  if stack == "goth" or stack == "both" then
    -- Notify user
    api.nvim_notify(notify_icon .. "Stack focused on GOTH (Go/Templ/HTMX)", vim.log.levels.INFO, { title = "Stack" })

    -- Ensure gopls is configured optimally
    local lspconfig = safe_require("lspconfig")
    if lspconfig and lspconfig.gopls then
      -- Configure with error handling
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
      if vim.fn.executable("templ") ~= 1 then
        vim.notify(
          "templ command not found. Install with 'go install github.com/a-h/templ/cmd/templ@latest'",
          vim.log.levels.ERROR
        )
        return
      end

      vim.notify("Generating Templ files...", vim.log.levels.INFO)
      vim.fn.jobstart("templ generate", {
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
  if stack == "nextjs" or stack == "both" then
    api.nvim_notify(notify_icon .. "Stack focused on Next.js", vim.log.levels.INFO, { title = "Stack" })

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

  -- Apply colorscheme highlights based on stack
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

-- Initial setup on startup: detect stack and notify
function M.setup()
  if not vim.g.current_stack or vim.g.current_stack == "" then
    local st = M.detect_stack()
    if st then
      -- Set global stack variable
      if st == "both" then
        vim.g.current_stack = "goth+nextjs"
      else
        vim.g.current_stack = st
      end

      -- Notify user of detected stack with a short delay to avoid startup clutter
      vim.defer_fn(function()
        local icon = ""
        if st == "goth" then
          icon = stack_icons["goth"] or "󰟓 "
        elseif st == "nextjs" then
          icon = stack_icons["nextjs"] or " "
        elseif st == "both" then
          icon = stack_icons["both"] or "󰡄 "
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
end

return M
