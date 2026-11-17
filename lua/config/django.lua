local M = {}

local django_by_root = {}

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

local function resolve_root_dir(dir)
  local markers = {
    ".git",
    "manage.py",
    "pyproject.toml",
    "requirements.txt",
    "Pipfile",
  }
  local marker = vim.fs.find(markers, { path = dir, upward = true })[1]
  if marker then
    return vim.fs.dirname(marker)
  end
  return dir
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
    local matches = vim.fn.glob(root .. "/" .. pattern, false, true)
    for _, match in ipairs(matches) do
      table.insert(files, match)
    end
  end

  local req_dir = root .. "/requirements"
  if vim.fn.isdirectory(req_dir) == 1 then
    local req_files = vim.fn.glob(req_dir .. "/*.txt", false, true)
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

local function is_django_root(root)
  if django_by_root[root] == nil then
    django_by_root[root] = detect_django(root)
  end
  return django_by_root[root]
end

local function template_filetype(path)
  local mode = get_mode()
  local enabled = mode == "on" or mode == "auto" and is_django_root(resolve_root_dir(vim.fs.dirname(path)))
  return enabled and "htmldjango" or "html"
end

local function redetect_html_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local filetype = vim.bo[buf].filetype
    if vim.api.nvim_buf_is_loaded(buf) and (filetype == "html" or filetype == "htmldjango") then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("filetype detect")
      end)
    end
  end
end

function M.setup()
  if vim.g.django_mode == nil then
    vim.g.django_mode = "auto"
  end

  vim.filetype.add({ pattern = { [".*[/\\]templates[/\\].+%.html"] = template_filetype } })

  vim.api.nvim_create_user_command("DjangoEnable", function()
    set_mode("on")
    redetect_html_buffers()
    vim.notify("Django mode enabled", vim.log.levels.INFO)
  end, { desc = "Enable Django template detection" })

  vim.api.nvim_create_user_command("DjangoDisable", function()
    set_mode("off")
    redetect_html_buffers()
    vim.notify("Django mode disabled", vim.log.levels.INFO)
  end, { desc = "Disable Django template detection" })

  vim.api.nvim_create_user_command("DjangoAuto", function()
    set_mode("auto")
    django_by_root = {}
    redetect_html_buffers()
    vim.notify("Django mode set to auto", vim.log.levels.INFO)
  end, { desc = "Auto-detect Django projects" })

  vim.api.nvim_create_user_command("DjangoStatus", function()
    local mode = get_mode()
    local status = mode
    if mode == "auto" then
      status = is_django_root(resolve_root_dir(vim.fn.getcwd())) and "auto (detected)" or "auto (not detected)"
    end
    vim.notify("Django mode: " .. status, vim.log.levels.INFO)
  end, { desc = "Show Django mode status" })
end

return M
