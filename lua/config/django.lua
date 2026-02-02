local M = {}

local state = {
  root = nil,
  is_django = false,
}

local function normalize_mode(mode)
  if mode == "on" or mode == "off" or mode == "auto" then
    return mode
  end
  return "auto"
end

local function get_mode()
  return normalize_mode(vim.g.django_mode)
end

local function set_mode(mode)
  vim.g.django_mode = normalize_mode(mode)
end

local function file_contains(path, needle)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return false
  end
  for _, line in ipairs(lines) do
    if line:lower():find(needle, 1, true) then
      return true
    end
  end
  return false
end

local function resolve_root_dir(cwd)
  local markers = {
    ".git",
    "manage.py",
    "pyproject.toml",
    "requirements.txt",
    "Pipfile",
  }
  local marker = vim.fs.find(markers, { path = cwd, upward = true })[1]
  if marker then
    return vim.fs.dirname(marker)
  end
  return cwd
end

local function detect_django(root)
  if vim.fn.filereadable(root .. "/manage.py") == 1 then
    return true
  end

  local files = {}
  local patterns = {
    "pyproject.toml",
    "requirements.txt",
    "requirements-dev.txt",
    "requirements/dev.txt",
    "Pipfile",
    "Pipfile.lock",
  }

  for _, pattern in ipairs(patterns) do
    local matches = vim.fn.glob(root .. "/" .. pattern, 0, 1)
    for _, match in ipairs(matches) do
      table.insert(files, match)
    end
  end

  local req_dir = root .. "/requirements"
  if vim.fn.isdirectory(req_dir) == 1 then
    local req_files = vim.fn.glob(req_dir .. "/*.txt", 0, 1)
    for _, match in ipairs(req_files) do
      table.insert(files, match)
    end
  end

  for _, path in ipairs(files) do
    if file_contains(path, "django") then
      return true
    end
  end

  return false
end

local function refresh_state(cwd)
  local root = resolve_root_dir(cwd)
  if root ~= state.root then
    state.root = root
    state.is_django = detect_django(root)
  end
end

local function is_template_path(path)
  return path:match("[/\\\\]templates[/\\\\].+%.html$")
end

local function should_enable()
  local mode = get_mode()
  if mode == "on" then
    return true
  end
  if mode == "off" then
    return false
  end
  refresh_state(vim.fn.getcwd())
  return state.is_django
end

local function apply_to_buffer(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" or not is_template_path(name) then
    return
  end

  if should_enable() then
    vim.bo[bufnr].filetype = "htmldjango"
  elseif vim.bo[bufnr].filetype == "htmldjango" then
    vim.bo[bufnr].filetype = "html"
  end
end

local function apply_to_open_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      apply_to_buffer(buf)
    end
  end
end

function M.setup()
  if vim.g.django_mode == nil then
    vim.g.django_mode = "auto"
  end

  local group = vim.api.nvim_create_augroup("DjangoTemplateDetect", { clear = true })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = group,
    callback = function(args)
      apply_to_buffer(args.buf)
    end,
    desc = "Set htmldjango for Django templates",
  })

  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    group = group,
    callback = function()
      if get_mode() == "auto" then
        refresh_state(vim.fn.getcwd())
      end
      apply_to_open_buffers()
    end,
    desc = "Refresh Django template detection",
  })

  vim.api.nvim_create_user_command("DjangoEnable", function()
    set_mode("on")
    apply_to_open_buffers()
    vim.notify("Django mode enabled", vim.log.levels.INFO)
  end, { desc = "Enable Django template detection" })

  vim.api.nvim_create_user_command("DjangoDisable", function()
    set_mode("off")
    apply_to_open_buffers()
    vim.notify("Django mode disabled", vim.log.levels.INFO)
  end, { desc = "Disable Django template detection" })

  vim.api.nvim_create_user_command("DjangoAuto", function()
    set_mode("auto")
    refresh_state(vim.fn.getcwd())
    apply_to_open_buffers()
    vim.notify("Django mode set to auto", vim.log.levels.INFO)
  end, { desc = "Auto-detect Django projects" })

  vim.api.nvim_create_user_command("DjangoStatus", function()
    refresh_state(vim.fn.getcwd())
    local mode = get_mode()
    local status = mode
    if mode == "auto" then
      status = state.is_django and "auto (detected)" or "auto (not detected)"
    end
    vim.notify("Django mode: " .. status, vim.log.levels.INFO)
  end, { desc = "Show Django mode status" })
end

return M
