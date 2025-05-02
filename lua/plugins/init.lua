-- lua/plugins/init.lua
-- Plugin specifications for lazy.nvim
-- This file is imported by lazy.nvim via `import = "plugins"` in your lazy config

---@type LazySpec[]
return {
  -- Utility libraries
  { "nvim-lua/plenary.nvim" },
  { "nvim-lua/popup.nvim" },

  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Themes and UI
  { "sainnhe/gruvbox-material", lazy = false, priority = 1000 },
  { "folke/tokyonight.nvim", lazy = true, priority = 900 },
  { "rcarriga/nvim-notify", lazy = true, priority = 940 },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
  },

  -- File explorer (Oil)
  {
    "stevearc/oil.nvim",
    lazy = false,
    config = function()
      require("oil").setup()
    end,
  },

  -- Keybinding guide
  { "folke/which-key.nvim", event = "VeryLazy" },

  -- Snacks picker
  { "folke/snacks.nvim", event = "VeryLazy" },

  -- Fuzzy finder (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Treesitter for syntax and folding
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
  },

  -- LSP and completion
  { "neovim/nvim-lspconfig", event = "BufReadPre" },
  { "williamboman/mason.nvim", cmd = "Mason" },
  { "williamboman/mason-lspconfig.nvim", after = "mason.nvim" },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("config.completion").setup()
    end,
  },

  -- Git integration
  { "lewis6991/gitsigns.nvim", event = "VeryLazy" },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
    event = "VeryLazy",
  },

  -- Auto-pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Conditional stack-specific plugins can live in separate files (plugins/goth.lua, plugins/nextjs.lua)
}
