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

    local function save_layout(layout)
      local data = vim.fn.json_encode({ layout = layout })
      vim.fn.mkdir(vim.fn.fnamemodify(layout_file, ":h"), "p")
      vim.fn.writefile({ data }, layout_file)
    end

    vim.g.telescope_layout = layout_data.layout

    local max_columns = vim.o.columns
    if max_columns < 120 and vim.g.telescope_layout ~= "ebony" then
      vim.g.telescope_layout = "ebony"
      save_layout("ebony")
    elseif max_columns >= 120 and vim.g.telescope_layout ~= "ivory" then
      vim.g.telescope_layout = "ivory"
      save_layout("ivory")
    end

    -- Define border styles
    -- { top, right, bottom, left,
    -- top_left, top_right,
    -- bottom_right, bottom_left }
    vim.g.telescope_borders = {
      ivory = {
        prompt = { "─", " ", "─", " ", " ", " ", "─", "─" },
        results = { "─", "│", " ", " ", " ", " ", "│", " " },
        preview = { "─", " ", " ", " ", "─", "─", " ", " " },
      },
      ebony = {
        preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
        results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      },
    }

    -- Create a helper function that applies the current layout to any picker
    local function with_layout(picker_name)
      return function()
        -- Get the current layout and borders
        local layout = vim.g.telescope_layout or "ivory"
        local borders = vim.g.telescope_borders[layout] or vim.g.telescope_borders.ivory
        require("telescope.builtin")[picker_name]({
          layout_strategy = layout,
          borderchars = borders,
        })
      end
    end

    return {
      -- Layout toggle
      {
        "<leader>fl",
        function()
          -- Toggle between ivory and ebony
          vim.g.telescope_layout = (vim.g.telescope_layout == "ivory") and "ebony" or "ivory"
          local layout = vim.g.telescope_layout
          -- Save preference to file
          save_layout(layout)
          vim.notify("Telescope layout: " .. layout .. " (saved)")
        end,
        desc = "Toggle Layout",
      },
      -- Core finder functions - using our layout wrapper
      { "<leader>ff",  with_layout("find_files"),                desc = "Find Files" },
      { "<leader>fg",  with_layout("live_grep"),                 desc = "Find Text (Grep)" },
      { "<leader>fb",  with_layout("buffers"),                   desc = "Find Buffers" },
      { "<leader>fh",  with_layout("help_tags"),                 desc = "Find Help" },
      { "<leader>fr",  with_layout("oldfiles"),                  desc = "Recent Files" },
      -- Extended search functionality
      { "<leader>fs",  with_layout("grep_string"),               desc = "Find Current Word" },
      { "<leader>fc",  with_layout("command_history"),           desc = "Command History" },
      { "<leader>f/",  with_layout("search_history"),            desc = "Search History" },
      -- Git integration
      { "<leader>fGc", "<cmd>Telescope git_commits<cr>",         desc = "Find Git Commits" },
      { "<leader>fGb", "<cmd>Telescope git_branches<cr>",        desc = "Find Git Branches" },
      { "<leader>fGs", "<cmd>Telescope git_status<cr>",          desc = "Find Git Status" },
      { "<leader>fGf", "<cmd>Telescope git_files<cr>",           desc = "Find Git Files" },
      -- LSP integration
      { "<leader>fd",  "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
      { "<leader>fD",  with_layout("diagnostics"),               desc = "Workspace Diagnostics" },
      -- Other useful pickers
      { "<leader>ft",  with_layout("treesitter"),                desc = "Find Symbols (Treesitter)" },
      { "<leader>fk",  with_layout("keymaps"),                   desc = "Find Keymaps" },
    }
  end,

  config = function()
    -- IMPORTANT: Register custom layout strategies FIRST before any setup
    local layout_strategies = require("telescope.pickers.layout_strategies")
    local actions = require("telescope.actions")

    -- Custom vertical layout with full screen usage and preview on top
    layout_strategies.ebony = function(picker, max_columns, max_lines)
      local has_previewer = picker.previewer ~= nil and picker.previewer ~= false

      local borders = vim.g.telescope_borders.ebony
      local preview_height = has_previewer and math.floor(max_lines * 0.4) or 0
      local prompt_line = has_previewer and (preview_height + 3) or 1

      local layout = {
        prompt = {
          line = prompt_line,
          height = 1,
          width = max_columns - 2,
          col = 2,
          border = true,
          borderchars = borders.prompt,
          enter = true,
          title = false,
        },
        results = {
          line = prompt_line + 2,
          height = max_lines - prompt_line - 2,
          width = max_columns - 2,
          col = 2,
          border = true,
          borderchars = borders.results,
          enter = false,
          title = false,
        }
      }

      if has_previewer then
        layout.preview = {
          line = 2,
          height = preview_height,
          width = max_columns - 2,
          col = 2,
          border = true,
          borderchars = borders.preview,
          enter = false,
          title = false,
        }
      end
      return layout
    end

    -- Custom ivory layout (bottom pane style)
    layout_strategies.ivory = function(picker, max_columns, max_lines)
      local layout = layout_strategies.bottom_pane(picker, max_columns, max_lines)
      local has_previewer = picker.previewer ~= nil and picker.previewer ~= false

      if layout.prompt then
        layout.prompt.height = 1
        layout.prompt.line = math.floor(max_lines * 0.55)
        layout.prompt.width = max_columns
      end

      if has_previewer then
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
          layout.preview.width = max_columns - layout.results.width - 1
        end
      else
        if layout.results and layout.prompt then
          layout.results.line = layout.prompt.line + layout.prompt.height + 1
          layout.results.height = max_lines - layout.results.line + 1
          layout.results.width = max_columns
        end
      end
      return layout
    end

    local telescope = require("telescope")
    local actions = require("telescope.actions")

    -- Basic configuration with both layout options predefined
    telescope.setup({

      defaults = {
        prompt_title = false,
        preview_title = false,
        results_title = false,
        mappings = {
          i = {
            ["<esc>"] = actions.close,
          },
        },

        prompt_prefix = " ",
        selection_caret = "  ",
        path_display = { "filename_first" },
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = vim.g.telescope_layout or "ivory",
        layout_config = {
          ivory = {
            height = 1,
            width = 1.0,
            prompt_position = "top",
            preview_cutoff = 120,
          },
          ebony = {
            width = 1.0,        -- Full width
            height = 1.0,       -- Full height
            preview_cutoff = 0, -- Always show preview
            prompt_position = "top",
          },
        },

        -- Dynamic borderchars based on terminal width
        borderchars = function()
          local layout = vim.g.telescope_layout or "ivory"
          return vim.g.telescope_borders[layout]
        end,

        -- Preview configuration with line numbers
        preview = {
          timeout = 1000,
          hide_on_startup = false,
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
          "--glob=!README.md",
          "--glob=!lazy-lock.json",
        },
      },
      pickers = {
        find_files = {
          prompt_title = false,
          preview_title = false,
          no_ignore = false,
          hidden = true,
          follow = true,
          find_command = vim.fn.executable("fd") == 1 and
              { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" } or nil,
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
          prompt_title = false,
          preview_title = false,
          previewer = false,
          sort_mru = true,
          ignore_current_buffer = false,
          mappings = {
            i = {
              ["<c-d>"] = "delete_buffer", -- Delete buffer with Ctrl-d
            },
          },
        },
        help_tags = {
          prompt_title = false,
          preview_title = false,
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
          prompt_title = false,
          preview_title = false,
          prompt_prefix = " Find Current Word: ",
          only_sort_text = true,
        },
        command_history = {
          prompt_title = false,
          preview_title = false,
          prompt_prefix = " Command History: ",
          max_item_count = 100,
        },
        search_history = {
          prompt_title = false,
          preview_title = false,
          prompt_prefix = " Search History: ",
          max_item_count = 100,
        },
        git_commits = {
          prompt_title = false,
          preview_title = false,
          prompt_prefix = " Git Commits: ",
          preview = true,
        },
        git_branches = {
          prompt_title = false,
          preview_title = false,
          prompt_prefix = " Git Branches: ",
          show_remote_tracking_branch = true,
        },
        git_status = {
          prompt_title = false,
          preview_title = false,
          prompt_prefix = " Git Status: ",
          show_staged = true,
        },
        diagnostics = {
          prompt_title = false,
          preview_title = false,
          prompt_prefix = " Workspace Diagnostics: ",
          severity_sort = true,
        },
        treesitter = {
          prompt_title = false,
          preview_title = false,
          prompt_prefix = " Find Symbols: ",
          symbols = { "class", "function", "method", "variable" },
        },
        keymaps = {
          prompt_title = false,
          preview_title = false,
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

    -- Auto-update borders and layout on window resize
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        local max_columns = vim.o.columns
        local current_layout = vim.g.telescope_layout or "ivory"
        local target_layout = nil

        if max_columns < 120 and current_layout ~= "ebony" then
          target_layout = "ebony"
        elseif max_columns >= 120 and current_layout ~= "ivory" then
          target_layout = "ivory"
        end

        if target_layout then
          vim.g.telescope_layout = target_layout
          local layout_file = vim.fn.stdpath("data") .. "/telescope_layout.json"
          local data = vim.fn.json_encode({ layout = target_layout })
          vim.fn.mkdir(vim.fn.fnamemodify(layout_file, ":h"), "p")
          vim.fn.writefile({ data }, layout_file)

          vim.notify("Telescope auto-switched to " .. target_layout .. " layout", vim.log.levels.INFO)
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
  end,
}
