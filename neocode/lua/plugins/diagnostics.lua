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
    icons = true,
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
    signs = { error = "", warning = "", hint = "", information = "" },
    use_diagnostic_signs = false,
  },

  -- Explicit config to ensure setup(opts)
  config = function(_, opts)
    require("trouble").setup(opts)
  end,

  -- Keybindings
  keys = {
    { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics" },
    { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
    { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List" },
    { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List" },
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
