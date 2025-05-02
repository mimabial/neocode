-- lua/plugins/lsp.lua
-- Consolidated LSP-related plugin specifications for lazy.nvim
return {
  -- LSP configuration and management
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "jose-elias-alvarez/null-ls.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("config.lsp").setup()
    end,
  },

  -- Optional: enhanced UI for LSP diagnostics and code actions
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = { bind = true, handler_opts = { border = "single" } },
  },
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp" },
    opts = {},
  },

  -- LSP UI enhancements (hover, peek, etc.)
  {
    "glepnir/lspsaga.nvim",
    branch = "main",
    event = "LspAttach",
    opts = { border_style = "single" },
  },

  -- Inlay hints support for Neovim >=0.10
  {
    "lvimuser/lsp-inlayhints.nvim",
    event = "LspAttach",
    opts = { inlay_hints = { parameter_hints = true, type_hints = true } },
    config = function(_, opts)
      require("lsp-inlayhints").setup(opts)
    end,
  },

  -- Markdown preview and LSP integrations
  {
    "jose-elias-alvarez/typescript.nvim",
    ft = { "typescript", "typescriptreact", "typescript.tsx" },
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {},
  },
}
