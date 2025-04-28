return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      enabled = vim.fn.executable("make") == 1,
    },
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-project.nvim",
    "nvim-telescope/telescope-frecency.nvim",
    -- Make sure this is loaded only if nvim-dap is available
    {
      "nvim-telescope/telescope-dap.nvim",
      dependencies = {
        "mfussenegger/nvim-dap",
      },
    },
    "kkharji/sqlite.lua", -- needed for frecency
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    -- Find files/text
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find Text (Grep)" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
    { "<leader>fR", "<cmd>Telescope frecency<cr>", desc = "Frecent Files" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Find Keymaps" },

    -- Project management
    { "<leader>fp", "<cmd>Telescope project<cr>", desc = "Find Projects" },
    { "<leader>fP", "<cmd>lua require('telescope').extensions.project.project{}<cr>", desc = "Find Project" },
    
    -- Git
    { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
    { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
    
    -- Code navigation
    { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Find Commands" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Find Document Symbols" },
    { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Find Workspace Symbols" },
    { "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Find Document Diagnostics" },
    { "<leader>fD", "<cmd>Telescope diagnostics<cr>", desc = "Find Workspace Diagnostics" },
    { "<leader>fi", "<cmd>Telescope lsp_implementations<cr>", desc = "Find Implementations" },
    { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "Find References" },
    
    -- Vim-related
    { "<leader>fo", "<cmd>Telescope vim_options<cr>", desc = "Find Options" },
    { "<leader>ft", "<cmd>Telescope filetypes<cr>", desc = "Find Filetypes" },
    { "<leader>fT", "<cmd>Telescope builtin<cr>", desc = "Find Telescope Pickers" },
    
    -- Other
    { "<leader>f.", "<cmd>Telescope resume<cr>", desc = "Resume Last Search" },
    { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in Current Buffer" },
    { "<leader>fe", "<cmd>Telescope file_browser<cr>", desc = "File Browser" },
    {
      "<leader>fC",
      function()
        require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Find Config Files",
    },
  },
  opts = function()
    local actions = require("telescope.actions")
    local fb_actions = require("telescope").extensions.file_browser.actions

    return {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        multi_icon = " ",
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        file_ignore_patterns = { 
          "node_modules", 
          "%.git/", 
          "%.DS_Store$", 
          "^.git/", 
          "^target/", 
          "^build/",
          "^dist/",
          "^.next/",
          "^.yarn/", 
          "^.idea/", 
          "^.vscode/", 
          "^__pycache__/",
          "%.sqlite3$",
          "%.o$",
          "%.a$",
          "%.out$",
          "%.class$",
          "%.pdf$",
          "%.mkv$",
          "%.mp4$",
          "%.zip$"
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
        },
        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-c>"] = actions.close,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,
            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-l>"] = actions.complete_tag,
            ["<C-/>"] = actions.which_key,
            ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
            ["<C-w>"] = { "<c-s-w>", type = "command" },
          },
          n = {
            ["<esc>"] = actions.close,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["H"] = actions.move_to_top,
            ["M"] = actions.move_to_middle,
            ["L"] = actions.move_to_bottom,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,
            ["gg"] = actions.move_to_top,
            ["G"] = actions.move_to_bottom,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,
            ["?"] = actions.which_key,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" },
        },
        live_grep = {
          -- Exclude some directories from grep results
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
          show_all_buffers = true,
          sort_lastused = true,
          previewer = false,
          mappings = {
            i = {
              ["<c-d>"] = actions.delete_buffer,
            },
            n = {
              ["dd"] = actions.delete_buffer,
            },
          },
        },
        commands = {
          theme = "dropdown",
        },
        colorscheme = {
          enable_preview = true,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
        file_browser = {
          theme = "dropdown",
          hijack_netrw = true,
          mappings = {
            ["i"] = {
              ["<C-c>"] = actions.close,
              ["<C-n>"] = fb_actions.create,
              ["<C-r>"] = fb_actions.rename,
              ["<C-h>"] = fb_actions.goto_parent_dir,
              ["<C-e>"] = fb_actions.goto_home_dir,
              ["<C-w>"] = fb_actions.goto_cwd,
              ["<C-t>"] = fb_actions.change_cwd,
              ["<C-f>"] = fb_actions.toggle_browser,
              ["<C-g>"] = fb_actions.toggle_hidden,
              ["<C-d>"] = fb_actions.remove,
              ["<C-y>"] = fb_actions.copy,
              ["<C-m>"] = fb_actions.move,
            },
            ["n"] = {
              ["n"] = fb_actions.create,
              ["r"] = fb_actions.rename,
              ["h"] = fb_actions.goto_parent_dir,
              ["e"] = fb_actions.goto_home_dir,
              ["w"] = fb_actions.goto_cwd,
              ["t"] = fb_actions.change_cwd,
              ["f"] = fb_actions.toggle_browser,
              ["g"] = fb_actions.toggle_hidden,
              ["d"] = fb_actions.remove,
              ["y"] = fb_actions.copy,
              ["m"] = fb_actions.move,
            },
          },
        },
        project = {
          base_dirs = {
            { path = "~/projects", max_depth = 4 },
            { path = "~/work", max_depth = 4 },
          },
          hidden_files = true,
        },
      },
    }
  end,
  config = function(_, opts)
    require("telescope").setup(opts)
    
    -- Load extensions
    local telescope = require("telescope")
    
    -- Load available extensions and safely handle errors
    local function safe_load_extension(name)
      local status_ok, _ = pcall(telescope.load_extension, name)
      if not status_ok then
        vim.notify("Could not load telescope extension: " .. name, vim.log.levels.WARN)
      end
    end
    
    -- Core extensions
    safe_load_extension("fzf")
    safe_load_extension("ui-select")
    
    -- File and project navigation
    safe_load_extension("file_browser")
    safe_load_extension("project")
    safe_load_extension("frecency")
    
    -- Only load dap if nvim-dap is installed and loaded
    if package.loaded["dap"] then
      safe_load_extension("dap")
    end
  end,
}
