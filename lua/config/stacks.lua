-- lua/config/stacks.lua
-- Enhanced, fail-safe stack detection and configuration for GOTH and Next.js

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
-- @return boolean with error handling
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

--- Search file contents for pattern
-- @param file string file path
-- @param pattern string pattern to search for
-- @param max_lines number max lines to check
-- @return boolean
local function file_contains(file, pattern, max_lines)
  local ok, result = pcall(function()
    max_lines = max_lines or 100
    if vim.fn.filereadable(file) == 0 then
      return false
    end

    local lines = vim.fn.readfile(file, "", max_lines)
    local content = table.concat(lines, "\n")
    return content:match(pattern) ~= nil
  end)

  return ok and result or false
end

--- Detect current project stack with more accurate heuristics
-- @return string "goth", "nextjs", "both" or nil
function M.detect_stack()
  -- Add safety wrapper around the entire function
  local ok, result = pcall(function()
    -- GOTH stack indicators with try/catch safety
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
    local gofiles = fn.glob("**/*.go", false, true)
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

    -- Add debug logging for stack detection
    vim.defer_fn(function()
      vim.notify(
        string.format("Stack detection: GOTH score: %d, Next.js score: %d", goth_score, nextjs_score),
        vim.log.levels.DEBUG
      )
    end, 1000)

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

  -- If detection fails, provide a fallback
  if not ok then
    vim.notify("Stack detection failed: " .. tostring(result), vim.log.levels.WARN)
    -- Check for some very basic indicators
    if vim.fn.filereadable("go.mod") == 1 then
      return "goth"
    elseif vim.fn.filereadable("next.config.js") == 1 or vim.fn.filereadable("package.json") == 1 then
      return "nextjs"
    end
  end

  return result
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

    -- Add specific commands for GOTH
    vim.api.nvim_create_user_command("GoRun", function()
      -- Check if we're in a Go project
      if vim.fn.filereadable("go.mod") ~= 1 then
        vim.notify("Not in a Go project (no go.mod found)", vim.log.levels.WARN)
        return
      end

      local term = safe_require("toggleterm.terminal")
      if term and term.Terminal then
        local Terminal = term.Terminal
        local t = Terminal:new({
          cmd = "go run .",
          direction = "float",
          close_on_exit = false,
          on_open = function()
            vim.cmd("startinsert!")
          end,
        })
        t:toggle()
      else
        vim.cmd("!go run .")
      end
    end, { desc = "Run Go project" })

    -- Add Templ generation command
    vim.api.nvim_create_user_command("TemplGenerate", function()
      if vim.fn.executable("templ") ~= 1 then
        vim.notify("templ command not found", vim.log.levels.ERROR)
        return
      end

      local result = vim.fn.system("templ generate")
      if vim.v.shell_error ~= 0 then
        vim.notify("Error generating templ files: " .. result, vim.log.levels.ERROR)
      else
        vim.notify("Successfully generated templ files", vim.log.levels.INFO)
      end
    end, { desc = "Generate Templ files" })

    -- Add GOTH server command for running with hot reload
    vim.api.nvim_create_user_command("GOTHServer", function()
      -- Check if we have air for hot reload
      local air_exists = vim.fn.filereadable(".air.toml") == 1
      local cmd = air_exists and "air" or "templ generate && go run ."

      local term = safe_require("toggleterm.terminal")
      if term and term.Terminal then
        local Terminal = term.Terminal
        local t = Terminal:new({
          cmd = cmd,
          direction = "float",
          close_on_exit = false,
          on_open = function()
            vim.cmd("startinsert!")
            vim.notify("Starting GOTH server" .. (air_exists and " with air hot-reload" or ""), vim.log.levels.INFO)
          end,
        })
        t:toggle()
      else
        vim.cmd("!" .. cmd)
      end
    end, { desc = "Run GOTH server" })

    -- Add Templ Component creation command
    vim.api.nvim_create_user_command("TemplNew", function()
      -- Get the component name from user input
      local component_name = vim.fn.input("Component Name: ")
      if component_name == "" then
        vim.notify("Component name cannot be empty", vim.log.levels.ERROR)
        return
      end

      -- Create a new buffer
      local bufnr = vim.api.nvim_create_buf(true, false)

      -- Set buffer name
      vim.api.nvim_buf_set_name(bufnr, component_name .. ".templ")

      -- Set filetype
      vim.api.nvim_buf_set_option(bufnr, "filetype", "templ")

      -- Generate component content
      local content = {
        "package components",
        "",
        "type " .. component_name .. "Props struct {",
        "  // Add props here",
        "}",
        "",
        "templ " .. component_name .. "(props " .. component_name .. "Props) {",
        "  <div>",
        "    <h1>" .. component_name .. " Component</h1>",
        "    <p>Content goes here</p>",
        "  </div>",
        "}",
      }

      -- Set buffer content
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)

      -- Open the buffer in the current window
      vim.api.nvim_win_set_buf(0, bufnr)

      -- Position cursor at the props section
      vim.api.nvim_win_set_cursor(0, { 4, 0 })

      -- Enter insert mode
      vim.cmd("startinsert!")
    end, { desc = "Create new Templ component" })
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
      elseif lspconfig.ts_ls then
        -- Fallback to basic tsserver
        lspconfig.ts_ls.setup({
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

    -- Add specific Next.js commands

    -- Next.js dev server
    vim.api.nvim_create_user_command("NextDev", function()
      -- Check if we're in a Next.js project
      if vim.fn.filereadable("package.json") ~= 1 then
        vim.notify("Not in a Next.js project (no package.json found)", vim.log.levels.WARN)
        return
      end

      local term = safe_require("toggleterm.terminal")
      if term and term.Terminal then
        local Terminal = term.Terminal
        local t = Terminal:new({
          cmd = "npm run dev",
          direction = "float",
          close_on_exit = false,
          on_open = function()
            vim.cmd("startinsert!")
            vim.notify(" Starting Next.js development server...", vim.log.levels.INFO, { title = "Next.js" })
          end,
        })
        t:toggle()
      else
        vim.cmd("!npm run dev")
      end
    end, { desc = "Run Next.js development server" })

    -- Next.js build command
    vim.api.nvim_create_user_command("NextBuild", function()
      if vim.fn.filereadable("package.json") ~= 1 then
        vim.notify("Not in a Next.js project (no package.json found)", vim.log.levels.WARN)
        return
      end

      local term = safe_require("toggleterm.terminal")
      if term and term.Terminal then
        local Terminal = term.Terminal
        local t = Terminal:new({
          cmd = "npm run build",
          direction = "float",
          close_on_exit = false,
          on_open = function()
            vim.cmd("startinsert!")
            vim.notify(" Building Next.js application...", vim.log.levels.INFO, { title = "Next.js" })
          end,
        })
        t:toggle()
      else
        vim.cmd("!npm run build")
      end
    end, { desc = "Build Next.js application" })

    -- Next.js component creation
    vim.api.nvim_create_user_command("NextNewComponent", function()
      -- Get component information
      local component_name = vim.fn.input("Component Name: ")
      if component_name == "" then
        vim.notify("Component name cannot be empty", vim.log.levels.ERROR)
        return
      end

      local is_client = vim.fn.confirm("Is this a client component?", "&Yes\n&No", 1) == 1

      -- Create components directory if it doesn't exist
      vim.fn.mkdir("components", "p")

      -- File path and content
      local file_path = "components/" .. component_name .. ".tsx"
      local content = {}

      if is_client then
        table.insert(content, "'use client'")
        table.insert(content, "")
        table.insert(content, "import { useState } from 'react'")
        table.insert(content, "")
      end

      table.insert(content, "interface " .. component_name .. "Props {")
      table.insert(content, "  // Define props here")
      table.insert(content, "  children?: React.ReactNode")
      table.insert(content, "}")
      table.insert(content, "")
      table.insert(
        content,
        "export default function " .. component_name .. "({ children }: " .. component_name .. "Props) {"
      )

      if is_client then
        table.insert(content, "  const [state, setState] = useState(false)")
        table.insert(content, "")
      end

      table.insert(content, "  return (")
      table.insert(content, '    <div className="p-4 border rounded shadow">')
      table.insert(content, '      <h2 className="text-xl font-bold">' .. component_name .. "</h2>")
      table.insert(content, "      {children}")
      table.insert(content, "    </div>")
      table.insert(content, "  )")
      table.insert(content, "}")

      -- Create the file
      local bufnr = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_name(bufnr, file_path)
      vim.api.nvim_buf_set_option(bufnr, "filetype", "typescriptreact")
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
      vim.api.nvim_win_set_buf(0, bufnr)

      -- Position cursor at props interface
      vim.api.nvim_win_set_cursor(0, { 4, 0 })

      -- Save the file
      vim.cmd("write")
      vim.notify(" Created new component: " .. file_path, vim.log.levels.INFO, { title = "Next.js" })
    end, { desc = "Create a new Next.js component" })

    -- Next.js page creation
    vim.api.nvim_create_user_command("NextNewPage", function()
      -- Get the page name from user input
      local page_name = vim.fn.input("Page Name (e.g. about): ")
      if page_name == "" then
        vim.notify("Page name cannot be empty", vim.log.levels.ERROR)
        return
      end

      -- Determine if this is a new App Router or Pages Router project
      local is_app_router = vim.fn.isdirectory("app") == 1

      local file_path
      local content

      if is_app_router then
        -- App Router structure
        file_path = "app/" .. page_name .. "/page.tsx"
        content = {
          "export default function " .. page_name:gsub("^%l", string.upper) .. "Page() {",
          "  return (",
          '    <div className="container mx-auto py-8">',
          '      <h1 className="text-3xl font-bold">' .. page_name:gsub("^%l", string.upper) .. " Page</h1>",
          "      <p>This is the " .. page_name .. " page content.</p>",
          "    </div>",
          "  )",
          "}",
        }

        -- Create directory if it doesn't exist
        vim.fn.mkdir("app/" .. page_name, "p")
      else
        -- Pages Router structure
        file_path = "pages/" .. page_name .. ".tsx"
        content = {
          "import Head from 'next/head'",
          "import type { NextPage } from 'next'",
          "",
          "const " .. page_name:gsub("^%l", string.upper) .. ": NextPage = () => {",
          "  return (",
          "    <>",
          "      <Head>",
          "        <title>" .. page_name:gsub("^%l", string.upper) .. " Page</title>",
          '        <meta name="description" content="' .. page_name .. ' page" />',
          "      </Head>",
          '      <div className="container mx-auto py-8">',
          '        <h1 className="text-3xl font-bold">' .. page_name:gsub("^%l", string.upper) .. " Page</h1>",
          "        <p>This is the " .. page_name .. " page content.</p>",
          "      </div>",
          "    </>",
          "  )",
          "}",
          "",
          "export default " .. page_name:gsub("^%l", string.upper),
        }

        -- Create pages directory if needed
        vim.fn.mkdir("pages", "p")
      end

      -- Create the file
      local bufnr = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_name(bufnr, file_path)
      vim.api.nvim_buf_set_option(bufnr, "filetype", "typescriptreact")
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
      vim.api.nvim_win_set_buf(0, bufnr)

      -- Save the file
      vim.cmd("write")
      vim.notify(" Created new page: " .. file_path, vim.log.levels.INFO, { title = "Next.js" })
    end, { desc = "Create a new Next.js page" })
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
  vim.keymap.set("n", "<leader>sg", function()
    M.configure_stack("goth")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, { desc = "Focus GOTH Stack + Dashboard" })

  vim.keymap.set("n", "<leader>sn", function()
    M.configure_stack("nextjs")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, { desc = "Focus Next.js Stack + Dashboard" })

  vim.keymap.set("n", "<leader>sb", function()
    M.configure_stack("both")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, { desc = "Focus Both Stacks + Dashboard" })
end

return M
