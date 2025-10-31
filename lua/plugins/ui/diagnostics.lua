return {
  "folke/trouble.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  -- Pass options to setup
  opts = {
    position = "bottom",
    height = 10,
    width = 50,
    use_icons = true,
    mode = "workspace_diagnostics",
    fold_open = "v",
    fold_closed = ">",
    group = true,
    padding = true,
    action_keys = {
      close = "q",
      cancel = "<esc>",
      refresh = "r",
      jump = { "<cr>", "<tab>" },
      open_split = { "<c-x>" },
      open_vsplit = { "<c-v>" },
      open_tab = { "<c-t>" },
      jump_close = { "o" },
      toggle_mode = "m",
      toggle_preview = "P",
      hover = "K",
      preview = "p",
      close_folds = { "zM", "zm" },
      open_folds = { "zR", "zr" },
      toggle_fold = { "zA", "za" },
      previous = "k",
      next = "j",
    },
    indent_lines = true,
    auto_open = false,
    auto_close = false,
    auto_preview = true,
    auto_fold = false,
    auto_jump = { "lsp_definitions" },
    signs = { error = "", warning = "", hint = "", information = "" },
    use_diagnostic_signs = false,
    win_config = {
      border = "single",
      persist = false, -- Keep trouble window open
    },
  },
  config = function(_, opts)
    require("trouble").setup(opts)

    -- Store source window when opening trouble, restore on close
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "trouble",
      callback = function(args)
        local source_win = vim.fn.win_getid(vim.fn.winnr("#"))
        vim.api.nvim_create_autocmd("WinClosed", {
          buffer = args.buf,
          once = true,
          callback = function()
            vim.schedule(function()
              if vim.api.nvim_win_is_valid(source_win) then
                vim.api.nvim_set_current_win(source_win)
              end
            end)
          end,
        })
      end,
    })
  end,
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>cs",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>cl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    {
      "<leader>xl",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>xq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
    {
      "[q",
      function()
        local trou = require("trouble")
        if trou.is_open() then
          ---@diagnostic disable-next-line
          trou.previous({ skip_groups = true, jump = true })
        else
          vim.cmd.cprev()
        end
      end,
      desc = "Previous trouble/quickfix",
    },
    {
      "]q",
      function()
        local trou = require("trouble")
        if trou.is_open() then
          ---@diagnostic disable-next-line
          trou.next({ skip_groups = true, jump = true })
        else
          vim.cmd.cnext()
        end
      end,
      desc = "Next trouble/quickfix",
      silent = true,
    },
  },
}
