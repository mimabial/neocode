-- Theme Manager Module
-- Handles theme persistence, application, and system integration
--
-- Configuration via environment variables:
--   HYPR_THEME_CONF - Path to Hyprland theme metadata file (highest priority)
--   XDG_CONFIG_HOME - If set, uses $XDG_CONFIG_HOME/hypr/themes/theme.meta
--   Default: ~/.config/hypr/themes/theme.meta

local M = {}

M.cache_dir = vim.fn.stdpath("cache")
M.settings_file = M.cache_dir .. "/theme_settings.json"

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
    theme = data and data.theme or "kanagawa",
    variant = data and data.variant or nil,
    background = normalize_background(data and data.background) or "dark",
    transparency = normalize_transparency(data and data.transparency),
  }
end

local function theme_options(settings, background)
  return {
    background = background,
    transparency = settings.transparency,
  }
end

local function normalize_apply_options(options)
  return {
    background = options and options.background or nil,
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
  local content = vim.json.encode(normalized)
  vim.fn.writefile({ content }, M.settings_file)
end

-- Load all theme definitions
function M.load_themes()
  local themes = {}
  local def_path = vim.fn.stdpath("config") .. "/lua/plugins/themes/definitions"

  -- Get all theme definition files
  local files = vim.fn.glob(def_path .. "/*.lua", false, true)

  for _, file in ipairs(files) do
    local theme_name = vim.fn.fnamemodify(file, ":t:r")
    local ok, theme_def = pcall(require, "plugins.themes.definitions." .. theme_name)
    if ok and theme_def then
      themes[theme_name] = theme_def
    end
  end

  return themes
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

-- Apply a theme
-- @param theme_name string - Theme name
-- @param variant string|nil - Variant name (optional)
-- @param themes table - All loaded themes
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

-- @param options table - { background = "dark"|"light"|nil, transparency = boolean }
function M.apply_theme(theme_name, variant, themes, options)
  local theme = themes[theme_name]
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

  -- Don't default background here - let themes handle nil
  -- They can derive from variant or use vim.o.background as fallback

  -- Ensure lazy.nvim loads the plugin before applying (plugin-backed defs only).
  -- Snapshot defs are self-contained; loading their origin plugin is needless
  -- and defeats the point, so skip it.
  pcall(require, "lazy")
  local lazy_config = package.loaded["lazy.core.config"]
  if lazy_config and not theme.snapshot then
    -- Map of theme names to their plugin names (for special cases)
    local theme_to_plugin = {
      ayu = "neovim-ayu",
    }

    local plugin_to_load = nil

    -- Check special cases first
    if theme_to_plugin[theme_name] then
      plugin_to_load = theme_to_plugin[theme_name]
    -- Try exact matches
    elseif lazy_config.plugins[theme_name] then
      plugin_to_load = theme_name
    elseif lazy_config.plugins[theme_name .. ".nvim"] then
      plugin_to_load = theme_name .. ".nvim"
    else
      -- Try partial match - find plugin whose name ends with our theme name
      for plugin_name, _ in pairs(lazy_config.plugins) do
        if plugin_name:match(theme_name .. "$") or plugin_name:match(theme_name .. "%.nvim$") then
          plugin_to_load = plugin_name
          break
        end
      end
    end

    if plugin_to_load and not lazy_config.plugins[plugin_to_load]._.loaded then
      require("lazy").load({ plugins = { plugin_to_load } })
    end
  end

  -- Apply theme with opts table for flexible parameter handling
  local ok, err = pcall(theme.setup, {
    variant = variant,
    transparency = options.transparency,
    background = options.background,
  })
  if not ok then
    vim.notify("Error applying theme: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  if options.transparency then
    apply_transparency()
  end

  -- Save settings after setup
  -- Try to detect actual variant from colors_name (e.g., "tokyonight-day" -> "day")
  local actual_variant = variant
  local colors_name = vim.g.colors_name or ""
  -- Escape special pattern characters in theme_name (especially hyphens like in "rose-pine")
  local theme_pattern = theme_name:gsub("([%-%.%+%[%]%(%)%$%^%%%?%*])", "%%%1")
  if colors_name:match("^" .. theme_pattern .. "%-") then
    local detected = colors_name:gsub("^" .. theme_pattern .. "%-", "")
    -- Only use detected variant if it's a known variant for this theme
    if theme.variants then
      for _, v in ipairs(theme.variants) do
        if v == detected then
          actual_variant = detected
          break
        end
      end
    end
  end

  M.save_settings({
    theme = theme_name,
    variant = actual_variant,
    background = vim.o.background or "dark",
    transparency = options.transparency,
  })

  return true
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

-- Check if HyDE/Hyprland theming is available
function M.is_hyde_available()
  return vim.fn.filereadable(M.active_palette_file) == 1
end

-- Apply the active system theme.
-- Theme metadata may pin a Neovim colorscheme/variant; otherwise the active
-- Hypr palette is applied through the pywal definition.
function M.apply_system_theme(themes)
  local settings = M.load_settings()

  local active_palette = M.load_active_palette()
  local system_scheme = normalize_conf_string(read_theme_conf("NVIM_SCHEME"))
  local system_variant = normalize_conf_string(read_theme_conf("NVIM_VARIANT"))
  local conf_background = normalize_background(read_theme_conf("NVIM_BACKGROUND"))
    or normalize_background(read_theme_conf("COLOR_SCHEME"))
  local conf_transparency = parse_conf_transparency(read_theme_conf("NVIM_TRANSPARENCY"))

  local background = conf_background or active_palette and active_palette_background(active_palette) or settings.background
  if background then
    vim.o.background = background
  end

  local opts = theme_options(settings, background)
  if conf_transparency ~= nil then
    opts.transparency = conf_transparency
  end

  if system_scheme then
    if themes[system_scheme] then
      return M.apply_theme(system_scheme, system_variant, themes, opts)
    end
    vim.notify("System NVIM_SCHEME not found: " .. system_scheme .. "; falling back to pywal", vim.log.levels.WARN)
  end

  if not active_palette or not themes.pywal then
    return false
  end

  return M.apply_theme("pywal", nil, themes, opts)
end

-- Update Hyprland config with current theme
function M.update_hyprland_config(theme_name, variant)
  if vim.fn.filereadable(M.system_theme_file) ~= 1 then
    vim.notify("Hyprland theme config not found", vim.log.levels.WARN)
    return
  end

  local content = vim.fn.readfile(M.system_theme_file)
  local updated_scheme = false
  local updated_variant = false

  for i, line in ipairs(content) do
    if line:match("^%$NVIM_SCHEME") then
      content[i] = "$NVIM_SCHEME = " .. theme_name
      updated_scheme = true
    elseif line:match("^%$NVIM_VARIANT") then
      content[i] = "$NVIM_VARIANT = " .. (variant or "")
      updated_variant = true
    end
  end

  -- Add lines if they don't exist
  if not updated_scheme then
    table.insert(content, 1, "$NVIM_SCHEME = " .. theme_name)
  end
  if not updated_variant and variant then
    for i, line in ipairs(content) do
      if line:match("^%$NVIM_SCHEME") then
        table.insert(content, i + 1, "$NVIM_VARIANT = " .. variant)
        break
      end
    end
  end

  pcall(vim.fn.writefile, content, M.system_theme_file)

  -- Notify other nvim instances to reload theme
  vim.fn.jobstart(vim.fn.expand("~/.local/lib/hypr/util/nvim-theme-sync.sh"), { detach = true })

  vim.notify(
    "Updated system theme: " .. theme_name .. (variant and ("-" .. variant) or ""),
    vim.log.levels.INFO
  )
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

-- Setup theme sync (directory watchers + focus repair)
function M.setup_focus_sync(themes)
  local group = vim.api.nvim_create_augroup("ThemeSync", { clear = true })

  -- Files to watch for changes (external config files only, not our cache)
  local watch_files = {
    M.active_palette_file,
    M.system_theme_file,
  }

  -- Track exact file snapshots so same-second writes and atomic replaces are detected.
  local snapshots = {}
  for _, file in ipairs(watch_files) do
    snapshots[file] = read_watch_snapshot(file)
  end

  -- Check if any watched file changed
  local function check_for_changes()
    local changed = false
    for _, file in ipairs(watch_files) do
      local snapshot = read_watch_snapshot(file)
      if snapshots[file] ~= snapshot then
        snapshots[file] = snapshot
        changed = true
      end
    end
    return changed
  end

  -- Apply theme if files changed
  local function sync_theme()
    if check_for_changes() then
      M.apply_system_theme(themes)
    end
  end

  local sync_pending = false
  local function request_sync()
    if sync_pending then
      return
    end

    sync_pending = true
    vim.schedule(function()
      sync_pending = false
      sync_theme()
    end)
  end

  -- Watch parent directories so atomic file replacement still produces events.
  local watchers = {}
  local watch_dirs = {}
  for _, file in ipairs(watch_files) do
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
    callback = function()
      if M._file_watchers then
        for _, w in ipairs(M._file_watchers) do
          pcall(function() w:stop() end)
        end
      end
    end,
  })
