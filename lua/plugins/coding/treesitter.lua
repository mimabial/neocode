-- lua/plugins/treesitter.lua (fixed JSX parser)

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<C-space>", desc = "Increment selection" },
      { "<BS>",      mode = "x",                  desc = "Decrement selection" },
    },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "vim",
        "vimdoc",
        "tsx",
        "typescript",
      },
      highlight = {
        enable = true,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<BS>",
        },
      },
    },
    config = function(_, opts)
      -- Safe initialization with error handling
      local function setup_treesitter()
        -- Remove duplicates in ensure_installed
        local seen = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if seen[lang] then
            return false
          end
          seen[lang] = true
          return true
        end, opts.ensure_installed)

        -- Setup parsers with error handling
        pcall(function()
          -- Register filetypes to parsers mapping
          local ft_to_parser = require("nvim-treesitter.parsers").filetype_to_parsername
          ft_to_parser.javascriptreact = "jsx"
          ft_to_parser.typescriptreact = "tsx"
        end)

        -- Main TS setup with error handling
        require("nvim-treesitter.configs").setup(opts)
      end

      -- Run setup with global error handling
      pcall(setup_treesitter)

      -- Add custom highlights for JSX with error handling
      pcall(function()
        vim.api.nvim_create_autocmd("ColorScheme", {
          callback = function()
            -- JSX highlights
            vim.api.nvim_set_hl(0, "@tag.jsx", { link = "@tag.tsx" })
            vim.api.nvim_set_hl(0, "@tag.delimiter.jsx", { link = "@tag.delimiter.tsx" })
            vim.api.nvim_set_hl(0, "@constructor.jsx", { link = "@constructor.tsx" })
          end,
        })
      end)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      max_lines = 8,
      separator = "─",
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)

      -- Function to properly extract and set treesitter context colors
      local function update_context_highlights()
        -- Direct color extraction from highlight groups
        local function get_hl_color(group, attr, fallback)
          local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
          local val = ok and hl[attr]
          if not val then
            return fallback
          end
          if type(val) == "number" then
            return string.format("#%06x", val)
          end
          return tostring(val)
        end

        -- Get background from Normal highlight group (works for all themes)
        local bg_color = get_hl_color("Normal", "bg", "NONE")
        local border_color = get_hl_color("FloatBorder", "fg", get_hl_color("Comment", "fg", "#666666"))

        -- Set treesitter context highlights
        vim.api.nvim_set_hl(0, "TreesitterContext", { bg = bg_color })
        vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = border_color })
      end

      -- Initial setup
      update_context_highlights()

      -- Update highlights when colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Delay to ensure theme is fully applied
          vim.defer_fn(update_context_highlights, 100)
        end,
      })
    end,
  },
}
