local M = {}

-- Gets the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
function M.get_root()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws)
        return vim.uri_to_fname(ws.uri)
      end, workspace) or client.config.root_dir and { client.config.root_dir } or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if path:find(r, 1, true) then
          roots[#roots + 1] = r
        end
      end
    end
  end
  table.sort(roots, function(a, b)
    return #a > #b
  end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find({ ".git", "go.mod", "package.json", "tsconfig.json", "Makefile" }, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end

-- Returns the color value or fallback value from a highlight name
---@param hl_name string name of the highlight group
---@param attr string attribute like "fg" or "bg"
---@param fallback string fallback hex color value
function M.get_hl_color(hl_name, attr, fallback)
  local color = vim.api.nvim_get_hl(0, { name = hl_name })[attr]
  if not color then
    return fallback
  end

  -- Convert to hex
  if type(color) == "number" then
    color = string.format("#%06x", color)
  end

  return color or fallback
end

-- This function returns a string for a statusline component
-- that shows the current working directory in a limited space
function M.cwd()
  local cwd = vim.fn.getcwd()
  local home = os.getenv("HOME")
  if cwd:find(home, 1, true) == 1 then
    cwd = "~" .. cwd:sub(#home + 1)
  end
  return vim.fn.pathshorten(cwd)
end

-- Toggles between normal buffers and terminal
function M.toggle_term()
  local term_buffers = {}

  -- Find terminal buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].buftype == "terminal" then
      table.insert(term_buffers, bufnr)
    end
  end

  if #term_buffers == 0 then
    -- No terminal buffers exist, create one
    vim.cmd("terminal")
  else
    local current_bufnr = vim.api.nvim_get_current_buf()

    if vim.bo[current_bufnr].buftype == "terminal" then
      -- Currently in a terminal buffer, go back to previous
      vim.cmd("b#")
    else
      -- Switch to the first terminal buffer
      vim.cmd("buffer " .. term_buffers[1])
    end
  end
end

-- Opens a floating terminal
function M.float_term(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    size = { width = 0.8, height = 0.8 },
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
      width = math.floor(vim.o.columns * opts.size.width),
      height = math.floor(vim.o.lines * opts.size.height),
    },
    on_create = opts.on_create,
  })
  
  float:toggle()
end

-- Add border to LspInfo window
function M.lspinfo_border()
  local old_lspinfo = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return old_lspinfo(contents, syntax, opts, ...)
  end
end

-- Check if a plugin is installed
function M.has_plugin(name)
  return require("lazy.core.config").plugins[name] ~= nil
end

-- Check if a file exists
function M.file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- Join all the arguments passed into a single path
-- Handles leading/trailing/duplicate slashes
function M.join_paths(...)
  local args = {...}
  if #args == 0 then
    return ""
  end
  
  local result = args[1]
  for i = 2, #args do
    if result:sub(-1) ~= "/" and args[i]:sub(1, 1) ~= "/" then
      result = result .. "/" .. args[i]
    elseif result:sub(-1) == "/" and args[i]:sub(1, 1) == "/" then
      result = result .. args[i]:sub(2)
    else
      result = result .. args[i]
    end
  end
  
  return result
end

-- Get a formatted date string
function M.get_date()
  return os.date("%Y-%m-%d")
end

-- Get the visual selection text
function M.get_visual_selection()
  local save_reg = vim.fn.getreg('"')
  local save_regtype = vim.fn.getregtype('"')
  
  vim.cmd('noau normal! "vy"')
  
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', save_reg, save_regtype)
  
  -- Replace any newlines with actual newlines
  text = string.gsub(text, "\\n", "\n")
  return text
end

-- Generate a UUID (v4)
function M.uuid()
  local random = math.random
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function (c)
    local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
    return string.format('%x', v)
  end)
end

-- Returns a function that debounces fn by ms milliseconds
function M.debounce(fn, ms)
  local timer = vim.loop.new_timer()
  local is_debouncing = false
  
  return function(...)
    local args = { ... }
    local wrapped = function()
      fn(unpack(args))
      is_debouncing = false
    end
    
    if is_debouncing then
      timer:stop()
    end
    
    is_debouncing = true
    timer:start(ms, 0, vim.schedule_wrap(wrapped))
  end
end

