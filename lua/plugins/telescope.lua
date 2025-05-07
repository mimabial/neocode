-- lua/plugins/telescope.lua

return {

  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Telescope",
  keys = {
    { "<leader>fi", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fj", "<cmd>Telescope live_grep<cr>", desc = "Find Text" },
    { "<leader>fk", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
    { "<leader>fl", "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
  },
  opts = {

    defaults = {
      layout_strategy = "bottom_pane",
      layout_config = {
        bottom_pane = {
          height = 0.6,
          width = 1.0,
          prompt_position = "top",
          preview_cutoff = 120,
        },
      },
      sorting_strategy = "ascending",
      borderchars = {
        prompt = { "─", " ", "─", " ", "─", "─", "─", "─" },
        results = { "─", "│", " ", " ", " ", " ", "│", " " },
        preview = { "─", " ", " ", " ", "─", "─", " ", " " },
      },
      prompt_title = false,
      results_title = false,
      preview_title = false,
      prompt_prefix = " ",
      winblend = 0,
      cycle_layout_list = { "bottom_pane" },
      -- two‐char prefixes everywhere:
      entry_prefix = "  ",
      selection_caret = "  ",
    },
    pickers = {
      find_files = {
        prompt_title = false,
        preview_title = false,
        hidden = true,
        find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" },
        follow = true,
        prompt_prefix = " Find Files: ",
      },
      live_grep = {
        prompt_title = false,
        preview_title = false,
        additional_args = function()
          return {
            "--hidden",
            "--glob=!.git/",
            "--glob=!node_modules/",
            "--glob=!vendor/",
            "--glob=!.next/",
            "--glob=!dist/",
            "--glob=!build/",
          }
        end,
        prompt_prefix = " Live Grep: ",
      },
      buffers = {
        prompt_title = false,
        prompt_prefix = " Buffers: ",
      },
      help_tags = {
        prompt_title = false,
        prompt_prefix = " Help: ",
      },
    },
  },
  config = function(_, opts)
    -- Custom bottom_pane layout that adds more space between prompt and results
    require("telescope.pickers.layout_strategies").custom_bottom = function(
      picker,
      max_columns,
      max_lines,
      layout_config
    )
      local layout =
        require("telescope.pickers.layout_strategies").bottom_pane(picker, max_columns, max_lines, layout_config)

      -- Add padding between prompt and results
      if layout.prompt and layout.results then
        layout.results.line = layout.prompt.line + layout.prompt.height + 1 -- Extra space here
        layout.results.height = max_lines - layout.results.line + 1
        layout.results.width = math.floor(max_columns * 0.4)
      end

      -- Make preview take full remaining height
      if layout.prompt and layout.preview then
        layout.preview.line = layout.prompt.line + layout.prompt.height + 1
        layout.preview.height = max_lines - layout.preview.line + 1
        layout.preview.width = math.floor(max_columns * 0.6) - 1
      end

      return layout
    end

    -- Override layout strategy with custom one
    opts.defaults.layout_strategy = "custom_bottom"

    -- Set up Telescope with our configurations
    local telescope = require("telescope")
    telescope.setup(opts)

    -- Add autocmd to configure preview windows
    vim.api.nvim_create_autocmd("User", {
      pattern = "TelescopePreviewerLoaded",
      callback = function(event)
        -- Set options for the preview window
        vim.wo.number = true
        vim.wo.linebreak = true
        vim.wo.list = false
        vim.wo.numberwidth = 6
      end,
    })

    -- Get color scheme colors
    local colors = _G.get_ui_colors and _G.get_ui_colors()
      or {
        green = "#89b482",
        yellow = "#d8a657",
        aqua = "#7daea3",
      }

    -- Match snacks.picker highlights
    vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.green, bold = true })
    vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.yellow })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = colors.gray })
    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = colors.gray })
    vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = colors.gray })
    vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = colors.gray })

    -- Set highlights for line numbers to match the theme
    vim.api.nvim_set_hl(0, "TelescopePreviewLine", { link = "CursorLine" })
    vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { link = "Normal" })
    vim.api.nvim_set_hl(0, "TelescopePreviewLineNr", { link = "LineNr" })
  end,
}
