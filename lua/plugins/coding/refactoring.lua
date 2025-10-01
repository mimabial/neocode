return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Spectre",
  keys = {
    {
      "<leader>sR",
      function()
        require("spectre").toggle()
      end,
      desc = "Search and Replace (Spectre)",
    },
    {
      "<leader>sr",
      function()
        require("spectre").open_file_search()
      end,
      desc = "Search and Replace (Current File)",
    },
    {
      "<leader>sw",
      function()
        require("spectre").open_visual({ select_word = true })
      end,
      desc = "Search Word Under Cursor",
    },
    {
      "<leader>sW",
      function()
        require("spectre").open_visual()
      end,
      mode = "v",
      desc = "Search Selection",
    },
  },
  opts = {
    open_cmd = "noswapfile vnew",
    live_update = false,
    line_sep_start = "┌─────────────────────────────────────────",
    result_padding = "│  ",
    line_sep = "└─────────────────────────────────────────",
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
        cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
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
    },
  },
  config = function(_, opts)
    require("spectre").setup(opts)

    -- Convert to floating window after opening
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "spectre_panel",
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local split_win = vim.api.nvim_get_current_win()

        -- Close the split
        vim.api.nvim_win_close(split_win, false)

        local top_spacing = math.floor(vim.o.lines * 0.00)     -- 0%
        local bottom_spacing = math.floor(vim.o.lines * 0.04)  -- 4%
        local left_spacing = math.floor(vim.o.columns * 0.02)  -- 2%
        local right_spacing = math.floor(vim.o.columns * 0.02) -- 2%

        local available_height = vim.o.lines - top_spacing - bottom_spacing
        local available_width = vim.o.columns - left_spacing - right_spacing

        local width = math.min(math.floor(vim.o.columns * 0.5), available_width)
        local height = math.min(math.floor(vim.o.lines * 0.9), available_height)

        vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          col = vim.o.columns - width - right_spacing,
          row = top_spacing,
          border = "single",
          style = "minimal",
        })
      end,
    })
  end,
}
