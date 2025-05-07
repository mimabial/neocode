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
        prompt = { "─", " ", "─", " ", "─", "─", "─", "─" },
        results = { "─", "│", " ", " ", " ", " ", "│", " " },
        preview = { "─", " ", " ", " ", "─", "─", " ", " " },
      },
      vertical = {
        prompt = { "━", "┃", " ", "┃", "┏", "┓", "┃", "┃" },
        results = { "━", "┃", "━", "┃", "┣", "┫", "┛", "┗" },
        preview = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
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
          -- Toggle between ivory and vertical
          vim.g.telescope_layout = (vim.g.telescope_layout == "ivory") and "vertical" or "ivory"
          local layout = vim.g.telescope_layout

          -- Save preference to file
          save_layout(layout)

          vim.notify("Telescope layout: " .. (layout == "ivory" and "bottom_pane" or "vertical") .. " (saved)")
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

      -- Stack-specific finders (fallback to telescope if snacks unavailable)
      {
        "<leader>sg",
        with_layout(function()
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
        end),
        desc = "Find GOTH files",
      },

      {
        "<leader>sn",
        with_layout(function()
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
        end),
        desc = "Find Next.js files",
      },

      -- Mappings for layout toggle with persistence
      mappings = {
        i = {
          ["<C-l>"] = function()
            -- Toggle layout
            vim.g.telescope_layout = (vim.g.telescope_layout == "ivory") and "vertical" or "ivory"

            -- Save the layout setting
            local layout = vim.g.telescope_layout

            -- Save preference to file
            save_layout(layout)

            -- Get current picker
            local state = require("telescope.actions.state")
            local picker = state.get_current_picker()

            -- Update layout
            if picker then
              picker.layout_strategy = vim.g.telescope_layout
              picker:refresh()
              vim.notify("Telescope layout: " .. (layout == "ivory" and "bottom_pane" or "vertical") .. " (saved)")
            end
          end,
        },
        n = {
          ["<C-l>"] = function()
            -- Toggle layout
            vim.g.telescope_layout = (vim.g.telescope_layout == "ivory") and "vertical" or "ivory"

            -- Save the layout setting
            local layout = vim.g.telescope_layout

            -- Save preference to file
            save_layout(layout)

            -- Get current picker
            local state = require("telescope.actions.state")
            local picker = state.get_current_picker()

            -- Update layout
            if picker then
              picker.layout_strategy = vim.g.telescope_layout
              picker:refresh()
              vim.notify("Telescope layout: " .. (layout == "ivory" and "bottom_pane" or "vertical") .. " (saved)")
            end
          end,
        },
      },
    }
  end,

  config = function()
    local telescope = require("telescope")

    -- Custom bottom_pane layout that adds more space between prompt and results
    require("telescope.pickers.layout_strategies").ivory = function(picker, max_columns, max_lines, layout_config)
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

    -- Create command to toggle layouts with persistence
    vim.api.nvim_create_user_command("TelescopeToggleLayout", function()
      -- Toggle layout
      vim.g.telescope_layout = (vim.g.telescope_layout == "ivory") and "vertical" or "ivory"
      local layout = vim.g.telescope_layout

      -- Save preference to file
      local layout_file = vim.fn.stdpath("data") .. "/telescope_layout.json"
      local data = vim.fn.json_encode({ layout = layout })
      vim.fn.mkdir(vim.fn.fnamemodify(layout_file, ":h"), "p")
      vim.fn.writefile({ data }, layout_file)

      local disp_name = (layout == "ivory") and "bottom_pane" or "vertical"
      vim.notify("Telescope layout: " .. disp_name .. " (saved)")
    end, {})

    -- Basic configuration with both layout options predefined
    telescope.setup({
      defaults = {
        prompt_title = false,
        preview_title = false,
        results_title = false,

        prompt_prefix = " ",
        selection_caret = "  ",
        path_display = { "truncate" },
        selection_strategy = "reset",
        sorting_strategy = "ascending",

        -- Use global layout setting
        layout_strategy = vim.g.telescope_layout or "ivory",

        -- Layouts configuration
        layout_config = {
          ivory = {
            height = 0.6,
            width = 1.0,
            prompt_position = "top",
          },
          vertical = {
            prompt_position = "top",
            mirror = false,
            width = 1.0,
            height = 1.0,
            preview_height = 0.4,
          },
          bottom_pane = {
            height = 0.6,
            width = 1.0,
            prompt_position = "top",
          },
        },

        -- Default borderchars (will be overridden by picker specific borderchars)
        borderchars = vim.g.telescope_borders and vim.g.telescope_borders[vim.g.telescope_layout or "ivory"] or {
          prompt = { "─", " ", "─", " ", "─", "─", "─", "─" },
          results = { "─", "│", " ", " ", " ", " ", "│", " " },
          preview = { "─", " ", " ", " ", "─", "─", " ", " " },
        },

        -- Preview configuration with line numbers
        preview = {
          timeout = 500,
          -- Make sure preview has enough space for line numbers
          width_padding = 3,
          height_padding = 1,
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
      },
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
      border = true,
      pickers = {
        find_files = {
          prompt_title = false,
          preview_title = false,
          hidden = true,
          follow = true,
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" },
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

    -- Enhanced preview window settings - explicitly enable line numbers
    vim.api.nvim_create_autocmd("User", {
      pattern = "TelescopePreviewerLoaded",
      callback = function()
        -- Setup line numbers
        vim.wo.number = true
        vim.wo.relativenumber = false
        vim.wo.signcolumn = "yes:1"
        vim.wo.numberwidth = 4

        -- Other preview window settings
        vim.wo.wrap = false
        vim.wo.linebreak = true
        vim.wo.list = false
        vim.wo.cursorline = true

        -- Force redraw to ensure line numbers appear
        vim.cmd("redraw")
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

      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = colors.border })
      vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = colors.border })
      vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = colors.border })
      vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.green, bold = true })
      vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.blue })

      -- Add highlight for line numbers in preview
      vim.api.nvim_set_hl(0, "TelescopePreviewLine", { fg = colors.blue, bold = true })
      vim.api.nvim_set_hl(0, "TelescopePreviewLineNr", { fg = colors.gray or "#928374" })
    end

    update_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = update_highlights,
    })
  end,
}
