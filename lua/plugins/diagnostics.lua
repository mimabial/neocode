-- lua/plugins/trouble.lua
-- Plugin specification for trouble.nvim (Diagnostics list)
return {
  "folke/trouble.nvim",
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
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
      persist = true, -- Keep trouble window open
    },
  },

  -- Explicit config to ensure setup(opts)
  config = function(_, opts)
    require("trouble").setup(opts)

    -- Add autocmd to prevent trouble from auto-closing when focus is lost
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "Trouble",
      callback = function()
        -- Set buffer-local option to prevent closing
        vim.api.nvim_win_set_option(0, "winfixheight", true)
      end,
      desc = "Make Trouble window persist",
    })
  end,

  -- Keybindings
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
      "<leader>xL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>xQ",
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
    },
  },
}