-- Extend a table but ignore keys that already exist
function M.extend_tbl(default, opts)
  opts = opts or {}
  local tbl = vim.deepcopy(default)
  
  for k, v in pairs(opts) do
    if type(v) == "table" and type(tbl[k]) == "table" then
      tbl[k] = M.extend_tbl(tbl[k], v)
    else
      tbl[k] = v
    end
  end
  
  return tbl
end

-- Get a list of all installed LSP servers
function M.get_lsp_servers()
  local servers = {}
  if vim.fn.exists("*mason_lspconfig#get_installed_servers") == 1 then
    servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
  end
  return servers
end

-- Utility function to reload modules
function M.reload_module(module_name)
  package.loaded[module_name] = nil
  return require(module_name)
end

-- Format current buffer
function M.format_buffer()
  -- Check if there are formatters available
  local has_conform = pcall(require, "conform")
  local has_formatter = pcall(require, "formatter")
  
  if has_conform then
    require("conform").format({ async = false, lsp_fallback = true })
  elseif has_formatter then
    vim.cmd("Format")
  else
    vim.lsp.buf.format({ async = false })
  end
end

-- Strip whitespace from start and end of string
function M.trim(s)
  return s:match("^%s*(.-)%s*$")
end

-- Add current git branch to statusline 
function M.git_branch()
  local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
  if branch ~= "" then
    return " " .. branch
  else
    return ""
  end
end

-- Get current filename or [No Name]
function M.filename()
  local filename = vim.fn.expand("%:t")
  if filename == "" then
    return "[No Name]"
  end
  return filename
end

-- Get file's modified status
function M.modified()
  if vim.bo.modified then
    return "+"
  elseif vim.bo.modifiable == false or vim.bo.readonly == true then
    return "-"
  end
  return ""
end

-- Get formated file location
function M.fileinfo()
  local encode = vim.bo.fileencoding
  if encode == "" then
    encode = vim.o.encoding
  end
  local format = vim.bo.fileformat
  return format .. " | " .. encode
end

-- Toggle quickfix list
function M.toggle_qf()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists then
    vim.cmd("cclose")
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("copen")
  end
end

-- Toggle colorcolumn
function M.toggle_colorcolumn()
  if vim.wo.colorcolumn == "" then
    vim.wo.colorcolumn = "80,100,120"
  else
    vim.wo.colorcolumn = ""
  end
end

-- Execute shell command and return output
function M.exec_cmd(cmd)
  local handle = io.popen(cmd)
  if not handle then
    return ""
  end
  
  local result = handle:read("*a")
  handle:close()
  
  return M.trim(result)
end

-- Get current working directory name (just the last component)
function M.cwd_name()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

-- Return only icons and filenames for neo-tree
function M.neo_tree_items()
  if vim.bo.filetype ~= "neo-tree" then
    return ""
  end
  
  local utils = require("neo-tree.utils")
  local state = require("neo-tree.sources.filesystem.state")
  local items = {}
  
  local context = (state.current_position or {}).search_pattern or ""
  local tree =  state.tree
  if tree then
    for _, node in ipairs(tree:get_nodes()) do
      local name = utils.basename(node.path)
      local icon = node.icon or (node:get_icon() or {}).icon or ""
      table.insert(items, icon .. " " .. name)
    end
  end
  
  return table.concat(items, ", ")
end