end

-- Register user commands
function M.register_commands(themes)
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
          M.apply_theme(theme_name, choice, themes, theme_options(settings, settings.background))
        end
      end)
    else
      M.apply_theme(theme_name, nil, themes, theme_options(settings, settings.background))
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
    if M.apply_theme(theme_name, requested_variant, themes, theme_options(settings, settings.background)) then
      local applied = M.load_settings()
      M.update_hyprland_config(applied.theme, applied.variant)
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
    M.apply_theme(next_theme, nil, themes, theme_options(settings, settings.background))
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
              M.apply_theme(choice.name, variant, themes, theme_options(settings, settings.background))
            end
          end)
        else
          M.apply_theme(choice.name, nil, themes, theme_options(settings, settings.background))
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

    M.apply_theme(settings.theme, next_variant, themes, theme_options(settings, nil))

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
        M.apply_theme(settings.theme, choice, themes, theme_options(settings, nil))
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
    M.apply_theme(settings.theme, settings.variant, themes, theme_options(settings, new_bg))

    vim.notify("Background: " .. new_bg, vim.log.levels.INFO)
  end, { desc = "Toggle background mode (dark/light)" })

  vim.api.nvim_create_user_command("ToggleTransparency", function()
    local settings = M.load_settings()
    local transparency = not settings.transparency
    local background = vim.o.background or settings.background or "dark"

    if M.apply_theme(settings.theme, settings.variant, themes, {
      background = background,
      transparency = transparency,
    }) then
      vim.notify("Transparency: " .. (transparency and "enabled" or "disabled"), vim.log.levels.INFO)
    end
  end, { desc = "Toggle background transparency" })

  -- System theme sync commands
  vim.api.nvim_create_user_command("SystemSync", function()
    M.apply_system_theme(themes)
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
