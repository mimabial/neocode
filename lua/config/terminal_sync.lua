-- Terminal color sync module
-- Syncs Neovim background/foreground to terminals using OSC escape sequences
local M = {}
local colors_lib = require("lib.colors")

local function has_terminal_ui()
  for _, ui in ipairs(vim.api.nvim_list_uis()) do
    if ui.stdout_tty then
      return true
    end
  end

  return false
end

-- Send OSC escape sequence to terminal
-- Wraps in tmux passthrough if running inside tmux
local function send_osc(code, value)
  if not has_terminal_ui() then
    return false
  end

  -- Kitty prefers ST terminator, most others use BEL
  local terminator = "\007"  -- BEL
  if vim.env.TERM == "xterm-kitty" or vim.env.KITTY_WINDOW_ID then
    terminator = "\027\\"  -- ST (String Terminator)
  end

  local osc = string.format("\027]%s;%s%s", code, value, terminator)

  -- If inside tmux, wrap in passthrough sequence
  if os.getenv("TMUX") then
    osc = string.format("\027Ptmux;\027%s\027\\", osc:gsub("\027", "\027\027"))
  end

  -- Use vim.api.nvim_chan_send to send directly to terminal
  -- Channel 2 is stderr which goes to the terminal
  vim.api.nvim_chan_send(2, osc)
  return true
end

-- Sync colors to terminal
function M.sync_terminals()
  if not has_terminal_ui() then
    return false
  end

  local colors = colors_lib.extract_basic()

  -- OSC 10: Set foreground color
  send_osc(10, colors.fg)

  -- OSC 11: Set background color
  send_osc(11, colors.bg)
  return true
end

-- Reset terminal colors to defaults
function M.reset_terminals()
  if not has_terminal_ui() then
    return false
  end

  -- OSC 110: Reset foreground
  send_osc(110, "")
  -- OSC 111: Reset background
  send_osc(111, "")
  return true
end

-- Setup autocommands for terminal sync
function M.setup()
  local group = vim.api.nvim_create_augroup("TerminalSync", { clear = true })

  -- Explicit theme application owns sync timing.
  -- FocusGained stays as a repair path if another program resets terminal colors.
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = M.sync_terminals,
    desc = "Sync terminal colors when Neovim gains focus",
  })

  -- Reset colors on VimLeave (when Neovim exits completely)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = M.reset_terminals,
    desc = "Reset terminal colors on Neovim exit",
  })

  -- User commands
  vim.api.nvim_create_user_command("TerminalSync", function()
    if M.sync_terminals() then
      vim.notify("Terminal colors synced", vim.log.levels.INFO)
    else
      vim.notify("Terminal sync is only available in terminal UI sessions", vim.log.levels.WARN)
    end
  end, { desc = "Sync terminal colors with Neovim colorscheme" })

  vim.api.nvim_create_user_command("TerminalReset", function()
    if M.reset_terminals() then
      vim.notify("Terminal colors reset", vim.log.levels.INFO)
    else
      vim.notify("Terminal reset is only available in terminal UI sessions", vim.log.levels.WARN)
    end
  end, { desc = "Reset terminal colors to defaults" })
end

return M
