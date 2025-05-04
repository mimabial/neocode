-- lua/plugins/nextjs.lua
-- Next.js and TypeScript development enhancements
return {
  -- TypeScript tools for LSP enrichment
  {
    "pmizio/typescript-tools.nvim",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "typescript.tsx", "javascript.jsx" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      -- these go directly into require("typescript-tools").setup
      tsserver_plugins = { "@styled/typescript-styled-plugin" },
      expose_as_code_action = { "fix_all", "add_missing_imports", "remove_unused" },
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
    config = function(_, opts)
      local tt = require("typescript-tools")
      -- setup with opts
      tt.setup({ settings = opts })

      -- create TS user commands
      local api = require("typescript-tools.api")
      for cmd, fn in pairs({
        TSOrganizeImports = api.organize_imports,
        TSRenameFile = api.rename_file,
        TSAddMissingImports = api.add_missing_imports,
        TSRemoveUnused = api.remove_unused,
        TSFixAll = api.fix_all,
      }) do
        vim.api.nvim_create_user_command(cmd, fn, { desc = cmd })
      end

      -- filetype keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          local km = vim.keymap.set
          km("n", "<leader>sno", api.organize_imports, { buffer = buf, desc = "Organize Imports" })
          km("n", "<leader>snr", api.rename_file, { buffer = buf, desc = "Rename File" })
          km("n", "<leader>sni", api.add_missing_imports, { buffer = buf, desc = "Add Missing Imports" })
          km("n", "<leader>snu", api.remove_unused, { buffer = buf, desc = "Remove Unused" })
          km("n", "<leader>snf", api.fix_all, { buffer = buf, desc = "Fix All" })
        end,
      })
    end,
    priority = 80,
  },

  -- Formatter integration for Next.js filetypes
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
        html = { "prettierd", "prettier" },
        json = { "prettierd", "prettier" },
        graphql = { "prettierd", "prettier" },
      },
      -- configuration for each formatter
      formatters = {
        prettierd = { env = { PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/.prettierrc") } },
        prettier = {
          prepend_args = function(_, ctx)
            local util = require("conform.util")
            -- root_file now takes a single options table: patterns and path
            local config = util.root_file({
              patterns = { ".prettierrc", "prettier.config.js", ".prettierrc.json5" },
              path = ctx.filename,
            })
            if config then
              return { "--config", config }
            else
              return { "--print-width", "100", "--single-quote", "true" }
            end
          end,
        },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)
    end,
    priority = 50,
  },

  -- JSON schema support
  { "b0o/SchemaStore.nvim", lazy = true, priority = 55 },

  -- Tailwind integration
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "css", "html", "javascript", "typescript", "javascriptreact", "typescriptreact" },
    opts = { user_default_options = { tailwind = true, mode = "background" } },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
    priority = 65,
  },
  { "roobert/tailwindcss-colorizer-cmp.nvim", opts = { color_square_width = 2 }, priority = 60 },

  -- Snippet loader for Next.js snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      -- Ensure paths is a list of strings
      require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
    end,
    priority = 70,
  },
}
