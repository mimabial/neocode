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
        ["<C-r>"] = "actions.refresh",

        ["<C-c>"] = "actions.close",
        ["q"] = "actions.close",

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
      local detail = false -- State variable

      -- Merge keymap with detail toggle
      opts.keymaps = vim.tbl_extend("force", opts.keymaps or {}, {
        ["gd"] = {
          desc = "Toggle file detail view",
          callback = function()
            detail = not detail
            if detail then
              require("oil").set_columns({ "permissions", "size" })
            else
              require("oil").set_columns({})
            end
          end,
        },
      })

      require("oil").setup(opts)
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    keys = {
      {
        "<leader>e",
        function()
          -- Don't open nvim-tree if we're in oil
          if vim.bo.filetype == "oil" then
            vim.notify("Cannot open nvim-tree in oil buffer", vim.log.levels.WARN)
            return
          end
          vim.cmd("NvimTreeToggle")
        end,
        desc = "Open NvimTree Explorer",
      },
    },
    opts = function()
      return {
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        log = {
          enable = true,
          truncate = true,
          types = {
            all = false,
            config = false,
            copy_paste = false,
            diagnostics = true,
            git = false,
            profile = false,
            watcher = true,
          },
        },
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        view = {
          width = 30,
          side = "right",
        },
        diagnostics = {
          enable = true,
          show_on_dirs = false,
          show_on_open_dirs = false,
          debounce_delay = 500,

          severity = {
            min = vim.diagnostic.severity.HINT,
            max = vim.diagnostic.severity.ERROR,
          },
          icons = {
            hint = "H",
            info = "I",
            warning = "W",
            error = "E",
          },
        },
        git = {
          enable = true,
          ignore = true,
        },
        filesystem_watchers = {
          enable = true,
        },
        actions = {
          open_file = {
            resize_window = true,
            quit_on_open = false,
          },
          remove_file = {
            close_window = true,
          },
          change_dir = {
            enable = true,
            global = true,
            restrict_above_cwd = true,
          },
        },
        renderer = {
          root_folder_label = true,
          highlight_git = true,
          highlight_opened_files = "none",
          special_files = { "Makefile", "README.md", "readme.md", "LICENSE", "Dockerfile" },

          indent_markers = {
            enable = true,
            icons = {
              corner = "󱞩", -- alt: └ 
              edge = "│", --alt: │┆
              item = "│", -- alt: ├
              bottom = "─",
              none = "│",
            },
          },
          icons = {
            git_placement = "after",
            modified_placement = "after",
            show = {
              file = false,
              folder = false,
              folder_arrow = false,
              git = true,
            },

            glyphs = {
              default = "",
              symlink = "",
              folder = {
                default = "/",
                empty = "/",
                empty_open = "/",
                open = "/",
                symlink = "/",
                symlink_open = "/",
              },
              git = {
                unstaged = "󰰩",
                staged = "󰰣",
                unmerged = " ",
                renamed = "󰰠",
                untracked = "",
                deleted = "󰯶",
                ignored = "󰰅",
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
          vim.keymap.set("n", "<ESC>", api.tree.close, opts("Close"))
          vim.keymap.set("n", "q", api.tree.close, opts("Close"))
        end,
      }
    end,
    config = function(_, opts)
      require("nvim-tree").setup(opts)
      -- Close Neovim if nvim-tree is the last window
      vim.api.nvim_create_autocmd("BufEnter", {
        nested = true,
        callback = function()
          if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == "NvimTree" then
            vim.cmd("quit")
          end
        end,
      })

      -- Prevent floating nvim-tree from closing on focus loss
      -- vim.api.nvim_create_autocmd("FileType", {
      --   pattern = "NvimTree",
      --   callback = function(args)
      --     local bufnr = args.buf
      --     vim.api.nvim_create_autocmd("WinLeave", {
      --       buffer = bufnr,
      --       callback = function()
      --         return true -- Prevent default behavior
      --       end,
      --     })
      --   end,
      -- })

      local function setup_nvim_tree_highlights()
        local colors = (_G.get_ui_colors and _G.get_ui_colors()) or {
          bg = "NONE",
          fg = "NONE",
        }
        vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = colors.bg, fg = colors.fg })
        vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = colors.bg, fg = colors.bg })
      end

      setup_nvim_tree_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_nvim_tree_highlights })
    end,
  },
}
