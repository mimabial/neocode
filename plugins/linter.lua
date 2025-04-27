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

    -- Filter out linters that aren't installed
    local function filter_linters(linters_list)
      local filtered = {}
      for _, linter in ipairs(linters_list) do
        -- Check if the linter is available
        if lint.linters[linter] and vim.fn.executable(lint.linters[linter].cmd) == 1 then
          table.insert(filtered, linter)
        end
      end
      return filtered
    end

    -- Process and filter linters by filetype
    local linters_by_ft_filtered = {}
    for ft, linters in pairs(opts.linters_by_ft) do
      linters_by_ft_filtered[ft] = filter_linters(linters)
    end

    lint.linters_by_ft = linters_by_ft_filtered

    -- Configure linter options
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
        local ft = vim.bo.filetype
        -- Only try to lint if there are linters configured for this filetype
        if linters_by_ft_filtered[ft] and #linters_by_ft_filtered[ft] > 0 then
          require("lint").try_lint()
        end
      end,
    })

    -- Add key mapping to manually trigger linting
    vim.keymap.set("n", "<leader>cl", function()
      require("lint").try_lint()
      vim.notify("Triggered linting", vim.log.levels.INFO)
    end, { desc = "Trigger linting" })
  end,
}
