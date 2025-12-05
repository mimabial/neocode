-- Terminal color sync module
-- Syncs Neovim background/foreground to terminals using OSC escape sequences
local M = {}
local colors_lib = require("lib.colors")

-- Send OSC escape sequence to terminal
-- Wraps in tmux passthrough if running inside tmux
local function send_osc(code, value)
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
end

-- Sync colors to terminal
function M.sync_terminals()
  local colors = colors_lib.extract_basic()

  -- Debug logging
  local log = io.open("/tmp/terminal-sync-debug.log", "a")
  if log then
    log:write(os.date("%Y-%m-%d %H:%M:%S") .. " - Syncing terminal colors\n")
    log:write("  FG: " .. colors.fg .. "\n")
    log:write("  BG: " .. colors.bg .. "\n")
    log:close()
  end

  -- OSC 10: Set foreground color
  send_osc(10, colors.fg)

  -- OSC 11: Set background color
  send_osc(11, colors.bg)
end

-- Reset terminal colors to defaults
function M.reset_terminals()
  -- OSC 110: Reset foreground
  send_osc(110, "")
  -- OSC 111: Reset background
  send_osc(111, "")
end

-- Setup autocommands for terminal sync
function M.setup()
  local group = vim.api.nvim_create_augroup("TerminalSync", { clear = true })

  -- Sync on VimEnter (when Neovim starts)
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      -- Small delay to ensure colorscheme is loaded
      vim.defer_fn(M.sync_terminals, 100)
    end,
    desc = "Sync terminal colors on Neovim startup",
  })

  -- Sync on colorscheme change
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = M.sync_terminals,
    desc = "Sync terminal colors with Neovim colorscheme",
  })

  -- Sync on FocusGained (when switching back to Neovim from another split/program)
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
    M.sync_terminals()
    vim.notify("Terminal colors synced", vim.log.levels.INFO)
  end, { desc = "Sync terminal colors with Neovim colorscheme" })

  vim.api.nvim_create_user_command("TerminalReset", function()
    M.reset_terminals()
    vim.notify("Terminal colors reset", vim.log.levels.INFO)
  end, { desc = "Reset terminal colors to defaults" })
end

return M
