local FORMAT_MAX_BUFFER_BYTES = 1000000
local SYNC_FORMAT_MAX_LINES = 1000

local format_excluded_filetypes = {
  sql = true,
  diff = true,
  gitcommit = true,
  oil = true,
  htmldjango = true,
}

local function buffer_allows_formatting(bufnr)
  if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat or require("lib.bigfile").is_big(bufnr) then
    return false
  end
  if format_excluded_filetypes[vim.bo[bufnr].filetype] then
    return false
  end
  return vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr)) <= FORMAT_MAX_BUFFER_BYTES
end

local function go_module_path(dirname)
  local go_mod = vim.fs.find("go.mod", { path = dirname, upward = true, type = "file" })[1]
  for _, line in ipairs(go_mod and vim.fn.readfile(go_mod) or {}) do
    local module_path = line:match('^module%s+"?([^"%s]+)')
    if module_path then
      return module_path
    end
  end
end

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
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

      vim.api.nvim_create_user_command("Format", function(args)
        local range = args.range > 0
            and {
              start = { args.line1, 0 },
              ["end"] = { args.line2, #vim.fn.getline(args.line2) },
            }
          or nil
        require("conform").format({ async = true, lsp_format = "fallback", range = range })
      end, { range = true, desc = "Format buffer or range" })

      vim.api.nvim_create_user_command("FormatWith", function(args)
        require("conform").format({ async = true, formatters = { args.args } })
      end, {
        nargs = 1,
        complete = function()
          return vim.tbl_keys(require("conform").formatters)
        end,
        desc = "Format with specific formatter",
      })
    end,
    opts = function()
      return {
        format_on_save = function(bufnr)
          if not buffer_allows_formatting(bufnr) or vim.api.nvim_buf_line_count(bufnr) > SYNC_FORMAT_MAX_LINES then
            return
          end
          return { timeout_ms = 1000, lsp_format = "fallback", quiet = false }
        end,
        format_after_save = function(bufnr)
          if not buffer_allows_formatting(bufnr) or vim.api.nvim_buf_line_count(bufnr) <= SYNC_FORMAT_MAX_LINES then
            return
          end
          return { lsp_format = "fallback", quiet = false }
        end,
        formatters_by_ft = {
          -- Lua
          lua = { "stylua" },

          -- Shell
          sh = { "shfmt" },
          bash = { "shfmt" },

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
            prepend_args = function(_, ctx)
              local module_path = go_module_path(ctx.dirname)
              return module_path and { "-local", module_path } or {}
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
        },
        notify_on_error = true,
      }
    end,
  },
}
