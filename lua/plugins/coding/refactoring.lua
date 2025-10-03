return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Spectre",
  keys = {
    {
      "<leader>sr",
      function()
        require("spectre").open_file_search()
      end,
      desc = "Search and Replace (Current File)",
    },
    {
      "<leader>sR",
      function()
        require("spectre").toggle()
      end,
      desc = "Search and Replace (Project)",
    },
    {
      "<leader>sw",
      function()
        require("spectre").open_file_search({ select_word = true })
      end,
      desc = "Search Word (Current File)",
    },
    {
      "<leader>sW",
      function()
        require("spectre").open_visual({ select_word = true })
      end,
      desc = "Search Word (Project)",
    },
  },
  opts = {
    open_cmd = "vnew",
    live_update = true,
    line_sep_start = "┌─",
    result_padding = "│  ",
    line_sep = "└─",
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
        cmd = "<cmd>lua require('spectre').open_file_search()<CR>",
        desc = "open file",
      },
      ["send_to_qf"] = {
        map = "<leader>q",
        cmd = "<cmd>lua require('spectre').send_to_qf()<CR>",
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
  },
  config = function(_, opts)
    local spectre = require("spectre")
    spectre.setup(opts)

    -- Global function for replace + refresh
    _G.spectre_replace_and_refresh = function()
      require('spectre.actions').run_replace()
      vim.defer_fn(function()
        require('spectre').resume_last_search()
      end, 100)
    end

    -- Store reference to original window state
    local state_module = require("spectre.state")
    local original_set_state = state_module.set_state

    -- Override set_state to track the window
    state_module.set_state = function(new_state)
      original_set_state(new_state)

      -- After state is set, check if we need to float the window
      vim.schedule(function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].filetype == "spectre_panel" then
          local current_win = vim.api.nvim_get_current_win()

          -- Check if it's not already floating
          local win_config = vim.api.nvim_win_get_config(current_win)
          if win_config.relative == "" then
            -- It's a split window, convert to floating

            local top_spacing = math.floor(vim.o.lines * 0.00)
            local bottom_spacing = math.floor(vim.o.lines * 0.04)
            local left_spacing = math.floor(vim.o.columns * 0.02)
            local right_spacing = math.floor(vim.o.columns * 0.02)

            local available_height = vim.o.lines - top_spacing - bottom_spacing
            local available_width = vim.o.columns - left_spacing - right_spacing

            local width = math.min(math.floor(vim.o.columns * 0.5), available_width)
            local height = math.min(math.floor(vim.o.lines * 0.9), available_height)

            -- Convert current window to floating instead of creating new one
            vim.api.nvim_win_set_config(current_win, {
              relative = "editor",
              width = width,
              height = height,
              col = vim.o.columns - width - right_spacing,
              row = top_spacing,
              border = "single",
              style = "minimal",
            })
          end
        end
      end)
    end
  end,
}
