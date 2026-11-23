return {
  "christoomey/vim-tmux-navigator",
  -- Only load when inside tmux
  enabled = vim.env.TMUX ~= nil,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>",  "<cmd>TmuxNavigateLeft<cr>" },
    { "<c-j>",  "<cmd>TmuxNavigateDown<cr>" },
    { "<c-k>",  "<cmd>TmuxNavigateUp<cr>" },
    { "<c-l>",  "<cmd>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
    { "<c-;>",  "<cmd>TmuxNavigatePrevious<cr>" },
  },
}
