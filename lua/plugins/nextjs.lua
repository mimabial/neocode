-- Configuration for Next.js development
return {
  -- TypeScript tools
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
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
  },

  -- React snippets and tools
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      local c = ls.choice_node
      
      -- Next.js specific snippets
      ls.add_snippets("typescriptreact", {
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
          t({"interface PageProps {", "  params: {", "    "}),
          i(1, "id"),
          t({": string", "  }", "}", "", "export default function Page({ params }: PageProps) {", "  return (", "    <div>"}),
          t({"Dynamic parameter: {params."}), f(function(args) return args[1][1] end, {1}), t({"}", "    </div>"),
          t({"", "  );", "}", ""}),
        }),
        
        -- Next.js with search params
        s("nsearch", {
          t({"export default function Page({", "  searchParams,", "}: {", "  searchParams: { [key: string]: string | string[] | undefined };", "}) {", "  return (", "    <div>"}),
          t({"Search param: {searchParams."}), i(1, "query"), t({" as string}", "    </div>"),
          t({"", "  );", "}", ""}),
        }),
        
        -- Next.js with data fetching
        s("nfetch", {
          t({"async function getData() {", "  const res = await fetch('"}),
          i(1, "https://api.example.com/data"),
          t({"'", "  });", "  "}),
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
      })
      
      -- Add the same snippets to javascript JSX files
      ls.filetype_extend("javascriptreact", { "typescriptreact" })
      
      -- Add snippets for Next.js API routes
      ls.add_snippets("typescript", {
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
      })
      
      -- Add snippets for next.config.js
      ls.add_snippets("javascript", {
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
      })
      
      -- Add snippets for package.json
      ls.add_snippets("json", {
        -- Next.js dependencies
        s("ndeps", {
          t({"\"dependencies\": {", "  \"next\": \"^14.0.0\",", "  \"react\": \"^18.2.0\",", "  \"react-dom\": \"^18.2.0\"", "},", "\"devDependencies\": {", "  \"@types/node\": \"^20.0.0\",", "  \"@types/react\": \"^18.2.0\",", "  \"@types/react-dom\": \"^18.2.0\",", "  \"typescript\": \"^5.0.0\"", "}"}),
        }),
      })
    end,
  },

  -- React specific tools
  {
    "windwp/nvim-ts-autotag",
    opts = {
      filetypes = { "html", "tsx", "jsx", "javascriptreact", "typescriptreact" },
    },
  },
  
  -- React component refactoring
  {
    "vuki656/package-info.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {},
    event = "BufRead package.json",
  },
  
  -- Tailwind CSS support
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        tailwind = true,
        mode = "background",
        css = true,
        css_variables = true,
      },
    },
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
  },
  
  -- Add custom formatters for Next.js
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        javascriptreact = { { "prettierd", "prettier" } },
        typescriptreact = { { "prettierd", "prettier" } },
        css = { { "prettierd", "prettier" } },
        json = { { "prettierd", "prettier" } },
        jsonc = { { "prettierd", "prettier" } },
        graphql = { { "prettierd", "prettier" } },
      },
      formatters = {
        prettierd = {
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/.prettierrc"),
          },
        },
        prettier = {
          options = {
            configPath = vim.fn.getcwd() .. "/.prettierrc",
          },
        },
      },
    },
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
  },
  
  -- Add ESLint integration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mfussenegger/nvim-lint",
      config = function()
        require("lint").linters_by_ft = {
          javascript = {"eslint"},
          typescript = {"eslint"},
          javascriptreact = {"eslint"},
          typescriptreact = {"eslint"},
        }
        
        -- Automatically lint on save
        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
          pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
          callback = function()
            require("lint").try_lint()
          end,
        })
      end,
    },
  },
  
  -- Better file browser for Next.js project navigation
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("file_browser")
      
      -- Add custom mapping for Next.js project structure
      vim.keymap.set("n", "<leader>fn", function()
        local opts = {
          path = "%:p:h",
          cwd = vim.fn.getcwd(),
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = false,
          initial_mode = "normal",
          layout_config = { height = 40 },
        }
        require("telescope").extensions.file_browser.file_browser(opts)
      end, { desc = "Browse Next.js Project" })
    end,
  },
  
  -- Add custom configuration for Next.js projects in LSP
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Enhance tsserver configuration for Next.js
      if opts.servers and opts.servers.tsserver then
        opts.servers.tsserver.settings = vim.tbl_deep_extend("force", opts.servers.tsserver.settings or {}, {
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
        })
      }
      
      -- Add custom handlers for Next.js files
      if opts.setup then
        local lspconfig = require("lspconfig")
        
        opts.setup.tsserver = function(_, server_opts)
          -- Register custom handlers for Next.js file structure
          vim.api.nvim_create_autocmd("BufRead", {
            pattern = {"app/*/page.tsx", "app/*/layout.tsx", "app/*/route.ts"},
            callback = function(args)
              -- Add specific LSP features for Next.js files
              local fname = vim.fn.expand("%:t")
              local bufnr = args.buf
              
              if fname == "page.tsx" then
                -- Add code lens for pages
                vim.api.nvim_buf_set_var(bufnr, "is_nextjs_page", true)
              elseif fname == "layout.tsx" then
                -- Add code lens for layouts
                vim.api.nvim_buf_set_var(bufnr, "is_nextjs_layout", true)
              elseif fname == "route.ts" then
                -- Add code lens for API routes
                vim.api.nvim_buf_set_var(bufnr, "is_nextjs_api", true)
              end
            end
          })
          
          -- Continue with normal setup
          return false
        end
      end
      
      return opts
    end,
  },
  
  -- Next.js project management
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      if opts.defaults then
        -- Add Next.js specific keymaps in the which-key menu
        opts.defaults["<leader>sn"] = { 
          name = "+Next.js Stack",
          -- Create a new Next.js project
          n = { 
            function()
              vim.ui.input({ prompt = "Project name: " }, function(name)
                if not name or name == "" then
                  return
                end
                
                -- Create a new terminal for project initialization
                local Terminal = require("toggleterm.terminal").Terminal
                local nextjs_init = Terminal:new({
                  cmd = string.format("npx create-next-app@latest %s --typescript --eslint --tailwind --app --src-dir --import-alias '@/*'", name),
                  hidden = false,
                  direction = "float",
                  float_opts = {
                    width = math.floor(vim.o.columns * 0.9),
                    height = math.floor(vim.o.lines * 0.9),
                  },
                  on_exit = function()
                    vim.cmd("cd " .. name)
                    vim.notify("Next.js project '" .. name .. "' initialized! Run 'cd " .. name .. " && npm run dev'", vim.log.levels.INFO)
                  end,
                })
                nextjs_init:toggle()
              end)
            end,
            "New Next.js Project" 
          },
          -- Run the development server
          d = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local nextjs_dev = Terminal:new({
                cmd = "npm run dev",
                hidden = false,
                direction = "horizontal",
                on_open = function(term)
                  vim.cmd("startinsert!")
                end,
              })
              nextjs_dev:toggle()
            end,
            "Run Development Server" 
          },
          -- Build the production version
          b = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local nextjs_build = Terminal:new({
                cmd = "npm run build",
                hidden = false,
                direction = "horizontal",
                on_open = function(term)
                  vim.cmd("startinsert!")
                end,
              })
              nextjs_build:toggle()
            end,
            "Build for Production" 
          },
          -- Start the production server
          s = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local nextjs_start = Terminal:new({
                cmd = "npm run start",
                hidden = false,
                direction = "horizontal",
                on_open = function(term)
                  vim.cmd("startinsert!")
                end,
              })
              nextjs_start:toggle()
            end,
            "Start Production Server" 
          },
          -- Run tests
          t = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local nextjs_test = Terminal:new({
                cmd = "npm run test",
                hidden = false,
                direction = "horizontal",
                on_open = function(term)
                  vim.cmd("startinsert!")
                end,
              })
              nextjs_test:toggle()
            end,
            "Run Tests" 
          },
          -- Lint the project
          l = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local nextjs_lint = Terminal:new({
                cmd = "npm run lint",
                hidden = false,
                direction = "horizontal",
                on_open = function(term)
                  vim.cmd("startinsert!")
                end,
              })
              nextjs_lint:toggle()
            end,
            "Lint Project" 
          },
          -- Create a new component
          c = { function() require("config.utils").new_nextjs_component("client") end, "New Client Component" },
          -- Create a new server component
          S = { function() require("config.utils").new_nextjs_component("server") end, "New Server Component" },
          -- Create a new page component
          p = { function() require("config.utils").new_nextjs_component("page") end, "New Page" },
          -- Create a new layout component
          L = { function() require("config.utils").new_nextjs_component("layout") end, "New Layout" },
          -- Generate component from clipboard
          g = {
            function()
              -- Get text from clipboard
              local clipboard = vim.fn.getreg("+")
              if not clipboard or clipboard == "" then
                vim.notify("Clipboard is empty", vim.log.levels.ERROR)
                return
              end
              
              -- Ask for component name
              vim.ui.input({ prompt = "Component name: " }, function(name)
                if not name or name == "" then
                  return
                end
                
                -- Create component file
                local file_path = "src/components/" .. name .. ".tsx"
                
                -- Check if src/components directory exists
                if vim.fn.isdirectory("src/components") == 0 then
                  vim.fn.mkdir("src/components", "p")
                end
                
                -- Create the file with appropriate React component structure
                local file = io.open(file_path, "w")
                if file then
                  -- Format clipboard content as component
                  local content = string.format([['use client';

import React from 'react';

interface %sProps {
  // Add props here
}

export default function %s({ }: %sProps) {
  return (
%s
  );
}
]], name, name, name, clipboard)
                  
                  file:write(content)
                  file:close()
                  
                  -- Open the new file
                  vim.cmd("edit " .. file_path)
                  vim.notify("Component created: " .. file_path, vim.log.levels.INFO)
                else
                  vim.notify("Failed to create component file", vim.log.levels.ERROR)
                end
              end)
            end,
            "Generate Component from Clipboard"
          },
          -- Install a package
          i = {
            function()
              vim.ui.input({ prompt = "Package name: " }, function(package)
                if not package or package == "" then
                  return
                end
                
                local Terminal = require("toggleterm.terminal").Terminal
                local npm_install = Terminal:new({
                  cmd = "npm install " .. package,
                  hidden = false,
                  direction = "float",
                  on_open = function(term)
                    vim.cmd("startinsert!")
                  end,
                })
                npm_install:toggle()
              end)
            end,
            "Install Package"
          },
          -- Install a development package
          D = {
            function()
              vim.ui.input({ prompt = "Dev package name: " }, function(package)
                if not package or package == "" then
                  return
                end
                
                local Terminal = require("toggleterm.terminal").Terminal
                local npm_install_dev = Terminal:new({
                  cmd = "npm install -D " .. package,
                  hidden = false,
                  direction = "float",
                  on_open = function(term)
                    vim.cmd("startinsert!")
                  end,
                })
                npm_install_dev:toggle()
              end)
            end,
            "Install Dev Package"
          },
        }
      end
      
      return opts
    end,
  },
  
  -- Custom commands for Next.js development
  {
    "folke/which-key.nvim",
    optional = true,
    config = function(_, _)
      -- Add autocommand for quick functions in Next.js files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"typescriptreact", "javascriptreact"},
        callback = function(args)
          local buffer = args.buf
          local file_path = vim.api.nvim_buf_get_name(buffer)
          
          if file_path:match("app/.*/page%.[jt]sx$") or file_path:match("pages/.*%.[jt]sx$") then
            -- We're in a Next.js page file
            vim.api.nvim_buf_create_user_command(buffer, "NextAdd", function(cmd_args)
              local component_type = cmd_args.args
              if component_type == "metadata" then
                -- Add metadata export
                local lines = {
                  "",
                  "export const metadata = {",
                  "  title: 'Page Title',",
                  "  description: 'Page description',",
                  "};"
                }
                
                -- Insert at the top of the file
                vim.api.nvim_buf_set_lines(buffer, 0, 0, false, lines)
                vim.notify("Added metadata export", vim.log.levels.INFO)
              elseif component_type == "loading" then
                -- Create corresponding loading.tsx file
                local dir = vim.fn.fnamemodify(file_path, ":h")
                local loading_path = dir .. "/loading.tsx"
                
                local file = io.open(loading_path, "w")
                if file then
                  file:write([[
export default function Loading() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
    </div>
  );
}
]])
                  file:close()
                  vim.notify("Created loading.tsx", vim.log.levels.INFO)
                else
                  vim.notify("Failed to create loading.tsx", vim.log.levels.ERROR)
                end
              elseif component_type == "error" then
                -- Create corresponding error.tsx file
                local dir = vim.fn.fnamemodify(file_path, ":h")
                local error_path = dir .. "/error.tsx"
                
                local file = io.open(error_path, "w")
                if file then
                  file:write([['use client';

import { useEffect } from 'react';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100">
      <h2 className="text-2xl font-bold text-red-600 mb-4">Something went wrong!</h2>
      <button
        className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
        onClick={() => reset()}
      >
        Try again
      </button>
    </div>
  );
}
]])
                  file:close()
                  vim.notify("Created error.tsx", vim.log.levels.INFO)
                else
                  vim.notify("Failed to create error.tsx", vim.log.levels.ERROR)
                end
              else
                vim.notify("Unknown component type. Options: metadata, loading, error", vim.log.levels.WARN)
              end
            end, { nargs = 1, complete = function() return { "metadata", "loading", "error" } end, desc = "Add Next.js component" })
          end
          
          -- For API routes
          if file_path:match("app/.*/route%.[jt]s$") or file_path:match("pages/api/.*%.[jt]s$") then
            vim.api.nvim_buf_create_user_command(buffer, "NextAddMethod", function(cmd_args)
              local method = cmd_args.args:upper()
              local valid_methods = {GET = true, POST = true, PUT = true, DELETE = true, PATCH = true}
              
              if not valid_methods[method] then
                vim.notify("Invalid HTTP method. Use: GET, POST, PUT, DELETE, PATCH", vim.log.levels.WARN)
                return
              end
              
              local template
              if method == "GET" then
                template = [[
export async function GET(request: Request) {
  // Handle GET request
  return Response.json({ message: 'GET request handler' });
}
]]
              elseif method == "POST" then
                template = [[
export async function POST(request: Request) {
  // Parse the request body
  const body = await request.json();
  
  // Handle POST request
  return Response.json({ message: 'POST request handled', received: body });
}
]]
              elseif method == "PUT" then
                template = [[
export async function PUT(request: Request) {
  // Parse the request body
  const body = await request.json();
  
  // Handle PUT request
  return Response.json({ message: 'PUT request handled', received: body });
}
]]
              elseif method == "DELETE" then
                template = [[
export async function DELETE(request: Request) {
  // Handle DELETE request
  return Response.json({ message: 'DELETE request handled' });
}
]]
              else -- PATCH
                template = [[
export async function PATCH(request: Request) {
  // Parse the request body
  const body = await request.json();
  
  // Handle PATCH request
  return Response.json({ message: 'PATCH request handled', received: body });
}
]]
              end
              
              -- Add to the end of the file
              local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
              table.insert(lines, "")
              
              for line in template:gmatch("[^\r\n]+") do
                table.insert(lines, line)
              end
              
              vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
              vim.notify("Added " .. method .. " method handler", vim.log.levels.INFO)
            end, { nargs = 1, complete = function() return { "GET", "POST", "PUT", "DELETE", "PATCH" } end, desc = "Add HTTP method handler" })
          end
        end
      })
    end,
  },
}
