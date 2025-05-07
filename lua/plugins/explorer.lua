-- lua/plugins/explorer.lua
return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    priority = 80,
    opts = {
      columns = {
        "icon",
        "size",
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return name == ".." or name == ".git"
        end,
      },
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
      -- Get UI colors for consistent styling
      local colors = _G.get_ui_colors and _G.get_ui_colors()
        or {
          bg = "#282828",
          fg = "#d4be98",
          border = "#665c54",
        }

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
        end,
      }
    end,
    config = function(_, opts)
      -- Safe loading
      local ok, nvim_tree = pcall(require, "nvim-tree")
      if not ok then
        vim.notify("Failed to load nvim-tree", vim.log.levels.WARN)
        return
      end

      -- Setup with error handling
      local setup_ok, err = pcall(function()
        nvim_tree.setup(opts)

        -- Create stack-specific tree commands
        vim.api.nvim_create_user_command("NvimTreeGOTH", function()
          require("nvim-tree.api").tree.toggle({
            path = vim.fn.getcwd(),
            find_file = true,
            filters = {
              custom = {
                "^.git$",
                "^node_modules$",
                "^vendor$",
                "^.next$",
              },
            },
          })
        end, { desc = "Open NvimTree focused on GOTH stack" })

        vim.api.nvim_create_user_command("NvimTreeNext", function()
          require("nvim-tree.api").tree.toggle({
            path = vim.fn.getcwd(),
            find_file = true,
            filters = {
              custom = {
                "^.git$",
                "^vendor$",
              },
            },
          })
        end, { desc = "Open NvimTree focused on Next.js stack" })
      end)

      if not setup_ok then
        vim.notify("Failed to setup nvim-tree: " .. tostring(err), vim.log.levels.ERROR)
      end

      -- Update the existing explorer toggle command to support nvim-tree
      vim.api.nvim_create_user_command("ExplorerToggle", function(opts)
        local explorer = opts.args ~= "" and opts.args or vim.g.default_explorer or "oil"

        if explorer == "nvim-tree" then
          pcall(vim.cmd, "NvimTreeToggle")
        elseif explorer == "oil" then
          local oil = safe_require("oil")
          if oil then
            oil.open()
          else
            -- Fallback to NvimTree if oil not available
            pcall(vim.cmd, "NvimTreeToggle")
          end
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
