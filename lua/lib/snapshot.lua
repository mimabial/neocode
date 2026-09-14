-- Runtime applier for snapshotted (frozen) colorschemes.
-- A snapshot captures a plugin's resolved highlights + terminal colors so the
-- theme renders identically with no plugin dependency. Data lives in
-- plugins/themes/definitions/data/<scheme>.lua.
local set_background = require("lib.background").set

local M = {}

local function capture_variants(captures)
  local variants, seen = {}, {}
  for _, capture in ipairs(captures) do
    if capture.variant and not seen[capture.variant] then
      seen[capture.variant] = true
      variants[#variants + 1] = capture.variant
    end
  end
  return variants
end

-- Build a theme definition from a snapshot data module.
--   name  : colorscheme name to report as vim.g.colors_name
--   icon  : picker glyph
--   source: capture list or lazy loader returning a list of {
--                variant?   = "<the plugin's own variant name>",
--                background = "dark"|"light",
--                terminal   = { [0..15] = "#hex" },
--                highlights = { Group = spec, ... } }
--   variants: optional catalog that keeps a lazy source unloaded
-- variant is absent for schemes with no variant axis; it is independent of
-- background, so neither is derivable from the other.
function M.definition(name, icon, source, variants)
  assert(type(source) == "table" or type(source) == "function", "snapshot source must be a table or loader")
  local captures = type(source) == "table" and source or nil
  local function load_captures()
    if not captures then
      captures = source()
      assert(type(captures) == "table", "snapshot loader must return captures")
    end
    return captures
  end

  variants = variants or capture_variants(load_captures())
  table.sort(variants)
  local has_variants = #variants > 0
  local function find(match)
    for _, capture in ipairs(load_captures()) do
      if match(capture) then return capture end
    end
  end

  return {
    icon = icon,
    -- theme_manager reads nil as "no variant axis".
    variants = has_variants and variants or nil,
    variant_for_background = function(background)
      local capture = find(function(c) return c.background == background end)
      return capture and capture.variant
    end,
    setup = function(opts)
      local available = load_captures()
      local snap
      if opts.background then
        snap = find(function(c)
          return (not opts.variant or c.variant == opts.variant) and c.background == opts.background
        end)
      end
      if not snap and opts.variant then
        snap = find(function(c) return c.variant == opts.variant end)
      end
      snap = snap or available[1]

      set_background(snap.background)
      if vim.g.colors_name then
        vim.cmd("highlight clear")
      end
      vim.g.colors_name = name

      for group, spec in pairs(snap.highlights) do
        vim.api.nvim_set_hl(0, group, spec)
      end

      -- Write all 16 even if an older capture omits the table, so stale
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
      return { variant = snap.variant, background = snap.background }
    end,
  }
end

return M
