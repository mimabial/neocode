-- lua/config/stack_commands.lua
-- Stack-specific commands for GOTH and Next.js

local M = {}

function M.setup()
  -- ==================================
  -- GOTH Stack Commands
  -- ==================================

  -- TemplGenerate: generate Templ components
  vim.api.nvim_create_user_command("TemplGenerate", function()
    if vim.fn.executable("templ") ~= 1 then
      vim.notify("Templ command not found. Install templ first.", vim.log.levels.ERROR)
      return
    end

    local result = vim.fn.system("templ generate")
    if vim.v.shell_error ~= 0 then
      vim.notify("Error generating templ files: " .. result, vim.log.levels.ERROR)
      return
    end
    vim.notify("󰟓 Successfully generated templ components", vim.log.levels.INFO, { title = "GOTH" })
  end, { desc = "Generate Templ components" })

  -- TemplNew: create a new Templ component
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

    vim.notify("Created new templ component: " .. component_name, vim.log.levels.INFO, { title = "GOTH" })
  end, { desc = "Create a new Templ component" })

  -- GOTHServer: run GOTH stack server
  vim.api.nvim_create_user_command("GOTHServer", function()
    -- Check if templ is installed
    if vim.fn.executable("templ") ~= 1 then
      vim.notify("Templ command not found. Install templ first.", vim.log.levels.ERROR)
      return
    end

    -- Generate templ files first
    local result = vim.fn.system("templ generate")
    if vim.v.shell_error ~= 0 then
      vim.notify("Error generating templ files: " .. result, vim.log.levels.ERROR)
      return
    end

    -- Check if toggleterm is available
    local ok, term = pcall(require, "toggleterm.terminal")
    if not ok then
      vim.cmd("!go run .")
      return
    end

    -- Create and toggle terminal
    local Terminal = term.Terminal
    local t = Terminal:new({
      cmd = "go run .",
      direction = "float",
      close_on_exit = false,
      on_open = function()
        vim.cmd("startinsert!")
        vim.notify("󰟓 Starting GOTH server...", vim.log.levels.INFO, { title = "GOTH" })
      end,
    })
    t:toggle()
  end, { desc = "Run GOTH server" })

  -- GoRun: run Go project
  vim.api.nvim_create_user_command("GoRun", function()
    -- Check if toggleterm is available
    local ok, term = pcall(require, "toggleterm.terminal")
    if not ok then
      vim.cmd("!go run .")
      return
    end

    -- Create and toggle terminal
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
  end, { desc = "Run Go project" })

  -- GoTest: run Go tests
  vim.api.nvim_create_user_command("GoTest", function()
    -- Check if toggleterm is available
    local ok, term = pcall(require, "toggleterm.terminal")
    if not ok then
      vim.cmd("!go test ./...")
      return
    end

    -- Create and toggle terminal
    local Terminal = term.Terminal
    local t = Terminal:new({
      cmd = "go test ./...",
      direction = "float",
      close_on_exit = false,
      on_open = function()
        vim.cmd("startinsert!")
        vim.notify("Running Go tests...", vim.log.levels.INFO, { title = "GOTH" })
      end,
    })
    t:toggle()
  end, { desc = "Run Go tests" })

  -- ==================================
  -- Next.js Stack Commands
  -- ==================================

  -- NextDev: run Next.js development server
  vim.api.nvim_create_user_command("NextDev", function()
    -- Check if toggleterm is available
    local ok, term = pcall(require, "toggleterm.terminal")
    if not ok then
      vim.cmd("!npm run dev")
      return
    end

    -- Create and toggle terminal
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
  end, { desc = "Run Next.js development server" })

  -- NextBuild: build Next.js application
  vim.api.nvim_create_user_command("NextBuild", function()
    -- Check if toggleterm is available
    local ok, term = pcall(require, "toggleterm.terminal")
    if not ok then
      vim.cmd("!npm run build")
      return
    end

    -- Create and toggle terminal
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
  end, { desc = "Build Next.js application" })

  -- NextTest: run Next.js tests
  vim.api.nvim_create_user_command("NextTest", function()
    -- Check if toggleterm is available
    local ok, term = pcall(require, "toggleterm.terminal")
    if not ok then
      vim.cmd("!npm run test")
      return
    end

    -- Create and toggle terminal
    local Terminal = term.Terminal
    local t = Terminal:new({
      cmd = "npm run test",
      direction = "float",
      close_on_exit = false,
      on_open = function()
        vim.cmd("startinsert!")
        vim.notify(" Running Next.js tests...", vim.log.levels.INFO, { title = "Next.js" })
      end,
    })
    t:toggle()
  end, { desc = "Run Next.js tests" })

  -- NextLint: run Next.js linter
  vim.api.nvim_create_user_command("NextLint", function()
    -- Check if toggleterm is available
    local ok, term = pcall(require, "toggleterm.terminal")
    if not ok then
      vim.cmd("!npm run lint")
      return
    end

    -- Create and toggle terminal
    local Terminal = term.Terminal
    local t = Terminal:new({
      cmd = "npm run lint",
      direction = "float",
      close_on_exit = false,
      on_open = function()
        vim.cmd("startinsert!")
        vim.notify(" Running Next.js linter...", vim.log.levels.INFO, { title = "Next.js" })
      end,
    })
    t:toggle()
  end, { desc = "Run Next.js linter" })

  -- NextNewPage: create a new Next.js page
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

  -- NextNewComponent: create a new Next.js component
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
end

return M
