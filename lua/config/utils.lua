-- Utility module for Neovim configuration

local M = {}

-- Determine project root
-- Uses LSP workspace folders, LSP root_dir, or fallback patterns
---@return string root directory
function M.get_root()
  local bufname = vim.api.nvim_buf_get_name(0)
  local path = bufname ~= "" and vim.loop.fs_realpath(bufname) or nil
  local roots = {}

  if path then
    for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      local folders = client.config.workspace_folders
        and vim.tbl_map(function(ws) return vim.uri_to_fname(ws.uri) end, folders)
        or client.config.root_dir and { client.config.root_dir } or {}

      for _, p in ipairs(folders) do
        local real = vim.loop.fs_realpath(p)
        if real and path:find(real, 1, true) then
          table.insert(roots, real)
        end
      end
    end
  end

  table.sort(roots, function(a, b) return #a > #b end)
  local root = roots[1]

  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    local found = vim.fs.find({ ".git", "go.mod", "package.json", "tsconfig.json", "Makefile" }, {
      path = path,
      upward = true,
    })
    root = found and vim.fs.dirname(found[1]) or vim.loop.cwd()
  end

  return root
end

-- Get highlight group color
---@param hl_name string
---@param attr string 'fg' or 'bg'
---@param fallback string hex fallback
---@return string color
function M.get_hl_color(hl_name, attr, fallback)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_name })
  local value = ok and hl[attr]
  if not value then
    return fallback
  end

  if type(value) == "number" then
    return string.format("#%06x", value)
  end

  return tostring(value)
end

