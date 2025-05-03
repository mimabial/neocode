-- lua/plugins/oil.lua
-- Plugin specification for Oil.nvim file explorer with stack-specific integration
return {
  "stevearc/oil.nvim",
  lazy = false,
  priority = 900,
  dependencies = { "nvim-tree/nvim-web-devicons" },

  opts = {
    default_file_explorer = true,
    use_default_keymaps = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = true,
    cleanup_delay_ms = 2000,
    lsp_file_methods = { autosave_changes = true },

    columns = { "size", "permissions" },
    buf_options = { buflisted = false, bufhidden = "hide" },
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

    view_options = {
      show_hidden = false,
      is_hidden_file = function(name)
        return vim.startswith(name, ".")
      end,
      is_always_hidden = function()
        return false
      end,
    },

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

    float = { padding = 2, border = "rounded", max_width = 0, max_height = 0, win_options = { winblend = 0 } },
    preview = { border = "rounded", win_options = { winblend = 0 } },
    progress = { border = "rounded", win_options = { winblend = 0 } },
  },

  config = function(_, opts)
    local oil = require("oil")
    oil.setup(opts)

    -- Stack-specific Oil commands
    local function make_cmd(name)
      vim.api.nvim_create_user_command(name, function()
        local stack = name:sub(4):lower()
        vim.g.current_stack = stack
        oil.open()
        vim.notify("Oil focused on " .. stack:upper() .. " stack", vim.log.levels.INFO)
      end, { desc = "Oil explorer: " .. name:sub(4) .. " stack" })
    end
    make_cmd("OilGOTH")
    make_cmd("OilNEXTJS")

    -- Adjust view and highlights when opening Oil buffer
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      desc = "Oil buffer customizations",
      callback = function()
        local stack = vim.g.current_stack or ""
        -- update view_options per stack
        local view_opts = {
          show_hidden = true,
          is_hidden_file = function(name)
            if stack == "goth" then
              return vim.startswith(name, ".") or name == "vendor" or name == "node_modules" or name == "go.sum"
            elseif stack == "nextjs" then
              return vim.startswith(name, ".")
                or vim.tbl_contains({ "node_modules", ".next", ".turbo", "out", ".vercel" }, name)
            end
            return false
          end,
        }
        oil.setup({ view_options = view_opts })

        -- window settings
        vim.wo.number = false
        vim.wo.relativenumber = true
        vim.wo.cursorline = true

        -- Close mapping
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true, desc = "Close Oil" })

        -- Theme-specific highlights
        if vim.g.colors_name == "gruvbox-material" then
          local hl = vim.api.nvim_set_hl
          hl(0, "OilDir", { fg = "#7daea3", bold = true })
          hl(0, "OilDirIcon", { fg = "#7daea3", bold = true })
          hl(0, "OilLink", { fg = "#89b482", underline = true })
          hl(0, "OilFile", { fg = "#d4be98" })
          hl(0, "OilTypeDir", { link = "OilDir" })
          hl(0, "OilTypeFile", { link = "OilFile" })
          hl(0, "OilTypeSymlink", { link = "OilLink" })
          hl(0, "OilColumn", { link = "Comment" })
        end
      end,
    })
  end,
}
