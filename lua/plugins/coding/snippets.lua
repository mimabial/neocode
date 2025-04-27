--------------------------------------------------------------------------------
-- Snippets Configuration
--------------------------------------------------------------------------------
--
-- This module configures snippet support for various languages.
--
-- Features:
-- 1. LuaSnip as the snippet engine
-- 2. VSCode-compatible snippets from friendly-snippets
-- 3. Custom snippets for various languages
-- 4. Snippet keybindings for navigation and expansion
-- 5. Support for dynamic snippets and choice nodes
-- 6. Integration with completion system
--
-- Snippets dramatically improve coding speed by providing templates
-- for common patterns that can be quickly expanded.
--------------------------------------------------------------------------------

return {
  -- Main snippet engine
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets", -- Collection of snippets for various languages
      "honza/vim-snippets",           -- Additional snippets from vim-snippets
    },
    build = "make install_jsregexp",  -- Improves regex support
    config = function()
      local ls = require("luasnip")

      -- Load pre-defined snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()

      -- Load custom snippets
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" }
      })

      -- Setup LuaSnip
      ls.setup({
        history = true,                                  -- Keep track of snippet history for jumping back
        update_events = "TextChanged,TextChangedI",      -- Update snippets as you type
        delete_check_events = "TextChanged,InsertLeave", -- Check for deleted snippets
        enable_autosnippets = true,                      -- Enable automatic snippets
        ext_opts = {
          [require("luasnip.util.types").choiceNode] = {
            active = {
              virt_text = { { "●", "GruvboxOrange" } },
            },
          },
          [require("luasnip.util.types").insertNode] = {
            active = {
              virt_text = { { "●", "GruvboxBlue" } },
            },
          },
        },
      })

      -- Key mappings for snippet navigation
      vim.keymap.set({ "i", "s" }, "<C-j>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end, { silent = true, desc = "Snippet: Expand or jump forward" })

      vim.keymap.set({ "i", "s" }, "<C-k>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true, desc = "Snippet: Jump backward" })

      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true, desc = "Snippet: Cycle choices forward" })

      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        if ls.choice_active() then
          ls.change_choice(-1)
        end
      end, { silent = true, desc = "Snippet: Cycle choices backward" })

      -- Add snippet filetype extensions
      ls.filetype_extend("typescript", { "javascript", "tsdoc" })
      ls.filetype_extend("typescript.tsx", { "typescript", "javascript.jsx", "javascript" })
      ls.filetype_extend("javascript.jsx", { "javascript" })
      ls.filetype_extend("typescriptreact", { "typescript.tsx" })
      ls.filetype_extend("javascriptreact", { "javascript.jsx" })
      ls.filetype_extend("python", { "django", "numpy", "pandas", "matplotlib", "pytorch" })
      ls.filetype_extend("rust", { "rust-analyzer" })
      ls.filetype_extend("cpp", { "c" })
      ls.filetype_extend("lua", { "luadoc" })
      ls.filetype_extend("html", { "htmldjango", "eruby" })
      ls.filetype_extend("markdown", { "latex" })

      -- Custom snippet definitions
      -- These can be expanded by using their trigger text and then <Tab>

      -- Define helper functions for snippets
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      local c = ls.choice_node
      local d = ls.dynamic_node
      local sn = ls.snippet_node
      local rep = require("luasnip.extras").rep
      local fmt = require("luasnip.extras.fmt").fmt

      -- Add custom snippets for various languages
      ls.add_snippets("all", {
        -- Date snippet for any file type
        s("date", f(function() return os.date("%Y-%m-%d") end)),

        -- Current time snippet
        s("time", f(function() return os.date("%H:%M:%S") end)),

        -- User name and email (from global config)
        s("user", f(function()
          local name = vim.g.user_name or "Your Name"
          return name
        end)),

        s("email", f(function()
          local email = vim.g.user_email or "your.email@example.com"
          return email
        end)),
      })

      -- Add file header comment snippets for various languages
      local header_snippets = {
        lua = s("header", fmt([[
--------------------------------------------------------------------------------
-- {}
--------------------------------------------------------------------------------
--
-- Author: {}
-- Date: {}
--
-- Description:
-- {}
--
--------------------------------------------------------------------------------

]], {
          i(1, "File Title"),
          f(function() return vim.g.user_name or "Your Name" end),
          f(function() return os.date("%Y-%m-%d") end),
          i(2, "File description"),
        })),

        python = s("header", fmt([[
# -----------------------------------------------------------------------------
# {}
# -----------------------------------------------------------------------------
#
# Author: {}
# Date: {}
#
# Description:
# {}
#
# -----------------------------------------------------------------------------

]], {
          i(1, "File Title"),
          f(function() return vim.g.user_name or "Your Name" end),
          f(function() return os.date("%Y-%m-%d") end),
          i(2, "File description"),
        })),

        -- Add more languages as needed
      }

      -- Add header snippets to each language
      for lang, snippet in pairs(header_snippets) do
        ls.add_snippets(lang, { snippet })
      end

      -- Initialize custom snippet directories
      -- Create a 'snippets' directory if it doesn't exist
      local snippets_dir = vim.fn.stdpath("config") .. "/snippets"
      if vim.fn.isdirectory(snippets_dir) == 0 then
        vim.fn.mkdir(snippets_dir, "p")
      end
    end,
  },

  -- Integration with completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "saadparwaiz1/cmp_luasnip", -- LuaSnip completion source
    },
    opts = function(_, opts)
      -- Ensure LuaSnip source is included
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "luasnip", priority = 800 })
    end,
  },

  -- Better snippets for specific languages/frameworks
  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip").filetype_extend("typescript", { "javascript" })
      require("luasnip").filetype_extend("typescript.tsx", { "javascript.jsx" })
      require("luasnip").filetype_extend("javascriptreact", { "javascript.jsx" })
      require("luasnip").filetype_extend("typescriptreact", { "typescript.tsx" })
    end,
  },

  -- LaTeX snippets
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    ft = { "tex", "latex", "markdown" },
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function()
      require("luasnip-latex-snippets").setup({
        use_treesitter = true,
        allow_on_markdown = true,
      })
    end,
  },

  -- Snippet UI improvements
  {
    "smjonas/snippet-converter.nvim",
    cmd = "ConvertSnippets",
    config = function()
      require("snippet_converter").setup({
        templates = {
          vscode_luasnip = true,
          ultisnips_luasnip = true,
          snipmate_luasnip = true,
        },
      })
    end,
  },
}
