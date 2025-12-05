return {
  "knubie/vim-kitty-navigator",
  -- Only load when in kitty and NOT in tmux
  enabled = vim.env.TERM == "xterm-kitty" and vim.env.TMUX == nil,
  build = "cp ./*.py ~/.config/kitty/",
  -- Note: This plugin automatically maps <C-h/j/k/l> for kitty integration
}
