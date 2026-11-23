-- JSON, YAML, ESLint, plus optional node-based servers (tailwindcss, etc).
return {
  { "b0o/SchemaStore.nvim", lazy = true },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.ensure_installed = opts.ensure_installed or {}
      opts.tools = opts.tools or {}

      opts.servers.jsonls = {
        settings = { json = {} },
        before_init = function(_, config)
          config.settings.json.schemas = require("schemastore").json.schemas()
        end,
      }

      opts.servers.yamlls = {
        settings = { yaml = { schemaStore = { enable = false, url = "" } } },
        before_init = function(_, config)
          config.settings.yaml.schemas = require("schemastore").yaml.schemas()
        end,
      }

      opts.servers.eslint = { settings = { packageManager = "npm" } }

      opts.servers.ts_ls = {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
              languages = { "vue" },
            },
          },
        },
      }

      if vim.fn.executable("node") == 1 then
        vim.list_extend(opts.ensure_installed, {
          "jsonls", "yamlls", "eslint", "html", "cssls", "ts_ls",
          "tailwindcss", "emmet_ls", "vue_ls", "svelte", "astro",
        })
        vim.list_extend(opts.tools, { "prettierd", "markdownlint" })

        local tailwind_configs = {
          "tailwind.config.js",
          "tailwind.config.cjs",
          "tailwind.config.mjs",
          "tailwind.config.ts",
          "theme/static_src/tailwind.config.js",
          "theme/static_src/tailwind.config.cjs",
          "theme/static_src/tailwind.config.mjs",
          "theme/static_src/tailwind.config.ts",
        }

        local tailwind_manifests = {
          { names = { "package.json", "package.json5" }, needles = { '"tailwindcss"', '"@tailwindcss/' } },
          { names = { "mix.lock", "Gemfile.lock" }, needles = { "tailwind" } },
        }
        local manifest_scans = {}

        local function manifest_mentions_any(path, needles)
          local stat = vim.uv.fs_stat(path)
          if not stat then
            return false
          end
          local version = stat.mtime.sec .. "." .. stat.mtime.nsec
          local scan = manifest_scans[path]
          if not scan or scan.version ~= version then
            local ok, content = pcall(vim.fn.readblob, path)
            scan = {
              version = version,
              mentions = ok and vim.iter(needles):any(function(needle)
                return content:find(needle, 1, true) ~= nil
              end),
            }
            manifest_scans[path] = scan
          end
          return scan.mentions
        end

        local function is_tailwind_root(dir)
          for _, config in ipairs(tailwind_configs) do
            if vim.uv.fs_stat(vim.fs.joinpath(dir, config)) then
              return true
            end
          end
          for _, manifest in ipairs(tailwind_manifests) do
            for _, name in ipairs(manifest.names) do
              if manifest_mentions_any(vim.fs.joinpath(dir, name), manifest.needles) then
                return true
              end
            end
          end
          return false
        end

        opts.servers.tailwindcss = {
          -- nvim-lspconfig falls back to .git for Tailwind v4 projects. That
          -- is too broad for this setup: config repos and theme files can make
          -- the server index huge trees and OOM. Require a real Tailwind marker.
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if fname == "" then
              return
            end
            for dir in vim.fs.parents(fname) do
              if is_tailwind_root(dir) then
                on_dir(dir)
                return
              end
            end
          end,
        }
      end

      return opts
    end,
  },
}
