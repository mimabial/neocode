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
      return data
    end
  end
  return { theme = "kanagawa", variant = nil, transparency = false }
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
function M.apply_theme(theme_name, variant, transparency, themes)
  local theme = themes[theme_name]
  if not theme then
    vim.notify("Theme '" .. theme_name .. "' not found", vim.log.levels.ERROR)
    return false
  end

  -- Save settings
  M.save_settings({
    theme = theme_name,
    variant = variant,
    transparency = transparency or false,
  })

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

    if plugin_to_load then
      require("lazy").load({ plugins = { plugin_to_load } })
    end
  end

  -- Apply theme
  local ok, err = pcall(theme.setup, variant, transparency)
  if not ok then
    vim.notify("Error applying theme: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  return true
end

-- Apply system theme from Hyprland config
function M.apply_system_theme(themes)
  if vim.fn.filereadable(M.system_theme_file) ~= 1 then
    vim.notify("System theme file not readable", vim.log.levels.WARN)
    return false
  end

  local content = vim.fn.readfile(M.system_theme_file)
  local scheme, variant

  -- Skip if file is empty (happens during write operations)
  if #content == 0 then
    return false
  end

  -- Debug: Write to log file
  local debug_log = io.open("/tmp/nvim-theme-debug.log", "a")
  if debug_log then
    debug_log:write("\n=== " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===\n")
    debug_log:write("File: " .. M.system_theme_file .. "\n")
    debug_log:write("Lines: " .. #content .. "\n")
    for i, line in ipairs(content) do
      debug_log:write(string.format("Line %d: [%s]\n", i, line))
    end
  end

  for _, line in ipairs(content) do
    if line:match("^%$NVIM_SCHEME") then
      local match = line:match("=%s*(.+)")
      if match then
        scheme = match:gsub("%s+$", "")
        if debug_log then
          debug_log:write("Extracted scheme: [" .. scheme .. "]\n")
        end
      end
    elseif line:match("^%$NVIM_VARIANT") then
      local match = line:match("=%s*(.+)")
      if match then
        variant = match:gsub("%s+$", "")
        if variant == "" then
          variant = nil
        end
        if debug_log then
          debug_log:write("Extracted variant: [" .. (variant or "empty") .. "]\n")
        end
      end
    end
  end

  if debug_log then
    debug_log:write("Final scheme: " .. (scheme or "none") .. "\n")
    debug_log:write("Final variant: " .. (variant or "none") .. "\n")
    debug_log:write("Themes table type: " .. type(themes) .. "\n")
    if type(themes) == "table" then
      debug_log:write("Themes table keys: ")
      for k in pairs(themes) do
        debug_log:write(k .. ", ")
      end
      debug_log:write("\n")
      debug_log:write("themes[" .. (scheme or "nil") .. "] = " .. tostring(themes[scheme or ""]) .. "\n")
    end
    debug_log:close()
  end

  -- Don't apply if no valid scheme found
  if not scheme then
    local log = io.open("/tmp/nvim-theme-debug.log", "a")
    if log then
      log:write("Returning false: no scheme found\n")
      log:close()
    end
    return false
  end

  local log = io.open("/tmp/nvim-theme-debug.log", "a")
  if log then
    log:write("About to notify detected scheme\n")
    log:close()
  end

  vim.notify("Detected scheme: " .. scheme .. ", variant: " .. (variant or "none"), vim.log.levels.INFO)

  log = io.open("/tmp/nvim-theme-debug.log", "a")
  if log then
    log:write("After notify, checking if themes[" .. scheme .. "] exists\n")
    log:close()
  end

  if themes[scheme] then
    local settings = M.load_settings()
    vim.notify("Applying theme: " .. scheme, vim.log.levels.INFO)

    log = io.open("/tmp/nvim-theme-debug.log", "a")
    if log then
      log:write("Calling M.apply_theme\n")
      log:close()
    end

    local ok, err = pcall(M.apply_theme, scheme, variant, settings.transparency, themes)

    log = io.open("/tmp/nvim-theme-debug.log", "a")
    if log then
      log:write("apply_theme result: " .. tostring(ok) .. ", error: " .. tostring(err) .. "\n")
      log:close()
    end

    return ok
  else
    vim.notify("Scheme not found in themes: " .. (scheme or "none"), vim.log.levels.WARN)
  end

  return false
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

-- Setup focus-based theme sync (check when returning to Neovim)
function M.setup_focus_sync(themes)
  if vim.fn.filereadable(M.system_theme_file) ~= 1 then
    return
  end

  -- Track last modification time to avoid unnecessary reloads
  local stat = vim.loop.fs_stat(M.system_theme_file)
  if not stat then
    return
  end
  M.last_theme_mtime = stat.mtime.sec

  local group = vim.api.nvim_create_augroup("ThemeFocusSync", { clear = true })

  -- Check for theme changes when Neovim gains focus
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      local current_stat = vim.loop.fs_stat(M.system_theme_file)
      if current_stat and current_stat.mtime.sec ~= M.last_theme_mtime then
        M.last_theme_mtime = current_stat.mtime.sec
        M.apply_system_theme(themes)

        -- Notify other nvim instances to reload theme
        vim.fn.jobstart(vim.fn.expand("~/.local/lib/hypr/util/nvim-theme-sync.sh"), { detach = true })
      end
    end,
    desc = "Sync with system theme when Neovim gains focus",
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
    if theme.variants and #theme.variants > 0 then
      vim.ui.select(theme.variants, {
        prompt = "Select variant:",
      }, function(choice)
        if choice then
          M.apply_theme(theme_name, choice, M.load_settings().transparency, themes)
        end
      end)
    else
      M.apply_theme(theme_name, nil, M.load_settings().transparency, themes)
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
    M.apply_theme(settings.theme, settings.variant, settings.transparency, themes)
    vim.notify("Transparency: " .. (settings.transparency and "ON" or "OFF"), vim.log.levels.INFO)
  end, { desc = "Toggle theme transparency" })

  vim.api.nvim_create_user_command("SystemSetTheme", function(opts)
    local theme_name = opts.args ~= "" and opts.args or M.load_settings().theme
    local settings = M.load_settings()

    M.update_hyprland_config(theme_name, settings.variant)
    M.apply_theme(theme_name, settings.variant, settings.transparency, themes)
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
end

return M
