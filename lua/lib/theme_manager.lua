-- Configuration via environment variables:
--   HYPR_THEME_CONF - Path to Hyprland theme metadata file (highest priority)
--   XDG_CONFIG_HOME - If set, uses $XDG_CONFIG_HOME/hypr/themes/theme.meta
--   Default: ~/.config/hypr/themes/theme.meta

local set_background = require("lib.background").set

local M = {}
local background_variants = {}

M.cache_dir = vim.fn.stdpath("cache")
M.settings_file = M.cache_dir .. "/theme_settings.json"
M.system_theme_setter = vim.fn.expand("~/.local/lib/hypr/theme/theme.switch.sh")

-- System theme configuration (can be overridden via environment variables)
M.system_theme_file = vim.env.HYPR_THEME_CONF
  or vim.env.XDG_CONFIG_HOME and (vim.env.XDG_CONFIG_HOME .. "/hypr/themes/theme.meta")
  or vim.fn.expand("~/.config/hypr/themes/theme.meta")

M.active_palette_file = vim.env.HYPR_STATE_HOME
    and (vim.env.HYPR_STATE_HOME .. "/active-palette.json")
  or vim.env.XDG_STATE_HOME and (vim.env.XDG_STATE_HOME .. "/hypr/active-palette.json")
  or vim.fn.expand("~/.local/state/hypr/active-palette.json")

local normalize_background

local function normalize_transparency(value)
  return value == true
end

local function normalize_conf_string(value)
  if value == nil then
    return nil
  end
  local v = tostring(value):gsub("^%s+", ""):gsub("%s+$", ""):gsub('^["\']', ""):gsub('["\']$', "")
  if v == "" then
    return nil
  end
  return v
end

local function normalize_settings(data)
  return {
    theme = data and data.theme or "catppuccin",
    variant = data and data.variant or nil,
    background = normalize_background(data and data.background) or "dark",
    transparency = normalize_transparency(data and data.transparency),
  }
end

local function options_from_settings(settings, background)
  return {
    background = background,
    transparency = settings.transparency,
  }
end

local function normalize_apply_options(options)
  return {
    background = normalize_background(options and options.background),
    transparency = normalize_transparency(options and options.transparency),
  }
end

