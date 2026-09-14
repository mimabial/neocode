return {
  "knubie/vim-kitty-navigator",
  lazy = false,
  enabled = vim.env.TERM == "xterm-kitty" and vim.env.TMUX == nil,
}
