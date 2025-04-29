-- lua/config/stack.lua
local M = {}

-- Detect the current project stack (GOTH or Next.js)
function M.detect_stack()
  -- Check for Go files
  local has_go = vim.fn.glob("**/*.go") ~= ""
  local has_templ = vim.fn.glob("**/*.templ") ~= ""
  local has_go_mod = vim.fn.filereadable("go.mod") == 1
  
  -- Check for Next.js files
  local has_next_config = vim.fn.filereadable("next.config.js") == 1 or 
                          vim.fn.filereadable("next.config.mjs") == 1 or
                          vim.fn.filereadable("next.config.ts") == 1
  local has_package_json = vim.fn.filereadable("package.json") == 1
  local is_next_js = false
  
  if has_package_json then
    local content = table.concat(vim.fn.readfile("package.json"), "\n")
    is_next_js = content:find('"next"') ~= nil
  end
  
  -- Determine project type
  if has_go_mod and (has_go or has_templ) then
    return "goth"
  elseif is_next_js or has_next_config then
    return "nextjs"
  end
  
  return nil -- Unknown project type
end

-- Configure stack-specific settings
function M.configure_stack(stack)
  if not stack then
    stack = M.detect_stack()
  end
  
  if not stack then
    return -- No stack detected, nothing to configure
  end
  
  -- Store the current stack globally for other plugins to access
  vim.g.current_stack = stack
  
  -- Apply stack-specific settings
  if stack == "goth" then
    M.configure_goth()
  elseif stack == "nextjs" then
    M.configure_nextjs()
  end
  
  -- Notify the user
  vim.notify("Configured for " .. stack .. " stack", vim.log.levels.INFO)
end

-- Configure GOTH stack settings
function M.configure_goth()
  -- Set Go-specific settings
  vim.g.go_highlight_types = 1
  vim.g.go_highlight_fields = 1
  vim.g.go_highlight_functions = 1
  vim.g.go_highlight_function_calls = 1
  
  -- Configure formatters for GOTH stack
  if package.loaded["conform"] then
    require("conform").setup({
      formatters_by_ft = {
        go = { "gofumpt", "goimports" },
        templ = { "templ" },
      },
    })
  end
  
  -- Load correct LSP configuration
  if package.loaded["lspconfig"] then
    -- Configure gopls
    require("lspconfig").gopls.setup({
      settings = {
        gopls = {
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
          analyses = {
            unusedparams = true,
            unusedvariable = true,
            fieldalignment = true,
            nilness = true,
            shadow = true,
            useany = true,
          },
          semanticTokens = true,
          usePlaceholders = true,
          staticcheck = true,
          directoryFilters = {
            "-node_modules",
            "-vendor",
            "-build",
            "-dist",
          },
          expandWorkspaceToModule = true,
        },
      },
    })
    
    -- Configure templ LSP
    require("lspconfig").templ.setup({})
    
    -- Configure html LSP with templ support
    require("lspconfig").html.setup({
      filetypes = { "html", "templ" },
    })
  end
  
  -- Set up file watchers for templ
  if package.loaded["lsp-inlayhints"] then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "go", "templ" },
      callback = function()
        require("lsp-inlayhints").on_attach()
      end,
    })
  end
  
  -- Register custom commands
  vim.api.nvim_create_user_command("GoTest", function()
    vim.cmd("!go test ./...")
  end, { desc = "Run Go tests" })
  
  vim.api.nvim_create_user_command("GoModTidy", function()
    vim.cmd("!go mod tidy")
  end, { desc = "Run go mod tidy" })
  
  vim.api.nvim_create_user_command("TemplGen", function()
    vim.cmd("!templ generate")
  end, { desc = "Generate Templ files" })
  
  -- Add file type detection
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.templ",
    callback = function()
      vim.bo.filetype = "templ"
    end,
  })
  
  -- HTMX attribute highlighting
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html", "templ" },
    callback = function()
      vim.cmd([[
        syntax match htmlArg contained "\<hx-[a-zA-Z\-]\+\>" 
        highlight link htmlArg @attribute.htmx
      ]])
    end,
  })
end