local function read_json_file(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end

  local ok, content = pcall(vim.fn.readfile, path)
  if not ok or not content[1] then
    return nil
  end

  local success, data = pcall(vim.json.decode, table.concat(content, "\n"))
  if success then
    return data
  end
  return nil
end

local function atomic_write(path, lines)
  local tmp = ("%s.%d.tmp"):format(path, vim.fn.getpid())
  local ok, result = pcall(vim.fn.writefile, lines, tmp)
  ok = ok and result == 0 and vim.fn.rename(tmp, path) == 0
  if not ok then
    vim.fn.delete(tmp)
  end
  return ok
end

-- Resolve the background colour bar chrome (statusline/tabline/winbar) should
-- use given the current transparency setting. Returns "NONE" when transparent.
function M.bar_bg(default_bg)
  return M.load_settings().transparency and "NONE" or default_bg
end

-- Load theme settings from cache
function M.load_settings()
  local ok, content = pcall(vim.fn.readfile, M.settings_file)
  if ok and content[1] then
    local success, data = pcall(vim.json.decode, content[1])
    if success then
      return normalize_settings(data)
    end
  end
  return normalize_settings(nil)
end

-- Save theme settings to cache
function M.save_settings(settings)
  local normalized = normalize_settings(settings)
  vim.fn.mkdir(M.cache_dir, "p")
  if not atomic_write(M.settings_file, { vim.json.encode(normalized) }) then
    vim.notify("Failed to save theme settings", vim.log.levels.WARN)
    return false
  end
  return true
end

function M.load_catalog()
  local catalog = {}
  local def_path = vim.fn.stdpath("config") .. "/lua/plugins/themes/definitions"

  local files = vim.fn.glob(def_path .. "/*.lua", false, true)

  for _, file in ipairs(files) do
    local theme_name = vim.fn.fnamemodify(file, ":t:r")
    local ok, theme_def = pcall(require, "plugins.themes.definitions." .. theme_name)
    if ok and type(theme_def) == "table" and type(theme_def.setup) == "function" then
      catalog[theme_name] = theme_def
    else
      local reason = ok and "invalid definition" or tostring(theme_def)
      vim.notify(("Failed to load theme '%s': %s"):format(theme_name, reason), vim.log.levels.ERROR)
    end
  end

  M.catalog = catalog
  return catalog
end

local function get_catalog()
  return M.catalog or M.load_catalog()
end

local function theme_supports_variant(theme)
  return theme and theme.variants and #theme.variants > 0
end

local function variant_is_valid(theme, variant)
  if not theme_supports_variant(theme) or not variant or variant == "" then
    return false
  end

  for _, candidate in ipairs(theme.variants) do
    if candidate == variant then
      return true
    end
  end

  return false
end

local function sanitize_variant(theme, variant)
  if variant_is_valid(theme, variant) then
    return variant
  end

  return nil
end

-- Clear the background on every group painted the scheme's base bg, so a theme
-- obeys transparency whether or not its plugin has an option for it (snapshots
-- and .vim schemes have none). Distinct surfaces -- floats, CursorLine, Visual --
-- keep their colors. No-op once the scheme has already cleared Normal itself.
local function apply_transparency()
  local base = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
  if not base then
    return
  end
  for group in pairs(vim.api.nvim_get_hl(0, {})) do
    local spec = vim.api.nvim_get_hl(0, { name = group })
    if spec.bg == base then
      spec.bg = "NONE"
      vim.api.nvim_set_hl(0, group, spec)
    end
  end
end

function M.apply_theme(theme_name, variant, options)
  local theme = get_catalog()[theme_name]
  if not theme then
    vim.notify("Theme '" .. theme_name .. "' not found", vim.log.levels.ERROR)
    return false
  end

  if variant ~= nil and not variant_is_valid(theme, variant) then
    local valid = theme.variants and table.concat(theme.variants, ", ") or "none"
    vim.notify(
      ("Invalid variant '%s' for theme '%s' (valid: %s)"):format(variant, theme_name, valid),
      vim.log.levels.ERROR
    )
    return false
  end
  options = normalize_apply_options(options)

  -- Live definitions name their plugin explicitly. Snapshots and palette-driven
  -- definitions omit it and remain self-contained.
  local lazy_ok, lazy = pcall(require, "lazy")
  local lazy_config = package.loaded["lazy.core.config"]
  if theme.plugin then
    if not lazy_ok or not lazy_config then
      vim.notify("lazy.nvim is unavailable for theme '" .. theme_name .. "'", vim.log.levels.ERROR)
      return false
    end
    local plugin = lazy_config.plugins[theme.plugin]
    if not plugin then
      vim.notify(("Theme '%s' requires unknown plugin '%s'"):format(theme_name, theme.plugin), vim.log.levels.ERROR)
      return false
    end
    if not plugin._.loaded then
      local loaded, load_err = pcall(lazy.load, { plugins = { theme.plugin } })
      if not loaded then
        vim.notify("Error loading theme plugin: " .. tostring(load_err), vim.log.levels.ERROR)
        return false
      end
    end
  end

  local ok, result, setup_error = pcall(theme.setup, {
    variant = variant,
    transparency = options.transparency,
    background = options.background,
  })
  if not ok then
    vim.notify("Error applying theme: " .. tostring(result), vim.log.levels.ERROR)
    return false
  end
  if type(result) ~= "table" then
    local reason = setup_error or "definition returned no result"
    vim.notify(("Theme '%s' rejected its configuration: %s"):format(theme_name, reason), vim.log.levels.ERROR)
    return false
  end

  local actual_variant = result.variant
  if actual_variant ~= nil and not variant_is_valid(theme, actual_variant) then
    vim.notify(("Theme '%s' returned invalid variant '%s'"):format(theme_name, actual_variant), vim.log.levels.ERROR)
    return false
  end

  local actual_background = normalize_background(result.background)
  if result.background ~= nil and not actual_background then
    vim.notify(("Theme '%s' returned invalid background '%s'"):format(theme_name, result.background), vim.log.levels.ERROR)
    return false
  end

  if options.transparency then
    apply_transparency()
  end

  local settings = {
    theme = theme_name,
    variant = actual_variant,
    background = actual_background or normalize_background(vim.o.background) or "dark",
    transparency = options.transparency,
  }
  if not M.save_settings(settings) then
    return false
  end

  return true, settings
end

-- Read variables from theme.meta (Hyprland format: $VAR = value)
local function read_theme_conf(var_name)
  if vim.fn.filereadable(M.system_theme_file) ~= 1 then
    return nil
  end
  local content = vim.fn.readfile(M.system_theme_file)
  for _, line in ipairs(content) do
    if line:match("^%s*%$" .. var_name) then
      local match = line:match("=%s*(.+)")
      if match then
        local value = match:gsub("%s+$", "")
        if value ~= "" then
          return value
        end
      end
    end
  end
  return nil
end

normalize_background = function(value)
  if not value then
    return nil
  end
  local v = tostring(value):gsub('^["\']', ""):gsub('["\']$', ""):lower()
  if v == "dark" or v == "light" then
    return v
  end
  if v == "prefer-dark" then
    return "dark"
  end
  if v == "prefer-light" then
    return "light"
  end
  return nil
end

local function parse_conf_transparency(value)
  if value == nil then
    return nil
  end
  local v = tostring(value):gsub('^["\']', ""):gsub('["\']$', ""):gsub("%s+", ""):lower()
  if v == "true" or v == "1" or v == "on" or v == "yes" then
    return true
  elseif v == "false" or v == "0" or v == "off" or v == "no" then
    return false
  end
  return nil
end

local function is_light_color(hex)
  if not hex or not hex:match("^#%x%x%x%x%x%x$") then
    return false
  end

  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)
  return ((0.299 * r + 0.587 * g + 0.114 * b) / 255) > 0.5
