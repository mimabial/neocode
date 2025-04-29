-- lua/plugins/nextjs.lua
return {
  -- TypeScript/Next.js LSP enhancement
  {
    "pmizio/typescript-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
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
        tsserver_format_options = {
          allowIncompleteCompletions = false,
          allowRenameOfImportPath = false,
        },
      },
    },
    ft = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    config = function(_, opts)
      -- Setup typescript-tools
      require("typescript-tools").setup(opts)
      
      -- Add commands for typescript actions
      vim.api.nvim_create_user_command("TSOrganizeImports", function()
        require("typescript-tools.api").organize_imports()
      end, { desc = "Organize Imports" })
      
      vim.api.nvim_create_user_command("TSRenameFile", function()
        require("typescript-tools.api").rename_file()
      end, { desc = "Rename File" })
      
      vim.api.nvim_create_user_command("TSAddMissingImports", function()
        require("typescript-tools.api").add_missing_imports()
      end, { desc = "Add Missing Imports" })
      
      vim.api.nvim_create_user_command("TSRemoveUnused", function()
        require("typescript-tools.api").remove_unused()
      end, { desc = "Remove Unused" })
      
      vim.api.nvim_create_user_command("TSFixAll", function()
        require("typescript-tools.api").fix_all()
      end, { desc = "Fix All" })
      
      -- Add Next.js specific keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
        callback = function()
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = desc })
          end
          
          map("n", "<leader>sno", function() require("typescript-tools.api").organize_imports() end, "Organize Imports")
          map("n", "<leader>snr", function() require("typescript-tools.api").rename_file() end, "Rename File")
          map("n", "<leader>sni", function() require("typescript-tools.api").add_missing_imports() end, "Add Missing Imports")
          map("n", "<leader>snu", function() require("typescript-tools.api").remove_unused() end, "Remove Unused")
          map("n", "<leader>snf", function() require("typescript-tools.api").fix_all() end, "Fix All")
        end
      })
    end,
    priority = 80,
  },
  
  -- Add custom formatters for Next.js
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        css = { "prettierd", "prettier" },
        json = { "prettierd", "prettier" },
        jsonc = { "prettierd", "prettier" },
        graphql = { "prettierd", "prettier" },
        html = { "prettierd", "prettier" },
      },
      formatters = {
        prettierd = {
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/.prettierrc"),
          },
        },
        prettier = {
          prepend_args = function(self, ctx)
            -- Try to detect project's .prettierrc
            local prettier_config = require("conform.util").root_file({
              ".prettierrc",
              ".prettierrc.json",
              ".prettierrc.yml",
              ".prettierrc.yaml",
              ".prettierrc.json5",
              ".prettierrc.js",
              "prettier.config.js",
              ".prettierrc.toml",
            }, ctx.filename)
            
            -- Use project config or default to built-in config
            if prettier_config then
              return { "--config", prettier_config }
            else
              return { "--print-width", "100", "--single-quote", "true" }
            end
          end,
        },
      },
    },
    priority = 50,
  },
  
  -- Schema store for better JSON validation
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
    priority = 55,
  },
  
  -- Tailwind CSS support
  {
    "NvChad/nvim-colorizer.lua",
    config = true,
    opts = {
      user_default_options = {
        tailwind = true,
        mode = "background",
        css = true,
        css_variables = true,
      },
    },
    ft = { "css", "html", "javascript", "typescript", "javascriptreact", "typescriptreact" },
    priority = 65,
  },
  
  -- Tailwind CSS completion
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    opts = {
      color_square_width = 2,
    },
    priority = 60,
  },
  
  -- React snippets and tools
  {
    "L3MON4D3/LuaSnip",
    config = function()
      -- Create snippets directory if it doesn't exist
      local snippets_dir = vim.fn.stdpath("config") .. "/snippets"
      if vim.fn.isdirectory(snippets_dir) == 0 then
        vim.fn.mkdir(snippets_dir, "p")
      end
      
      -- Create React/Next.js snippets
      local nextjs_snippets_file = snippets_dir .. "/nextjs.lua"
      if vim.fn.filereadable(nextjs_snippets_file) == 0 then
        local file = io.open(nextjs_snippets_file, "w")
        if file then
          file:write([[
-- Next.js snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

local snippets = {
  -- Next.js page component
  s("npage", {
    t({"export default function Page() {", "  return (", "    "}),
    i(1, "<div>Page content</div>"),
    t({"", "  );", "}", ""}),
  }),
  
  -- Next.js layout component
  s("nlayout", {
    t({"export default function Layout({ children }: { children: React.ReactNode }) {", "  return (", "    "}),
    i(1, "<div>{children}</div>"),
    t({"", "  );", "}", ""}),
  }),
  
  -- Next.js server component
  s("nserver", {
    t({"import { headers } from 'next/headers';", "", "export default async function ServerComponent() {", "  const headersList = headers();", "  ", "  return (", "    "}),
    i(1, "<div>Server Component</div>"),
    t({"", "  );", "}", ""}),
  }),
  
  -- Next.js client component
  s("nclient", {
    t({"'use client';", "", "import { useState } from 'react';", "", "export default function ClientComponent() {", "  const [state, setState] = useState("}),
    i(1, "null"),
    t({");", "  ", "  return (", "    "}),
    i(2, "<div>Client Component</div>"),
    t({"", "  );", "}", ""}),
  }),
  
  -- Next.js API route
  s("napi", {
    t({"export async function GET(request: Request) {", "  "}),
    i(1, "// Handle GET request"),
    t({"", "  return Response.json({ message: 'Hello from API route!' });", "}", ""}),
  }),
  
  -- Next.js with route params
  s("nparams", {
    t({"interface PageProps {","  params: {","    "}),
    i(1, "id"),
    t({": string","  }","}","","export default function Page({ params }: PageProps) {","  return (","    <div>","      Dynamic parameter: {params."}),
    f(function(args) return args[1][1] end, {1}),
    t({"}","    </div>","  );","}",""}),
  }),

  
  -- Next.js with search params
  s("nsearch", {
    t({"export default function Page({","  searchParams,","}: {","  searchParams: { [key: string]: string | string[] | undefined };","}) {","  return (","    <div>","      Search param: {searchParams."}),
    i(1, "query"),
    t({" as string}","    </div>","  );","}",""}),
  }),
  
  -- Next.js with data fetching
  s("nfetch", {
    t({"async function getData() {", "  const res = await fetch('"}),
    i(1, "https://api.example.com/data"),
    t("', "),
    c(2, {
      t({"// No cache - revalidate every request", "  { cache: 'no-store' }"}),
      t({"// Cache with revalidation", "  { next: { revalidate: 60 } }"}),
      t({"// Cache until manually revalidated", "  { cache: 'force-cache' }"}),
    }),
    t({");", "  ", "  if (!res.ok) {", "    throw new Error('Failed to fetch data');", "  }", "  ", "  return res.json();", "}", "", "export default async function Page() {", "  const data = await getData();", "  ", "  return (", "    <div>", "      <h1>Data:</h1>", "      <pre>{JSON.stringify(data, null, 2)}</pre>", "    </div>", "  );", "}", ""}),
  }),
  
  -- React useState hook
  s("ust", {
    t({"const ["}),
    i(1, "state"),
    t({", set"}),
    f(function(args)
      local state = args[1][1]
      return state:gsub("^%l", string.upper)
    end, {1}),
    t({"] = useState("}),
    i(2, "initialState"),
    t({");"}),
  }),
  
  -- React useEffect
  s("uef", {
    t({"useEffect(() => {", "  "}),
    i(1, "// Effect code"),
    t({"", "  return () => {", "    "}),
    i(2, "// Cleanup code"),
    t({"", "  };", "}, ["}),
    i(3, "/* dependencies */"),
    t({"]);"}),
  }),
  
  -- React component with props
  s("rcomp", {
    t({"interface "}),
    i(1, "Component"),
    t({"Props {", "  "}),
    i(2, "// Props"),
    t({"", "}", "", "export function "}),
    f(function(args) return args[1][1] end, {1}),
    t({"({ "}),
    i(3, "/* destructured props */"),
    t({" }: "}),
    f(function(args) return args[1][1] end, {1}),
    t({"Props) {", "  return (", "    "}),
    i(0, "<div></div>"),
    t({"", "  );", "}", ""}),
  }),
  
  -- Next.js metadata export
  s("nmeta", {
    t({"export const metadata = {", "  title: '"}),
    i(1, "Page Title"),
    t({"',", "  description: '"}),
    i(2, "Page Description"),
    t({"',", "};", ""}),
  }),
}

return snippets
]])
          file:close()
        end
      end
      
      -- Create JavaScript snippets file
      local js_snippets_file = snippets_dir .. "/javascript.lua"
      if vim.fn.filereadable(js_snippets_file) == 0 then
        local file = io.open(js_snippets_file, "w")
        if file then
          file:write([[
-- JavaScript snippets for Next.js
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

local snippets = {
  -- Next.js config
  s("nconfig", {
    t({"/** @type {import('next').NextConfig} */", "const nextConfig = {", "  "}),
    c(1, {
      t({"// Base configuration", "reactStrictMode: true,"}),
      t({"// With redirects", "reactStrictMode: true,", "  async redirects() {", "    return [", "      {", "        source: '/old-path',", "        destination: '/new-path',", "        permanent: true,", "      },", "    ];", "  },"}),
      t({"// With image domains", "reactStrictMode: true,", "  images: {", "    domains: ['example.com'],", "  },"}),
      t({"// With API rewrites", "reactStrictMode: true,", "  async rewrites() {", "    return {", "      beforeFiles: [", "        {", "          source: '/api/:path*',", "          destination: 'https://api.example.com/:path*',", "        },", "      ],", "    };", "  },"}),
    }),
    t({"", "};", "", "module.exports = nextConfig;", ""}),
  }),
}

return snippets
]])
          file:close()
        end
      end
      
      -- Create TypeScript snippets file
      local ts_snippets_file = snippets_dir .. "/typescript.lua"
      if vim.fn.filereadable(ts_snippets_file) == 0 then
        local file = io.open(ts_snippets_file, "w")
        if file then
          file:write([[
-- TypeScript snippets for Next.js
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local snippets = {
  -- Next.js API handler
  s("napi", {
    t({"export async function GET(request: Request) {", "  "}),
    i(1, "// Handle GET request"),
    t({"", "  return Response.json({ message: 'Hello from API route!' });", "}", ""}),
  }),
  
  -- Next.js API handler with multiple HTTP methods
  s("napi-methods", {
    t({"export async function GET(request: Request) {", "  "}),
    i(1, "// Handle GET request"),
    t({"", "  return Response.json({ message: 'Hello from GET' });", "}", "", "export async function POST(request: Request) {", "  const body = await request.json();", "  ", "  "}),
    i(2, "// Handle POST request"),
    t({"", "  return Response.json({ message: 'Hello from POST', received: body });", "}", ""}),
  }),
  
  -- Next.js dynamic API route
  s("napi-dynamic", {
    t({"export async function GET(", "  request: Request,", "  { params }: { params: { "}),
    i(1, "id"),
    t({": string } }", ") {", "  "}),
    t({"const "}), f(function(args) return args[1][1] end, {1}), t({" = params."}), f(function(args) return args[1][1] end, {1}), t({";", "  ", "  return Response.json({ "}),
    f(function(args) return args[1][1] end, {1}), t({" });", "}", ""}),
  }),
  
  -- TypeScript React component type
  s("tscomp", {
    t({"import React from 'react';", "", "type "}), i(1, "Component"), t({"Props = {", "  "}), i(2, "children: React.ReactNode"), t({"", "};", "", "export default function "}), 
    f(function(args) return args[1][1] end, {1}), 
    t({" ({ "}), i(3, "children"), t({" }: "}), f(function(args) return args[1][1] end, {1}), t({"Props) {", "  return (", "    "}), 
    i(0, "<div>{children}</div>"), 
    t({"", "  );", "}", ""})
  }),
}

return snippets
]])
          file:close()
        end
      end
    end,
    priority = 70,
  },
  
  -- React component refactoring
  {
    "vuki656/package-info.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {},
    event = "BufRead package.json",
    priority = 65,
  },
  
  -- Improve Typescript/React development with better treesitter support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "typescript",
          "tsx",
          "javascript",
          "css",
          "html",
          "json",
          "jsonc",
          "prisma",
        })
      end
    end,
    priority = 65,
  },

  -- Enhanced jsx/tsx commenting
  {
    "numToStr/Comment.nvim",
    opts = function(_, opts)
      local ft = require("Comment.ft")
      ft.set("javascriptreact", {"{/* %s */}", "// %s"})
      ft.set("typescriptreact", {"{/* %s */}", "// %s"})
      return opts
    end,
    priority = 60,
  },
  
  -- Next.js utilities
  {
    "nvim-lua/plenary.nvim",
    optional = true,
    config = function()
      -- Create a utility function for creating Next.js components
      _G.new_nextjs_component = function(type)
        type = type or "client" -- Default to client component
        
        -- Get the component name from user input
        local component_name = vim.fn.input("Component Name: ")
        if component_name == "" then
          vim.notify("Component name cannot be empty", vim.log.levels.ERROR)
          return
        end
        
        -- Create a new buffer
        local bufnr = vim.api.nvim_create_buf(true, false)
        
        -- Set buffer name
        vim.api.nvim_buf_set_name(bufnr, component_name .. ".tsx")
        
        -- Set filetype
        vim.api.nvim_buf_set_option(bufnr, "filetype", "typescriptreact")
        
        -- Generate component content based on type
        local content = {}
        if type == "client" then
          table.insert(content, "'use client';")
          table.insert(content, "")
          table.insert(content, "import React from 'react';")
          table.insert(content, "")
          table.insert(content, "interface " .. component_name .. "Props {")
          table.insert(content, "  // Props go here")
          table.insert(content, "}")
          table.insert(content, "")
          table.insert(content, "export default function " .. component_name .. "({ }: " .. component_name .. "Props) {")
          table.insert(content, "  return (")
          table.insert(content, "    <div>")
          table.insert(content, "      " .. component_name .. " Component")
          table.insert(content, "    </div>")
          table.insert(content, "  );")
          table.insert(content, "}")
        elseif type == "server" then
          table.insert(content, "import React from 'react';")
          table.insert(content, "")
          table.insert(content, "interface " .. component_name .. "Props {")
          table.insert(content, "  // Props go here")
          table.insert(content, "}")
          table.insert(content, "")
          table.insert(content, "export default async function " .. component_name .. "({ }: " .. component_name .. "Props) {")
          table.insert(content, "  // Server-side logic here")
          table.insert(content, "  return (")
          table.insert(content, "    <div>")
          table.insert(content, "      " .. component_name .. " Server Component")
          table.insert(content, "    </div>")
          table.insert(content, "  );")
          table.insert(content, "}")
        elseif type == "page" then
          table.insert(content, "import React from 'react';")
          table.insert(content, "")
          table.insert(content, "export const metadata = {")
          table.insert(content, "  title: '" .. component_name .. "',")
          table.insert(content, "  description: '" .. component_name .. " page',")
          table.insert(content, "};")
          table.insert(content, "")
          table.insert(content, "export default function Page() {")
          table.insert(content, "  return (")
          table.insert(content, "    <main className=\"p-4\">")
          table.insert(content, "      <h1 className=\"text-2xl font-bold\">" .. component_name .. " Page</h1>")
          table.insert(content, "    </main>")
          table.insert(content, "  );")
          table.insert(content, "}")
        elseif type == "layout" then
          table.insert(content, "import React from 'react';")
          table.insert(content, "")
          table.insert(content, "export default function " .. component_name .. "Layout({")
          table.insert(content, "  children,")
          table.insert(content, "}: {")
          table.insert(content, "  children: React.ReactNode;")
          table.insert(content, "}) {")
          table.insert(content, "  return (")
          table.insert(content, "    <div className=\"layout\">")
          table.insert(content, "      {children}")
          table.insert(content, "    </div>")
          table.insert(content, "  );")
          table.insert(content, "}")
        end
        
        -- Set buffer content
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
        
        -- Open the buffer in the current window
        vim.api.nvim_win_set_buf(0, bufnr)
        
        -- Position cursor
        if type == "client" then
          vim.api.nvim_win_set_cursor(0, {7, 0}) -- Position at props
        elseif type == "server" then
          vim.api.nvim_win_set_cursor(0, {7, 0}) -- Position at props
        elseif type == "page" then
          vim.api.nvim_win_set_cursor(0, {6, 0}) -- Position at page content
        elseif type == "layout" then
          vim.api.nvim_win_set_cursor(0, {9, 0}) -- Position at layout
        end
        
        -- Enter insert mode
        vim.cmd("startinsert!")
      end
      
      -- Create commands for Next.js development
      vim.api.nvim_create_user_command("NextJSClientComponent", function()
        _G.new_nextjs_component("client")
      end, { desc = "Create a new Next.js client component" })
      
      vim.api.nvim_create_user_command("NextJSServerComponent", function()
        _G.new_nextjs_component("server")
      end, { desc = "Create a new Next.js server component" })
      
      vim.api.nvim_create_user_command("NextJSPage", function()
        _G.new_nextjs_component("page")
      end, { desc = "Create a new Next.js page" })
      
      vim.api.nvim_create_user_command("NextJSLayout", function()
        _G.new_nextjs_component("layout")
      end, { desc = "Create a new Next.js layout" })
      
      -- Create a command to start the Next.js development server
      vim.api.nvim_create_user_command("NextJSDev", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local nextjs_dev = Terminal:new({
          cmd = "npm run dev",
          direction = "float",
          close_on_exit = false,
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.notify("Starting Next.js development server...", vim.log.levels.INFO)
          end,
        })
        nextjs_dev:toggle()
      end, { desc = "Start Next.js development server" })
      
      -- Create a command to build the Next.js project
      vim.api.nvim_create_user_command("NextJSBuild", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local nextjs_build = Terminal:new({
          cmd = "npm run build",
          direction = "float",
          close_on_exit = false,
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.notify("Building Next.js project...", vim.log.levels.INFO)
          end,
        })
        nextjs_build:toggle()
      end, { desc = "Build Next.js project" })
      
      -- Create a command to lint the Next.js project
      vim.api.nvim_create_user_command("NextJSLint", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local nextjs_lint = Terminal:new({
          cmd = "npm run lint",
          direction = "float",
          close_on_exit = false,
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.notify("Linting Next.js project...", vim.log.levels.INFO)
          end,
        })
        nextjs_lint:toggle()
      end, { desc = "Lint Next.js project" })
      
      -- Add Next.js keymaps for specific file types
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
        callback = function()
          vim.keymap.set("n", "<leader>snc", "<cmd>NextJSClientComponent<CR>", { buffer = true, desc = "New Client Component" })
          vim.keymap.set("n", "<leader>sns", "<cmd>NextJSServerComponent<CR>", { buffer = true, desc = "New Server Component" })
          vim.keymap.set("n", "<leader>snp", "<cmd>NextJSPage<CR>", { buffer = true, desc = "New Page" })
          vim.keymap.set("n", "<leader>snl", "<cmd>NextJSLayout<CR>", { buffer = true, desc = "New Layout" })
          vim.keymap.set("n", "<leader>snd", "<cmd>NextJSDev<CR>", { buffer = true, desc = "Start Dev Server" })
          vim.keymap.set("n", "<leader>snb", "<cmd>NextJSBuild<CR>", { buffer = true, desc = "Build Project" })
          vim.keymap.set("n", "<leader>snl", "<cmd>NextJSLint<CR>", { buffer = true, desc = "Lint Project" })
        end
      })
      
      -- Auto-detect Next.js project and create useful resources
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.g.current_stack == "nextjs" then
            -- Create useful VSCode settings file if in a Next.js project
            local vscode_dir = vim.fn.getcwd() .. "/.vscode"
            local settings_file = vscode_dir .. "/settings.json"
            
            if vim.fn.isdirectory(vscode_dir) == 0 then
              vim.fn.mkdir(vscode_dir, "p")
            end
            
            if vim.fn.filereadable(settings_file) == 0 then
              local settings = {
                ["editor.formatOnSave"] = true,
                ["editor.defaultFormatter"] = "esbenp.prettier-vscode",
                ["editor.codeActionsOnSave"] = {
                  ["source.fixAll.eslint"] = true,
                },
                ["typescript.tsdk"] = "node_modules/typescript/lib",
                ["typescript.enablePromptUseWorkspaceTsdk"] = true,
                ["tailwindCSS.includeLanguages"] = {
                  ["typescript"] = "javascript",
                  ["typescriptreact"] = "javascript"
                },
                ["tailwindCSS.emmetCompletions"] = true,
              }
              
              local file = io.open(settings_file, "w")
              if file then
                file:write(vim.json.encode(settings))
                file:close()
                vim.notify("Created VSCode settings for Next.js project", vim.log.levels.INFO)
              end
            end
            
            -- Create .prettierrc if it doesn't exist
            local prettier_config = vim.fn.getcwd() .. "/.prettierrc"
            if vim.fn.filereadable(prettier_config) == 0 then
              local prettier_settings = {
                semi = true,
                singleQuote = true,
                printWidth = 100,
                tabWidth = 2,
                trailingComma = "es5",
                bracketSpacing = true,
              }
              
              local file = io.open(prettier_config, "w")
              if file then
                file:write(vim.json.encode(prettier_settings))
                file:close()
                vim.notify("Created .prettierrc for Next.js project", vim.log.levels.INFO)
              end
            end
          end
        end,
        once = true,
      })
    end,
    priority = 50,
  },
}
