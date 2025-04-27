--------------------------------------------------------------------------------
-- Linters Configuration
--------------------------------------------------------------------------------
--
-- This module configures code linters for different languages.
-- Linters analyze code for potential errors, bugs, stylistic errors, and
-- suspicious constructs.
--
-- We use nvim-lint to integrate linters that don't have Language Server Protocol
-- support directly.
--
-- Each linter is configured with:
-- 1. The file types it supports
-- 2. Any special configuration it needs
-- 3. Any command-line arguments to customize behavior
--
-- To add a new linter:
-- 1. Check if it's available in require("lint").linters
-- 2. Add it to the linters_by_ft table
--------------------------------------------------------------------------------

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Define linters by filetype
      linters_by_ft = {
        -- General linters for multiple filetypes
        ["*"] = { "codespell" },
        
        -- Language-specific linters
        lua = { "luacheck" },
        python = { "flake8", "mypy", "pydocstyle" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
        vue = { "eslint_d" },
        html = { "tidy" },
        css = { "stylelint" },
        scss = { "stylelint" },
        json = { "jsonlint" },
        yaml = { "yamllint" },
        markdown = { "markdownlint", "vale" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },
        go = { "golangci_lint" },
        rust = { "cargo" },
        docker = { "hadolint" },
        terraform = { "tflint" },
        sql = { "sqlfluff" },
        php = { "php" },
      },
      
      -- Linter-specific configuration
      linters = {
        -- Lua
        luacheck = {
          args = { "--globals", "vim", "--no-max-line-length" },
        },
      
      -- Run linters automatically
      autostart = true,
      
      -- Methods to trigger linting
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    },
    
    config = function(_, opts)
      local lint = require("lint")
      
      -- Setup nvim-lint with the provided options
      lint.linters_by_ft = opts.linters_by_ft
      
      -- Configure linters
      for name, linter_opts in pairs(opts.linters) do
        if lint.linters[name] then
          for opt_name, opt_value in pairs(linter_opts) do
            lint.linters[name][opt_name] = opt_value
          end
        end
      end
      
      -- Set up autocmd to trigger linting
      local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
      vim.api.nvim_create_autocmd(opts.events, {
        group = lint_augroup,
        callback = function()
          -- Skip linting if explicitly disabled
          if vim.b.disable_autoformat or vim.g.disable_autoformat then
            return
          end
          lint.try_lint()
        end,
      })
      
      -- Create commands to manually trigger lint
      vim.api.nvim_create_user_command("Lint", function()
        lint.try_lint()
      end, { desc = "Trigger linting for current file" })
      
      -- Command to toggle automatic linting
      vim.api.nvim_create_user_command("LintToggle", function()
        vim.b.disable_linting = not vim.b.disable_linting
        vim.notify(
          "Automatic linting " .. (vim.b.disable_linting and "disabled" or "enabled") .. " for current buffer",
          vim.log.levels.INFO
        )
      end, { desc = "Toggle automatic linting for current buffer" })
    end,
  },
}
        
        -- Python
        flake8 = {
          args = { "--max-line-length", "88", "--extend-ignore", "E203" },
          -- Find local versions of flake8
          condition = function()
            return vim.fn.executable("flake8") > 0
          end,
        },
        mypy = {
          -- Try to use local venv if available
          condition = function()
            return vim.fn.executable("mypy") > 0
          end,
        },
        pydocstyle = {},
        
        -- JavaScript/TypeScript
        eslint_d = {
          condition = function(ctx)
            return vim.fs.find({ 
              ".eslintrc", 
              ".eslintrc.js", 
              ".eslintrc.cjs",
              ".eslintrc.yaml", 
              ".eslintrc.yml", 
              ".eslintrc.json"
            }, { path = ctx.filename, upward = true })[1]
          end,
        },
        
        -- Shell
        shellcheck = {
          args = { "--severity", "warning" },
        },
        
        -- Markdown
        markdownlint = {
          args = { "--config", ".markdownlint.json" },
        },
        vale = {},
        
        -- JSON
        jsonlint = {},
        
        -- YAML
        yamllint = {
          args = { "-f", "parsable" },
        },
        
        -- Go
        golangci_lint = {
          args = { "run", "--out-format=json" },
        },
        
        -- Rust
        cargo = {
          args = { "clippy", "--message-format=json", "--", "-W", "clippy::all" },
        },
        
        -- Docker
        hadolint = {},
        
        -- Terraform
        tflint = {},
        
        -- SQL
        sqlfluff = {
          args = { "lint", "--dialect", "postgres", "--format", "json" },
        },
        
        -- PHP
        php = {
          args = { "-l", "-d", "display_errors=on", "-d", "log_errors=off" },
        },
        
        -- Common spell checker (works with all filetypes)
        codespell = {
          args = { "--quiet-level=4", "-" },
          ignore_exitcode = true,
        },
      },
