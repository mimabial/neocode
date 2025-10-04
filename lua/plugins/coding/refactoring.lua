return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Spectre",
  keys = {
    {
      "<leader>sr",
      function()
        local disabled_fts = { "oil", "NvimTree", "Trouble", "lazy", "mason", "spectre_panel" }
        if vim.tbl_contains(disabled_fts, vim.bo.filetype) then return end
        require("spectre").open_file_search()
      end,
      desc = "Search and Replace (Current File)",
    },
    {
      "<leader>sR",
      function()
        local disabled_fts = { "oil", "NvimTree", "Trouble", "lazy", "mason", "spectre_panel" }
        if vim.tbl_contains(disabled_fts, vim.bo.filetype) then return end
        require("spectre").toggle()
      end,
      desc = "Search and Replace (Project)",
    },
    {
      "<leader>sw",
      function()
        local disabled_fts = { "oil", "NvimTree", "Trouble", "lazy", "mason", "spectre_panel" }
        if vim.tbl_contains(disabled_fts, vim.bo.filetype) then return end
        require("spectre").open_file_search({ select_word = true })
      end,
      desc = "Search Word (Current File)",
    },
    {
      "<leader>sW",
      function()
        local disabled_fts = { "oil", "NvimTree", "Trouble", "lazy", "mason", "spectre_panel" }
        if vim.tbl_contains(disabled_fts, vim.bo.filetype) then return end
        require("spectre").open_visual({ select_word = true })
      end,
      desc = "Search Word (Project)",
    },
  },
  opts = function()
    return {
      default = {
        find = {
          cmd = "rg",
          options = {}
        },
        replace = {
          cmd = "sed"
        }
      },

      -- Window size options
      is_open_target_win = true,
      is_insert_mode = false,

      open_cmd = function()
        local width = math.max(math.floor(vim.o.columns * 0.6), 80)
        return width .. 'vnew'
      end,

      color_devicons = true,
      live_update = false,
      lnum_for_results = true,
      line_sep_start = "┌────────────────────────────────────────", -- alt: ┌─
      result_padding = "│  ", -- alt: │
      line_sep = "└──────────────────────────────────────", -- alt: └─
      highlight = {
        ui = "String",
        search = "DiffChange",
        replace = "DiffDelete",
      },
      mapping = {
        ["toggle_line"] = {
          map = "dd",
          cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
          desc = "toggle item",
        },
        ["enter_file"] = {
          map = "<cr>",
          cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
          desc = "open file",
        },
        ["send_to_qf"] = {
          map = "<leader>q",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send to quickfix",
        },
        ["replace_cmd"] = {
          map = "<leader>c",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "replace command",
        },
        ["show_option_menu"] = {
          map = "<leader>o",
          cmd = "<cmd>lua require('spectre').show_options()<CR>",
          desc = "show options",
        },
        ["run_current_replace"] = {
          map = "<leader>rc",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
          desc = "replace current",
        },
        ["run_replace"] = {
          map = "<leader>R",
          cmd = "<cmd>lua _G.spectre_replace_and_refresh()<CR>",
          desc = "replace all",
        },
        ["change_view_mode"] = {
          map = "<leader>v",
          cmd = "<cmd>lua require('spectre').change_view()<CR>",
          desc = "change view mode",
        },
        ["change_replace_sed"] = {
          map = "trs",
          cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
          desc = "use sed",
        },
        ["change_replace_oxi"] = {
          map = "tro",
          cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
          desc = "use oxi",
        },
        ["toggle_live_update"] = {
          map = "tu",
          cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
          desc = "toggle live update",
        },
        ["toggle_ignore_case"] = {
          map = "ti",
          cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
          desc = "toggle ignore case",
        },
        ["toggle_ignore_hidden"] = {
          map = "th",
          cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
          desc = "toggle hidden",
        },
        ["resume_last_search"] = {
          map = "<leader>l",
          cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
          desc = "resume last search",
        },
        ["quit"] = {
          map = "q",
          cmd = "<cmd>close<CR>",
          desc = "quit",
        },
        ["escape"] = {
          map = "<ESC>",
          cmd = "<cmd>close<CR>",
          desc = "quit",
        },
      },
    }
  end,

  config = function(_, opts)
    require("spectre").setup(opts)

    -- Store original spectre window size
    local spectre_width = nil

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "spectre_panel",
      callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.cursorline = true

        -- Store original width on first open
        if not spectre_width then
          spectre_width = vim.api.nvim_win_get_width(0)
        end
      end,
    })

    -- Shrink spectre when leaving to file
    vim.api.nvim_create_autocmd("WinLeave", {
      pattern = "*",
      callback = function()
        if vim.bo.filetype == "spectre_panel" then
          vim.api.nvim_win_set_width(0, 30)
        end
      end,
    })

    -- Expand spectre when returning
    vim.api.nvim_create_autocmd("WinEnter", {
      pattern = "*",
      callback = function()
        if vim.bo.filetype == "spectre_panel" and spectre_width then
          vim.api.nvim_win_set_width(0, spectre_width)
        end
      end,
    })

    -- Ensure proper highlighting
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "spectre_panel",
      callback = function()
        vim.opt_local.signcolumn = "no"
        vim.opt_local.cursorline = true
      end,
    })
  end,
}
