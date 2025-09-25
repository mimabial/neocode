return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    priority = 80,
    opts = {
      columns = {},
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return name == ".." or name == ".git"
        end,
      },
      -- Buffer-local options to disable global confirm for oil buffers
      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },
      -- Window-local options
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      confirmation = {
        show_preview = true,
        delete = true,
        trash = true,
      },
      cleanup_delay_ms = 2000,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      prompt_save_on_select_new_entry = false,
      float = {
        border = "single",
        max_width = 120,
        max_height = 40,
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
      use_default_keymaps = true,
    },
    config = function(_, opts)
      require("oil").setup(opts)

      -- Disable global confirm for oil buffers specifically
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function()
          vim.opt_local.confirm = false
        end,
      })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    keys = {
      { "<leader>E", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree Explorer" },
    },
    opts = function()
      return {
        disable_netrw = true,
        hijack_cursor = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        view = {
          adaptive_size = false,
          width = 30,
          side = "left",
          preserve_window_proportions = true,
        },
        git = {
          enable = true,
          ignore = false,
        },
        filesystem_watchers = {
          enable = true,
        },
        actions = {
          open_file = {
            resize_window = true,
            window_picker = {
              enable = true,
            },
          },
        },
        renderer = {
          root_folder_label = false,
          highlight_git = true,
          highlight_opened_files = "name",
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              git = {
                unstaged = "•",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        filters = {
          git_ignored = false,
          dotfiles = false,
          custom = {
            "^.git$",
            "^node_modules$",
            "^.cache$",
            "^.DS_Store$",
          },
          exclude = {},
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          severity = {
            min = vim.diagnostic.severity.HINT,
            max = vim.diagnostic.severity.ERROR,
          },
          icons = {
            hint = " ",
            info = " ",
            warning = " ",
            error = " ",
          },
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")

          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- Default mappings
          vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
          vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
          vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
          vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
          vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
          vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
          vim.keymap.set("n", "y", api.fs.copy.node, opts("Copy"))
          vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
          vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
          vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
          vim.keymap.set("n", "a", api.fs.create, opts("Create"))
          vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
          vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
          vim.keymap.set("n", "q", api.tree.close, opts("Close"))
        end,
      }
    end,
    config = function(_, opts)
      require("nvim-tree").setup(opts)

      -- Explorer toggle command
      vim.api.nvim_create_user_command("ExplorerToggle", function(opts)
        local explorer = opts.args ~= "" and opts.args or vim.g.default_explorer or "oil"

        if explorer == "nvim-tree" then
          vim.cmd("NvimTreeToggle")
        elseif explorer == "oil" then
          require("oil").open()
        elseif explorer == "netrw" then
          vim.cmd("Explore")
        end
      end, {
        nargs = "?",
        complete = function()
          return { "oil", "nvim-tree", "netrw" }
        end,
        desc = "Toggle file explorer (oil, nvim-tree, or netrw)",
      })
    end,
  },
}