end

function M.load_active_palette()
  local palette = read_json_file(M.active_palette_file)
  if not palette or not palette.bg or not palette.fg or type(palette.colors) ~= "table" then
    return nil
  end
  return palette
end

local function active_palette_background(palette)
  return normalize_background(palette.background) or (is_light_color(palette.bg) and "light" or "dark")
end

-- Apply the active system theme.
-- Theme metadata may pin a Neovim colorscheme/variant; otherwise the active
-- Hypr palette is applied through the pywal definition.
function M.apply_system_theme()
  local catalog = get_catalog()
  local settings = M.load_settings()

  local active_palette = M.load_active_palette()
  local system_scheme = normalize_conf_string(read_theme_conf("NVIM_SCHEME"))
  local system_variant = normalize_conf_string(read_theme_conf("NVIM_VARIANT"))
  local conf_background = normalize_background(read_theme_conf("NVIM_BACKGROUND"))
    or normalize_background(read_theme_conf("COLOR_SCHEME"))
  local conf_transparency = parse_conf_transparency(read_theme_conf("NVIM_TRANSPARENCY"))

  local background = conf_background or active_palette and active_palette_background(active_palette) or settings.background
  if background then
    set_background(background)
  end

  local opts = options_from_settings(settings, background)
  if conf_transparency ~= nil then
    opts.transparency = conf_transparency
  end

  if system_scheme and catalog[system_scheme] then
    if system_variant and not variant_is_valid(catalog[system_scheme], system_variant) then
      vim.notify(
        ("System variant '%s' is invalid for '%s'; falling back to pywal"):format(system_variant, system_scheme),
        vim.log.levels.WARN
      )
    elseif M.apply_theme(system_scheme, system_variant, opts) then
      return true
    else
      vim.notify("System theme failed; falling back to pywal", vim.log.levels.WARN)
    end
  elseif system_scheme then
    vim.notify("System NVIM_SCHEME not found: " .. system_scheme .. "; falling back to pywal", vim.log.levels.WARN)
  end

  if not active_palette or not catalog.pywal then
    return false
  end

  return M.apply_theme("pywal", nil, opts)
end

