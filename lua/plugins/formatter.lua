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
      go = { "gofumpt", "goimports" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      java = { "google_java_format" },
      kotlin = { "ktlint" },
      php = { "php_cs_fixer" },
      ruby = { "rubocop" },
      sh = { "shfmt", "shellcheck" },
      bash = { "shfmt", "shellcheck" },
      zsh = { "shfmt" },
      -- Add GOTH stack specific formatters
      templ = { "templ" },
    },
    
    -- Set up format-on-save with more advanced configuration
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

      -- Check file size - don't auto-format large files
      local max_file_size = 1000000 -- 1MB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
      if ok and stats and stats.size > max_file_size then
        return
      end

      -- Format asynchronously if the buffer is large
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      local async = line_count > 1000

      return {
        timeout_ms = 3000, -- More time for complex files
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
        args = { "--search-parent-directories", "--stdin-filepath", "$FILENAME", "-" },
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
        prepend_args = function(self, ctx)
          local args = { "--print-width", "100" }
          -- Try to find local prettier config
          local prettier_config = require("conform.util").root_file({
            ".prettierrc",
            ".prettierrc.json",
            ".prettierrc.yml",
            ".prettierrc.yaml",
            ".prettierrc.json5",
            ".prettierrc.js",
            "prettier.config.js",
            ".prettierrc.toml",
          }, ctx.filename)
          
          if prettier_config then
            args = vim.list_extend(args, { "--config", prettier_config })
          end
          
          return args
        end,
      },
      -- Config for templ formatting
      templ = {
        command = "templ",
        args = { "fmt", "-" }, -- Newer versions support stdin
        stdin = true,
      },
      -- Add shell format
      shfmt = {
        prepend_args = { "-i", "2" },
      },
      
      -- Go formatters
      gofumpt = {
        -- Latest gofumpt can format from stdin
        stdin = true,
        args = { "-extra" },
      },
      goimports = {
        stdin = true,
      },
    },
    
    -- Set notification settings
    notify_on_error = true,
    
    -- Format range options
    format_after_save = {
      lsp_fallback = true,
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
    
    -- Create a command to format with specific formatter
    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.range > 0 then
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, 999999 },
        }
      end
      
      require("conform").format({
        async = true,
        lsp_fallback = true,
        range = range,
      })
    end, { range = true })
  end,
}
