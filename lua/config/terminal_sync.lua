-- Sync Neovim background/foreground to the host terminal via OSC sequences.
-- Wraps in tmux passthrough when inside tmux.

local M = {}

local function has_terminal_ui()
  for _, ui in ipairs(vim.api.nvim_list_uis()) do
    if ui.stdout_tty then
      return true
    end
  end
  return false
end

local function send_osc(code, value)
  if not has_terminal_ui() then
    return false
  end

  -- Kitty needs ST; everything else accepts BEL.
  local terminator = "\007"
  if vim.env.TERM == "xterm-kitty" or vim.env.KITTY_WINDOW_ID then
    terminator = "\027\\"
  end

  local osc = string.format("\027]%s;%s%s", code, value, terminator)
  if os.getenv("TMUX") then
    osc = string.format("\027Ptmux;\027%s\027\\", osc:gsub("\027", "\027\027"))
  end

  vim.api.nvim_chan_send(2, osc)
  return true
end

function M.sync_terminals()
  if not has_terminal_ui() then
    return false
  end
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  if normal.fg then
    send_osc(10, string.format("#%06x", normal.fg))
  else
    send_osc(110, "")
  end
  if normal.bg then
    send_osc(11, string.format("#%06x", normal.bg))
  else
    send_osc(111, "")
  end
  local cursor = vim.api.nvim_get_hl(0, { name = "Cursor", link = false })
  if cursor.fg then
    send_osc(21, string.format("cursor_text=#%06x", cursor.fg))
  else
    send_osc(21, "cursor_text=")
  end
  return true
end

function M.reset_terminals()
  if not has_terminal_ui() then
    return false
  end
  send_osc(110, "")
  send_osc(111, "")
  send_osc(112, "")
  send_osc(21, "cursor_text=")
  return true
end

function M.setup()
  local group = vim.api.nvim_create_augroup("TerminalSync", { clear = true })

  vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
    group = group,
    callback = function()
      vim.schedule(M.sync_terminals)
    end,
    desc = "Sync terminal colors on startup and colorscheme change",
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = M.reset_terminals,
    desc = "Reset terminal colors on Neovim exit",
  })

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
