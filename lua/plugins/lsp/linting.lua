-- nvim-lint for filetypes where LSP diagnostics are insufficient
-- (shellcheck > bashls, markdownlint > marksman). Lua/TS/Python/JSON/YAML
-- already get good diagnostics from their LSPs.

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    linters_by_ft = {
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      zsh = { "shellcheck" },
      markdown = { "markdownlint" },
    },
    linters = {},
  },
  config = function(_, opts)
    local lint = require("lint")

    local function is_executable(cmd)
      return type(cmd) == "string" and vim.fn.executable(cmd) == 1
    end

    local function filter_linters(list)
      local out = {}
      for _, name in ipairs(list) do
        local l = lint.linters[name]
        if l and is_executable(l.cmd) then
          table.insert(out, name)
        end
      end
      return out
    end

    local linters_by_ft = {}
    for ft, linters_for_ft in pairs(opts.linters_by_ft) do
      linters_by_ft[ft] = filter_linters(linters_for_ft)
    end
    lint.linters_by_ft = linters_by_ft

    for name, config in pairs(opts.linters) do
      if lint.linters[name] then
        for key, val in pairs(config) do
          lint.linters[name][key] = val
        end
      end
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      callback = function()
        local ft = vim.bo.filetype
        if linters_by_ft[ft] and #linters_by_ft[ft] > 0 then
          lint.try_lint()
        end
      end,
    })

    vim.keymap.set("n", "<leader>cL", function()
      lint.try_lint()
      vim.notify("Triggered linting", vim.log.levels.INFO)
    end, { desc = "Trigger linting" })
  end,
}
