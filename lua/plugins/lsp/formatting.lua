local function resolve_root_dir(cwd)
  local git_dir = vim.fs.find({ ".git" }, { path = cwd, upward = true })[1]
  if git_dir then
    return vim.fs.dirname(git_dir)
  end

  local root_markers = {
    "go.mod",
    "go.work",
    "package.json",
    "pyproject.toml",
    "requirements.txt",
    "Cargo.toml",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "composer.json",
    "Gemfile",
    "CMakeLists.txt",
    "compile_commands.json",
    ".terraform.lock.hcl",
  }
  local marker = vim.fs.find(root_markers, { path = cwd, upward = true })[1]
  if marker then
    return vim.fs.dirname(marker)
  end

  return cwd
end

local function build_mason_tools_opts(cwd)
  cwd = cwd or vim.fn.getcwd()
  local root_dir = resolve_root_dir(cwd)
  local tools = {}

  local function add(list)
    for _, tool in ipairs(list) do
      tools[tool] = true
    end
  end

  local function has_any(names)
    for _, name in ipairs(names) do
      if name:find("[*?[]") then
        if #vim.fn.glob(root_dir .. "/" .. name, 0, 1) > 0 then
          return true
        end
      else
        local path = root_dir .. "/" .. name
        if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
          return true
        end
      end
    end
    return false
  end

  -- Baseline tools
  add({
    "stylua",
    "shfmt",
    "shellcheck",
  })

  if has_any({ "package.json", "pnpm-lock.yaml", "yarn.lock" }) then
    add({ "prettierd", "prettier" })
  end

  if has_any({ "pyproject.toml", "requirements.txt", "poetry.lock", "Pipfile", "setup.py" }) then
    add({ "ruff", "black", "isort" })
  end

  if has_any({ "go.mod", "go.work" }) then
    add({ "gofumpt", "goimports", "golines" })
  end

  if has_any({ "Cargo.toml" }) then
    add({ "rustfmt" })
  end

  if has_any({ "CMakeLists.txt", "Makefile", "compile_commands.json" }) then
    add({ "clang-format" })
  end

  if has_any({ "pom.xml", "build.gradle", "build.gradle.kts" }) then
    add({ "google-java-format" })
  end

  if has_any({ "Gemfile", ".rubocop.yml" }) then
    add({ "rubocop" })
  end

  if has_any({ "composer.json" }) then
    add({ "php-cs-fixer" })
  end

  if has_any({ "*.tf", ".terraform.lock.hcl" }) then
    add({ "terraform-fmt" })
  end

  if has_any({ "*.sql", "dbt_project.yml" }) then
    add({ "sqlfluff", "sql-formatter" })
  end

  if has_any({ "*.toml" }) then
    add({ "taplo" })
  end

  if has_any({ "*.yaml", "*.yml", ".yamllint", ".yamllint.yml" }) then
    add({ "yamlfmt" })
  end

  if has_any({ "*.md", "README.md", "readme.md" }) then
    add({ "markdownlint" })
  end

  if has_any({ "buf.yaml", "buf.gen.yaml", "buf.work.yaml" }) then
    add({ "buf" })
  end

  local ensure_installed = vim.tbl_keys(tools)
  table.sort(ensure_installed)

  return {
    ensure_installed = ensure_installed,
    run_on_start = true,
  }
end

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = build_mason_tools_opts,
    config = function(_, opts)
      local installer = require("mason-tool-installer")
      installer.setup(opts)

      local last_signature = table.concat(opts.ensure_installed or {}, "\n")
      local function refresh(cwd)
        local new_opts = build_mason_tools_opts(cwd)
        local new_signature = table.concat(new_opts.ensure_installed or {}, "\n")
        if new_signature == last_signature then
          return
        end
        last_signature = new_signature
        installer.setup(new_opts)
        installer.check_install(false)
      end

      if vim.fn.exists(":MasonToolsRefresh") == 0 then
        vim.api.nvim_create_user_command("MasonToolsRefresh", function()
          refresh()
        end, { desc = "Refresh tools for current project" })
      end

      vim.api.nvim_create_autocmd("DirChanged", {
        group = vim.api.nvim_create_augroup("MasonToolInstallerRefresh", { clear = true }),
        callback = function(event)
          refresh(event.cwd)
        end,
        desc = "Refresh Mason tools when the working directory changes",
      })
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
          if vim.tbl_contains({ "sql", "diff", "gitcommit", "oil", "htmldjango" }, ft) then
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
          if vim.tbl_contains({ "sql", "diff", "gitcommit", "oil", "htmldjango" }, ft) then
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