-- Configure Next.js stack settings
function M.configure_nextjs()
  -- TypeScript/JavaScript settings
  vim.g.typescript_indent_disable = 1
  
  -- Configure formatters for Next.js
  if package.loaded["conform"] then
    require("conform").setup({
      formatters_by_ft = {
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        json = { "prettierd", "prettier" },
        css = { "prettierd", "prettier" },
        html = { "prettierd", "prettier" },
      },
    })
  end
  
  -- Load correct LSP configuration
  if package.loaded["lspconfig"] then
    if package.loaded["typescript-tools"] then
      -- Use typescript-tools for better TS/JS support
      require("typescript-tools").setup({
        settings = {
          -- For Next.js
          tsserver_plugins = {
            "@styled/typescript-styled-plugin",
          },
          expose_as_code_action = {
            "fix_all",
            "add_missing_imports",
            "remove_unused",
          },
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
    end
    
    -- Configure Tailwind CSS LSP
    require("lspconfig").tailwindcss.setup({
      settings = {
        tailwindCSS = {
          experimental = {
            classRegex = {
              { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
              { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              { "classnames\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              { "twMerge\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
            },
          },
          validate = true,
        },
      },
    })
    
    -- Configure ESLint
    require("lspconfig").eslint.setup({
      settings = {
        workingDirectories = { { mode = "auto" } },
      },
    })
  end
  
  -- Set up prettier config for this project
  local prettier_config = vim.fn.getcwd() .. "/.prettierrc"
  if not vim.fn.filereadable(prettier_config) then
    local basic_config = {
      trailingComma = "es5",
      tabWidth = 2,
      semi = true,
      singleQuote = true,
      printWidth = 100,
      bracketSpacing = true,
    }
    
    local file = io.open(prettier_config, "w")
    if file then
      file:write(vim.json.encode(basic_config))
      file:close()
      vim.notify("Created basic .prettierrc for Next.js project", vim.log.levels.INFO)
    end
  end
  
  -- Register custom commands
  vim.api.nvim_create_user_command("NextDev", function()
    vim.cmd("!npm run dev")
  end, { desc = "Start Next.js dev server" })
  
  vim.api.nvim_create_user_command("NextBuild", function()
    vim.cmd("!npm run build")
  end, { desc = "Build Next.js project" })
  
  vim.api.nvim_create_user_command("NextLint", function()
    vim.cmd("!npm run lint")
  end, { desc = "Lint Next.js project" })
  
  -- Set path to include Next.js specific directories
  vim.opt_local.path:append("app")
  vim.opt_local.path:append("components")
  vim.opt_local.path:append("lib")
  
  -- Add file type detection for Next.js files
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "app/*/page.tsx", "app/*/layout.tsx", "app/api/*/route.ts" },
    callback = function(opts)
      local filename = vim.fn.fnamemodify(opts.match, ":t")
      if filename == "page.tsx" then
        vim.b.next_file_type = "page"
      elseif filename == "layout.tsx" then
        vim.b.next_file_type = "layout"
      elseif filename == "route.ts" then
        vim.b.next_file_type = "api"
      end
    end,
  })
end

-- Create commands for switching stacks
function M.setup()
  -- Create stack switching commands
  vim.api.nvim_create_user_command("StackFocus", function(opts)
    local stack = opts.args
    
    -- Auto-detect stack if no argument provided
    if stack == "" then
      stack = M.detect_stack() or ""
      if stack == "" then
        vim.notify("Could not auto-detect stack type. Please specify 'goth' or 'nextjs'", vim.log.levels.WARN)
        return
      end
    elseif not (stack == "goth" or stack == "nextjs") then
      vim.notify("Please specify a valid stack: 'goth' or 'nextjs'", vim.log.levels.ERROR)
      return
    end
    
    -- Configure the selected stack
    M.configure_stack(stack)
    
  end, { nargs = "?", desc = "Focus on a specific tech stack", complete = function()
    return { "goth", "nextjs" }
  end})
  
  -- Auto-detect on startup
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      -- Only run once after plugins are loaded
      vim.defer_fn(function()
        if vim.g.current_stack == nil then
          local detected = M.detect_stack()
          if detected then
            M.configure_stack(detected)
          end
        end
      end, 1000) -- Delay to ensure all plugins are loaded
    end,
    once = true,
  })
  
  -- Setup keymaps
  vim.keymap.set("n", "<leader>sg<leader>f", "<cmd>StackFocus goth<cr>", { desc = "Focus GOTH Stack" })
  vim.keymap.set("n", "<leader>sn<leader>f", "<cmd>StackFocus nextjs<cr>", { desc = "Focus Next.js Stack" })
end

return M
