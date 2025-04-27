--------------------------------------------------------------------------------
-- Git Integration
--------------------------------------------------------------------------------
--
-- This module provides a comprehensive Git experience with a focus on:
-- 1. Core Git functionality via Fugitive - the gold standard of Git plugins
-- 2. Inline status indicators and hunk management with Gitsigns
-- 3. Advanced diff view and history exploration with Diffview
-- 4. Conflict resolution tools for merge scenarios
-- 5. Branch and worktree management for complex workflows
--
-- The goal is to provide all Git functionality needed without leaving Neovim,
-- while keeping the UI clean and the performance high.
--------------------------------------------------------------------------------

return {
  -- Core Git Commands with Fugitive
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull", "Gdiff", "Gcommit", "Gwrite" },
    dependencies = {
      "tpope/vim-rhubarb", -- GitHub integration (browse, create PRs, etc.)
    },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>",        desc = "Git Status" },
      { "<leader>gd", "<cmd>Gdiff<CR>",      desc = "Git Diff" },
      { "<leader>gb", "<cmd>Git blame<CR>",  desc = "Git Blame" },
      { "<leader>gc", "<cmd>Git commit<CR>", desc = "Git Commit" },
      { "<leader>gp", "<cmd>Git push<CR>",   desc = "Git Push" },
      { "<leader>gl", "<cmd>Git pull<CR>",   desc = "Git Pull" },
      { "<leader>go", "<cmd>GBrowse<CR>",    desc = "Open in GitHub/GitLab", mode = { "n", "v" } },
    },
    config = function()
      -- Create user commands for common Git operations
      vim.api.nvim_create_user_command("GCommit", function(opts)
        vim.cmd("Git commit " .. table.concat(opts.fargs, " "))
      end, { nargs = "*", complete = "file" })

      vim.api.nvim_create_user_command("GPush", function(opts)
        vim.cmd("Git push " .. table.concat(opts.fargs, " "))
      end, { nargs = "*" })

      vim.api.nvim_create_user_command("GPull", function(opts)
        vim.cmd("Git pull " .. table.concat(opts.fargs, " "))
      end, { nargs = "*" })

      -- Add Fugitive buffer mappings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "fugitive" },
        callback = function()
          -- Local mappings for Fugitive buffers
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = desc })
          end

          -- Navigation
          map("n", "gj", "<cmd>cnext<CR>", "Next hunk/file")
          map("n", "gk", "<cmd>cprev<CR>", "Previous hunk/file")
          map("n", "q", "<cmd>close<CR>", "Close Fugitive window")

          -- Git operations
          map("n", "cc", "<cmd>Git commit<CR>", "Create commit")
          map("n", "ca", "<cmd>Git commit --amend<CR>", "Amend commit")
          map("n", "ce", "<cmd>Git commit --amend --no-edit<CR>", "Amend commit (no edit)")

          -- Rebasing
          map("n", "rr", "<cmd>Git rebase --interactive HEAD~10<CR>", "Interactive rebase")
          map("n", "ri", "<cmd>Git rebase --interactive<CR>", "Interactive rebase")
          map("n", "rp", "<cmd>Git rebase --continue<CR>", "Continue rebase")
          map("n", "rs", "<cmd>Git rebase --skip<CR>", "Skip rebase")
          map("n", "ra", "<cmd>Git rebase --abort<CR>", "Abort rebase")
        end
      })
    end,
  },

  -- Git signs in the gutter and hunk operations
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
      status_formatter = nil,  -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
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
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation - integrate with jumplist
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

        -- Hunk Actions
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

        -- Blame functionality
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { desc = "Blame Line" })
        map("n", "<leader>hB", gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })

        -- Diffing
        map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, { desc = "Diff This ~" })
        map("n", "<leader>ht", gs.toggle_deleted, { desc = "Toggle Deleted" })

        -- Text object for hunks
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Hunk" })
      end,
    },
  },

  -- Advanced diff and history view
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<CR>",          desc = "DiffView Open" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "File History" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<CR>",   desc = "Repo File History" },
    },
    opts = {
      diff_binaries = false,   -- Show diffs for binaries
      enhanced_diff_hl = true, -- Enhanced diff highlighting
      use_icons = true,        -- Requires nvim-web-devicons
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
          winbar_info = false,
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          winbar_info = false,
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
      default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
      },
      hooks = {},
      keymaps = {
        disable_defaults = false, -- Disable the default keymaps
        view = {
          ["<tab>"] = "<cmd>DiffviewToggleFiles<CR>",
          ["gf"] = "<cmd>DiffviewFocusFiles<CR>",
          ["gq"] = "<cmd>DiffviewClose<CR>",
          ["[c"] = "[c", -- Previous diff hunk
          ["]c"] = "]c", -- Next diff hunk
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
    },
  },

  -- Conflict resolution
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
      { "<leader>gco", "<cmd>GitConflictChooseOurs<CR>",   desc = "Choose Ours" },
      { "<leader>gct", "<cmd>GitConflictChooseTheirs<CR>", desc = "Choose Theirs" },
      { "<leader>gcb", "<cmd>GitConflictChooseBoth<CR>",   desc = "Choose Both" },
      { "<leader>gcn", "<cmd>GitConflictChooseNone<CR>",   desc = "Choose None" },
      { "<leader>gcj", "<cmd>GitConflictNextConflict<CR>", desc = "Next Conflict" },
      { "<leader>gck", "<cmd>GitConflictPrevConflict<CR>", desc = "Prev Conflict" },
      { "<leader>gcl", "<cmd>GitConflictListQf<CR>",       desc = "List Conflicts" },
    },
    opts = {
      default_mappings = false,   -- Disable default mappings
      disable_diagnostics = true, -- Disable diagnostic markers for conflict regions
      list_opener = "copen",      -- Command to open the quickfix list
      highlights = {              -- Custom highlights for conflict markers
        current = "DiffText",
        incoming = "DiffAdd",
        ancestor = "DiffChange",
      },
    },
  },

  -- Lazygit integration - TUI Git interface
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitCurrentFile",
      "LazyGitFilterCurrentFile",
      "LazyGitFilter",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      vim.g.lazygit_floating_window_scaling_factor = 0.9 -- Make the floating window almost fill the screen
      vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
      vim.g.lazygit_use_neovim_remote = false            -- Set to true if nvr is installed to open commits in Neovim
    end,
  },

  -- Git worktree management
  {
    "ThePrimeagen/git-worktree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>gw", "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>",       desc = "Git Worktrees" },
      { "<leader>gW", "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>", desc = "Create Worktree" },
    },
    config = function()
      require("git-worktree").setup({
        change_directory_command = "cd",  -- Command to change directory (could be `cd` or `tcd`)
        update_on_change = true,          -- Update files on git worktree change
        update_on_change_command = "e .", -- Command that updates the buffer list
        clearjunk = false,                -- Clean up temporary files when switching worktrees
        autopush = false,                 -- Auto-push changes when switching worktrees
        autopull = false,                 -- Auto-pull changes when switching worktrees
      })

      -- Load Telescope extension
      require("telescope").load_extension("git_worktree")

      -- Create keymaps
      vim.api.nvim_create_user_command("WorktreeAdd", function(opts)
        -- Parse branch name and optional path from arguments
        local args = opts.args
        local branch = args:match("^([^%s]+)")
        local path = args:match("^[^%s]+ (.+)$")

        -- If no path was provided, use branch name
        if not path then
          path = branch
        end

        -- Create the worktree
        require("git-worktree").create_worktree(path, branch, "origin")
      end, {
        nargs = "+",
        desc = "Add a new worktree (args: branch [path])",
        complete = function()
          -- Provide available remote branches for completion
          local branches = vim.fn.systemlist("git branch -r | grep -v HEAD | sed 's/origin\\///'")
          return vim.tbl_filter(function(branch)
            return branch:match("^%s*(.-)%s*$")
          end, branches)
        end
      })
    end,
  },

  -- Neogit - Magit-like interface for Git
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "sindrets/diffview.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gn", "<cmd>Neogit<CR>", desc = "Neogit" },
    },
    opts = {
      integrations = {
        -- Enable Diffview integration
        diffview = true,
        -- Enable Telescope integration
        telescope = true,
      },
      -- Custom mappings for Neogit buffers
      mappings = {
        status = {
          ["q"] = "Close",
          ["1"] = "Depth1",
          ["2"] = "Depth2",
          ["3"] = "Depth3",
          ["4"] = "Depth4",
          ["<tab>"] = "Toggle",
          ["x"] = "Discard",
          ["s"] = "Stage",
          ["S"] = "StageUnstaged",
          ["<c-s>"] = "StageAll",
          ["u"] = "Unstage",
          ["U"] = "UnstageStaged",
          ["d"] = "DiffAtFile",
          ["$"] = "CommandHistory",
          ["<c-r>"] = "RefreshBuffer",
          ["o"] = "GoToFile",
          ["<enter>"] = "Toggle",
          ["<c-v>"] = "VSplitOpen",
          ["<c-x>"] = "SplitOpen",
          ["<c-t>"] = "TabOpen",
          ["?"] = "HelpPopup",
        },
      },
      -- Disable signs by default to avoid conflicts with gitsigns
      signs = {
        -- Change type
        section = { "", "" },
        item = { "", "" },
        hunk = { "", "" },
      },
    },
  },
}
