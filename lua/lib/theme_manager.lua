-- Theme Manager Module
-- Handles theme persistence, application, and system integration
--
-- Configuration via environment variables:
--   HYPR_THEME_CONF - Path to Hyprland theme config file (highest priority)
--   XDG_CONFIG_HOME - If set, uses $XDG_CONFIG_HOME/hypr/themes/theme.conf
--   Default: ~/.config/hypr/themes/theme.conf

local M = {}

M.cache_dir = vim.fn.stdpath("cache")
M.settings_file = M.cache_dir .. "/theme_settings.json"

-- System theme configuration (can be overridden via environment variables)
M.system_theme_file = vim.env.HYPR_THEME_CONF
  or vim.env.XDG_CONFIG_HOME and (vim.env.XDG_CONFIG_HOME .. "/hypr/themes/theme.conf")
  or vim.fn.expand("~/.config/hypr/themes/theme.conf")

-- Load theme settings from cache
function M.load_settings()
  local ok, content = pcall(vim.fn.readfile, M.settings_file)
  if ok and content[1] then
    local success, data = pcall(vim.json.decode, content[1])
    if success then
      -- Ensure background field exists (migration from old format)
      if data.background == nil then
        data.background = "dark"
      end
      return data
    end
  end
  return { theme = "kanagawa", variant = nil, background = "dark", transparency = false }
end

-- Save theme settings to cache
function M.save_settings(settings)
  vim.fn.mkdir(M.cache_dir, "p")
  local content = vim.json.encode(settings)
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

-- Apply a theme
-- @param theme_name string - Theme name
-- @param variant string|nil - Variant name (optional)
-- @param transparency boolean - Enable transparency
-- @param themes table - All loaded themes
-- @param background string|nil - "dark" or "light" (optional, inferred from variant if not provided)
function M.apply_theme(theme_name, variant, transparency, themes, background)
  local theme = themes[theme_name]
  if not theme then
    vim.notify("Theme '" .. theme_name .. "' not found", vim.log.levels.ERROR)
    return false
  end

  -- Don't default background here - let themes handle nil
  -- They can derive from variant or use vim.o.background as fallback

  -- Ensure lazy.nvim loads the plugin before applying
  -- This is needed for lazy-loaded colorscheme plugins
  pcall(require, "lazy")
  local lazy_config = package.loaded["lazy.core.config"]
  if lazy_config then
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
    transparency = transparency,
    background = background,
  })
  if not ok then
    vim.notify("Error applying theme: " .. tostring(err), vim.log.levels.ERROR)
    return false
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
    transparency = transparency or false,
  })

  return true
end

-- State file for reading color mode
M.staterc_file = vim.fn.expand("~/.local/state/hypr/staterc")
M.auto_theme_state = vim.fn.expand("~/.local/state/hypr/auto_theme_state.json")

-- Color modes: 0=Theme, 1=Auto(wallpaper), 2=Dark(wallpaper), 3=Light(wallpaper), 4=AutoDetect(daemon)
M.COLOR_MODE = {
  THEME = 0,
  WALLPAPER_AUTO = 1,
  WALLPAPER_DARK = 2,
  WALLPAPER_LIGHT = 3,
  AUTO_DETECT = 4,
}

-- Read a variable from staterc
local function read_staterc(var_name)
  if vim.fn.filereadable(M.staterc_file) ~= 1 then
    return nil
  end
  local content = vim.fn.readfile(M.staterc_file)
  for _, line in ipairs(content) do
    local match = line:match("^" .. var_name .. '="?([^"]*)"?')
    if match then
      return match
    end
  end
  return nil
end

-- Read variables from theme.conf (Hyprland format: $VAR = value)
local function read_theme_conf(var_name)
  if vim.fn.filereadable(M.system_theme_file) ~= 1 then
    return nil
  end
  local content = vim.fn.readfile(M.system_theme_file)
  for _, line in ipairs(content) do
    if line:match("^%$" .. var_name) then
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

