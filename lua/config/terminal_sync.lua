-- Sync Neovim background/foreground to the host terminal via OSC sequences.
-- Wraps in tmux passthrough when inside tmux.

local M = {}

local OSC_FOREGROUND = 10
local OSC_BACKGROUND = 11
local OSC_CURSOR = 12
local OSC_KITTY_COLORS = 21
local OSC_RESET_OFFSET = 100

local function has_terminal_ui()
  for _, ui in ipairs(vim.api.nvim_list_uis()) do
    if ui.stdout_tty then
      return true
    end
  end
  return false
end

local function send_osc(code, value)
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
end

local function foot_colors()
  local term = vim.env.TERM
  if vim.env.TMUX then
    term = vim.fn.systemlist({ "tmux", "display-message", "-p", "#{client_termname}" })[1]
  end
  if term ~= "foot" then
    return {}
  end

  local file = io.open((vim.env.XDG_CACHE_HOME or vim.env.HOME .. "/.cache") .. "/hypr/render/foot/colors.ini", "r")
  if not file then
    return {}
  end
  local colors, active = {}, false
  for line in file:lines() do
    if line:sub(1, 1) == "[" then
      active = line == "[colors-dark]"
    elseif active then
      local name, value = line:match("^(%S+)=(.+)$")
      if name then colors[name] = value end
    end
  end
  file:close()
  return colors
end

local function set_or_reset_color(code, hex)
  if hex then
    send_osc(code, "#" .. hex)
  else
    send_osc(code + OSC_RESET_OFFSET, "")
  end
end

local function set_or_reset_cursor_text(hex)
  send_osc(OSC_KITTY_COLORS, "cursor_text=" .. (hex and "#" .. hex or ""))
end

local function hex_from_rgb(rgb)
  return rgb and string.format("%06x", rgb)
end

local function restore_color(code, color)
  set_or_reset_color(code, color and color:match("^%x%x%x%x%x%x$"))
end

function M.sync_terminals()
  if not has_terminal_ui() then
    return false
  end
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  set_or_reset_color(OSC_FOREGROUND, hex_from_rgb(normal.fg))
  set_or_reset_color(OSC_BACKGROUND, hex_from_rgb(normal.bg))
  local cursor = vim.api.nvim_get_hl(0, { name = "Cursor", link = false })
  set_or_reset_cursor_text(hex_from_rgb(cursor.fg))
  return true
end

function M.reset_terminals()
  if not has_terminal_ui() then
    return false
  end
  local colors = foot_colors()
  local cursor_text, cursor = (colors.cursor or ""):match("^(%x%x%x%x%x%x)%s+(%x%x%x%x%x%x)$")
  restore_color(OSC_FOREGROUND, colors.foreground)
  restore_color(OSC_BACKGROUND, colors.background)
  restore_color(OSC_CURSOR, cursor)
  set_or_reset_cursor_text(cursor_text)
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
