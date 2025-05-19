local M = {}
local api = vim.api
local fn = vim.fn
local uv = vim.loop
local fs = vim.fs

--- Safely require a module
---@param name string
---@return any? module or nil
function M.safe_require(name)
  local ok, mod = pcall(require, name)
  if not ok then
    api.nvim_notify(string.format("[Utils] Failed to load '%s': %s", name, mod), vim.log.levels.WARN, {})
    return nil
  end
  return mod
end

--- Determine project root via LSP or filesystem markers
---@return string
function M.get_root()
  local buf = api.nvim_get_current_buf()
  local name = api.nvim_buf_get_name(buf)
  local path = name ~= "" and uv.fs_realpath(name) or nil
  local root = uv.cwd()

  -- Try LSP workspace roots
  if path then
    local candidates = {}
    for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
      local ws = client.config.workspace_folders or {}
      for _, f in ipairs(ws) do
        local dir = vim.uri_to_fname(f.uri)
        local rp = uv.fs_realpath(dir)
        if rp and path:sub(1, #rp) == rp then
          table.insert(candidates, rp)
        end
      end
      if client.config.root_dir then
        local rd = uv.fs_realpath(client.config.root_dir)
        if rd and path:sub(1, #rd) == rd then
          table.insert(candidates, rd)
        end
      end
    end
    table.sort(candidates, function(a, b)
      return #a > #b
    end)
    if #candidates > 0 then
      return candidates[1]
    end
  end

  -- Fallback to filesystem markers
  local start = path and fs.dirname(path) or root
  local markers = { ".git", "go.mod", "package.json", "tsconfig.json", "Makefile" }
  local found = fs.find(markers, { path = start, upward = true })
  if found and #found > 0 then
    return fs.dirname(found[1])
  end

  return root
end

--- Get color from highlight group
---@param group string
---@param attr "fg"|"bg"
---@param fallback string
---@return string
function M.get_hl_color(group, attr, fallback)
  local ok, hl = pcall(api.nvim_get_hl, 0, { name = group })
  local val = ok and hl[attr]
  if not val then
    return fallback
  end
  if type(val) == "number" then
    return string.format("#%06x", val)
  end
  return tostring(val)
end

--- Shorten cwd for statusline
---@return string
function M.cwd()
  local cwd = fn.getcwd()
  local home = os.getenv("HOME") or ""
  if home ~= "" and cwd:sub(1, #home) == home then
    return "~" .. cwd:sub(#home + 1)
  end
  return fn.pathshorten(cwd)
end

--- Toggle or open terminal buffer
function M.toggle_term()
  local bufs = api.nvim_list_bufs()
  local terms = vim.tbl_filter(function(b)
    return vim.bo[b].buftype == "terminal"
  end, bufs)
  if #terms == 0 then
    api.nvim_command("terminal")
  else
    local cur = api.nvim_get_current_buf()
    if vim.bo[cur].buftype == "terminal" then
      api.nvim_command("b#")
    else
      api.nvim_command("buffer " .. terms[1])
    end
  end
end

--- Open floating terminal
---@param cmd string
---@param opts table?
function M.float_term(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    size = { w = 0.8, h = 0.8 },
    border = "rounded",
    on_create = function() end,
  }, opts or {})
  local Terminal = require("toggleterm.terminal").Terminal
  local t = Terminal:new({
    cmd = cmd,
    hidden = true,
    direction = "float",
    float_opts = {
      border = opts.border,
      width = math.floor(vim.o.columns * opts.size.w),
      height = math.floor(vim.o.lines * opts.size.h),
    },
    on_create = opts.on_create,
  })
  t:toggle()
end

--- Reload a Lua module
---@param name string
---@return any
function M.reload_module(name)
  package.loaded[name] = nil
  return require(name)
end

--- Debounce a function
---@param fnc function
---@param ms number
---@return function
function M.debounce(fnc, ms)
  local timer = uv.new_timer()
  local busy
  return function(...)
    local args = { ... }
    if busy then
      timer:stop()
    end
    busy = true
    timer:start(
      ms,
      0,
      vim.schedule_wrap(function()
        fnc(table.unpack(args))
        busy = false
      end)
    )
  end
end

--- Deep merge tables
---@param default table
---@param opts table
---@return table
function M.extend_tbl(default, opts)
  if type(opts) ~= "table" then
    return default
  end
  local res = vim.deepcopy(default)
  for k, v in pairs(opts) do
    if type(v) == "table" and type(res[k]) == "table" then
      res[k] = M.extend_tbl(res[k], v)
    else
      res[k] = v
    end
  end
  return res
end

--- Trim whitespace
---@param s string
---@return string
function M.trim(s)
  return (s or ""):match("^%s*(.-)%s*$")
end

--- Generate UUID v4
---@return string
function M.uuid()
  math.randomseed(os.time())
  local tpl = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  local uuid = tpl:gsub("[xy]", function(c)
    local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
    return ("%x"):format(v)
  end)
  return uuid
end

-- Functions from extras.lua begin here

--- Get the current file name or fallback
---@return string
function M.filename()
  local f = fn.expand("%:t")
  return (f ~= "" and f) or "[No Name]"
end

--- Return fileformat and encoding
---@return string
function M.fileinfo()
  local fmt = vim.bo.fileformat or vim.o.fileformat
  local enc = vim.bo.fileencoding or vim.o.encoding
  return fmt .. " | " .. enc
end

--- Count search hits for statusline
---@return string
function M.search_count()
  local sc = fn.searchcount({ maxcount = 999, timeout = 500 })
  if vim.v.hlsearch == 1 and sc.total > 0 then
    return string.format("[%d/%d]", sc.current, sc.total)
  end
  return ""
end

--- Get current Git branch (prefixed)
---@return string
function M.git_branch()
  local branch = fn.systemlist("git rev-parse --abbrev-ref HEAD")[1] or ""
  return (branch ~= "" and " " .. branch) or ""
end

--- Execute a shell command and trim whitespace
---@param cmd string
---@return string
function M.exec_cmd(cmd)
  local ok, out = pcall(fn.system, cmd)
  if not ok then
    return ""
  end
  return out and M.trim(out) or ""
end

--- Check if a file or directory exists
---@param path string
---@return boolean
function M.file_exists(path)
  return vim.loop.fs_stat(path) ~= nil
end

--- Join paths with '/'
---@param ... string
---@return string
function M.join_paths(...)
  return table.concat({ ... }, "/")
end

--- Get current date in YYYY-MM-DD format
---@return string
function M.get_date()
  -- os.date may return a table (if you pass "*t") or string, so force a string
  local d = os.date("%Y-%m-%d")
  if type(d) == "string" then
    return d
  end
  return ""
end

--- Get visual selection text
---@return string
function M.get_visual_selection()
  local save_reg, save_type = fn.getreg("v"), fn.getregtype("v")
  vim.cmd('noau normal! gv"vy')
  local txt = fn.getreg("v") or ""
  fn.setreg("v", save_reg, save_type)
  -- gsub returns multiple values; capture only the transformed string
  local res = txt:gsub("\r?\n?%s*$", "")
  return res
end

return M
