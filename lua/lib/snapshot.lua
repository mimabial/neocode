-- Runtime applier for snapshotted (frozen) colorschemes.
-- A snapshot captures a plugin's resolved highlights + terminal colors so the
-- theme renders identically with no plugin dependency. Data lives in
-- plugins/themes/definitions/data/<scheme>.lua.
local M = {}

-- Build a theme definition from a snapshot data module.
--   name  : colorscheme name to report as vim.g.colors_name
--   icon  : picker glyph
--   captures : list of {
--                variant?   = "<the plugin's own variant name>",
--                background = "dark"|"light",
--                palette    = { name = "#hex", ... },
--                terminal   = { [0..15] = "#hex" },
--                highlights = { Group = spec, ... } }
-- variant is absent for schemes with no variant axis; it is independent of
-- background, so neither is derivable from the other.
function M.definition(name, icon, captures)
  local variants, seen = {}, {}
  for _, capture in ipairs(captures) do
    if capture.variant and not seen[capture.variant] then
      seen[capture.variant] = true
      variants[#variants + 1] = capture.variant
    end
  end
  table.sort(variants)
  local has_variants = #variants > 0

  return {
    icon = icon,
    -- theme_manager reads nil as "no variant axis".
    variants = has_variants and variants or nil,
    -- Self-contained: apply_theme must not load the origin plugin for these.
    snapshot = true,
    setup = function(opts)
      local variant = nil
      if has_variants then
        variant = opts.variant
        if variant == nil or not seen[variant] then
          variant = variants[1]
        end
      end

      local function find(match)
        for _, capture in ipairs(captures) do
          if match(capture) then return capture end
        end
      end
      local snap = find(function(c)
        return c.variant == variant and c.background == opts.background
      end) or find(function(c)
        return c.variant == variant
      end) or captures[1]

      vim.o.background = snap.background
      if vim.g.colors_name then
        vim.cmd("highlight clear")
      end
      vim.g.colors_name = name

      for group, spec in pairs(snap.highlights) do
        vim.api.nvim_set_hl(0, group, spec)
      end

      if snap.terminal then
        for i = 0, 15 do
          vim.g["terminal_color_" .. i] = snap.terminal[i]
        end
      end

      -- Applying via set_hl (not :colorscheme) skips the ColorScheme event, so
      -- fire it for downstream listeners (terminal_sync's OSC bg/cursor push to
      -- kitty, bufferline re-setup, etc.) — exactly as a hand-written scheme does.
      -- Fire under a sentinel pattern, not `name`: lazy.nvim keys a ColorScheme
      -- handler on each plugin's colorscheme name, so firing `name` would load
      -- the very plugin this snapshot exists to replace. Our listeners register
      -- with `*` and read vim.g.colors_name, so they still run.
      vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "snapshot:" .. name })
    end,
  }
end

return M
