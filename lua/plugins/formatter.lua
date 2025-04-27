return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
    -- Add keybinding to toggle format on save (global)
    {
      "<leader>ta",
      function()
        vim.cmd("FormatToggle")
      end,
      desc = "Toggle auto format (global)",
    },
    -- Add keybinding to toggle format on save (buffer)
    {
      "<leader>tA",
      function()
        vim.cmd("FormatToggleBuffer")
      end,
      desc = "Toggle auto format (buffer)",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { { "prettierd", "prettier" } },
      typescript = { { "prettierd", "prettier" } },
      javascriptreact = { { "prettierd", "prettier" } },
      typescriptreact = { { "prettierd", "prettier" } },
      json = { { "prettierd", "prettier" } },
      jsonc = { { "prettierd", "prettier" } },
      html = { { "prettierd", "prettier" } },
      css = { { "prettierd", "prettier" } },
      scss = { { "prettierd", "prettier" } },
      markdown = { { "prettierd", "prettier" } },
      yaml = { { "prettierd", "prettier" } },
      rust = { "rustfmt" },
      go = { "gofmt", "goimports" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      java = { "google_java_format" },
      kotlin = { "ktlint" },
      php = { "php_cs_fixer" },
      ruby = { "rubocop" },
      sh = { "shfmt", "shellcheck" },
      bash = { "shfmt", "shellcheck" },
      zsh = { "shfmt" },
    },
    -- Set up format-on-save
    format_on_save = function(bufnr)
      -- Disable autoformat on certain filetypes
      local ignore_filetypes = { "sql", "java" }
      if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
        return
      end

      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      -- Format asynchronously if the buffer is large
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      local async = line_count > 1000

      return {
        timeout_ms = 1000, -- More time for complex files
        lsp_fallback = true,
        async = async, -- Use async for large files
      }
    end,
    -- Customize formatters
    formatters = {
      -- Customize default options for formatters
      stylua = {
        -- Use a standard stylua.toml if it exists in the project
        cwd = function()
          local util = require("conform.util")
          return util.root_file({ "stylua.toml", ".stylua.toml" })
        end,
      },
      -- Configure black for Python
      black = {
        prepend_args = { "--fast", "--line-length", "88" },
      },
      -- Configure isort for Python
      isort = {
        prepend_args = { "--profile", "black" },
      },
      -- Configure prettier for web development
      prettier = {
        prepend_args = { "--print-width", "100" },
      },
      -- Add shell format
      shfmt = {
        prepend_args = { "-i", "2" },
      },
    },
  },
  config = function(_, opts)
    require("conform").setup(opts)

    -- Add commands to toggle format-on-save
    vim.api.nvim_create_user_command("FormatToggle", function()
      vim.g.disable_autoformat = not vim.g.disable_autoformat
      vim.notify("Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"), vim.log.levels.INFO)
    end, {})

    vim.api.nvim_create_user_command("FormatToggleBuffer", function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.b[bufnr].disable_autoformat = not vim.b[bufnr].disable_autoformat
      vim.notify(
        "Format on save " .. (vim.b[bufnr].disable_autoformat and "disabled" or "enabled") .. " for this buffer",
        vim.log.levels.INFO
      )
    end, {})
  end,
}
