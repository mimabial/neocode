-- lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
  },
  cmd = "Telescope",
  keys = function()
    -- Load saved layout preference or use default
    local layout_file = vim.fn.stdpath("data") .. "/telescope_layout.json"
    local layout_data = { layout = "ivory" }

    -- Try to read saved layout
    if vim.fn.filereadable(layout_file) == 1 then
      local file_content = vim.fn.readfile(layout_file)
      if file_content and #file_content > 0 then
        local ok, data = pcall(vim.fn.json_decode, file_content[1])
        if ok and data and data.layout then
          layout_data = data
        end
      end
    end

    -- Set global layout value from saved preference
    vim.g.telescope_layout = layout_data.layout

    -- Function to save layout preference
    local function save_layout(layout)
      local data = vim.fn.json_encode({ layout = layout })
      vim.fn.mkdir(vim.fn.fnamemodify(layout_file, ":h"), "p")
      vim.fn.writefile({ data }, layout_file)
    end

    -- Define border styles
    vim.g.telescope_borders = {
      ivory = {
        prompt = { " ", " ", "─", " ", " ", " ", "─", "─" },
        results = { "─", "│", " ", " ", " ", " ", "│", " " },
        preview = { "─", " ", " ", " ", "─", "─", " ", " " },
      },
      ebony = {
        prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
        results = { "━", " ", " ", " ", " ", " ", " ", " " },
        preview = { " ", " ", "━", " ", " ", " ", " ", " " },
      },
    }

    -- Create a helper function that applies the current layout to any picker
    local function with_layout(picker_name)
      return function()
        -- Get the current layout and borders
        local layout = vim.g.telescope_layout or "ivory"
        local borders = vim.g.telescope_borders[layout] or vim.g.telescope_borders.ivory

        -- Get the picker function
        local builtin = require("telescope.builtin")
        local picker_fn = builtin[picker_name]

        -- Call the picker with the current layout and borders
        picker_fn({
          layout_strategy = layout,
          borderchars = borders,
        })
      end
    end

    -- Stack-specific finder functions (separate from with_layout)
    local function find_goth_files()
      local layout = vim.g.telescope_layout or "ivory"
      local borders = vim.g.telescope_borders[layout] or vim.g.telescope_borders.ivory

      require("telescope.builtin").find_files({
        layout_strategy = layout,
        borderchars = borders,
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

    local function find_nextjs_files()
      local layout = vim.g.telescope_layout or "ivory"
      local borders = vim.g.telescope_borders[layout] or vim.g.telescope_borders.ivory

      require("telescope.builtin").find_files({
        layout_strategy = layout,
        borderchars = borders,
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

    -- Return keymaps
    return {
      -- Core finder functions - using our layout wrapper
      { "<leader>ff", with_layout("find_files"), desc = "Find Files" },
      { "<leader>fg", with_layout("live_grep"), desc = "Find Text (Grep)" },
      { "<leader>fb", with_layout("buffers"), desc = "Find Buffers" },
      { "<leader>fh", with_layout("help_tags"), desc = "Find Help" },
      { "<leader>fr", with_layout("oldfiles"), desc = "Recent Files" },

      -- Layout toggle with persistence
      {
        "<leader>fl",
        function()
          -- Toggle between ivory and ebony
          vim.g.telescope_layout = (vim.g.telescope_layout == "ivory") and "ebony" or "ivory"
          local layout = vim.g.telescope_layout

          -- Save preference to file
          save_layout(layout)

          vim.notify("Telescope layout: " .. (layout == "ivory" and "ivory" or "ebony") .. " (saved)")
        end,
        desc = "Toggle Layout",
      },

      -- Extended search functionality
      { "<leader>fs", with_layout("grep_string"), desc = "Find Current Word" },
      { "<leader>fc", with_layout("command_history"), desc = "Command History" },
      { "<leader>f/", with_layout("search_history"), desc = "Search History" },

      -- Git integration
      { "<leader>gc", with_layout("git_commits"), desc = "Git Commits" },
      { "<leader>gb", with_layout("git_branches"), desc = "Git Branches" },
      { "<leader>gs", with_layout("git_status"), desc = "Git Status" },

      -- LSP integration
      {
        "<leader>fd",
        function()
          local layout = vim.g.telescope_layout or "ivory"
          local borders = vim.g.telescope_borders[layout] or vim.g.telescope_borders.ivory
          require("telescope.builtin").diagnostics({
            bufnr = 0,
            layout_strategy = layout,
            borderchars = borders,
          })
        end,
        desc = "Document Diagnostics",
      },
      { "<leader>fD", with_layout("diagnostics"), desc = "Workspace Diagnostics" },

      -- Other useful pickers
      { "<leader>ft", with_layout("treesitter"), desc = "Find Symbols (Treesitter)" },
      { "<leader>fk", with_layout("keymaps"), desc = "Find Keymaps" },

      -- Stack-specific finders (uses separate functions)
      { "<leader>sg", find_goth_files, desc = "Find GOTH files" },
      { "<leader>sn", find_nextjs_files, desc = "Find Next.js files" },
    }
  end,

  config = function()
    -- IMPORTANT: Register custom layout strategies FIRST before any setup
    local layout_strategies = require("telescope.pickers.layout_strategies")

    -- Reusable function for ebony layout positioning
    local function apply_ebony_layout(picker, max_columns, max_lines)
      local layout = layout_strategies.vertical(picker, max_columns, max_lines)

      -- Position preview at top with full width
      if layout.preview then
        layout.preview.line = 1
        layout.preview.height = math.floor(max_lines * 0.5)
        layout.preview.width = max_columns
        layout.preview.col = 0
      end
      -- Position prompt below preview
      if layout.prompt and layout.preview then
        layout.prompt.line = layout.preview.line + layout.preview.height + 1
        layout.prompt.width = max_columns - 1
        layout.prompt.height = 1
        layout.prompt.col = 0
      end
      -- Position results below prompt
      if layout.results and layout.prompt then
        layout.results.line = layout.prompt.line + layout.prompt.height + 1
        layout.results.height = math.floor(max_lines * 0.5) - layout.prompt.height
        layout.results.width = max_columns
        layout.results.col = 0
      end
      return layout
    end

    -- Create the custom ivory layout (bottom pane style)
    layout_strategies.ivory = function(picker, max_columns, max_lines)
      max_columns = max_columns or vim.o.columns
      max_lines = max_lines or vim.o.lines

      if max_columns < 120 then
        return apply_ebony_layout(picker, max_columns, max_lines)
      end

      local layout = layout_strategies.bottom_pane(picker, max_columns, max_lines)

      if layout.prompt then
        layout.prompt.height = 1
        layout.prompt.line = math.floor(max_lines * 0.55)
        layout.prompt.width = max_columns - 1
      end

      -- Add padding between prompt and results
      if layout.prompt and layout.results then
        layout.results.line = layout.prompt.line + layout.prompt.height + 1
        layout.results.height = max_lines - layout.results.line + 1
        layout.results.width = math.floor(max_columns * 0.4)
      end

      -- Make preview take full remaining height
      if layout.prompt and layout.preview then
        layout.preview.col = layout.results.width + 1
        layout.preview.line = layout.prompt.line + layout.prompt.height + 1
        layout.preview.height = max_lines - layout.preview.line + 1
        layout.preview.width = math.floor(max_columns * 0.6)
      end

      return layout
    end

    -- Create custom vertical layout with full screen usage and proper spacing
    layout_strategies.ebony = function(picker, max_columns, max_lines)
      max_columns = max_columns or vim.o.columns
      max_lines = max_lines or vim.o.lines

      return apply_ebony_layout(picker, max_columns, max_lines)
    end

    -- Function to get responsive borders based on terminal width
    local function get_responsive_borders(max_columns)
      max_columns = max_columns or vim.o.columns

      if max_columns < 120 then
        -- Subtle borders for medium and small screens
        return {
          ivory = {
            prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
            results = { "━", " ", " ", " ", " ", " ", " ", " " },
            preview = { " ", " ", "━", " ", " ", " ", " ", " " },
          },
          ebony = {
            prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
            results = { "━", " ", " ", " ", " ", " ", " ", " " },
            preview = { " ", " ", "━", " ", " ", " ", " ", " " },
          },
        }
      else
        -- Full decorative borders for wide screens
        return {
          ivory = {
            prompt = { " ", " ", "─", " ", " ", " ", "─", "─" },
            results = { "─", "│", " ", " ", " ", " ", "│", " " },
            preview = { "─", " ", " ", " ", "─", "─", " ", " " },
          },
          ebony = {
            prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
            results = { "━", " ", " ", " ", " ", " ", " ", " " },
            preview = { " ", " ", "━", " ", " ", " ", " ", " " },
          },
        }
      end
    end

    -- Update borders function
    local function update_telescope_borders(max_columns)
      vim.g.telescope_borders = get_responsive_borders(max_columns)
    end

    -- Enhanced layout toggle with responsive borders
    local function toggle_layout_with_responsive_borders()
      local max_columns = vim.o.columns

      -- Update borders based on current terminal size
      update_telescope_borders(max_columns)

      -- Toggle layout
      local layout = vim.g.telescope_layout or "ivory"
      layout = layout == "ivory" and "ebony" or "ivory"
      vim.g.telescope_layout = layout

      -- Get current picker and refresh
      local current_picker = require("telescope.actions.state").get_current_picker()
      if current_picker then
        current_picker.layout_strategy = layout
        current_picker.original_options.borderchars = vim.g.telescope_borders[layout]
        current_picker:refresh()
      end

      -- Save preference
      local layout_file = vim.fn.stdpath("data") .. "/telescope_layout.json"
      local data = vim.fn.json_encode({ layout = layout })
      vim.fn.mkdir(vim.fn.fnamemodify(layout_file, ":h"), "p")
      vim.fn.writefile({ data }, layout_file)

      vim.notify("Telescope layout: " .. layout .. " (borders updated for " .. max_columns .. " cols)")
    end

    local telescope = require("telescope")

    -- Basic configuration with both layout options predefined
    telescope.setup({

      defaults = {
        prompt_title = false,
        preview_title = false,
        results_title = false,

        prompt_prefix = " ",
        selection_caret = "  ",
        path_display = { "filename_first" },
        selection_strategy = "reset",
        sorting_strategy = "ascending",

        -- Use global layout setting
        layout_strategy = vim.g.telescope_layout or "ivory",

        -- Layouts configuration
        layout_config = {
          ivory = {
            height = 1,
            width = 1.0,
            prompt_position = "top",
            preview_cutoff = 0, -- Always show preview
          },
          ebony = {
            width = 1.0, -- Full width
            height = 1.0, -- Full height
            preview_cutoff = 1, -- Always show preview
            prompt_position = "top",
          },
        },

        -- Dynamic borderchars based on terminal width
        borderchars = function()
          local max_columns = vim.o.columns
          update_telescope_borders(max_columns)
          local layout = vim.g.telescope_layout or "ivory"
          return vim.g.telescope_borders[layout]
        end,

        -- Preview configuration with line numbers
        preview = {
          timeout = 500,
          width_padding = 3,
          height_padding = 1,
          hide_on_startup = false,
        },
        color_devicons = true,
        file_ignore_patterns = {
          "%.git/",
          "node_modules/",
          "vendor/",
          ".next/",
          "dist/",
          "build/",
        },

        -- Keyboard mappings for layout toggling
        mappings = {
          i = {
            ["<C-l>"] = toggle_layout_with_responsive_borders,
          },
          n = {
            ["<C-l>"] = toggle_layout_with_responsive_borders,
          },
        },
      },
      set_env = { ["COLORTERM"] = "truecolor" },

      cycle_layout_list = { "ivory", "ebony" },
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
      pickers = {
        find_files = {
          prompt_title = false,
          preview_title = false,
          no_ignore = false,
          hidden = true,
          follow = true,
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" },
          prompt_prefix = " Find Files: ",
        },
        live_grep = {
          prompt_title = false,
          preview_title = false,
          only_sort_text = true,
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
          prompt_prefix = " Buffers: ",
          previewer = false,
          sort_mru = true,
          ignore_current_buffer = false,
        },
        help_tags = {
          prompt_prefix = " Help Tags: ",
          wrap_results = true,
        },
        oldfiles = {
          prompt_prefix = " Recent Files: ",
          cwd_only = true,
          prompt_title = false,
          preview_title = false,
        },
        grep_string = {
          prompt_prefix = " Find Current Word: ",
          only_sort_text = true,
        },
        command_history = {
          prompt_prefix = " Command History: ",
          max_item_count = 100,
        },
        search_history = {
          prompt_prefix = " Search History: ",
          max_item_count = 100,
        },
        git_commits = {
          prompt_prefix = " Git Commits: ",
          preview = true,
        },
        git_branches = {
          prompt_prefix = " Git Branches: ",
          show_remote_tracking_branch = true,
        },
        git_status = {
          prompt_prefix = " Git Status: ",
          show_staged = true,
        },
        diagnostics = {
          prompt_prefix = " Workspace Diagnostics: ",
          severity_sort = true,
        },
        treesitter = {
          prompt_prefix = " Find Symbols: ",
          symbols = { "class", "function", "method", "variable" },
        },
        keymaps = {
          prompt_prefix = " Find Keymaps: ",
          default_text = "",
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
    })

    -- Auto-update borders on window resize
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        -- Recompute borders for your new width
        local max_columns = vim.o.columns
        update_telescope_borders(max_columns)

        -- Grab the open picker (if any)
        local current_picker = require("telescope.actions.state").get_current_picker()
        if current_picker then
          local layout = vim.g.telescope_layout or "ivory"
          local borders = vim.g.telescope_borders[layout]

          -- Update both the “template” options and the live options
          current_picker.original_options.borderchars = borders
          current_picker.options.borderchars = borders

          -- Force a redraw
          current_picker:resume()
        end
      end,
    })

    -- Command for toggling layouts
    vim.api.nvim_create_user_command("TelescopeToggleLayout", function()
      vim.g.telescope_layout = (vim.g.telescope_layout == "ivory") and "ebony" or "ivory"
      local layout = vim.g.telescope_layout
      local layout_file = vim.fn.stdpath("data") .. "/telescope_layout.json"
      local data = vim.fn.json_encode({ layout = layout })
      vim.fn.mkdir(vim.fn.fnamemodify(layout_file, ":h"), "p")
      vim.fn.writefile({ data }, layout_file)
      vim.notify("Telescope layout: " .. (layout == "ivory" and "ivory" or "ebony") .. " (saved)")
    end, {})

    -- Enhanced preview settings
    vim.api.nvim_create_autocmd("User", {
      pattern = "TelescopePreviewerLoaded",
      callback = function()
        vim.wo.number = true
        vim.wo.relativenumber = false
        vim.wo.signcolumn = "yes:1"
        vim.wo.numberwidth = 4
        vim.wo.wrap = false
        vim.wo.linebreak = true
        vim.wo.list = false
        vim.wo.cursorline = true
      end,
    })

    -- Load fzf extension if available
    pcall(function()
      telescope.load_extension("fzf")
    end)

    -- Apply highlight groups that match the theme
    local function update_highlights()
      local colors = _G.get_ui_colors and _G.get_ui_colors()
        or {
          border = "#665c54",
          green = "#89b482",
          yellow = "#d8a657",
          blue = "#7daea3",
        }
      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = colors.border })
      vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.blue, bold = true })
      vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.blue })
    end

    update_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = update_highlights,
    })
  end,
}
