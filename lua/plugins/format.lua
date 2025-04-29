return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
    {
      "<leader>ta",
      function()
        vim.cmd("FormatToggle")
      end,
      desc = "Toggle auto format (global)",
    },
    {
      "<leader>tA",
      function()
        vim.cmd("FormatToggleBuffer")
      end,
      desc = "Toggle auto format (buffer)",
    },
  },
  init = function()
    -- Create commands early so they are available when needed
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
  opts = {
    log_level = vim.log.levels.DEBUG,
    -- Define formatters by filetype
    formatters_by_ft = {
      -- Common web development formats
      javascript = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
      scss = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      jsonc = { "prettierd", "prettier" },
      yaml = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
      graphql = { "prettierd", "prettier" },

      -- Lua
      lua = { "stylua" },

      -- Go & GOTH stack
      go = { "gofumpt", "goimports" },
      templ = { "templ" },

      -- Other languages
      python = { "isort", "black" },
      rust = { "rustfmt" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      java = { "google_java_format" },
      php = { "php_cs_fixer" },
      ruby = { "rubocop" },
      sh = { "shfmt" },
      bash = { "shfmt", "shellcheck" },
      zsh = { "shfmt" },
    },

    -- Format on save configuration
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      -- Don't auto-format certain filetypes
      local ignore_filetypes = { "sql", "diff", "gitcommit", "oil" }
      if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
        return
      end

      -- Don't auto-format large files
      local max_file_size = 1000000 -- 1MB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
      if ok and stats and stats.size > max_file_size then
        return
      end

      -- Configure timeout and async behavior based on file size
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      local async = line_count > 1000

      return {
        timeout_ms = 5000, -- Increased timeout for complex files
        lsp_fallback = true,
        async = async,
        quiet = false, -- Show format errors
      }
    end,

    -- Formatter-specific configurations
    formatters = {
      ["*"] = {
        -- global formatter settings
        stop_after_first = true,
      },
      -- JavaScript/TypeScript/Web
      prettier = {
        -- Try to find a local prettier config first
        prepend_args = function(self, ctx)
          local args = { "--print-width", "100" }
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
            table.insert(args, "--config")
            table.insert(args, prettier_config)
          end

          return args
        end,
      },

      prettierd = {
        env = {
          PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/.prettierrc"),
        },
      },

      -- Lua
      stylua = {
        args = function(self, ctx)
          local args = {
            "--search-parent-directories",
            "--respect-ignores",
            "--stdin-filepath",
            ctx.filename,
            "-"
          }

          local conf_path = require("conform.util").root_file({
            "stylua.toml",
            ".stylua.toml",
          }, ctx.filename)

          if conf_path then
            table.insert(args, 1, conf_path)
            table.insert(args, 1, "--config-path")
          end

          return args
        end,
      },


      -- Go & GOTH stack
      gofumpt = {
        prepend_args = { "-extra" },
      },

      goimports = {},

      templ = {
        command = "templ",
        args = function(ctx)
          -- Check templ version to determine if it supports stdin
          -- Newer versions use `fmt -` for stdin, older versions don't support stdin
          local supports_stdin = false
          local handle = io.popen("templ version 2>&1")
          if handle then
            local result = handle:read("*a")
            handle:close()

            -- Check version
            local major, minor = result:match("v(%d+)%.(%d+)")
            if major and minor then
              if tonumber(major) > 0 or (tonumber(major) == 0 and tonumber(minor) >= 2) then
                supports_stdin = true
              end
            end
          end

          if supports_stdin then
            return { "fmt", "-" }
          else
            return { "fmt", "$FILENAME" }
          end
        end,
        stdin = function()
          -- Again, check if stdin is supported based on templ version
          local version_output = vim.fn.system("templ version 2>&1")
          if version_output:find("v0.2") or version_output:find("v1.") then
            return true
          end
          return false
        end,
      },

      -- Python
      black = {
        prepend_args = { "--fast", "--line-length", "88" },
      },
      isort = {
        prepend_args = { "--profile", "black" },
      },

      -- Shell
      shfmt = {
        prepend_args = { "-i", "2", "-ci" },
      },

      -- C/C++
      clang_format = {
        prepend_args = function(self, ctx)
          local style_file = require("conform.util").root_file({
            ".clang-format",
          }, ctx.filename)

          if style_file then
            return {}
          else
            -- Default style if no config file found
            return { "-style='{BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 100}'" }
          end
        end,
      },
    },

    -- Format range options
    format_after_save = {
      lsp_fallback = true,
    },

    notify_on_error = true,
  },
  config = function(_, opts)
    local conform = require("conform")

    -- Setup conform with our options
    conform.setup(opts)

    -- Add a Format command that supports ranges
    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.range > 0 then
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, 999999 },
        }
      end

      conform.format({
        async = true,
        lsp_fallback = true,
        range = range,
      })
    end, { range = true, desc = "Format buffer or range" })

    -- Add command to format with a specific formatter
    vim.api.nvim_create_user_command("FormatWith", function(args)
      if not args.args or args.args == "" then
        vim.notify("Formatter name required", vim.log.levels.ERROR)
        return
      end

      conform.format({
        async = true,
        formatters = { args.args },
      })
    end, {
      nargs = 1,
      complete = function()
        return vim.tbl_keys(conform.formatters)
      end,
      desc = "Format with specific formatter"
    })

    -- Set up autocommands for stack-specific behaviors
    local stack_setup_group = vim.api.nvim_create_augroup("StackSpecificFormat", { clear = true })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = stack_setup_group,
      pattern = { "*.templ" },
      callback = function(args)
        -- Check if templ formatter is installed
        local is_templ_available = vim.fn.executable("templ") == 1

        if not is_templ_available then
          vim.notify("templ command not found. Install templ to enable formatting.", vim.log.levels.WARN)
        end
      end,
    })
  end,
}
