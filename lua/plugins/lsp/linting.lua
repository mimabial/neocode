-- nvim-lint for filetypes where LSP diagnostics are insufficient
-- (shellcheck > bashls, markdownlint > marksman). Lua/TS/Python/JSON/YAML
-- already get good diagnostics from their LSPs.

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "williamboman/mason.nvim" },
  opts = {
    linters_by_ft = {
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      zsh = { "zsh" },
      markdown = { "markdownlint" },
    },
    linters = {
      shellcheck = { reads_saved_file = true },
    },
  },
  config = function(_, opts)
    local lint = require("lint")

    local function is_executable(cmd)
      return type(cmd) == "string" and vim.fn.executable(cmd) == 1
    end

    local function reads_saved_file(name)
      local linter = lint.linters[name]
      return linter.reads_saved_file or not linter.stdin
    end

    local function sees_buffer_content(name)
      return not vim.bo.modified or not reads_saved_file(name)
    end

    local function buffer_digest()
      return vim.fn.sha256(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"))
    end

    local function installed_linters(ft)
      local out = {}
      for _, name in ipairs(opts.linters_by_ft[ft] or {}) do
        local l = lint.linters[name]
        if l and is_executable(l.cmd) then
          table.insert(out, name)
        end
      end
      return out
    end

    for name, config in pairs(opts.linters) do
      if lint.linters[name] then
        for key, val in pairs(config) do
          lint.linters[name][key] = val
        end
      end
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      callback = function(args)
        local saved_to_disk = args.event == "BufWritePost"
        if not saved_to_disk and vim.b.linted_changedtick == vim.b.changedtick then
          return
        end
        local linters = vim.tbl_filter(sees_buffer_content, installed_linters(vim.bo.filetype))
        if #linters == 0 then
          return
        end
        local digest = buffer_digest()
        local content_linted = vim.b.linted_digest == digest
        vim.b.linted_changedtick = vim.b.changedtick
        vim.b.linted_digest = digest
        if content_linted and not (saved_to_disk and vim.iter(linters):any(reads_saved_file)) then
          return
        end
        lint.try_lint(linters)
      end,
    })

    vim.keymap.set("n", "<leader>cL", function()
      lint.try_lint(vim.tbl_filter(sees_buffer_content, installed_linters(vim.bo.filetype)))
      vim.notify("Triggered linting", vim.log.levels.INFO)
    end, { desc = "Trigger linting" })
  end,
}
