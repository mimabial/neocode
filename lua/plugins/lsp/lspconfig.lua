-- LSP setup. Per-language configs live in lua/plugins/lang/*.lua and extend
-- this spec via opts.servers (a name -> vim.lsp.Config table),
-- opts.ensure_installed (servers) and opts.tools (formatters and linters, by
-- mason package name), both installed via mason. The config function applies them.

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },

    -- opts is a function so it composes with the lang/<lang>.lua opts
    -- functions instead of tbl_extend("force") wiping their additions.
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.ensure_installed = opts.ensure_installed or {}
      opts.tools = opts.tools or {}
      vim.list_extend(opts.ensure_installed, {
        "marksman",
        "taplo",
        "lemminx",
      })
      return opts
    end,

    config = function(_, opts)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- cmp-nvim-lsp normally refreshes only on InsertEnter. Register servers
      -- that finish attaching during the first insert session too.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("cmp_lsp_attach", { clear = true }),
        callback = function()
          if package.loaded.cmp then
            require("cmp_nvim_lsp")._on_insert_enter()
          end
        end,
      })

      -- Defaults applied to every server (merged with bundled nvim-lspconfig configs).
      vim.lsp.config("*", { capabilities = capabilities })

      -- Per-server settings registered by lang/<lang>.lua files.
      for name, cfg in pairs(opts.servers or {}) do
        vim.lsp.config(name, cfg)
      end

      require("mason-lspconfig").setup({
        ensure_installed = opts.ensure_installed,
        automatic_enable = true,
      })
      require("lib.mason_tools").ensure_available(opts.tools)
    end,
  },
}
