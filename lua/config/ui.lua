-- lua/config/ui.lua
-- Properly structured UI configuration with setup function for theme management

local M = {}

-- Persistence file for theme settings
local theme_cache_file = vim.fn.stdpath("cache") .. "/theme_settings.json"

-- Define all supported themes with their metadata
local themes = {
  ["gruvbox-material"] = {
    icon = "󰈰 ",
    variants = { "soft", "medium", "hard" },
    current_variant = "medium",
    setup = function(variant)
      if variant then
        vim.g.gruvbox_material_background = variant
      end
    end,
  },
  ["tokyonight"] = {
    icon = "󱣱 ",
    variants = { "storm", "moon", "night", "day" },
    current_variant = "storm",
    setup = function(variant)
      if variant then
        require("tokyonight").setup({ style = variant })
      end
    end,
  },
  ["everforest"] = {
    icon = "󰪶 ",
    variants = { "soft", "medium", "hard" },
    current_variant = "medium",
    setup = function(variant)
      if variant then
        vim.g.everforest_background = variant
      end
    end,
  },
  ["kanagawa"] = {
    icon = "󰖭 ",
    variants = { "wave", "dragon", "lotus" },
    current_variant = "wave",
    setup = function(variant)
      if variant then
        require("kanagawa").setup({ theme = variant })
      end
    end,
  },
  ["nord"] = {
    icon = "󰔿 ",
  },
  ["rose-pine"] = {
    icon = "󰔎 ",
    variants = { "main", "moon", "dawn" },
    current_variant = "main",
    setup = function(variant)
      if variant then
        require("rose-pine").setup({ variant = variant })
      end
    end,
  },
  ["catppuccin"] = {
    icon = "󰄛 ",
    variants = { "mocha", "macchiato", "frappe", "latte" },
    current_variant = "mocha",
    setup = function(variant)
      if variant then
        require("catppuccin").setup({ flavour = variant })
      end
    end,
  },
}

-- Load persisted theme settings
local function load_theme_settings()
  local settings = { theme = "gruvbox-material", variant = nil, transparency = false }

  -- Try to read from cache file
  local file = io.open(theme_cache_file, "r")
  if file then
    local content = file:read("*all")
    file:close()

    -- Parse JSON safely
    local ok, parsed = pcall(vim.fn.json_decode, content)
    if ok and type(parsed) == "table" then
      settings = parsed
    end
  end

  return settings
end

-- Save theme settings to cache file
local function save_theme_settings(settings)
  local file = io.open(theme_cache_file, "w")
  if file then
    local ok, json = pcall(vim.fn.json_encode, settings)
    if ok then
      file:write(json)
      file:close()
      return true
    else
      file:close()
    end
  end
  return false
end

-- Apply theme with error handling and UI refresh
local function apply_theme(theme_name, variant, transparency)
  local theme = themes[theme_name]
  if not theme then
    vim.notify(string.format("Theme '%s' not found", theme_name), vim.log.levels.ERROR)
    return false
  end

  -- Run theme-specific setup if available
  if theme.setup and variant then
    local ok, err = pcall(theme.setup, variant)
    if not ok then
      vim.notify(string.format("Failed to set variant for '%s': %s", theme_name, err), vim.log.levels.WARN)
    else
      -- Update current variant if successful
      if theme.variants and vim.tbl_contains(theme.variants, variant) then
        theme.current_variant = variant
      end
    end
  end

  -- Set transparency if specified
  if transparency ~= nil then
    -- Handle transparency for each theme
    if theme_name == "gruvbox-material" then
      vim.g.gruvbox_material_transparent_background = transparency and 1 or 0
    elseif theme_name == "tokyonight" then
      pcall(function()
        require("tokyonight").setup({ transparent = transparency })
      end)
    elseif theme_name == "everforest" then
      vim.g.everforest_transparent_background = transparency and 1 or 0
    elseif theme_name == "kanagawa" then
      pcall(function()
        require("kanagawa").setup({ transparent = transparency })
      end)
    elseif theme_name == "catppuccin" then
      pcall(function()
        require("catppuccin").setup({ transparent_background = transparency })
      end)
    elseif theme_name == "rose-pine" then
      pcall(function()
        require("rose-pine").setup({ disable_background = transparency })
      end)
    elseif theme_name == "nord" then
      vim.g.nord_disable_background = transparency
    end
  end

  -- Apply the theme
  local ok, err = pcall(vim.cmd, "colorscheme " .. theme_name)
  if not ok then
    vim.notify(string.format("Failed to apply theme '%s': %s", theme_name, err), vim.log.levels.ERROR)
    -- Fallback to gruvbox-material
    pcall(vim.cmd, "colorscheme gruvbox-material")
    return false
  end

  -- Save settings to persist between sessions
  save_theme_settings({
    theme = theme_name,
    variant = variant or theme.current_variant,
    transparency = transparency or false,
  })

  -- Force refresh of UI elements
  vim.defer_fn(function()
    -- Update UI component colors
    pcall(function()
      -- Refresh UI components that need updating with theme
      if package.loaded["lualine"] then
        require("lualine").refresh()
      end
      if package.loaded["bufferline"] then
        require("bufferline").setup()
      end
      -- Update additional components
      if _G.refresh_ui_colors and type(_G.refresh_ui_colors) == "function" then
        _G.refresh_ui_colors()
      end
    end)
  end, 10)

  local icon = theme.icon or "󱥸 " -- Default icon
  vim.notify(icon .. "Switched to " .. theme_name .. (variant and (" - " .. variant) or ""), vim.log.levels.INFO)

  return true
