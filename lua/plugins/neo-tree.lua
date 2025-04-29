return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- Make sure this loads first
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
    { "<leader>be", "<cmd>Neotree buffers reveal float<cr>",          desc = "Buffer explorer" },
    { "<leader>ge", "<cmd>Neotree git_status reveal float<cr>",       desc = "Git status explorer" },
    { "<leader>se", "<cmd>Neotree document_symbols reveal float<cr>", desc = "Symbols Explorer" },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  init = function()
    -- Do not auto-open Neo-tree at startup, even for directories
    vim.g.neo_tree_remove_legacy_commands = 1
  end,
  opts = {
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    open_files_do_not_replace_types = { "terminal", "trouble", "qf", "edgy" },
    close_if_last_window = true, -- Close Neo-tree if it is the last window left
    popup_border_style = "",
    enable_git_status = true,
    enable_diagnostics = true,
    hide_root_node = true,
    retain_hidden_root_indent = true,
    show_scrolled_off_parent_node = true,
    sort_case_insensitive = true,

    source_selector = {
      winbar = true,
      content_layout = "center",
      sources = {
        { source = "filesystem",       display_name = " Files" },
        { source = "buffers",          display_name = " Buffers" },
        { source = "git_status",       display_name = " Git" },
        { source = "document_symbols", display_name = " Symbols" },
      },
      separator = { left = "", right = "" },
    },

    default_component_configs = {
      container = {
        enable_character_fade = true,
        width = "100%",
        right_padding = 0,
      },
      indent = {
        indent_size = 2,
        padding = 1,
        -- indent guides
        with_markers = true,
        indent_marker = "│",
        last_indent_marker = "└",

        -- expander config, needed for nesting files
        with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = "",
        expander_expanded = "",

      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "󰉖",
        folder_empty_open = "󰷏",
        -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
        -- then these will never be used.
        default = "",

      },
      modified = {
        symbol = "",
      },
      git_status = {
        symbols = {
          -- Change type
          added     = "✚", -- NOTE: you can set any of these to an empty string to not show them
          deleted   = "✖",
          modified  = "",
          renamed   = "󰁕",
          -- Status type
          untracked = "",
          ignored   = "",
          unstaged  = "󰄱",
          staged    = "",
          conflict  = "",
        },
        align = "right",
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
        never_show_by_pattern = {},
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
              messages[#messages + 1] = { ("%s."):format(i), "Identifier" }
              messages[#messages + 1] = { (" %s: "):format(result.msg), "Normal" }
              messages[#messages + 1] = { result.val, "String" }
              messages[#messages + 1] = { "\n", "Normal" }
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
        event = "neo_tree_popup_input_ready",
        ---@param args { bufnr: integer, winid: integer }
        handler = function(args)
          vim.cmd("stopinsert")
          vim.keymap.set("i", "<esc>", vim.cmd.stopinsert, { noremap = true, buffer = args.bufnr })
        end,
      },
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
      },
      -- Handle Neo-tree close if it is the last window
      {
        event = "neo_tree_window_after_open",
        handler = function(args)
          -- Check if Neo-tree is the only window
          if #vim.api.nvim_list_wins() == 1 then
            local buftype = vim.bo[vim.api.nvim_win_get_buf(0)].filetype
            if buftype == "neo-tree" then
              -- Close Neo-tree if it's the only window left
              vim.defer_fn(function()
                if #vim.api.nvim_list_wins() == 1 and vim.bo[vim.api.nvim_win_get_buf(0)].filetype == "neo-tree" then
                  vim.cmd("quit")
                end
              end, 0)
            end
          end
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
            { "name",           zindex = 10 },
            { "symlink_target", zindex = 10,        highlight = "NeoTreeSymlinkTarget" },
            { "clipboard",      zindex = 10 },
            { "diagnostics",    errors_only = true, zindex = 20,                       align = "right",          hide_when_expanded = true },
            { "git_status",     zindex = 20,        align = "right",                   hide_when_expanded = true },
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
            { "clipboard",      zindex = 10 },
            { "bufnr",          zindex = 10 },
            { "modified",       zindex = 20, align = "right" },
            { "diagnostics",    zindex = 20, align = "right" },
            { "git_status",     zindex = 20, align = "right" },
          },
        },
      },
    },
  },
  config = function(_, opts)
    -- Setup custom highlights for better appearance
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        -- Create highlight groups based on the colorscheme
        local bg_color = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
        local fg_color = vim.api.nvim_get_hl(0, { name = "Normal" }).fg

        -- Get colors from Gruvbox Material or fallback
        local green_color = vim.api.nvim_get_hl(0, { name = "GruvboxGreen" }).fg or "#89b482"
        local aqua_color = vim.api.nvim_get_hl(0, { name = "GruvboxAqua" }).fg or "#7daea3"
        local red_color = vim.api.nvim_get_hl(0, { name = "GruvboxRed" }).fg or "#ea6962"
        local yellow_color = vim.api.nvim_get_hl(0, { name = "GruvboxYellow" }).fg or "#d8a657"
        local orange_color = vim.api.nvim_get_hl(0, { name = "GruvboxOrange" }).fg or "#e78a4e"
        local blue_color = vim.api.nvim_get_hl(0, { name = "GruvboxBlue" }).fg or "#7daea3"

        -- Enhanced highlight groups for Neo-tree
        vim.api.nvim_set_hl(0, "NeoTreeRootName", { fg = blue_color, bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = aqua_color })
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = aqua_color, bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeFileIcon", { fg = yellow_color })
        vim.api.nvim_set_hl(0, "NeoTreeFileName", { fg = fg_color })
        vim.api.nvim_set_hl(0, "NeoTreeFileNameOpened", { fg = green_color, bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { fg = "#504945" })
        vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { fg = yellow_color, bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeTitleBar", { fg = yellow_color, bg = "#3c3836", bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = green_color })
        vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = yellow_color })
        vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = red_color })
        vim.api.nvim_set_hl(0, "NeoTreeGitConflict", { fg = red_color, bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = orange_color, italic = true })
        vim.api.nvim_set_hl(0, "NeoTreeIndentMarker", { fg = "#504945" })
        vim.api.nvim_set_hl(0, "NeoTreeExpander", { fg = "#7c6f64" })
        vim.api.nvim_set_hl(0, "NeoTreeSymbolicLinkTarget", { fg = yellow_color, italic = true })
        vim.api.nvim_set_hl(0, "NeoTreeTabActive", { bg = "#32302f", fg = fg_color, bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeTabInactive", { bg = "#282828", fg = "#a89984" })
        vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorActive", { bg = "#32302f", fg = "#665c54" })
        vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorInactive", { bg = "#282828", fg = "#665c54" })
        vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = "#3c3836" })
        vim.api.nvim_set_hl(0, "NeoTreeDimText", { fg = "#665c54" })
      end,
    })

    -- Better filtering for Go projects
    if not opts.filesystem.filtered_items then
      opts.filesystem.filtered_items = {}
    end

    -- Add common Go-related ignore patterns
    opts.filesystem.filtered_items.never_show = vim.list_extend(
      opts.filesystem.filtered_items.never_show or {},
      {
        ".git",
        "go.sum", -- Generally don't need to edit go.sum directly
        "vendor", -- Vendor directory is generally not edited directly
        "bin",    -- Compiled binaries
      }
    )

    -- Setup Neo-tree
    require("neo-tree").setup(opts)

    -- Add autocommand to check if Neo-tree is the last window and close it
    vim.api.nvim_create_autocmd("WinEnter", {
      callback = function()
        if #vim.api.nvim_list_wins() == 1 then
          local bufnr = vim.api.nvim_get_current_buf()
          if vim.bo[bufnr].filetype == "neo-tree" then
            vim.cmd("quit")
          end
        end
      end
    })

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

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        -- Get background color from your theme's Normal highlight group
        local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg

        -- Apply it to Neo-tree
        vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = normal_bg })
        vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = normal_bg })

        -- For other Neo-tree elements that need the same background
        vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = normal_bg })
        vim.api.nvim_set_hl(0, "NeoTreeRootName", { bg = normal_bg, bold = true })
      end,
    })
  end,
}
