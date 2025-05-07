-- lua/plugins/telescope.lua

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
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

    -- Toggle layout - Using our custom function
    {
      "<leader>fl",
      function()
        -- Our custom toggle function
        vim.fn.call("v:lua._G.telescope_toggle_layout", {})
      end,
      desc = "Toggle Telescope Layout",
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
  },
  opts = {
    defaults = {
      prompt_prefix = " ",
      selection_caret = "  ",
      path_display = { "truncate" },
      selection_strategy = "reset",
      sorting_strategy = "ascending",

      -- Start with horizontal layout
      layout_strategy = "horizontal",

      -- Define both layout configurations
      layout_config = {
        -- Horizontal layout (results left, preview right)
        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
          results_width = 0.45,
          width = 0.95,
          height = 0.95,
        },

        -- Vertical layout (results top, preview bottom)
        vertical = {
          prompt_position = "top",
          mirror = false,
          width = 0.95,
          height = 0.95,
          preview_height = 0.5,
        },

        width = 0.95,
        height = 0.95,
        preview_cutoff = 120,
      },

      -- Ensure preview is enabled
      preview = {
        check_mime_type = true,
        timeout = 500,
        msg_bg_fillchar = " ",
      },

      border = true,
      borderchars = {
        prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
        preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },

      color_devicons = true,
      set_env = { ["COLORTERM"] = "truecolor" },

      -- Custom mappings including layout toggle
      mappings = {
        i = {
          ["<C-l>"] = function()
            vim.fn.call("v:lua._G.telescope_toggle_layout", {})
          end,
        },
        n = {
          ["<C-l>"] = function()
            vim.fn.call("v:lua._G.telescope_toggle_layout", {})
          end,
        },
      },

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
      help_tags = {
        prompt_title = false,
        prompt_prefix = " Help: ",
      },
      tags = {
        only_sort_tags = true,
        fname_width = 25,
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    },
  },
  config = function(_, opts)
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
      callback = function()
        vim.wo.number = true
        vim.wo.wrap = false
        vim.wo.linebreak = true
        vim.wo.list = false
        vim.wo.cursorline = true
      end,
    })

    -- Load fzf extension if available for better performance
    pcall(function()
      telescope.load_extension("fzf")
    end)

    -- Track current layout to toggle between them
    vim.g.telescope_layout = "horizontal"

    -- Create a custom toggle layout function
    _G.telescope_toggle_layout = function()
      -- Get current picker if there is one
      local current_picker = require("telescope.actions.state").get_current_picker()
      if not current_picker then
        vim.notify("No active Telescope picker", vim.log.levels.INFO)
        return
      end

      -- Toggle between layouts
      local new_layout = vim.g.telescope_layout == "horizontal" and "vertical" or "horizontal"
      vim.g.telescope_layout = new_layout

      -- Apply new layout
      current_picker.layout_strategy = new_layout
      current_picker:refresh()

      vim.notify("Switched to " .. new_layout .. " layout", vim.log.levels.INFO)
    end

    -- Create a VimL command for the toggle
    vim.cmd([[
      command! TelescopeToggleLayout lua _G.telescope_toggle_layout()
    ]])

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
      vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.blue })
    end

    -- Update highlights now and when colorscheme changes
    update_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = update_highlights,
    })
  end,
}
