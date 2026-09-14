-- Runtime applier for snapshotted (frozen) colorschemes.
-- A snapshot captures a plugin's resolved highlights + terminal colors so the
-- theme renders identically with no plugin dependency. Data lives in
-- plugins/themes/definitions/data/<scheme>.lua.
local set_background = require("lib.background").set

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
  local function find(match)
    for _, capture in ipairs(captures) do
      if match(capture) then return capture end
    end
  end

  return {
    icon = icon,
    -- theme_manager reads nil as "no variant axis".
    variants = has_variants and variants or nil,
    -- Self-contained: apply_theme must not load the origin plugin for these.
    snapshot = true,
    variant_for_background = function(background)
      local capture = find(function(c) return c.background == background end)
      return capture and capture.variant
    end,
    setup = function(opts)
      local snap
      if opts.background then
        snap = find(function(c)
          return (not opts.variant or c.variant == opts.variant) and c.background == opts.background
        end)
      end
      if not snap and opts.variant then
        snap = find(function(c) return c.variant == opts.variant end)
      end
      snap = snap or captures[1]

      set_background(snap.background)
      if vim.g.colors_name then
        vim.cmd("highlight clear")
      end
      vim.g.colors_name = name

      for group, spec in pairs(snap.highlights) do
        vim.api.nvim_set_hl(0, group, spec)
      end

      -- Write all 16 even if a hand-edited entry omits the table, so stale
      -- terminal colors from the previous scheme are cleared (nil = cleared).
      local terminal = snap.terminal or {}
      for i = 0, 15 do
        vim.g["terminal_color_" .. i] = terminal[i]
      end

      -- Applying via set_hl (not :colorscheme) skips the ColorScheme event, so
      -- fire it for downstream listeners (terminal_sync's OSC bg/cursor push to
      -- kitty, bufferline re-setup, etc.) — exactly as a hand-written scheme does.
      -- Fire under a sentinel pattern, not `name`: lazy.nvim keys a ColorScheme
      -- handler on each plugin's colorscheme name, so firing `name` would load
      -- the very plugin this snapshot exists to replace. Our listeners register
      -- with `*` and read vim.g.colors_name, so they still run.
      vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "snapshot:" .. name })
      return snap.variant
    end,
  }
end

return M