-- Shorten and display cwd in statusline
function M.cwd()
  local cwd = vim.fn.getcwd()
  local home = vim.env.HOME
  if home and cwd:find(home, 1, true) == 1 then
    cwd = "~" .. cwd:sub(#home + 1)
  end
  return vim.fn.pathshorten(cwd)
end

-- Toggle between terminal and previous buffer
function M.toggle_term()
  local terms = vim.tbl_filter(function(buf)
    return vim.bo[buf].buftype == "terminal"
  end, vim.api.nvim_list_bufs())

  if #terms == 0 then
    vim.cmd("terminal")
    return
  end

  local cur = vim.api.nvim_get_current_buf()
  if vim.bo[cur].buftype == "terminal" then
    vim.cmd("b#")
  else
    vim.cmd("buffer " .. terms[1])
  end
end

-- Open floating terminal
---@param cmd string|nil
---@param opts table|nil
function M.float_term(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    size = { w = 0.8, h = 0.8 },
    border = "rounded",
    on_create = function() end,
  }, opts or {})

  local Terminal = require("toggleterm.terminal").Terminal
  local float = Terminal:new({
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

  float:toggle()
end

-- Add rounded border to LspInfo
function M.lspinfo_border()
  local orig = vim.lsp.util.open_floating_preview
  vim.lsp.util.open_floating_preview = function(contents, ft, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig(contents, ft, opts, ...)
  end
end

-- Check plugin existence
---@param name string plugin key
---@return boolean
function M.has_plugin(name)
  return require("lazy.core.config").plugins[name] ~= nil
end

-- Check if file exists
---@param path string
---@return boolean
function M.file_exists(path)
  local f = io.open(path, "r")
  if f then f:close() end
  return f ~= nil
end

-- Join filesystem paths
---@vararg string
---@return string
function M.join_paths(...)
  local parts = { ... }
  return table.concat(parts, "/"):gsub("/+", "/")
end

-- Get current date YYYY-MM-DD
function M.get_date()
  return os.date("%Y-%m-%d")
end

-- Get visual selection text
function M.get_visual_selection()
  local save_reg, save_type = vim.fn.getreg('v'), vim.fn.getregtype('v')
  vim.cmd('noau normal! gv"vy')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', save_reg, save_type)
  return text:gsub("\r?\n?%s*$", "")
end

-- Generate random UUID v4
function M.uuid()
  math.randomseed(os.time())
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return template:gsub('[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

-- Debounce a function by ms
---@param fn function
---@param ms number
---@return function
function M.debounce(fn, ms)
  local timer = vim.loop.new_timer()
  local running = false
  return function(...)
    local args = { ... }
    if running then timer:stop() end
    running = true
    timer:start(ms, 0, vim.schedule_wrap(function()
      fn(unpack(args))
      running = false
    end))
  end
end

-- Extend table without overwriting nested
function M.extend_tbl(default, opts)
  if type(opts) ~= 'table' then return default end
  local result = vim.deepcopy(default)
  for k, v in pairs(opts) do
    if type(v) == 'table' and type(result[k]) == 'table' then
      result[k] = M.extend_tbl(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

-- Reload Lua module
---@param name string
---@return table
function M.reload_module(name)
  package.loaded[name] = nil
  return require(name)
end

-- Format buffer via available plugins or LSP
function M.format_buffer()
  if pcall(require, 'conform') then
    require('conform').format({ async = false, lsp_fallback = true })
  elseif pcall(require, 'formatter') then
    vim.cmd('Format')
  else
    vim.lsp.buf.format({ async = false })
  end
end

-- Trim whitespace
---@param s string
---@return string
function M.trim(s)
  return (s or ''):match('^%s*(.-)%s*$')
end

-- Git branch for statusline
function M.git_branch()
  local branch = vim.fn.systemlist('git rev-parse --abbrev-ref HEAD')[1] or ''
  return branch ~= '' and ' ' .. branch or ''
end

-- Filename or placeholder
function M.filename()
  local name = vim.fn.expand('%:t')
  return name ~= '' and name or '[No Name]'
end

-- File info (format | encoding)
function M.fileinfo()
  local fmt = vim.bo.fileformat or vim.o.fileformat
  local enc = vim.bo.fileencoding or vim.o.encoding
  return fmt .. ' | ' .. enc
end

-- Toggle quickfix list
function M.toggle_qf()
  local qf = vim.fn.getqflist()
  if vim.fn.getwininfo()[1].quickfix == 1 then
    vim.cmd('cclose')
  elseif not vim.tbl_isempty(qf) then
    vim.cmd('copen')
  end
end

-- Toggle colorcolumn presets
function M.toggle_colorcolumn()
  vim.wo.colorcolumn = vim.wo.colorcolumn == '' and '80,100,120' or ''
end

-- Execute shell command, trim output
function M.exec_cmd(cmd)
  local ok, out = pcall(vim.fn.system, cmd)
  return ok and M.trim(out) or ''
end

-- Explorer integration (Oil | Snacks)
---@param path string? optional path
---@param float boolean? float window
function M.open_explorer(path, float)
  path = path or vim.fn.expand('%:p:h')
  if vim.g.default_explorer == 'oil' then
    local cmd = 'Oil' .. (float and ' --float' or '') .. ' ' .. path
    vim.cmd(cmd)
  elseif package.loaded['snacks.explorer'] then
    require('snacks.explorer').toggle({ path = path, float = float })
  else
    vim.cmd('Oil ' .. path)
  end
end

-- Explorer commands
function M.explorer_git_root()
  local root = M.exec_cmd('git rev-parse --show-toplevel')
  if root ~= '' then return M.open_explorer(root) end
  vim.notify('Not in Git repo', vim.log.levels.WARN)
  M.open_explorer()
end

function M.explorer_stack(stack, float)
  if stack then vim.g.current_stack = stack end
  M.open_explorer(nil, float)
  if stack then
    vim.notify('Explorer on ' .. stack .. ' stack', vim.log.levels.INFO)
  end
end

M.explorer_goth   = function(float) M.explorer_stack('goth', float) end
M.explorer_nextjs = function(float) M.explorer_stack('nextjs', float) end

function M.toggle_explorer()
  if vim.g.default_explorer == 'oil' then
    vim.g.default_explorer = 'snacks'
  else
    vim.g.default_explorer = 'oil'
  end
  M.open_explorer()
  vim.notify('Switched to ' .. vim.g.default_explorer .. ' explorer', vim.log.levels.INFO)
end

-- Picker integration (Snacks)
function M.find_files(opts)
  if vim.g.default_picker == 'snacks' and package.loaded['snacks.picker'] then
    require('snacks.picker').find_files(opts or {})
  else
    vim.notify('Picker not available', vim.log.levels.ERROR)
  end
end

function M.live_grep(opts)
  if vim.g.default_picker == 'snacks' and package.loaded['snacks.picker'] then
    require('snacks.picker').live_grep(opts or {})
  else
    vim.notify('Picker not available', vim.log.levels.ERROR)
  end
end

-- Generate components
---@param type string 'client'|'server'|'page'|'layout'
function M.new_nextjs_component(type)
  type = type or 'client'
  local name = vim.fn.input('Component Name: ')
  if name == '' then return vim.notify('Name required', vim.log.levels.ERROR) end

  local ft = 'typescriptreact'
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, name .. (type=='page' and '.tsx' or '.tsx'))
  vim.api.nvim_buf_set_option(buf, 'filetype', ft)

  local tpl = {
    client = {
      "'use client'", '',
      'import React from "react"', '',
      ('export default function %s(props: {}): JSX.Element {'):format(name),
      '  return (<div>'..name..' Component</div>)',
      '}',
    },
    server = {
      'import React from "react"', '',
      ('export default async function %s(): Promise<JSX.Element> {'):format(name),
      '  return (<div>'..name..' Server Component</div>)',
      '}',
    },
    page = {
      'import React from "react"', '',
      ('export const metadata = { title: "%s", description: "%s page" };'):format(name, name), '',
      'export default function Page() {',
      '  return (<main><h1>'..name..' Page</h1></main>)',
      '}',
    },
    layout = {
      'import React from "react"', '',
      ('export default function %sLayout({ children }: { children: React.ReactNode }) {'):format(name),
      '  return <div>{children}</div>',
      '}',
    },
  }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, tpl[type] or tpl.client)
  vim.api.nvim_win_set_buf(0, buf)
  vim.cmd('startinsert')
end

-- Generate Go Templ component
function M.new_templ_component()
  local name = vim.fn.input('Component Name: ')
  if name == '' then return vim.notify('Name required', vim.log.levels.ERROR) end

  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, name .. '.templ')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'templ')

  local lines = {
    'package components', '',
    ('type %sProps struct {'):format(name), '  -- props', '}', '',
    ('templ %s(props %sProps) {'):format(name, name),
    '  <div>', '    <h1>'..name..' Component</h1>', '  </div>', '}',
  }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_win_set_buf(0, buf)
  vim.cmd('startinsert')
end

return M
