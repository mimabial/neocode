-- Configuration for Next.js development
return {
  -- NextJS and React specific tools
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Enhance tsserver configuration for Next.js
        tsserver = {
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
        },
        -- ESLint for NextJS projects
        eslint = {
          settings = {
            workingDirectories = { { mode = "auto" } },
          },
        },
        -- Tailwind CSS for styling
        tailwindcss = {
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  { "classnames\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  { "twMerge\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  { "tv\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                },
              },
              validate = true,
            },
          },
        },
      },
    },
  },
  
  -- TypeScript tools
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      settings = {
        tsserver_plugins = {
          -- for Next.js
          "@styled/typescript-styled-plugin",
          -- Add other TypeScript plugins here as needed
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
      local d = ls.dynamic_node
      
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
      })
      
      -- Add the same snippets to javascript/typescript files
      ls.filetype_extend("javascript", { "javascriptreact" })
      ls.filetype_extend("typescript", { "typescriptreact" })
    end,
  },
  
  -- React specific tools
  {
    "windwp/nvim-ts-autotag",
    opts = {
      filetypes = { "html", "tsx", "javascriptreact", "typescriptreact" },
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
          -- Removed "jsx" as it's not a valid parser in newer treesitter
          -- JSX syntax is handled by javascript and tsx parsers
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
      },
    },
  },
  
  -- Better CSS and styling support
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
      custom_surroundings = {
        -- Add JSX/TSX component surround
        ["c"] = {
          input = { "<([%w-]+)>", "</[%w-]+>" },
          output = function()
            local component = vim.fn.input("Component name: ")
            if component == "" then
              return nil
            end
            return { { "<" .. component .. ">" }, { "</" .. component .. ">" } }
          end,
        },
      },
    },
  },
  
  -- Add support for component libraries often used with Next.js
  {
    "folke/trouble.nvim",
    -- Override to add JSX/TSX specific configuration
    opts = {
      use_diagnostic_signs = true,
      auto_preview = false,
      include_declaration = { "lsp_references", "lsp_implementations", "lsp_definitions" },
    },
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
}
