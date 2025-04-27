--------------------------------------------------------------------------------
-- Linters Configuration
--------------------------------------------------------------------------------
--
-- This module configures code linters for different languages.
-- Linters analyze code for potential errors, bugs, stylistic issues, and
-- suspicious constructs.
--
-- We use nvim-lint to integrate linters that don't have LSP support.
--
-- Features:
-- 1. Real-time linting as you type or on save
-- 2. Support for various linters per language
-- 3. Automatic triggering on file events
-- 4. Toggle functionality for enabling/disabling linting
-- 5. Linter-specific configuration options
--
-- To add a new linter:
-- 1. Check if it's available in require("lint").linters
-- 2. Add it to the linters_by_ft table
--------------------------------------------------------------------------------

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      
      -- Configure linters for different filetypes
      lint.linters_by_ft = {
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
      }
      
      -- Linter-specific configuration
      lint.linters.luacheck.args = { 
        "--globals", "vim", 
        "--no-max-line-length", 
        "--no-unused-args",
      }
      
      lint.linters.flake8.args = { 
        "--max-line-length", "88", 
        "--extend-ignore", "E203" 
      }
      
      lint.linters.shellcheck.args = { 
        "--severity", "warning",
        "--shell", "bash",
        "--enable", "all",
      }
      
      lint.linters.markdownlint.args = { 
        "--config", ".markdownlint.json" 
      }
      
      lint.linters.eslint_d.condition = function(ctx)
        return vim.fs.find({ 
          ".eslintrc", 
          ".eslintrc.js", 
          ".eslintrc.cjs",
          ".eslintrc.yaml", 
          ".eslintrc.yml", 
          ".eslintrc.json"
        }, { path = ctx.filename, upward = true })[1] ~= nil
      end
      
      lint.linters.golangci_lint.args = { 
        "run", 
        "--out-format=json",
      }
      
      lint.linters.cargo = {
        args = { "clippy", "--message-format=json", "--", "-W", "clippy::all" },
      }
      
      -- Set up autocmd for automatic linting
      local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
      
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          -- Skip linting if explicitly disabled
          if vim.b.disable_autoformat or vim.g.disable_autoformat then
            return
          end
          
          -- Don't lint large files
          local max_filesize = 500 * 1024 -- 500 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
          if ok and stats and stats.size > max_filesize then
            return
          end
          
          -- Don't lint certain filetypes
          local exclude_filetypes = { "alpha", "dashboard", "help", "NvimTree", "neo-tree", "Trouble", "lazy" }
          if vim.tbl_contains(exclude_filetypes, vim.bo.filetype) then
            return
          end
          
          lint.try_lint()
        end,
      })
      
      -- Command to manually trigger linting
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
      
      -- Keymap to toggle linting
      vim.keymap.set("n", "<leader>ul", function()
        vim.b.disable_linting = not vim.b.disable_linting
        vim.notify("Linting " .. (vim.b.disable_linting and "disabled" or "enabled"), vim.log.levels.INFO)
      end, { desc = "Toggle linting" })
    end,
  },
}
