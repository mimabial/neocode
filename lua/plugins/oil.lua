-- Plugin spec for Oil.nvim explorer
return {
  "stevearc/oil.nvim",
  lazy = false, -- Ensure it's loaded immediately
  priority = 900, -- Very high priority
  dependencies = { "nvim-tree/nvim-web-devicons" },

  opts = {
    default_file_explorer = true,
    use_default_keymaps = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = true,
    cleanup_delay_ms = 2000,
    lsp_file_methods = {
      autosave_changes = true,
    },

    columns = {
      "size",
      "permissions",
      -- "mtime",
      -- "icon",
    },

    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },

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

    -- Add your keymaps with oil-specific actions
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

    view_options = {
      show_hidden = false,
      is_hidden_file = function(name, bufnr)
        return vim.startswith(name, ".")
      end,
      is_always_hidden = function(name, bufnr)
        return false
      end,
    },

    float = {
      padding = 2,
      max_width = 0,
      max_height = 0,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
    },

    preview = {
      max_width = 0.9,
      min_width = { 40, 0.4 },
      width = nil,
      max_height = 0.9,
      min_height = { 5, 0.1 },
      height = nil,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
    },

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

  config = function(_, opts)
    require("oil").setup(opts)

    -- Set up commands for stack-specific Oil views
    vim.api.nvim_create_user_command("OilGOTH", function()
      vim.g.current_stack = "goth"
      require("oil").open()
      vim.notify("Oil focused on GOTH stack", vim.log.levels.INFO)
    end, { desc = "Oil explorer: GOTH stack" })

    vim.api.nvim_create_user_command("OilNextJS", function()
      vim.g.current_stack = "nextjs"
      require("oil").open()
      vim.notify("Oil focused on Next.js stack", vim.log.levels.INFO)
    end, { desc = "Oil explorer: Next.js stack" })

    -- Stack-specific filters for Oil's view_options
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function()
        -- Get the current stack
        local stack = vim.g.current_stack

        if stack == "goth" then
          -- Apply GOTH stack specific filters
          require("oil").setup({
            view_options = {
              show_hidden = true,
              is_hidden_file = function(name, bufnr)
                return vim.startswith(name, ".") or name == "vendor" or name == "node_modules" or name == "go.sum"
              end,
            },
          })
        elseif stack == "nextjs" then
          -- Apply Next.js stack specific filters
          require("oil").setup({
            view_options = {
              show_hidden = true,
              is_hidden_file = function(name, bufnr)
                return vim.startswith(name, ".")
                  or name == "node_modules"
                  or name == ".next"
                  or name == ".turbo"
                  or name == "out"
                  or name == ".vercel"
              end,
            },
          })
        end
        -- Disable numbers in Oil
        vim.wo.number = false
        vim.wo.relativenumber = true

        -- Enable cursorline for better visibility
        vim.wo.cursorline = true

        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true, desc = "Close Oil" })

        if vim.g.colors_name == "gruvbox-material" then
          vim.api.nvim_set_hl(0, "OilDir", { fg = "#7daea3", bold = true })
          vim.api.nvim_set_hl(0, "OilDirIcon", { fg = "#7daea3", bold = true })
          vim.api.nvim_set_hl(0, "OilLink", { fg = "#89b482", underline = true })
          vim.api.nvim_set_hl(0, "OilFile", { fg = "#d4be98" })
          vim.api.nvim_set_hl(0, "OilTypeDir", { link = "OilDir" })
          vim.api.nvim_set_hl(0, "OilTypeFile", { link = "OilFile" })
          vim.api.nvim_set_hl(0, "OilTypeSymlink", { link = "OilLink" })
          vim.api.nvim_set_hl(0, "OilColumn", { link = "Comment" })
        end
      end,
    })
  end,
}