-- Get current color mode from staterc
function M.get_color_mode()
  local mode = read_staterc("enableWallDcol")
  return tonumber(mode) or 0
end

-- Check if HyDE/Hyprland theming is available
function M.is_hyde_available()
  return vim.fn.filereadable(M.system_theme_file) == 1
    or vim.fn.filereadable(M.staterc_file) == 1
end

-- Apply system theme based on current color mode
-- Returns true if system theme was applied, false to use fallback
function M.apply_system_theme(themes)
  local settings = M.load_settings()

  -- If no HyDE integration, return false to use fallback
  if not M.is_hyde_available() then
    return false
  end

  local color_mode = M.get_color_mode()

  -- Read theme.conf values (used in Theme mode, fallback in others)
  local conf_scheme = read_theme_conf("NVIM_SCHEME")
  local conf_variant = read_theme_conf("NVIM_VARIANT")
  local conf_background = read_theme_conf("NVIM_BACKGROUND")
  local conf_transparency = read_theme_conf("NVIM_TRANSPARENCY")

  local scheme, variant, background, transparency

  if color_mode == M.COLOR_MODE.THEME then
    -- Theme Mode: Use all values from theme.conf
    -- If theme.conf doesn't have NVIM_SCHEME, fall back to saved settings
    if not conf_scheme then
      return false -- Let colorscheme.lua use fallback
    end
    scheme = conf_scheme
    variant = conf_variant
    background = conf_background  -- Let theme derive from variant if nil
    transparency = conf_transparency == "true"

  elseif color_mode == M.COLOR_MODE.AUTO_DETECT then
    -- Auto Detect Mode: Use auto_theme daemon's settings
    background = "dark" -- default
    if vim.fn.filereadable(M.auto_theme_state) == 1 then
      local ok, state = pcall(function()
        local content = vim.fn.readfile(M.auto_theme_state)
        return vim.json.decode(content[1] or "{}")
      end)
      if ok and state and state.current_mode then
        background = state.current_mode
      end
    end
    -- Use saved theme, but override background from daemon
    scheme = settings.theme
    variant = settings.variant
    transparency = settings.transparency

  else
    -- Wallpaper Modes (Auto/Dark/Light): Follow system background mode
    local sys_background = read_staterc("BACKGROUND_MODE")

    if color_mode == M.COLOR_MODE.WALLPAPER_DARK then
      background = "dark"
    elseif color_mode == M.COLOR_MODE.WALLPAPER_LIGHT then
      background = "light"
    else
      -- Auto mode - use pywal's detection or BACKGROUND_MODE from staterc
      background = sys_background or "dark"
    end

    -- Use saved theme settings, but override background
    scheme = settings.theme
    variant = settings.variant
    transparency = settings.transparency
  end

  -- Validate scheme - if not found in themes, return false for fallback
  if not scheme or not themes[scheme] then
    return false
  end

  -- Set vim.o.background before applying theme
  if background then
    vim.o.background = background
  end

  -- Apply the theme
  return M.apply_theme(scheme, variant, transparency, themes, background)
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

