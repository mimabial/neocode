return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    linters_by_ft = {
      lua = { "luacheck" },
      python = { "flake8", "mypy" },
      javascript = { "eslint" },
      typescript = { "eslint" },
      javascriptreact = { "eslint" },
      typescriptreact = { "eslint" },
      json = { "jsonlint" },
      yaml = { "yamllint" },
      sh = { "shellcheck" },
      markdown = { "markdownlint" },
    },
    -- Configure linters here
    linters = {
      luacheck = {
        args = { "--globals", "vim", "--no-max-line-length" },
      },
      flake8 = {
        args = { "--max-line-length=88", "--extend-ignore=E203" },
      },
    },
  },
  config = function(_, opts)
    local lint = require("lint")
    lint.linters_by_ft = opts.linters_by_ft

    for name, linter in pairs(opts.linters) do
      if lint.linters[name] then
        for option, value in pairs(linter) do
          lint.linters[name][option] = value
        end
      end
    end

    -- Create autocommand to trigger linting
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })

    -- Add key mapping to manually trigger linting
    vim.keymap.set("n", "<leader>cl", function()
      require("lint").try_lint()
      vim.notify("Triggered linting", vim.log.levels.INFO)
    end, { desc = "Trigger linting" })
  end,
}
