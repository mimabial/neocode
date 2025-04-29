return {
  "stevearc/oil.nvim",
  priority = 100, -- Higher priority to ensure it loads early
  opts = {
    -- Oil will take over directory buffers (like `:e .` or `:e $PWD`)
    default_file_explorer = true,
    -- Id is automatically added at the beginning, and name at the end
    -- See :help oil-columns
    columns = {
      "icon",
      "size",
      "permissions",
      "mtime",
    },
    -- Buffer-local options to use for oil buffers
    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },
    -- Window-local options to use for oil buffers
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
    -- Send deleted files to trash instead of permanently deleting them
    delete_to_trash = true,
    -- Skip the confirmation popup for simple operations
    skip_confirm_for_simple_edits = true,
    -- Oil will automatically watch for external changes in the directory
    auto_refresh = true,
    -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap options with a `callback` key
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-h>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
    -- Set to false to disable all of the above keymaps
    use_default_keymaps = true,
    view_options = {
      -- Show files and directories that start with "."
      show_hidden = true,
      -- This function defines what is considered a "hidden" file
      is_hidden_file = function(name, bufnr)
        -- Common patterns for hidden files
        return vim.startswith(name, ".") or 
               name == "node_modules" or
               name == "vendor" or
               name == "dist" or
               name == ".next" or
               name == "build"
      end,
      -- This function defines what will never be shown, even when `show_hidden` is set
      is_always_hidden = function(name, bufnr)
        return name == ".git" or name == ".DS_Store"
      end,
    },
    -- Configuration for the floating window in oil.open_float
    float = {
      -- Padding around the floating window
      padding = 2,
      max_width = 80,
      max_height = 30,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
      -- This is the config that will be passed to nvim_open_win.
      -- Override any of the values with your own configuration.
      override = function(conf)
        return conf
      end,
    },
    -- Configuration for the actions floating preview window
    preview = {
      -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- min_width and max_width can be a single value or a list of mixed integer/float types.
      -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
      max_width = 0.9,
      -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
      min_width = { 40, 0.4 },
      -- optionally define an integer/float for the exact width of the preview window
      width = nil,
      -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- min_height and max_height can be a single value or a list of mixed integer/float types.
      -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
      max_height = 0.9,
      -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
      min_height = { 5, 0.1 },
      -- optionally define an integer/float for the exact height of the preview window
      height = nil,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
    },
    -- Configuration for the floating progress window
    progress = {
      max_width = 0.9,
      min_width = { 40, 0.4 },
      width = nil,
      max_height = { 10, 0.9 },
      min_height = { 5, 0.1 },
      height = nil,
      border = "rounded",
      minimized_border = "none",
      win_options = {
        winblend = 0,
      },
    },
  },
  -- Optional dependencies
  dependencies = { { "nvim-tree/nvim-web-devicons", lazy = true } },
  lazy = false,
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    { "_", "<CMD>Oil .<CR>", desc = "Open project root directory" },
    { "<leader>e", "<CMD>Oil<CR>", desc = "Open parent directory with Oil" },
    { "<leader>E", "<CMD>Oil --float<CR>", desc = "Open parent directory in float" },
  },
  config = function(_, opts)
    -- Get colors from Gruvbox Material palette for better styling
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        local green_color = vim.api.nvim_get_hl(0, { name = "GruvboxGreen" }).fg or "#89b482"
        local aqua_color = vim.api.nvim_get_hl(0, { name = "GruvboxAqua" }).fg or "#7daea3"
        local yellow_color = vim.api.nvim_get_hl(0, { name = "GruvboxYellow" }).fg or "#d8a657"
        
        -- Enhance Oil highlights for better integration with Gruvbox Material
        vim.api.nvim_set_hl(0, "OilDir", { fg = aqua_color, bold = true })
        vim.api.nvim_set_hl(0, "OilLink", { fg = green_color, underline = true })
        vim.api.nvim_set_hl(0, "OilFile", { fg = yellow_color })
        vim.api.nvim_set_hl(0, "OilCreate", { fg = green_color, bold = true })
        vim.api.nvim_set_hl(0, "OilDelete", { fg = "#ea6962", bold = true })
        vim.api.nvim_set_hl(0, "OilMove", { fg = "#d3869b", bold = true })
        vim.api.nvim_set_hl(0, "OilCopy", { fg = "#7daea3", bold = true })
        vim.api.nvim_set_hl(0, "OilChange", { fg = "#d8a657", bold = true })
      end,
    })

    require("oil").setup(opts)
    
    -- Add stack-specific configurations
    if vim.g.current_stack == "goth" then
      -- Custom filter for GOTH stack
      local goth_filter = function(name, bufnr)
        return vim.startswith(name, ".") or 
              name == "node_modules" or
              name == "vendor" or
              name == "bin" or
              name == "dist" or
              name == "build"
      end
      
      -- Apply GOTH-specific configuration
      require("oil").setup({
        view_options = {
          is_hidden_file = goth_filter,
        },
      })
    elseif vim.g.current_stack == "nextjs" then
      -- Custom filter for Next.js stack
      local nextjs_filter = function(name, bufnr)
        return vim.startswith(name, ".") or 
              name == "node_modules" or
              name == ".next" or
              name == "out" or
              name == ".turbo" or
              name == ".vercel"
      end
      
      -- Apply Next.js-specific configuration
      require("oil").setup({
        view_options = {
          is_hidden_file = nextjs_filter,
        },
      })
    end
  end,
}

