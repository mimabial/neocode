-- lua/plugins/telescope.lua

return {

  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    -- Optional dependencies for better performance
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
  },
  cmd = "Telescope",
  keys = {
    -- Core finder functions
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Find Files",
    },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Find Text (Grep)",
    },
    {
      "<leader>fb",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "Find Buffers",
    },
    {
      "<leader>fh",
      function()
        require("telescope.builtin").help_tags()
      end,
      desc = "Find Help",
    },
    {
      "<leader>fr",
      function()
        require("telescope.builtin").oldfiles()
      end,
      desc = "Recent Files",
    },

    -- Extended search functionality
    {
      "<leader>fs",
      function()
        require("telescope.builtin").grep_string()
      end,
      desc = "Find Current Word",
    },
    {
      "<leader>fc",
      function()
        require("telescope.builtin").command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>f/",
      function()
        require("telescope.builtin").search_history()
      end,
      desc = "Search History",
    },

    -- Git integration
    {
      "<leader>gc",
      function()
        require("telescope.builtin").git_commits()
      end,
      desc = "Git Commits",
    },
    {
      "<leader>gb",
      function()
        require("telescope.builtin").git_branches()
      end,
      desc = "Git Branches",
    },
    {
      "<leader>gs",
      function()
        require("telescope.builtin").git_status()
      end,
      desc = "Git Status",
    },

    -- LSP integration
    {
      "<leader>fd",
      function()
        require("telescope.builtin").diagnostics({ bufnr = 0 })
      end,
      desc = "Document Diagnostics",
    },
    {
      "<leader>fD",
      function()
        require("telescope.builtin").diagnostics()
      end,
      desc = "Workspace Diagnostics",
    },

    -- Other useful pickers
    {
      "<leader>ft",
      function()
        require("telescope.builtin").treesitter()
      end,
      desc = "Find Symbols (Treesitter)",
    },
    {
      "<leader>fk",
      function()
        require("telescope.builtin").keymaps()
      end,
      desc = "Find Keymaps",
    },

    -- Stack-specific finders (fallback to telescope if snacks unavailable)
    {
      "<leader>sg",
      function()
        local ok, snacks = pcall(require, "snacks.picker")
        if ok and snacks.custom and snacks.custom.goth_files then
          snacks.custom.goth_files()
        else
          require("telescope.builtin").find_files({
            find_command = {
              "find",
              ".",
              "-type",
              "f",
              "-name",
              "*.go",
              "-o",
              "-name",
              "*.templ",
              "-not",
              "-path",
              "*/vendor/*",
              "-not",
              "-path",
              "*/node_modules/*",
            },
          })
        end
      end,
      desc = "Find GOTH files",
    },

    {
      "<leader>sn",
      function()
        local ok, snacks = pcall(require, "snacks.picker")
        if ok and snacks.custom and snacks.custom.nextjs_files then
          snacks.custom.nextjs_files()
        else
          require("telescope.builtin").find_files({
            find_command = {
              "find",
              ".",
              "-type",
              "f",
              "\\(",
              "-name",
              "*.tsx",
              "-o",
              "-name",
              "*.jsx",
              "-o",
              "-name",
              "*.ts",
              "-o",
              "-name",
              "*.js",
              "\\)",
              "-not",
              "-path",
              "*/node_modules/*",
              "-not",
              "-path",
              "*/.next/*",
            },
          })
        end
      end,
      desc = "Find Next.js files",
    },
  },
  opts = {

    defaults = {
      prompt_prefix = " ",
      selection_caret = "  ",
      path_display = { "truncate" },
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      layout_strategy = "bottom_pane",
      layout_config = {
        bottom_pane = {
          height = 0.6,
          width = 1.0,
          prompt_position = "top",
        },
      },
      border = true,
      borderchars = {
        prompt = { "─", " ", "─", " ", "─", "─", "─", "─" },
        results = { "─", "│", " ", " ", " ", " ", "│", " " },
        preview = { "─", " ", " ", " ", "─", "─", " ", " " },
      },
      color_devicons = true,
      set_env = { ["COLORTERM"] = "truecolor" },

      cycle_layout_list = { "bottom_pane", "vertical" },
      file_ignore_patterns = {
        "%.git/",
        "node_modules/",
        "vendor/",
        ".next/",
        "dist/",
        "build/",
      },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--glob=!.git/",
        "--glob=!node_modules/",
        "--glob=!vendor/",
      },
      -- Try to recover gracefully if a picker fails
      on_complete = {
        function(picker)
          if picker.status.completed_with_error then
            vim.notify("Telescope picker encountered an error", vim.log.levels.WARN)
          end
        end,
      },
    },

    pickers = {
      find_files = {
        prompt_title = false,
        preview_title = false,
        hidden = true,
        find_command = vim.fn.executable("fd") == 1
            and { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" }
          or nil,
        prompt_prefix = " Find Files: ",
      },
      live_grep = {
        prompt_title = false,
        preview_title = false,
        prompt_prefix = " Live Grep: ",
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
      },
      buffers = {
        prompt_title = false,
        prompt_prefix = " Buffers: ",
        show_all_buffers = true,
        sort_lastused = true,
        mappings = {
          i = {
            ["<c-d>"] = "delete_buffer",
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
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

    -- Safe loading with fallback behavior
    local telescope_ok, telescope = pcall(require, "telescope")
    if not telescope_ok then
      vim.notify("Failed to load telescope.nvim. Some functionality may be limited.", vim.log.levels.WARN)
      return
    end

    -- Setup telescope with our configurations
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

    -- Load fzf extension if available for better performance
    pcall(function()
      telescope.load_extension("fzf")
    end)

    -- Ensure custom commands are available
    vim.api.nvim_create_user_command("TelescopeFindFiles", function()
      require("telescope.builtin").find_files()
    end, {})
    vim.api.nvim_create_user_command("TelescopeLiveGrep", function()
      require("telescope.builtin").live_grep()
    end, {})

    -- Create fallback functions that can be called from anywhere
    _G.telescope_find_files = function(opts)
      local ok, builtin = pcall(require, "telescope.builtin")
      if ok then
        builtin.find_files(opts or {})
      else
        -- Fallback if telescope isn't available
        vim.cmd("find")
      end
    end

    _G.telescope_live_grep = function(opts)
      local ok, builtin = pcall(require, "telescope.builtin")
      if ok then
        builtin.live_grep(opts or {})
      else
        -- Fallback using vimgrep
        vim.ui.input({ prompt = "Search pattern: " }, function(input)
          if input then
            vim.cmd("vimgrep " .. input .. " **/*")
            vim.cmd("copen")
          end
        end)
      end
    end

    -- Apply highlight groups that match the theme
    local function update_highlights()
      local colors = _G.get_ui_colors and _G.get_ui_colors()
        or {
          bg = "#282828",
          border = "#665c54",
          green = "#89b482",
          yellow = "#d8a657",
          blue = "#7daea3",
        }

      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = colors.border })
      vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = colors.border })
      vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = colors.border })
      vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.green, bold = true })
      vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.yellow })
    end

    -- Update highlights now and when colorscheme changes
    update_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = update_highlights,
    })
  end,
}
