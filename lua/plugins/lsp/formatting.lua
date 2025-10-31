return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "ruff",
        "stylua",
        "shfmt",
        "prettierd",
      },
      run_on_start = true,
    },
    config = function(_, opts)
      require("mason-tool-installer").setup(opts)
    end,
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
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
    opts = function()
      local util = require("conform.util")

      return {
        log_level = vim.log.levels.DEBUG,
        format_on_save = function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          local ft = vim.bo[bufnr].filetype
          if vim.tbl_contains({ "sql", "diff", "gitcommit", "oil" }, ft) then
            return
          end
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if ok and stats and stats.size > 1000000 then
            return
          end
          -- For large files (>1000 lines), skip sync formatting and use format_after_save instead
          if vim.api.nvim_buf_line_count(bufnr) > 1000 then
            return
          end
          return { timeout_ms = 1000, lsp_fallback = true, quiet = false }
        end,
        -- Asynchronous format after save for larger files
        format_after_save = function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          local ft = vim.bo[bufnr].filetype
          if vim.tbl_contains({ "sql", "diff", "gitcommit", "oil" }, ft) then
            return
          end
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if ok and stats and stats.size > 1000000 then
            return
          end
          -- Only format large files (>1000 lines) asynchronously after save
          if vim.api.nvim_buf_line_count(bufnr) > 1000 then
            return { lsp_fallback = true, quiet = false }
          end
        end,
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          json = { "prettier" },
          jsonc = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          lua = { "stylua" },
          python = { "ruff_organize_imports", "ruff_format" },
          php = { "php_cs_fixer" },
          sh = { "shfmt" },
          bash = { "shfmt", "shellcheck" },
        },
        formatters = {
          ["*"] = { stop_after_first = true },
          prettier = {
            prepend_args = function(_, ctx)
              local args = { "--print-width", "100", "--trailing-comma", "none" }
              local config = util.root_file({
                ".prettierrc",
                ".prettierrc.json",
                ".prettierrc.yml",
                ".prettierrc.yaml",
                ".prettierrc.json5",
                ".prettierrc.js",
                "prettier.config.js",
                ".prettierrc.toml",
              })
              if config then
                table.insert(args, "--config")
                table.insert(args, config)
              end
              return args
            end,
          },
          stylua = {
            config_path = vim.fn.stdpath("config") .. "/stylua.toml",
            args = function(_, ctx)
              return { "--search-parent-directories", "--respect-ignores", "--stdin-filepath", ctx.filename, "-" }
            end,
          },
          ruff_format = {
            command = "ruff",
            args = {
              "format",
              "--stdin-filename",
              "$FILENAME",
              "-",
            },
            stdin = true,
          },
          ruff_organize_imports = {
            command = "ruff",
            args = {
              "check",
              "--select",
              "I",
              "--fix",
              "--stdin-filename",
              "$FILENAME",
              "-",
            },
            stdin = true,
          },
          shfmt = { prepend_args = { "-i", "2", "-ci" } },
        },
        notify_on_error = true,
      }
    end,
    config = function(_, opts)
      local conform = require("conform")
      conform.setup(opts)

      -- Create Format command with LSP fallback
      vim.api.nvim_create_user_command("Format", function(args)
        local range = args.range > 0
            and {
              start = { args.line1, 0 },
              ["end"] = { args.line2, 999999 },
            }
          or nil
        conform.format({ async = true, lsp_fallback = true, range = range })
      end, { range = true, desc = "Format buffer or range" })

      vim.api.nvim_create_user_command("FormatWith", function(args)
        if not args.args or args.args == "" then
          vim.notify("Formatter name required", vim.log.levels.ERROR)
          return
        end
        conform.format({ async = true, formatters = { args.args } })
      end, {
        nargs = 1,
        complete = function()
          return vim.tbl_keys(require("conform").formatters)
        end,
        desc = "Format with specific formatter",
      })
    end,
  },
}
