local M = {}

-- Only use pcall for external dependencies that might not be installed
M.safe_require = function(mod)
  local ok, result = pcall(require, mod)
  if not ok then
    return nil
  end
  return result
end

-- For plugin setup - fail fast if plugin is expected to be there
M.setup_plugin = function(name, opts)
  local plugin = require(name)
  if type(plugin.setup) == "function" then
    plugin.setup(opts or {})
  else
    vim.notify("Plugin " .. name .. " has no setup function", vim.log.levels.WARN)
  end
end

-- For optional features - graceful degradation
M.try_feature = function(fn, fallback, desc)
  local ok, result = pcall(fn)
  if not ok then
    if fallback then
      return fallback()
    end
    if desc then
      vim.notify("Feature '" .. desc .. "' failed to load", vim.log.levels.DEBUG)
    end
    return nil
  end
  return result
end

-- Color extraction with single fallback (not 3+ layers)
M.get_hl_color = function(group, attr, fallback)
  local hl = vim.api.nvim_get_hl(0, { name = group })
  local val = hl[attr]
  if not val then
    return fallback
  end
  return type(val) == "number" and string.format("#%06x", val) or tostring(val)
end

-- Plugin availability check (better than repeated pcalls)
M.has_plugin = function(name)
  return require("lazy.core.config").plugins[name] ~= nil
end

-- Example of improved plugin configuration
M.configure_plugin = function(name, config_fn)
  if not M.has_plugin(name) then
    return
  end

  local plugin = require(name)
  config_fn(plugin)
end

-- Simplified theme management without excessive fallbacks
M.apply_theme = function(theme_name, variant)
  local themes = {
    kanagawa = function(v)
      require("kanagawa").setup({ theme = v or "wave" })
      vim.cmd("colorscheme kanagawa")
    end,
    gruvbox = function(v)
      if v then vim.o.background = v end
      vim.cmd("colorscheme gruvbox")
    end,
    -- Add other themes...
  }

  local theme_fn = themes[theme_name]
  if theme_fn then
    theme_fn(variant)
  else
    vim.notify("Unknown theme: " .. theme_name, vim.log.levels.WARN)
    vim.cmd("colorscheme habamax") -- Single fallback
  end
end

return M