end

-- Cycle to next theme
local function cycle_theme()
  local current = vim.g.colors_name or "gruvbox-material"
  local theme_names = vim.tbl_keys(themes)
  table.sort(theme_names)

  -- Find current index
  local current_idx = 1
  for i, name in ipairs(theme_names) do
    if current == name then
      current_idx = i
      break
    end
  end

  -- Get next theme
  local next_idx = current_idx % #theme_names + 1
  local next_theme = theme_names[next_idx]

  -- Preserve current transparency setting
  local settings = load_theme_settings()
  apply_theme(next_theme, nil, settings.transparency)
end

-- The setup function that init.lua will call
function M.setup()
  -- Create commands for theme switching with better error handling
  vim.api.nvim_create_user_command("ColorSchemeToggle", function()
    cycle_theme()
  end, { desc = "Toggle between color schemes" })

  vim.api.nvim_create_user_command("ColorScheme", function(opts)
    local args = opts.args
    if args == "" then
      local available = {}
      for name, theme in pairs(themes) do
        table.insert(
          available,
          theme.icon .. " " .. name .. (theme.variants and (" (" .. table.concat(theme.variants, ", ") .. ")") or "")
        )
      end
      vim.notify("Available themes:\n" .. table.concat(available, "\n"), vim.log.levels.INFO)
      return
    end

    -- Parse theme name and variant
    local theme_name, variant = args:match("([%w-]+)%s*(.*)$")
    if variant == "" then
      variant = nil
    end

    -- Load current settings
    local settings = load_theme_settings()
    apply_theme(theme_name, variant, settings.transparency)
  end, {
    nargs = "?",
    desc = "Set colorscheme",
    complete = function()
      return vim.tbl_keys(themes)
    end,
  })

  -- Set up theme variant switching command
  vim.api.nvim_create_user_command("ColorSchemeVariant", function(opts)
    local current = vim.g.colors_name or "gruvbox-material"
    local theme = themes[current]

    if not theme or not theme.variants then
      vim.notify("Current theme doesn't have variants", vim.log.levels.WARN)
      return
    end

    local variant = opts.args
    if variant == "" then
      vim.notify(
        "Available variants for " .. current .. ": " .. table.concat(theme.variants, ", "),
        vim.log.levels.INFO
      )
      return
    end

    -- Load current settings and preserve transparency
    local settings = load_theme_settings()
    apply_theme(current, variant, settings.transparency)
  end, {
    nargs = "?",
    desc = "Set colorscheme variant",
    complete = function()
      local current = vim.g.colors_name or "gruvbox-material"
      local theme = themes[current]
      return theme and theme.variants or {}
    end,
  })

  -- Improved transparency toggle with better error handling
  vim.api.nvim_create_user_command("ToggleTransparency", function()
    -- Load current settings
    local settings = load_theme_settings()
    -- Toggle transparency
    settings.transparency = not settings.transparency

    -- Apply current theme with new transparency setting
    apply_theme(settings.theme, settings.variant, settings.transparency)

    vim.notify(
      "Transparency " .. (settings.transparency and "enabled" or "disabled") .. " for " .. settings.theme,
      vim.log.levels.INFO
    )
  end, { desc = "Toggle background transparency" })

  -- Initial theme setup based on persisted settings
  vim.defer_fn(function()
    local settings = load_theme_settings()
    if settings.theme then
      apply_theme(settings.theme, settings.variant, settings.transparency)
    else
      vim.cmd("colorscheme gruvbox-material")
    end
  end, 10)

  -- Map theme toggling keys
  local map = vim.keymap.set

  -- toggle between light/dark variants
  map("n", "<leader>tt", "<cmd>ColorSchemeToggle<cr>", {
    desc = "Toggle theme",
  })

  -- pick a colorscheme
  map("n", "<leader>ts", "<cmd>ColorScheme<cr>", {
    desc = "Select theme",
  })

  -- pick a variant of the current theme (if supported)
  map("n", "<leader>tv", "<cmd>ColorSchemeVariant<cr>", {
    desc = "Select theme variant",
  })

  -- toggle background transparency
  map("n", "<leader>tb", "<cmd>ToggleTransparency<cr>", {
    desc = "Toggle transparency",
  })
end

return M