function M.update_system_theme(settings)
  if vim.fn.executable(M.system_theme_setter) ~= 1 then
    vim.notify("Hyprland theme setter not found", vim.log.levels.ERROR)
    return false
  end

  local mapping = settings.theme .. (settings.variant and (":" .. settings.variant) or "")
  local command = {
    M.system_theme_setter,
    "--nvim",
    mapping,
    "--nvim-background",
    settings.background,
    "--nvim-transparency",
    tostring(settings.transparency),
    "--quiet",
  }
  local job = vim.fn.jobstart(command, {
    detach = true,
    on_exit = function(_, code)
      vim.schedule(function()
        local level = code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        local message = code == 0 and "Updated system theme: " .. mapping or "System theme update failed"
        vim.notify(message, level)
      end)
    end,
  })
  if job <= 0 then
    vim.notify("Failed to start Hyprland theme setter", vim.log.levels.ERROR)
    return false
  end
  return true
end

local function read_watch_snapshot(file)
  if vim.fn.filereadable(file) ~= 1 then
    return "__missing__"
  end

  local ok, content = pcall(vim.fn.readfile, file)
  if not ok then
    return "__unreadable__"
  end

  return table.concat(content, "\n")
end

function M.sync(force)
  local changed = M._watch_snapshots == nil
  M._watch_snapshots = M._watch_snapshots or {}
  local snapshots = {}
  for _, file in ipairs(M._watch_files or {}) do
    local snapshot = read_watch_snapshot(file)
    snapshots[file] = snapshot
    if M._watch_snapshots[file] ~= snapshot then
      changed = true
    end
  end
  if not force and not changed then
    return true
  end
  local applied = M.apply_system_theme()
  if applied then
    M._watch_snapshots = snapshots
  end
  return applied
end

local function close_watchers()
  for _, watcher in ipairs(M._file_watchers or {}) do
    pcall(function()
      watcher:stop()
      watcher:close()
    end)
  end
  M._file_watchers = nil
end

-- Setup theme sync (directory watchers + focus repair)
function M.setup_focus_sync()
  close_watchers()
  local group = vim.api.nvim_create_augroup("ThemeSync", { clear = true })

  M._watch_files = {
    M.active_palette_file,
    M.system_theme_file,
  }
  M._watch_snapshots = {}
  for _, file in ipairs(M._watch_files) do
    M._watch_snapshots[file] = read_watch_snapshot(file)
  end

  local sync_pending = false
  local function request_sync()
    if sync_pending then
      return
    end

    sync_pending = true
    vim.schedule(function()
      sync_pending = false
      M.sync(false)
    end)
  end

  -- Watch parent directories so atomic file replacement still produces events.
  local watchers = {}
  local watch_dirs = {}
  for _, file in ipairs(M._watch_files) do
    local dir = vim.fs.dirname(file)
    if dir and vim.fn.isdirectory(dir) == 1 then
      watch_dirs[dir] = true
    end
  end

  for dir, _ in pairs(watch_dirs) do
    local watcher = vim.uv.new_fs_event()
    if watcher then
      local ok = pcall(function()
        watcher:start(dir, {}, vim.schedule_wrap(function(err)
          if not err then
            request_sync()
          end
        end))
      end)
      if ok then
        table.insert(watchers, watcher)
      end
    end
  end

  -- Store watchers to prevent garbage collection
  M._file_watchers = watchers

  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = request_sync,
    desc = "Repair theme sync after focus returns",
  })

  -- Cleanup on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = close_watchers,
  })
end

