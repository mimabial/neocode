--------------------------------------------------------------------------------
-- Plugin Configuration
--------------------------------------------------------------------------------
--
-- This is the main entry point for plugin configurations.
-- It imports all plugin modules from their respective directories:
--
-- Structure:
-- 1. Core plugins that are always loaded
-- 2. Import modules from subdirectories:
--    - editor/: Navigation, text objects, etc.
--    - coding/: Completion, LSP, snippets, etc.
--    - langs/: Language-specific plugins
--    - tools/: Git, terminal, etc.
--    - ui/: Themes, statusline, etc.
--    - util/: Telescope, which-key, etc.
--
-- Each plugin is configured with lazy.nvim's declarative syntax.
-- For more info about lazy.nvim, see: https://github.com/folke/lazy.nvim
--------------------------------------------------------------------------------

return {
  -- Core plugins (always loaded)

  -- Package Manager (manages itself)
  {
    "folke/lazy.nvim",
    version = false, -- Using latest version
  },

  -- Icons (dependency for many plugins)
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    config = function()
      require("nvim-web-devicons").setup({
        override = {}, -- Used to override icons
        default = true, -- Use default icons for filetypes
      })
    end,
  },

  -- Plenary (dependency for many plugins)
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  -- Nui.nvim (UI components used by many plugins)
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },

  -- Improved UI for messages, cmdline, and popups
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        -- Override markdown rendering so that cmp and other plugins use Treesitter
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        -- Show signatures as you type
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true,
            luasnip = true,
            throttle = 50,
          },
        },
        -- Enhanced hover documentation
        hover = {
          enabled = true,
          silent = false, -- Show messages while hovering
        },
      },
      -- Enable built-in features
      presets = {
        bottom_search = true, -- Search at bottom of screen
        command_palette = true, -- Command palette UI
        long_message_to_split = true, -- Long messages go to a split
        inc_rename = true, -- Incremental renaming UI
        lsp_doc_border = true, -- Add border to hover docs
      },
      -- Hide certain messages
      routes = {
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true }, -- Skip "written" messages
        },
      },
    },
  },

  -- Better UI components
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      -- Load dressing.nvim when vim.ui functions are called
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
    opts = {
      input = {
        enabled = true,
        default_prompt = "Input:",
        border = "rounded",
        win_options = { winblend = 10 },
      },
      select = {
        enabled = true,
        backend = { "telescope", "builtin" },
        telescope = { layout_strategy = "center" },
        builtin = {
          border = "rounded",
          win_options = { winblend = 10 },
        },
      },
    },
  },

  -- Enhanced notifications
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true })
        end,
        desc = "Dismiss all notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
      background_colour = "#000000",
      stages = "fade_in_slide_out", -- Animation style
      top_down = true, -- Notifications appear from top
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
  },

  -- Which-key for keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true }, -- Enable spelling suggestions
      defaults = {
        mode = { "n", "v" },
        -- Define key group prefixes for which-key
        ["g"] = { name = "+goto" },
        ["["] = { name = "+prev" },
        ["]"] = { name = "+next" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>q"] = { name = "+quit/session" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>w"] = { name = "+window" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add(opts.defaults)
    end,
  },

  -- Import all plugin modules
  { import = "plugins.editor" },  -- Editor enhancements
  { import = "plugins.coding" },  -- Coding support (LSP, completion, etc.)
  { import = "plugins.lsp" },     -- LSP configuration
  { import = "plugins.langs" },   -- Language specific plugins
  { import = "plugins.tools" },   -- Development tools (git, terminal, etc.)
  { import = "plugins.ui" },      -- UI components
  { import = "plugins.util" },    -- Utilities (telescope, etc.)
}
