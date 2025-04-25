--------------------------------------------------------------------------------
-- Git Integration
--------------------------------------------------------------------------------
--
-- This module provides comprehensive Git integration:
--
-- Features:
-- 1. Git commands via fugitive
-- 2. Inline git diff indicators
-- 3. Blame information
-- 4. GitHub integration
-- 5. Diff view for file changes
-- 6. Commit and PR templates
-- 7. Git conflict resolution
--
-- These tools provide a complete Git workflow without leaving Neovim.
--------------------------------------------------------------------------------

return {
  -- Core Git Commands
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull", "Gdiff", "Gcommit", "Gwrite" },
    dependencies = {
      "tpope/vim-rhubarb", -- GitHub integration
    },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git Status" },
      { "<leader>gd", "<cmd>Gdiff<CR>", desc = "Git Diff" },
      { "<leader>gb", "<cmd>Git blame<CR>", desc = "Git Blame" },
      { "<leader>gc", "<cmd>Git commit<CR>", desc = "Git Commit" },
      { "<leader>gp", "<cmd>Git push<CR>", desc = "Git Push" },
      { "<leader>gl", "<cmd>Git pull<CR>", desc = "Git Pull" },
      { "<leader>go", "<cmd>GBrowse<CR>", desc = "Open in GitHub", mode = { "n", "v" } },
    },
    config = function()
      vim.api.nvim_create_user_command("GCommit", function(opts)
        vim.cmd("Git commit " .. table.concat(opts.fargs, " "))
      end, { nargs = "*", complete = "file" })

      vim.api.nvim_create_user_command("GPush", function(opts)
        vim.cmd("Git push " .. table.concat(opts.fargs, " "))
      end, { nargs = "*" })

      vim.api.nvim_create_user_command("GPull", function(opts)
        vim.cmd("Git pull " .. table.concat(opts.fargs, " "))
      end, { nargs = "*" })
    end,
  },

  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,   -- Use default
      max_file_length = 40000,  -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      yadm = {
        enable = false,
      },
      -- Key mappings
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]h", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Next Hunk" })

        map("n", "[h", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Prev Hunk" })

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage Selected Hunk" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset Selected Hunk" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { desc = "Blame Line" })
        map("n", "<leader>htb", gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })
        map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, { desc = "Diff This ~" })
        map("n", "<leader>htd", gs.toggle_deleted, { desc = "Toggle Deleted" })

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Hunk" })
      end,
    },
  },

  -- Advanced diff view
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<CR>", desc = "DiffView Open" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "File History" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<CR>", desc = "Repo File History" },
    },
    config = function()
      require("diffview").setup({
        diff_binaries = false, -- Show diffs for binaries
        enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
        use_icons = true, -- Requires nvim-web-devicons
        icons = {
          folder_closed = "",
          folder_open = "",
        },
        signs = {
          fold_closed = "",
          fold_open = "",
          done = "✓",
        },
        view = {
          default = {
            layout = "diff2_horizontal",
            winbar_info = false, -- See ':h diffview-config-view.*.winbar_info'
          },
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers
            winbar_info = true, -- See ':h diffview-config-view.*.winbar_info'
          },
          file_history = {
            layout = "diff2_horizontal",
            winbar_info = false, -- See ':h diffview-config-view.*.winbar_info'
          },
        },
        file_panel = {
          listing_style = "tree", -- 'list' or 'tree'
          tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
          },
          win_config = {
            position = "left",
            width = 35,
            win_opts = {},
          },
        },
        file_history_panel = {
          log_options = {
            git = {
              single_file = {
                max_count = 512,
                follow = true,
                all = false,
                merges = false,
                no_merges = false,
                reverse = false,
              },
              multi_file = {
                max_count = 128,
                follow = false,
                all = false,
                merges = false,
                no_merges = false,
                reverse = false,
              },
            },
          },
          win_config = {
            position = "bottom",
            height = 16,
            win_opts = {},
          },
        },
        commit_log_panel = {
          win_config = {
            win_opts = {},
          },
        },
        default_args = {
          DiffviewOpen = {},
          DiffviewFileHistory = {},
        },
        hooks = {},
        keymaps = {
          disable_defaults = false, -- Disable the default keymaps
          view = {
            -- The `view` bindings are active in the diff buffers
            ["<tab>"] = "<cmd>DiffviewToggleFiles<CR>",
            ["gf"] = "<cmd>DiffviewFocusFiles<CR>",
            ["gq"] = "<cmd>DiffviewClose<CR>",
            ["[c"] = "[c",
            ["]c"] = "]c",
          },
          file_panel = {
            ["j"] = "next_entry",
            ["k"] = "prev_entry",
            ["<cr>"] = "select_entry",
            ["o"] = "select_entry",
            ["R"] = "refresh_files",
            ["<tab>"] = "select_next_entry",
            ["<s-tab>"] = "select_prev_entry",
            ["gq"] = "<cmd>DiffviewClose<CR>",
            ["<c-b>"] = "scroll_view(-0.25)",
            ["<c-f>"] = "scroll_view(0.25)",
            ["<c-d>"] = "scroll_view(0.50)",
            ["<c-u>"] = "scroll_view(-0.50)",
          },
          file_history_panel = {
            ["g!"] = "options", -- Open the option panel
            ["<C-d>"] = "scroll_view(0.50)",
            ["<C-u>"] = "scroll_view(-0.50)",
            ["j"] = "next_entry",
            ["k"] = "prev_entry",
            ["gf"] = "<cmd>DiffviewFocusFiles<CR>",
            ["gq"] = "<cmd>DiffviewClose<CR>",
            ["<cr>"] = "select_entry",
            ["o"] = "select_entry",
            ["y"] = "copy_hash", -- Copy the commit hash
          },
          option_panel = {
            ["q"] = "close",
            ["<cr>"] = "select",
            ["<c-c>"] = "close",
          },
        },
      })
    end,
  },

  -- Git conflict resolution
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    cmd = {
      "GitConflictChooseOurs",
      "GitConflictChooseTheirs",
      "GitConflictChooseBoth",
      "GitConflictChooseNone",
      "GitConflictNextConflict",
      "GitConflictPrevConflict",
      "GitConflictListQf",
    },
    keys = {
      { "<leader>gco", "<cmd>GitConflictChooseOurs<CR>", desc = "Choose Ours" },
      { "<leader>gct", "<cmd>GitConflictChooseTheirs<CR>", desc = "Choose Theirs" },
      { "<leader>gcb", "<cmd>GitConflictChooseBoth<CR>", desc = "Choose Both" },
      { "<leader>gcn", "<cmd>GitConflictChooseNone<CR>", desc = "Choose None" },
      { "<leader>gcj", "<cmd>GitConflictNextConflict<CR>", desc = "Next Conflict" },
      { "<leader>gck", "<cmd>GitConflictPrevConflict<CR>", desc = "Prev Conflict" },
      { "<leader>gcl", "<cmd>GitConflictListQf<CR>", desc = "List Conflicts" },
    },
    opts = {
      default_mappings = false,
      disable_diagnostics = true,
      list_opener = "copen",
      highlights = {
        current = "DiffText",
        incoming = "DiffAdd",
        ancestor = "DiffChange",
      },
    },
  },

  -- Git blame
  {
    "f-person/git-blame.nvim",
    cmd = { "GitBlameToggle" },
    keys = {
      { "<leader>gtb", "<cmd>GitBlameToggle<CR>", desc = "Toggle Git Blame" },
    },
    config = function()
      require("gitblame").setup({
        enabled = false,
        date_format = "%r",
        message_template = "  <author> • <date> • <summary>",
        message_when_not_committed = "  Not committed yet",
        highlight_group = "LineNr",
        display_virtual_text = true,
        delay = 1000,
        set_extmark_options = {},
      })
    end,
  },

  -- GitHub integration
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "Octo" },
    keys = {
      { "<leader>go", "<cmd>Octo<CR>", desc = "Octo" },
      { "<leader>goi", "<cmd>Octo issue list<CR>", desc = "Issue List" },
      { "<leader>gop", "<cmd>Octo pr list<CR>", desc = "PR List" },
      { "<leader>gor", "<cmd>Octo repo list<CR>", desc = "Repo List" },
    },
    config = function()
      require("octo").setup({
        default_remote = { "upstream", "origin" },
        ssh_aliases = {}, -- SSH aliases. e.g. { ["github.com-work"] = "github.com" }
        reaction_viewer_hint_icon = "",
        user_icon = " ",
        timeline_marker = " ",
        timeline_indent = "2",
        right_bubble_delimiter = "",
        left_bubble_delimiter = "",
        github_hostname = "",
        snippet_context_lines = 4,
        file_panel = {
          size = 10,
          use_icons = true,
        },
        mappings = {
          issue = {
            close_issue = { lhs = "<leader>ic", desc = "close issue" },
            reopen_issue = { lhs = "<leader>io", desc = "reopen issue" },
            list_issues = { lhs = "<leader>il", desc = "list open issues on same repo" },
            reload = { lhs = "<C-r>", desc = "reload issue" },
            open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
            copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
            add_assignee = { lhs = "<leader>aa", desc = "add assignee" },
            remove_assignee = { lhs = "<leader>ad", desc = "remove assignee" },
            create_label = { lhs = "<leader>lc", desc = "create label" },
            add_label = { lhs = "<leader>la", desc = "add label" },
            remove_label = { lhs = "<leader>ld", desc = "remove label" },
            goto_issue = { lhs = "<leader>gi", desc = "navigate to a local repo issue" },
            add_comment = { lhs = "<leader>ca", desc = "add comment" },
            delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "go to next comment" },
            prev_comment = { lhs = "[c", desc = "go to previous comment" },
            react_hooray = { lhs = "<leader>r+", desc = "add/remove 🎉 reaction" },
            react_heart = { lhs = "<leader>r<3", desc = "add/remove ❤️ reaction" },
            react_eyes = { lhs = "<leader>r👀", desc = "add/remove 👀 reaction" },
            react_thumbs_up = { lhs = "<leader>r+1", desc = "add/remove 👍 reaction" },
            react_thumbs_down = { lhs = "<leader>r-1", desc = "add/remove 👎 reaction" },
            react_rocket = { lhs = "<leader>r🚀", desc = "add/remove 🚀 reaction" },
            react_laugh = { lhs = "<leader>r😄", desc = "add/remove 😄 reaction" },
            react_confused = { lhs = "<leader>r😕", desc = "add/remove 😕 reaction" },
          },
          pull_request = {
            checkout_pr = { lhs = "<leader>po", desc = "checkout PR" },
            merge_pr = { lhs = "<leader>pm", desc = "merge commit PR" },
            squash_and_merge_pr = { lhs = "<leader>psm", desc = "squash and merge PR" },
            list_commits = { lhs = "<leader>pc", desc = "list PR commits" },
            list_changed_files = { lhs = "<leader>pf", desc = "list PR changed files" },
            show_pr_diff = { lhs = "<leader>pd", desc = "show PR diff" },
            add_reviewer = { lhs = "<leader>va", desc = "add reviewer" },
            remove_reviewer = { lhs = "<leader>vd", desc = "remove reviewer request" },
            close_pr = { lhs = "<leader>pc", desc = "close PR" },
            reopen_pr = { lhs = "<leader>po", desc = "reopen PR" },
            list_prs = { lhs = "<leader>pl", desc = "list open PRs on same repo" },
            reload = { lhs = "<C-r>", desc = "reload PR" },
            open_in_browser = { lhs = "<C-b>", desc = "open PR in browser" },
            copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
            goto_file = { lhs = "gf", desc = "go to file" },
            add_assignee = { lhs = "<leader>aa", desc = "add assignee" },
            remove_assignee = { lhs = "<leader>ad", desc = "remove assignee" },
            create_label = { lhs = "<leader>lc", desc = "create label" },
            add_label = { lhs = "<leader>la", desc = "add label" },
            remove_label = { lhs = "<leader>ld", desc = "remove label" },
            goto_issue = { lhs = "<leader>gi", desc = "navigate to a local repo issue" },
            add_comment = { lhs = "<leader>ca", desc = "add comment" },
            delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "go to next comment" },
            prev_comment = { lhs = "[c", desc = "go to previous comment" },
            react_hooray = { lhs = "<leader>r+", desc = "add/remove 🎉 reaction" },
            react_heart = { lhs = "<leader>r<3", desc = "add/remove ❤️ reaction" },
            react_eyes = { lhs = "<leader>r👀", desc = "add/remove 👀 reaction" },
            react_thumbs_up = { lhs = "<leader>r+1", desc = "add/remove 👍 reaction" },
            react_thumbs_down = { lhs = "<leader>r-1", desc = "add/remove 👎 reaction" },
            react_rocket = { lhs = "<leader>r🚀", desc = "add/remove 🚀 reaction" },
            react_laugh = { lhs = "<leader>r😄", desc = "add/remove 😄 reaction" },
            react_confused = { lhs = "<leader>r😕", desc = "add/remove 😕 reaction" },
          },
          review_thread = {
            goto_issue = { lhs = "<leader>gi", desc = "navigate to a local repo issue" },
            add_comment = { lhs = "<leader>ca", desc = "add comment" },
            add_suggestion = { lhs = "<leader>sa", desc = "add suggestion" },
            delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "go to next comment" },
            prev_comment = { lhs = "[c", desc = "go to previous comment" },
            select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
            select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            react_hooray = { lhs = "<leader>r+", desc = "add/remove 🎉 reaction" },
            react_heart = { lhs = "<leader>r<3", desc = "add/remove ❤️ reaction" },
            react_eyes = { lhs = "<leader>r👀", desc = "add/remove 👀 reaction" },
            react_thumbs_up = { lhs = "<leader>r+1", desc = "add/remove 👍 reaction" },
            react_thumbs_down = { lhs = "<leader>r-1", desc = "add/remove 👎 reaction" },
            react_rocket = { lhs = "<leader>r🚀", desc = "add/remove 🚀 reaction" },
            react_laugh = { lhs = "<leader>r😄", desc = "add/remove 😄 reaction" },
            react_confused = { lhs = "<leader>r😕", desc = "add/remove 😕 reaction" },
          },
          submit_win = {
            approve_review = { lhs = "<leader>sa", desc = "approve review" },
            comment_review = { lhs = "<leader>sc", desc = "comment review" },
            request_changes = { lhs = "<leader>sr", desc = "request changes review" },
            close_review_tab = { lhs = "<leader>sq", desc = "close review tab" },
          },
          review_diff = {
            add_review_comment = { lhs = "<leader>ca", desc = "add a new review comment" },
            add_review_suggestion = { lhs = "<leader>sa", desc = "add a new review suggestion" },
            focus_files = { lhs = "<leader>e", desc = "move focus to changed file panel" },
            toggle_files = { lhs = "<leader>b", desc = "hide/show changed files panel" },
            next_comment = { lhs = "]c", desc = "move to next comment" },
            prev_comment = { lhs = "[c", desc = "move to previous comment" },
            select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
            select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            toggle_viewed = { lhs = "<leader>v", desc = "toggle viewed state" },
          },
          file_panel = {
            next_entry = { lhs = "j", desc = "move to next changed file" },
            prev_entry = { lhs = "k", desc = "move to previous changed file" },
            select_entry = { lhs = "<cr>", desc = "show selected changed file diffs" },
            refresh_files = { lhs = "R", desc = "refresh changed files panel" },
            focus_files = { lhs = "<leader>e", desc = "move focus to changed file panel" },
            toggle_files = { lhs = "<leader>b", desc = "hide/show changed files panel" },
            select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
            select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            toggle_viewed = { lhs = "<leader>v", desc = "toggle viewed state" },
          },
        },
      })
    end,
  },

  -- Git worktree management
  {
    "ThePrimeagen/git-worktree.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>gw", "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>", desc = "Git Worktrees" },
      { "<leader>gW", "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>", desc = "Create Worktree" },
    },
    config = function()
      require("git-worktree").setup({
        change_directory_command = "cd",
        update_on_change = true,
        update_on_change_command = "e .",
        clearjunk = false,
        autopush = false,
        autopull = false,
      })

      require("telescope").load_extension("git_worktree")
    end,
  },

  -- Auto-generated commit messages
  {
    "perzanko/pre-commit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      run_on_save = {
        enabled = false,
      },
      commands = {
        ["prettier"] = {
          enabled = true,
          command = "prettier --write ${file}",
          pattern = "**/*.{ts,tsx,js,jsx,json,css,md,yml,yaml}",
        },
        ["stylua"] = {
          enabled = true,
          command = "stylua ${file}",
          pattern = "**/*.lua",
        },
        ["black"] = {
          enabled = true,
          command = "black ${file}",
          pattern = "**/*.py",
        },
      },
    },
  },
}
