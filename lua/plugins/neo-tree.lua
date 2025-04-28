return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    {
      "<leader>E",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.fn.stdpath("config") })
      end,
      desc = "Explorer NeoTree (config)",
    },
    { "<leader>be", "<cmd>Neotree buffers reveal float<cr>", desc = "Buffer explorer" },
    { "<leader>ge", "<cmd>Neotree git_status reveal float<cr>", desc = "Git status explorer" },
    { "<leader>se", "<cmd>Neotree document_symbols reveal float<cr>", desc = "Symbols Explorer" },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    {
      "s1n7ax/nvim-window-picker",
      opts = {
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          bo = {
            filetype = { "neo-tree", "neo-tree-popup", "notify", "quickfix" },
            buftype = { "terminal", "quickfix", "nofile" },
          },
        },
      },
    },
  },
  opts = {
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    open_files_do_not_replace_types = { "terminal", "trouble", "qf", "edgy" },
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    enable_normal_mode_for_inputs = false,
    sort_case_insensitive = true,
    
    source_selector = {
      winbar = true,
      content_layout = "center",
      sources = {
        { source = "filesystem", display_name = " Files" },
        { source = "buffers", display_name = " Buffers" },
        { source = "git_status", display_name = " Git" },
        { source = "document_symbols", display_name = " Symbols" },
      },
      separator = { left = "", right = "" },
    },
    
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
        folder_empty_open = "",
        default = "",
      },
      modified = {
        symbol = "●",
        highlight = "NeoTreeModified",
      },
      git_status = {
        symbols = {
          added = "", 
          modified = "", 
          deleted = "✖", 
          renamed = "󰁕", 
          untracked = "",
          ignored = "",
          unstaged = "󰄱",
          staged = "",
          conflict = "",
        },
      },
      name = {
        trailing_slash = false,
        highlight_opened_files = true,
        use_git_status_colors = true,
        highlight = "NeoTreeFileName",
      },
      symlink_target = {
        enabled = true,
      },
    },
    
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      hijack_netrw_behavior = "open_default",
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_hidden = true,
        hide_by_name = {},
        hide_by_pattern = { ".git/" },
        always_show = {},
        never_show = {
          ".DS_Store",
          "thumbs.db",
          ".git",
        },
      },
      commands = {
        system_open = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          vim.api.nvim_command("silent !open -g " .. vim.fn.shellescape(path))
        end,
        copy_selector = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify

          local results = {
            e = { val = modify(filename, ":e"), msg = "Extension only" },
            f = { val = filename, msg = "Filename" },
            F = { val = modify(filename, ":r"), msg = "Filename w/o extension" },
            h = { val = modify(filepath, ":~"), msg = "Path relative to Home" },
            p = { val = modify(filepath, ":."), msg = "Path relative to CWD" },
            P = { val = filepath, msg = "Absolute path" },
          }

          local messages = {
            { "\nChoose to copy to clipboard:\n", "Normal" },
          }
          for i, result in pairs(results) do
            if result.val and result.val ~= "" then
              messages[#messages+1] = { ("%s."):format(i), "Identifier" }
              messages[#messages+1] = { (" %s: "):format(result.msg), "Normal" }
              messages[#messages+1] = { result.val, "String" }
              messages[#messages+1] = { "\n", "Normal" }
            end
          end
          vim.api.nvim_echo(messages, false, {})
          local result = results[vim.fn.getcharstr()]
          if result and result.val and result.val ~= "" then
            vim.fn.setreg("+", result.val)
            vim.notify("Copied: " .. result.val)
          end
        end,
      },
    },
    
    window = {
      position = "left",
      width = 35,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      mappings = {
        ["<space>"] = "none",
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["<C-s>"] = "open_split",
        ["<C-v>"] = "open_vsplit",
        ["<C-t>"] = "open_tabnew",
        ["w"] = "open_with_window_picker",
        ["S"] = "split_with_window_picker",
        ["s"] = "vsplit_with_window_picker",
        ["t"] = "open_tabnew",
        ["W"] = "close_window",
        ["C"] = "close_node",
        ["z"] = "close_all_nodes",
        ["Z"] = "expand_all_nodes",
        ["R"] = "refresh",
        ["a"] = { "add", config = { show_path = "none" } },
        ["A"] = { "add_directory", config = { show_path = "none" } },
        ["d"] = { "delete", config = { show_path = "none" } },
        ["r"] = { "rename", config = { show_path = "none" } },
        ["y"] = { "copy_to_clipboard", config = { show_path = "none" } },
        ["Y"] = { "copy_selector", config = { show_path = "none" } },
        ["x"] = { "cut_to_clipboard", config = { show_path = "none" } },
        ["p"] = { "paste_from_clipboard", config = { show_path = "none" } },
        ["c"] = { "copy", config = { show_path = "none" } },
        ["m"] = { "move", config = { show_path = "none" } },
        ["q"] = "close_window",
        ["?"] = "show_help",
        ["<"] = "prev_source",
        [">"] = "next_source",
        ["i"] = { "show_file_details", config = { use_float = true } },
        ["o"] = { "system_open", config = { use_float = true } },
        ["h"] = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" and node:is_expanded() then
            require("neo-tree.sources.filesystem").toggle_directory(state, node)
          else
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end
        end,
        ["l"] = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" then
            if not node:is_expanded() then
              require("neo-tree.sources.filesystem").toggle_directory(state, node)
            elseif node:has_children() then
              require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
            end
          else
            require("neo-tree.sources.filesystem.commands").open(state)
          end
        end,
      },
    },
    
    buffers = {
      follow_current_file = { enabled = true },
      group_empty_dirs = true,
      show_unloaded = true,
      window = {
        mappings = {
          ["bd"] = "buffer_delete",
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
        },
      },
    },
    
    git_status = {
      window = {
        mappings = {
          ["A"] = "git_add_all",
          ["gu"] = "git_unstage_file",
          ["ga"] = "git_add_file",
          ["gr"] = "git_revert_file",
          ["gc"] = "git_commit",
          ["gp"] = "git_push",
          ["gg"] = "git_commit_and_push",
        },
      },
    },
    
    document_symbols = {
      follow_cursor = true,
      client_filters = {
        ["*"] = {
          kinds = {
            "File", "Module", "Namespace", "Package", "Class", "Method", 
            "Property", "Field", "Constructor", "Enum", "Interface", 
            "Function", "Variable", "Constant", "String", "Number", 
            "Boolean", "Array", "Object", "Key", "Null", "EnumMember", 
            "Struct", "Event", "Operator", "TypeParameter",
          },
        },
      },
    },
    
    event_handlers = {
      {
        event = "file_opened",
        handler = function(file_path)
          -- Auto close neo-tree after selecting a file in small windows
          if vim.fn.winwidth(0) < 100 then
            require("neo-tree").close_all()
          end
        end,
      },
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          -- Hide cursor in neo-tree window
          vim.cmd [[setlocal guicursor=n:block-Cursor/lCursor-blinkon0]]
          -- Make the background transparent
          vim.cmd [[setlocal winhl=Normal:NeoTreeNormal,NormalNC:NeoTreeNormalNC]]
          -- Improve the look
          vim.wo.signcolumn = "auto"
          vim.wo.cursorline = true
        end
      },
      {
        event = "neo_tree_buffer_leave",
        handler = function()
          vim.cmd [[setlocal guicursor=]]
        end
      }
    },
    
    renderers = {
      directory = {
        { "indent" },
        { "icon" },
        { "current_filter" },
        {
          "container",
          content = {
            { "name", zindex = 10 },
            { "symlink_target", zindex = 10, highlight = "NeoTreeSymlinkTarget" },
            { "clipboard", zindex = 10 },
            { "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
            { "git_status", zindex = 20, align = "right", hide_when_expanded = true },
          },
        },
      },
      file = {
        { "indent" },
        { "icon" },
        {
          "container",
          content = {
            {
              "name",
              zindex = 10,
            },
            { "symlink_target", zindex = 10, highlight = "NeoTreeSymlinkTarget" },
            { "clipboard", zindex = 10 },
            { "bufnr", zindex = 10 },
            { "modified", zindex = 20, align = "right" },
            { "diagnostics", zindex = 20, align = "right" },
            { "git_status", zindex = 20, align = "right" },
          },
        },
      },
    },
  },
  config = function(_, opts)
    -- Setup custom highlights for transparency
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE", blend = 0 })
        vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE", blend = 0 })
        vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { bg = "NONE", blend = 0 })
        vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "NONE", blend = 0 })
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#7daea3" })
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = "#a89984", bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeSymbolicLinkTarget", { fg = "#d8a657" })
        vim.api.nvim_set_hl(0, "NeoTreeIndentMarker", { fg = "#504945" })
        vim.api.nvim_set_hl(0, "NeoTreeExpander", { fg = "#7c6f64" })
      end,
    })
    
    -- Setup Neo-tree
    require("neo-tree").setup(opts)
    
    -- Run migrations if needed
    vim.defer_fn(function()
      -- Run migrations command to address migration warnings
      pcall(vim.cmd, "Neotree migrations")
    end, 1000)
    
    -- Refresh git status when lazygit is closed
    vim.api.nvim_create_autocmd("TermClose", {
      pattern = "*lazygit",
      callback = function()
        if package.loaded["neo-tree.sources.git_status"] then
          require("neo-tree.sources.git_status").refresh()
        end
      end,
    })
    
    -- Create custom commands for stack-specific operations
    vim.api.nvim_create_user_command("NeotreeGOTH", function()
      -- Filter to show only Go/Templ files
      require("neo-tree.command").execute({
        action = "show",
        source = "filesystem",
        toggle = true,
        dir = vim.loop.cwd(),
        find_file = vim.api.nvim_buf_get_name(0),
        position = "left",
      })
    end, { desc = "Open Neo-tree with GOTH focus" })
    
    vim.api.nvim_create_user_command("NeotreeNextJS", function()
      -- Filter to show only Next.js related files
      require("neo-tree.command").execute({
        action = "show",
        source = "filesystem",
        toggle = true,
        dir = vim.loop.cwd(),
        find_file = vim.api.nvim_buf_get_name(0),
        position = "left",
      })
    end, { desc = "Open Neo-tree with Next.js focus" })
  end,
}
