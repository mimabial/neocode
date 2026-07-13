-- Runtime applier for snapshotted (frozen) colorschemes.
-- A snapshot captures a plugin's resolved highlights + terminal colors so the
-- theme renders identically with no plugin dependency. Data lives in
-- plugins/themes/definitions/data/<scheme>.lua as { [variant] = { ... } }.
local M = {}

-- Build a theme definition from a snapshot data module.
--   name  : colorscheme name to report as vim.g.colors_name
--   icon  : picker glyph
--   data  : { [variant] = { background = "dark"|"light",
--                           terminal = { [0..15] = "#hex" },
--                           highlights = { Group = spec, ... } } }
function M.definition(name, icon, data)
  local variants = vim.tbl_keys(data)
  table.sort(variants)

  return {
    icon = icon,
    variants = variants,
    setup = function(opts)
      local variant = opts.variant
      if variant == nil or data[variant] == nil then
        variant = variants[1]
      end
      local snap = data[variant]

      vim.o.background = opts.background or snap.background or "dark"
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
      vim.api.nvim_exec_autocmds("ColorScheme", { pattern = name })
    end,
  }
end

return M
