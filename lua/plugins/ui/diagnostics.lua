return {
  "folke/trouble.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  opts = {
    auto_close = false,
    auto_preview = true,
    focus = true,
    win = {
      position = "bottom",
      size = { height = 10 },
      border = "single",
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
          trou.prev({ skip_groups = true, jump = true })
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