-- Setup theme sync (file watcher + focus-based fallback)
function M.setup_focus_sync(themes)
  local group = vim.api.nvim_create_augroup("ThemeSync", { clear = true })

  -- Files to watch for changes (external config files only, not our cache)
  local watch_files = {
    M.system_theme_file,
    M.staterc_file,
    M.auto_theme_state,
  }

  -- Track modification times
  local mtimes = {}
  for _, file in ipairs(watch_files) do
    local stat = vim.loop.fs_stat(file)
    if stat then
      mtimes[file] = stat.mtime.sec
    end
  end

  -- Check if any watched file changed
  local function check_for_changes()
    local changed = false
    for _, file in ipairs(watch_files) do
      local stat = vim.loop.fs_stat(file)
      if stat then
        if mtimes[file] ~= stat.mtime.sec then
          mtimes[file] = stat.mtime.sec
          changed = true
        end
      end
    end
    return changed
  end

  -- Apply theme if files changed
  local function sync_theme()
    if check_for_changes() then
      -- Reload settings and apply
      local settings = M.load_settings()
      if settings.background then
        vim.o.background = settings.background
      end
      M.apply_system_theme(themes)
    end
  end

  -- Method 1: File watcher using libuv (real-time updates)
  local watchers = {}
  for _, file in ipairs(watch_files) do
    if vim.fn.filereadable(file) == 1 then
      local watcher = vim.loop.new_fs_event()
      if watcher then
        local ok = pcall(function()
          watcher:start(file, {}, vim.schedule_wrap(function(err, filename, events)
            if not err then
              sync_theme()
            end
          end))
        end)
        if ok then
          table.insert(watchers, watcher)
        end
      end
    end
  end

  -- Store watchers to prevent garbage collection
  M._file_watchers = watchers

  -- Method 2: Focus-based sync (fallback for terminals that don't support file watching)
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = sync_theme,
    desc = "Sync with system theme when Neovim gains focus",
  })

  -- Method 3: Timer-based polling (fallback, only if file watchers failed)
  -- Can be enabled via: vim.g.theme_sync_poll_interval = 5000 (ms)
  local poll_interval = vim.g.theme_sync_poll_interval
  if poll_interval and poll_interval > 0 then
    local timer = vim.loop.new_timer()
    if timer then
      timer:start(poll_interval, poll_interval, vim.schedule_wrap(sync_theme))
      M._sync_timer = timer
    end
  elseif #watchers == 0 then
    -- No file watchers succeeded, enable polling as fallback
    local timer = vim.loop.new_timer()
    if timer then
      timer:start(5000, 5000, vim.schedule_wrap(sync_theme))
      M._sync_timer = timer
    end
  end

  -- Cleanup on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if M._file_watchers then
        for _, w in ipairs(M._file_watchers) do
          pcall(function() w:stop() end)
        end
      end
      if M._sync_timer then
        pcall(function() M._sync_timer:stop() end)
      end
    end,
  })
end

