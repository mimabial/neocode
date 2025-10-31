return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Spectre",
  keys = {
    {
      "<leader>sr",
      function()
        local disabled_fts = { "oil", "NvimTree", "Trouble", "lazy", "mason", "spectre_panel" }
        if vim.tbl_contains(disabled_fts, vim.bo.filetype) then
          return
        end
        require("spectre").open_file_search({
          path = vim.fn.expand("%:p"),
        })
      end,
      desc = "Search and Replace (Current File)",
    },
    {
      "<leader>sR",
      function()
        local disabled_fts = { "oil", "NvimTree", "Trouble", "lazy", "mason", "spectre_panel" }
        if vim.tbl_contains(disabled_fts, vim.bo.filetype) then
          return
        end
        require("spectre").toggle()
      end,
      desc = "Search and Replace (Project)",
    },
    {
      "<leader>sw",
      function()
        local disabled_fts = { "oil", "NvimTree", "Trouble", "lazy", "mason", "spectre_panel" }
        if vim.tbl_contains(disabled_fts, vim.bo.filetype) then
          return
        end
        require("spectre").open_file_search({
          select_word = true,
          path = vim.fn.expand("%:p"),
        })
      end,
      desc = "Search Word (Current File)",
    },
    {
      "<leader>sW",
      function()
        local disabled_fts = { "oil", "NvimTree", "Trouble", "lazy", "mason", "spectre_panel" }
        if vim.tbl_contains(disabled_fts, vim.bo.filetype) then
          return
        end
        require("spectre").open_visual({ select_word = true })
      end,
      desc = "Search Word (Project)",
    },
  },
  opts = function()
    return {
      -- Window size options
      is_open_target_win = true,
      is_insert_mode = false,

      open_cmd = function()
        vim.cmd("vnew")
        local width = vim.o.columns < 120 and vim.o.columns or math.min(math.floor(vim.o.columns * 0.5), 120)
        vim.cmd("vertical resize " .. width)
      end,
      live_update = true,
      mapping = {
        ["toggle_line"] = {
          map = "tt",
          cmd = "<cmd>lua require('spectre').toggle_line(); if not vim.fn.getline(vim.fn.line('.') + 1):find('└') then vim.cmd('normal! j') end<CR>",
          desc = "toggle item",
        },
        ["delete_line"] = {
          map = "dd",
          cmd = "<cmd>lua require('spectre.actions').run_current_delete()<CR>",
          desc = "delete current item",
        },
        ["leave_to_entry"] = {
          map = "<CR>",
          cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
          desc = "open file and jump to match",
        },
        ["go_to_entry"] = {
          map = "se",
          cmd = "<cmd>lua require('spectre.actions').select_entry(true)<CR>",
          desc = "open file and keep spectre open",
        },
        ["send_to_qf"] = {
          map = "<leader>qf",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all items to quickfix",
        },
        ["replace_cmd"] = {
          map = "<leader>rc",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "replace command",
        },
        ["run_current_replace"] = {
          map = "r",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace(); if not vim.fn.getline(vim.fn.line('.') + 1):find('└') then vim.cmd('normal! j') end<CR>",
          desc = "replace current",
        },
        ["run_replace"] = {
          map = "R",
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all",
        },
        ["quit"] = {
          map = "q",
          cmd = "<cmd>lua if #vim.api.nvim_list_wins() == 1 then vim.cmd('quit') else require('spectre').close() end<CR>",
          desc = "quit",
        },
        ["escape"] = {
          map = "<ESC>",
          cmd = "<cmd>lua if #vim.api.nvim_list_wins() == 1 then vim.cmd('quit') else require('spectre').close() end<CR>",
          desc = "quit",
        },
      },
      use_trouble_qf = true,
    }
  end,

  config = function(_, opts)
    require("spectre").setup(opts)

    -- Close Neovim if spectre is the last window
    vim.api.nvim_create_autocmd("WinClosed", {
      callback = function()
        -- Schedule to run after the window is actually closed
        vim.schedule(function()
          local wins = vim.api.nvim_list_wins()
          if #wins == 1 then
            local buf = vim.api.nvim_win_get_buf(wins[1])
            if vim.bo[buf].filetype == "spectre_panel" then
              vim.cmd("quit")
            end
          end
        end)
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "spectre_panel",
      callback = function(args)
        local bufnr = args.buf

        -- Store original width
        local original_width = vim.api.nvim_win_get_width(0)

        -- Window options
        vim.opt_local.number = false
        vim.opt_local.relativenumber = true
        vim.opt_local.signcolumn = "no"
        vim.opt_local.cursorline = true

        -- Buffer-local autocmds for window management
        vim.api.nvim_create_autocmd("WinLeave", {
          buffer = bufnr,
          callback = function()
            vim.api.nvim_win_set_width(0, 40)
          end,
        })

        vim.api.nvim_create_autocmd("WinEnter", {
          buffer = bufnr,
          callback = function()
            vim.api.nvim_win_set_width(0, original_width)
          end,
        })
      end,
    })
  end,
}