-- Register user commands
function M.register_commands()
  local themes = get_catalog()
  local function notify_available_themes()
    local available = {}
    for name, theme in pairs(themes) do
      local icon = theme.icon or ""
      local variant_info = theme.variants and #theme.variants > 0
        and (" - variants: " .. table.concat(theme.variants, ", "))
        or ""
      table.insert(available, icon .. " " .. name .. variant_info)
    end
    table.sort(available)

    vim.notify("Available themes:\n" .. table.concat(available, "\n"), vim.log.levels.INFO)
  end

  vim.api.nvim_create_user_command("Theme", function(opts)
    local theme_name = opts.args
    if theme_name == "" then
      theme_name = M.load_settings().theme
    end

    local theme = themes[theme_name]
    if not theme then
      vim.notify("Theme not found: " .. theme_name, vim.log.levels.ERROR)
      return
    end

    -- Handle variants
    local settings = M.load_settings()
    if theme.variants and #theme.variants > 0 then
      vim.ui.select(theme.variants, {
        prompt = "Select variant:",
      }, function(choice)
        if choice then
          M.apply_theme(theme_name, choice, options_from_settings(settings, settings.background))
        end
      end)
    else
      M.apply_theme(theme_name, nil, options_from_settings(settings, settings.background))
    end
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_keys(themes)
    end,
    desc = "Switch colorscheme theme",
  })

  vim.api.nvim_create_user_command("SystemSetTheme", function(opts)
    local theme_name = opts.args ~= "" and opts.args or M.load_settings().theme
    local settings = M.load_settings()
    local theme = themes[theme_name]

    if not theme then
      vim.notify("Theme not found: " .. theme_name, vim.log.levels.ERROR)
      return
    end

    local requested_variant = sanitize_variant(theme, settings.variant)
    local ok, applied = M.apply_theme(theme_name, requested_variant, options_from_settings(settings, settings.background))
    if ok then
      M.update_system_theme(applied)
    end
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_keys(themes)
    end,
    desc = "Set system theme in Hyprland config",
  })

  vim.api.nvim_create_user_command("ThemeList", notify_available_themes, {
    desc = "List all available themes",
  })

  -- Cycle through color schemes
  vim.api.nvim_create_user_command("CycleColorScheme", function()
    local theme_names = vim.tbl_keys(themes)
    table.sort(theme_names)

    local settings = M.load_settings()
    local current_idx = 1
    for i, name in ipairs(theme_names) do
      if name == settings.theme then
        current_idx = i
        break
      end
    end

    local next_idx = (current_idx % #theme_names) + 1
    local next_theme = theme_names[next_idx]

    -- Pass background, let setup handle variant selection
    M.apply_theme(next_theme, nil, options_from_settings(settings, settings.background))
    vim.notify("Theme: " .. next_theme, vim.log.levels.INFO)
  end, { desc = "Cycle through color schemes" })

  -- Select color scheme with picker
  vim.api.nvim_create_user_command("ColorScheme", function()
    local theme_names = vim.tbl_keys(themes)
    table.sort(theme_names)

    local settings = M.load_settings()

    -- Format items with icons
    local items = {}
    for _, name in ipairs(theme_names) do
      local icon = themes[name].icon or ""
      table.insert(items, { name = name, display = icon .. " " .. name })
    end

    vim.ui.select(items, {
      prompt = "Select theme:",
      format_item = function(item)
        return item.display
      end,
    }, function(choice)
      if choice then
        local theme = themes[choice.name]

        if theme.variants and #theme.variants > 0 then
          vim.ui.select(theme.variants, {
            prompt = "Select variant:",
          }, function(variant)
            if variant then
              M.apply_theme(choice.name, variant, options_from_settings(settings, settings.background))
            end
          end)
        else
          M.apply_theme(choice.name, nil, options_from_settings(settings, settings.background))
        end
      end
    end)
  end, { desc = "Select color scheme" })

  -- Cycle through variants of current theme
  vim.api.nvim_create_user_command("CycleColorVariant", function()
    local settings = M.load_settings()
    local theme = themes[settings.theme]

    if not theme then
      vim.notify("Current theme not found", vim.log.levels.ERROR)
      return
    end

    if not theme.variants or #theme.variants == 0 then
      vim.notify("Theme '" .. settings.theme .. "' has no variants", vim.log.levels.WARN)
      return
    end

    local current_idx = 1
    for i, v in ipairs(theme.variants) do
      if v == settings.variant then
        current_idx = i
        break
      end
    end

    local next_idx = (current_idx % #theme.variants) + 1
    local next_variant = theme.variants[next_idx]

    M.apply_theme(settings.theme, next_variant, options_from_settings(settings, nil))

    -- Show actual applied variant (may differ from requested due to bidirectional sync)
    local new_settings = M.load_settings()
    vim.notify("Variant: " .. (new_settings.variant or next_variant), vim.log.levels.INFO)
  end, { desc = "Cycle through variants of current theme" })

  -- Select variant with picker
  vim.api.nvim_create_user_command("ColorVariant", function()
    local settings = M.load_settings()
    local theme = themes[settings.theme]

    if not theme then
      vim.notify("Current theme not found", vim.log.levels.ERROR)
      return
    end

    if not theme.variants or #theme.variants == 0 then
      vim.notify("Theme '" .. settings.theme .. "' has no variants", vim.log.levels.WARN)
      return
    end

    vim.ui.select(theme.variants, {
      prompt = "Select variant for " .. settings.theme .. ":",
    }, function(choice)
      if choice then
        M.apply_theme(settings.theme, choice, options_from_settings(settings, nil))
        -- Show actual applied variant (may differ from requested due to bidirectional sync)
        local new_settings = M.load_settings()
        vim.notify("Variant: " .. (new_settings.variant or choice), vim.log.levels.INFO)
      end
    end)
  end, { desc = "Select variant for current theme" })

  -- Toggle background mode (dark/light)
  vim.api.nvim_create_user_command("ToggleBackground", function()
    local settings = M.load_settings()

    -- Use actual vim.o.background, not saved settings (which might be stale)
    local current_bg = vim.o.background or "dark"
    local new_bg = current_bg == "dark" and "light" or "dark"
    local theme = themes[settings.theme]
    local remembered = background_variants[settings.theme] or {}
    background_variants[settings.theme] = remembered
    remembered[current_bg] = settings.variant
    local variant = remembered[new_bg]
      or theme and theme.variant_for_background and theme.variant_for_background(new_bg)
    variant = sanitize_variant(theme, variant)
    if M.apply_theme(settings.theme, variant, options_from_settings(settings, new_bg)) then
      local actual = vim.o.background
      local level = actual == new_bg and vim.log.levels.INFO or vim.log.levels.WARN
      vim.notify(actual == new_bg and "Background: " .. actual or "Theme remains " .. actual, level)
    end
  end, { desc = "Toggle background mode (dark/light)" })

  vim.api.nvim_create_user_command("ToggleTransparency", function()
    local settings = M.load_settings()
    local transparency = not settings.transparency
    local background = vim.o.background or settings.background or "dark"

    if M.apply_theme(settings.theme, settings.variant, {
      background = background,
      transparency = transparency,
    }) then
      vim.notify("Transparency: " .. (transparency and "enabled" or "disabled"), vim.log.levels.INFO)
    end
  end, { desc = "Toggle background transparency" })

  -- System theme sync commands
  vim.api.nvim_create_user_command("SystemSync", function()
    M.sync(true)
  end, { desc = "Sync with system theme" })

  -- Color mode status command
  vim.api.nvim_create_user_command("ColorModeStatus", function()
    local settings = M.load_settings()
    local lines = {}

    local palette = M.load_active_palette()

    if not palette then
      table.insert(lines, "System Palette: not available")
      table.insert(lines, "")
    else
      table.insert(lines, "System Palette: " .. M.active_palette_file)
      table.insert(lines, "Source: " .. (palette.source or "unknown"))
      table.insert(lines, "Mode: " .. (palette.mode or "unknown"))
      table.insert(lines, "Palette Background: " .. (palette.bg or "unknown"))
      table.insert(lines, "")
    end

    table.insert(lines, "Current Theme: " .. (settings.theme or "none"))
    table.insert(lines, "Variant: " .. (settings.variant or "none"))
    table.insert(lines, "Background: " .. (settings.background or vim.o.background))
    table.insert(lines, "Transparency: " .. (settings.transparency and "enabled" or "disabled"))
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
  end, { desc = "Show color mode status" })

  vim.api.nvim_create_user_command("SystemDetect", function()
    if vim.fn.filereadable(M.system_theme_file) ~= 1 then
      vim.notify("System theme file not found: " .. M.system_theme_file, vim.log.levels.WARN)
      return
    end

    local scheme = normalize_conf_string(read_theme_conf("NVIM_SCHEME"))
    local variant = normalize_conf_string(read_theme_conf("NVIM_VARIANT"))

    if scheme then
      local msg = "System theme: " .. scheme
      if variant then
        msg = msg .. " (" .. variant .. ")"
      end
      local available = themes[scheme] and " [available]" or " [not available]"
      vim.notify(msg .. available, vim.log.levels.INFO)
    else
      vim.notify("No NVIM_SCHEME found in system theme file", vim.log.levels.WARN)
    end
  end, { desc = "Detect system theme" })

  vim.api.nvim_create_user_command("SystemListThemes", notify_available_themes, {
    desc = "List available themes for system",
  })
end

return M