-- Register user commands
function M.register_commands(themes)
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
          M.apply_theme(theme_name, choice, settings.transparency, themes, settings.background)
        end
      end)
    else
      M.apply_theme(theme_name, nil, settings.transparency, themes, settings.background)
    end
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_keys(themes)
    end,
    desc = "Switch colorscheme theme",
  })

  vim.api.nvim_create_user_command("ThemeTransparency", function()
    local settings = M.load_settings()
    settings.transparency = not settings.transparency
    M.apply_theme(settings.theme, settings.variant, settings.transparency, themes, settings.background)
    vim.notify("Transparency: " .. (settings.transparency and "ON" or "OFF"), vim.log.levels.INFO)
  end, { desc = "Toggle theme transparency" })

  vim.api.nvim_create_user_command("SystemSetTheme", function(opts)
    local theme_name = opts.args ~= "" and opts.args or M.load_settings().theme
    local settings = M.load_settings()

    M.update_hyprland_config(theme_name, settings.variant)
    M.apply_theme(theme_name, settings.variant, settings.transparency, themes, settings.background)
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_keys(themes)
    end,
    desc = "Set system theme in Hyprland config",
  })

  vim.api.nvim_create_user_command("ThemeList", function()
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
  end, { desc = "List all available themes" })

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
    M.apply_theme(next_theme, nil, settings.transparency, themes, settings.background)
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
              M.apply_theme(choice.name, variant, settings.transparency, themes, settings.background)
            end
          end)
        else
          M.apply_theme(choice.name, nil, settings.transparency, themes, settings.background)
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

    M.apply_theme(settings.theme, next_variant, settings.transparency, themes, nil)

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
        M.apply_theme(settings.theme, choice, settings.transparency, themes, nil)
        -- Show actual applied variant (may differ from requested due to bidirectional sync)
        local new_settings = M.load_settings()
        vim.notify("Variant: " .. (new_settings.variant or choice), vim.log.levels.INFO)
      end
    end)
  end, { desc = "Select variant for current theme" })

  -- Toggle background transparency (alias for ThemeTransparency)
  vim.api.nvim_create_user_command("ToggleBackgroundTransparency", function()
    local settings = M.load_settings()
    settings.transparency = not settings.transparency
    M.apply_theme(settings.theme, settings.variant, settings.transparency, themes, settings.background)
    vim.notify("Transparency: " .. (settings.transparency and "ON" or "OFF"), vim.log.levels.INFO)
  end, { desc = "Toggle background transparency" })

  -- Toggle background mode (dark/light)
  vim.api.nvim_create_user_command("ToggleBackground", function()
    local settings = M.load_settings()

    -- Use actual vim.o.background, not saved settings (which might be stale)
    local current_bg = vim.o.background or "dark"
    local new_bg = current_bg == "dark" and "light" or "dark"
    M.apply_theme(settings.theme, settings.variant, settings.transparency, themes, new_bg)

    vim.notify("Background: " .. new_bg, vim.log.levels.INFO)
  end, { desc = "Toggle background mode (dark/light)" })

  -- System theme sync commands
  vim.api.nvim_create_user_command("SystemSync", function()
    M.apply_system_theme(themes)
  end, { desc = "Sync with system theme" })

  -- Color mode status command
  vim.api.nvim_create_user_command("ColorModeStatus", function()
    local settings = M.load_settings()
    local lines = {}

    if not M.is_hyde_available() then
      table.insert(lines, "HyDE Integration: not available (standalone mode)")
      table.insert(lines, "")
    else
      local mode = M.get_color_mode()
      local mode_names = { [0] = "Theme", [1] = "Auto (Wallpaper)", [2] = "Dark (Wallpaper)", [3] = "Light (Wallpaper)", [4] = "Auto Detect (Daemon)" }
      local mode_name = mode_names[mode] or "Unknown"
      table.insert(lines, "Color Mode: " .. mode_name .. " (enableWallDcol=" .. mode .. ")")

      if mode == M.COLOR_MODE.AUTO_DETECT then
        if vim.fn.filereadable(M.auto_theme_state) == 1 then
          local ok, state = pcall(function()
            local content = vim.fn.readfile(M.auto_theme_state)
            return vim.json.decode(content[1] or "{}")
          end)
          if ok and state then
            table.insert(lines, "Daemon Mode: " .. (state.current_mode or "unknown"))
            table.insert(lines, "Last Change: " .. (state.last_change or "never"))
          end
        else
          table.insert(lines, "Daemon: not running")
        end
      end
      table.insert(lines, "")
    end

    table.insert(lines, "Current Theme: " .. (settings.theme or "none"))
    table.insert(lines, "Variant: " .. (settings.variant or "none"))
    table.insert(lines, "Background: " .. (settings.background or vim.o.background))
    table.insert(lines, "Transparency: " .. tostring(settings.transparency))

    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
  end, { desc = "Show color mode status" })

  vim.api.nvim_create_user_command("SystemDetect", function()
    if vim.fn.filereadable(M.system_theme_file) ~= 1 then
      vim.notify("System theme file not found: " .. M.system_theme_file, vim.log.levels.WARN)
      return
    end

    local content = vim.fn.readfile(M.system_theme_file)
    local scheme, variant

    for _, line in ipairs(content) do
      if line:match("^%$NVIM_SCHEME") then
        local match = line:match("=%s*(.+)")
        if match then
          scheme = match:gsub("%s+$", "")
        end
      elseif line:match("^%$NVIM_VARIANT") then
        local match = line:match("=%s*(.+)")
        if match then
          variant = match:gsub("%s+$", "")
          if variant == "" then
            variant = nil
          end
        end
      end
    end

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

  vim.api.nvim_create_user_command("SystemListThemes", function()
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
  end, { desc = "List available themes for system" })
end

return M