-- Generate a new Next.js component
function M.new_nextjs_component(type)
  type = type or "client" -- Default to client component
  
  -- Get the component name from user input
  local component_name = vim.fn.input("Component Name: ")
  if component_name == "" then
    vim.notify("Component name cannot be empty", vim.log.levels.ERROR)
    return
  end
  
  -- Create a new buffer
  local bufnr = vim.api.nvim_create_buf(true, false)
  
  -- Set buffer name
  vim.api.nvim_buf_set_name(bufnr, component_name .. ".tsx")
  
  -- Set filetype
  vim.api.nvim_buf_set_option(bufnr, "filetype", "typescriptreact")
  
  -- Generate component content based on type
  local content = {}
  if type == "client" then
    table.insert(content, "'use client';")
    table.insert(content, "")
    table.insert(content, "import React from 'react';")
    table.insert(content, "")
    table.insert(content, "interface " .. component_name .. "Props {")
    table.insert(content, "  // Props go here")
    table.insert(content, "}")
    table.insert(content, "")
    table.insert(content, "export default function " .. component_name .. "({ }: " .. component_name .. "Props) {")
    table.insert(content, "  return (")
    table.insert(content, "    <div>")
    table.insert(content, "      " .. component_name .. " Component")
    table.insert(content, "    </div>")
    table.insert(content, "  );")
    table.insert(content, "}")
  elseif type == "server" then
    table.insert(content, "import React from 'react';")
    table.insert(content, "")
    table.insert(content, "interface " .. component_name .. "Props {")
    table.insert(content, "  // Props go here")
    table.insert(content, "}")
    table.insert(content, "")
    table.insert(content, "export default async function " .. component_name .. "({ }: " .. component_name .. "Props) {")
    table.insert(content, "  // Server-side logic here")
    table.insert(content, "  return (")
    table.insert(content, "    <div>")
    table.insert(content, "      " .. component_name .. " Server Component")
    table.insert(content, "    </div>")
    table.insert(content, "  );")
    table.insert(content, "}")
  elseif type == "page" then
    table.insert(content, "import React from 'react';")
    table.insert(content, "")
    table.insert(content, "export default function Page() {")
    table.insert(content, "  return (")
    table.insert(content, "    <main className=\"p-4\">")
    table.insert(content, "      <h1 className=\"text-2xl font-bold\">" .. component_name .. " Page</h1>")
    table.insert(content, "    </main>")
    table.insert(content, "  );")
    table.insert(content, "}")
  elseif type == "layout" then
    table.insert(content, "import React from 'react';")
    table.insert(content, "")
    table.insert(content, "export default function " .. component_name .. "Layout({")
    table.insert(content, "  children,")
    table.insert(content, "}: {")
    table.insert(content, "  children: React.ReactNode;")
    table.insert(content, "}) {")
    table.insert(content, "  return (")
    table.insert(content, "    <div className=\"layout\">")
    table.insert(content, "      {children}")
    table.insert(content, "    </div>")
    table.insert(content, "  );")
    table.insert(content, "}")
  end
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
  
  -- Open the buffer in the current window
  vim.api.nvim_win_set_buf(0, bufnr)
  
  -- Position cursor
  if type == "client" then
    vim.api.nvim_win_set_cursor(0, {7, 0}) -- Position at props
  elseif type == "server" then
    vim.api.nvim_win_set_cursor(0, {7, 0}) -- Position at props
  elseif type == "page" then
    vim.api.nvim_win_set_cursor(0, {6, 0}) -- Position at page content
  elseif type == "layout" then
    vim.api.nvim_win_set_cursor(0, {9, 0}) -- Position at layout
  end
  
  -- Enter insert mode
  vim.cmd("startinsert!")
end

-- Generate a new Go Templ component
function M.new_templ_component()
  -- Get the component name from user input
  local component_name = vim.fn.input("Component Name: ")
  if component_name == "" then
    vim.notify("Component name cannot be empty", vim.log.levels.ERROR)
    return
  end
  
  -- Create a new buffer
  local bufnr = vim.api.nvim_create_buf(true, false)
  
  -- Set buffer name
  vim.api.nvim_buf_set_name(bufnr, component_name .. ".templ")
  
  -- Set filetype
  vim.api.nvim_buf_set_option(bufnr, "filetype", "templ")
  
  -- Generate component content
  local content = {
    "package components",
    "",
    "type " .. component_name .. "Props struct {",
    "  // Add props here",
    "}",
    "",
    "templ " .. component_name .. "(props " .. component_name .. "Props) {",
    "  <div>",
    "    <h1>" .. component_name .. " Component</h1>",
    "    <p>Content goes here</p>",
    "  </div>",
    "}"
  }
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
  
  -- Open the buffer in the current window
  vim.api.nvim_win_set_buf(0, bufnr)
  
  -- Position cursor at the props section
  vim.api.nvim_win_set_cursor(0, {4, 0})
  
  -- Enter insert mode
  vim.cmd("startinsert!")
end

-- Function to display search count in statusline
function M.search_count()
  local search = vim.fn.searchcount({maxcount = 0})
  if search.total > 0 then
    return string.format("[%d/%d]", search.current, search.total)
  else
    return ""
  end
end

return M
