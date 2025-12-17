return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Lua
        "stylua",

        -- Shell
        "shfmt",
        "shellcheck",

        -- Web Development
        "prettierd",
        "prettier",

        -- Python
        "ruff",
        "black",
        "isort",

        -- Go
        "gofumpt",
        "goimports",
        "golines",

        -- Rust
        "rustfmt",

        -- C/C++
        "clang-format",

        -- Java
        "google-java-format",

        -- PHP
        "php-cs-fixer",

        -- Ruby
        "rubocop",

        -- SQL
        "sqlfluff",
        "sql-formatter",

        -- TOML
        "taplo",

        -- YAML
        "yamlfmt",

        -- Markdown
        "markdownlint",

        -- Swift
        "swiftformat",

        -- Terraform
        "terraform-fmt",

        -- Proto
        "buf",
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
          -- Lua
          lua = { "stylua" },

          -- Shell
          sh = { "shfmt" },
          bash = { "shfmt" },
          zsh = { "shfmt" },

          -- Web Development
          javascript = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
          vue = { "prettierd", "prettier", stop_after_first = true },
          svelte = { "prettierd", "prettier", stop_after_first = true },
          astro = { "prettierd", "prettier", stop_after_first = true },
          html = { "prettierd", "prettier", stop_after_first = true },
          css = { "prettierd", "prettier", stop_after_first = true },
          scss = { "prettierd", "prettier", stop_after_first = true },
          less = { "prettierd", "prettier", stop_after_first = true },
          json = { "prettierd", "prettier", stop_after_first = true },
          jsonc = { "prettierd", "prettier", stop_after_first = true },
          yaml = { "prettierd", "prettier", stop_after_first = true },
          graphql = { "prettierd", "prettier", stop_after_first = true },

          -- Markdown
          markdown = { "prettierd", "prettier", "markdownlint", stop_after_first = true },
          ["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },

          -- Python
          python = { "ruff_organize_imports", "ruff_format" },

          -- Go
          go = { "goimports", "gofumpt" },

          -- Rust
          rust = { "rustfmt" },

          -- C/C++
          c = { "clang_format" },
          cpp = { "clang_format" },
          objc = { "clang_format" },
          objcpp = { "clang_format" },

          -- C#
          cs = { "csharpier" },

          -- Java
          java = { "google-java-format" },

          -- Kotlin
          kotlin = { "ktlint" },

          -- Swift
          swift = { "swiftformat" },

          -- Ruby
          ruby = { "rubocop" },

          -- PHP
          php = { "php_cs_fixer" },

          -- Elixir
          elixir = { "mix" },

          -- SQL
          sql = { "sqlfluff", "sql_formatter", stop_after_first = true },

          -- TOML
          toml = { "taplo" },

          -- Terraform
          terraform = { "terraform_fmt" },
          tf = { "terraform_fmt" },
          ["terraform-vars"] = { "terraform_fmt" },

          -- Protocol Buffers
          proto = { "buf" },

          -- Nix
          nix = { "alejandra", "nixpkgs_fmt", stop_after_first = true },

          -- Zig
          zig = { "zigfmt" },

          -- OCaml
          ocaml = { "ocamlformat" },

          -- Haskell
          haskell = { "fourmolu", "ormolu", stop_after_first = true },

          -- Dart/Flutter
          dart = { "dart_format" },

          -- LaTeX
          tex = { "latexindent" },
          bib = { "bibtex-tidy" },

          -- XML
          xml = { "xmlformat" },

          -- Fish
          fish = { "fish_indent" },

          -- Just
          just = { "just" },

          -- Makefile (careful - tabs matter!)
          -- make = {},  -- Usually skip formatting makefiles
        },
        formatters = {
          -- Lua
          stylua = {
            prepend_args = { "--search-parent-directories", "--respect-ignores" },
          },

          -- Python
          ruff_format = {
            command = "ruff",
            args = { "format", "--stdin-filename", "$FILENAME", "-" },
          },
          ruff_organize_imports = {
            command = "ruff",
            args = { "check", "--select", "I", "--fix", "--stdin-filename", "$FILENAME", "-" },
          },

          -- Go
          goimports = {
            prepend_args = function(self, ctx)
              local go_mod = util.root_file({ "go.mod" })(ctx.buf)
              if go_mod then
                return { "-local", "." }
              end
              return {}
            end,
          },
          gofumpt = {
            prepend_args = { "-extra" },
          },

          -- Shell
          shfmt = {
            prepend_args = { "-i", "2", "-ci", "-bn" },
          },

          -- C/C++
          clang_format = {
            prepend_args = function()
              return { "--style", "file", "--fallback-style", "llvm" }
            end,
          },

          -- SQL
          sqlfluff = {
            args = { "format", "--dialect=ansi", "-" },
          },

          -- Terraform
          terraform_fmt = {
            command = "terraform",
            args = { "fmt", "-" },
          },

          -- PHP
          php_cs_fixer = {
            command = "php-cs-fixer",
            args = {
              "fix",
              "$FILENAME",
              "--rules=@PSR12",
            },
          },

          -- Rust (uses rustfmt from toolchain)
          rustfmt = {
            command = "rustfmt",
            args = { "--edition", "2021" },
          },
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
