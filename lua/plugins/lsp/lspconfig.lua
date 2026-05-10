-- LSP setup. Per-language configs live in lua/plugins/lang/*.lua and extend
-- this spec via opts.servers (a name -> vim.lsp.Config table) and
-- opts.ensure_installed (servers to install via mason). The config function
-- here just applies them.

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
      vim.list_extend(opts.ensure_installed, {
        "marksman", "html", "cssls", "ts_ls", "taplo", "lemminx",
      })
      return opts
    end,

    config = function(_, opts)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

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
    end,
  },
}
