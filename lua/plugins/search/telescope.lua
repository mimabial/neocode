-- Telescope: owner of the <leader>f* namespace for find/search.
-- Also remaps q: / q/ / q? to picker-based history.

local IVORY_MIN_COLUMNS = 120

local BORDERS = {
  ivory = {
    prompt = { "─", " ", " ", " ", "╶", "╴", " ", " " },
    results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
  },
  ebony = {
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
    results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
  },
}

local current_layout

local function layout_for_width()
  return vim.o.columns < IVORY_MIN_COLUMNS and "ebony" or "ivory"
end

local function apply_layout(layout)
  current_layout = layout
  local config = package.loaded["telescope.config"]
  if config then
    config.values.layout_strategy = layout
    config.values.borderchars = BORDERS[layout]
  end
end

local function toggle_layout()
  apply_layout(current_layout == "ivory" and "ebony" or "ivory")
  vim.notify("Telescope: " .. current_layout)
end

local function picker(name)
  return function()
    require("telescope.builtin")[name]()
  end
end

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
    "nvim-telescope/telescope-ui-select.nvim",
  },
  event = "VeryLazy",
  cmd = "Telescope",
  keys = {
    { "<leader>fl", toggle_layout, desc = "Toggle Layout" },
    { "<leader>ff", picker("find_files"), desc = "Find Files" },
    { "<leader>ft", picker("live_grep"), desc = "Find Text (Grep)" },
    { "<leader>fb", picker("buffers"), desc = "Find Buffers" },
    { "<leader>fr", picker("oldfiles"), desc = "Recent Files" },
    { "<leader>fh", picker("help_tags"), desc = "Find Help" },
    { "<leader>fw", picker("grep_string"), desc = "Find Current Word" },
    { "<leader>fc", picker("command_history"), desc = "Command History" },
    { "<leader>f/", picker("search_history"), desc = "Search History" },
    { "q:", picker("command_history"), desc = "Command History" },
    { "q/", picker("search_history"), desc = "Search History" },
    { "q?", picker("search_history"), desc = "Search History" },
    { "<leader>fgc", picker("git_commits"), desc = "Git Commits" },
    { "<leader>fgb", picker("git_branches"), desc = "Git Branches" },
    { "<leader>fgs", picker("git_status"), desc = "Git Status" },
    { "<leader>fgf", picker("git_files"), desc = "Git Files" },
    { "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
    { "<leader>fD", picker("diagnostics"), desc = "Workspace Diagnostics" },
    { "<leader>fs", picker("treesitter"), desc = "Symbols" },
    { "<leader>fk", picker("keymaps"), desc = "Keymaps" },
  },

  config = function()
    current_layout = layout_for_width()
    -- IMPORTANT: Register custom layout strategies FIRST before any setup
    local layout_strategies = require("telescope.pickers.layout_strategies")
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local themes = require("telescope.themes")

    -- Custom vertical layout with full screen usage and preview on top
    layout_strategies.ebony = function(picker, max_columns, max_lines)
      local has_previewer = picker.previewer ~= nil and picker.previewer ~= false

      local borders = BORDERS.ebony
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
        },
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
        layout.prompt.col = 2
        layout.prompt.line = math.floor(max_lines * 0.4)
        layout.prompt.width = max_columns - 2
      end

      -- bottom_pane suppresses the results' top border (`{0, 1, 1, 1}`) because
      -- it stacks results flush against the prompt. Ivory adds a gap, so we
      -- need the full four-sided border back.
      if layout.results then
        layout.results.border = { 1, 1, 1, 1 }
      end

      if has_previewer then
        if layout.prompt and layout.results then
          layout.results.line = layout.prompt.line + layout.prompt.height + 1
          layout.results.height = max_lines - layout.results.line
          layout.results.width = math.floor(max_columns * 0.4)
        end
        if layout.prompt and layout.preview then
          layout.preview.col = layout.results.width + 4
          layout.preview.line = layout.prompt.line + layout.prompt.height + 1
          layout.preview.height = max_lines - layout.preview.line
          layout.preview.width = max_columns - layout.results.width - 4
        end
      else
        if layout.results and layout.prompt then
          layout.results.line = layout.prompt.line + layout.prompt.height + 1
          layout.results.height = max_lines - layout.results.line
          layout.results.width = max_columns
        end
      end
      return layout
    end

    -- Add a small visual gap between the prompt title bar and the results list.
    layout_strategies.ui_select_gap = function(picker, max_columns, max_lines, layout_config)
      local layout = layout_strategies.center(picker, max_columns, max_lines, layout_config)
      if layout.prompt then
        layout.prompt.height = 1
      end
      if layout.prompt and layout.results then
        layout.results.line = layout.prompt.line + layout.prompt.height + 2
      end
      return layout
    end

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
        -- Right-pad the "showing / total" counter so it doesn't sit flush
        -- against the prompt border (rendered as right-aligned virt_text).
        get_status_text = function(self, opts)
          local multi = #(self:get_multi_selection())
          local showing = (self.stats.processed or 0) - (self.stats.filtered or 0)
          local total = self.stats.processed or 0
          local icon = (opts and not opts.completed) and "*" or ""
          local text
          if showing == 0 and total == 0 then
            text = icon
          elseif multi == 0 then
            text = string.format("%s %s / %s", icon, showing, total)
          else
            text = string.format("%s %s/%s (%s)", icon, multi, showing, total)
          end
          return text == "" and text or text .. " "
        end,
        path_display = { "filename_first" },
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = current_layout,
        layout_config = {
          ivory = {
            height = 1,
            width = 1.0,
            prompt_position = "top",
            preview_cutoff = IVORY_MIN_COLUMNS,
          },
          ebony = {
            width = 1.0,
            height = 1.0,
            preview_cutoff = 0,
            prompt_position = "top",
          },
        },

        borderchars = BORDERS[current_layout],

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
          find_command = vim.fn.executable("fd") == 1
              and { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" }
            or nil,
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
        ["ui-select"] = themes.get_dropdown({
          previewer = false,
          layout_strategy = "ui_select_gap",
          layout_config = { width = 0.5, height = 0.4 },
          borderchars = {
            prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          },
        }),
      },
    })

    local width_layout = current_layout
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        local layout = layout_for_width()
        if layout ~= width_layout then
          width_layout = layout
          apply_layout(layout)
          vim.notify("Telescope auto-switched to " .. layout .. " layout", vim.log.levels.INFO)
        end
      end,
    })

    vim.api.nvim_create_user_command("TelescopeToggleLayout", toggle_layout, {})

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

    pcall(function()
      telescope.load_extension("fzf")
    end)
    pcall(function()
      telescope.load_extension("ui-select")
    end)
  end,
}
