-- JSON, YAML, ESLint, plus optional node-based servers (tailwindcss, etc).
return {
  { "b0o/SchemaStore.nvim", lazy = true },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "b0o/SchemaStore.nvim" },
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "jsonls", "yamlls", "eslint" })

      opts.servers.jsonls = {
        filetypes = { "json", "jsonc" },
        settings = { json = { schemas = require("schemastore").json.schemas() } },
      }

      opts.servers.yamlls = {
        settings = {
          yaml = {
            schemas = require("schemastore").yaml.schemas(),
            schemaStore = { enable = false, url = "" },
          },
        },
      }

      opts.servers.eslint = { settings = { packageManager = "npm" } }

      if vim.fn.executable("node") == 1 then
        vim.list_extend(opts.ensure_installed, {
          "tailwindcss", "emmet_ls", "vuels", "svelte", "astro",
        })
      end

      return opts
    end,
  },
}
