-- Plugin-backed applier for silkcircuit, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime (lives outside definitions/).
-- Requires the silkcircuit plugin to be installed.
return {
  all_variants = { "neon", "vibrant", "soft", "glow", "dawn" },
  -- Variants to (re)capture on bootstrap, independent of which a pack uses now.
  bootstrap_variants = { "soft", "vibrant" },
  -- Highlight groups to drop from the snapshot (their orphaned palette colors
  -- vanish too). Excluded groups fall back to the plugin's / nvim's defaults.
  exclude = {
    "^RedrawDebug",            -- nvim internal repaint debugger (never seen)
    "^GitSignsStaged",         -- staged-git signs (inherit regular git colors)
    "^BufferLine.*Diagnostic", -- bufferline per-tab diagnostic tints
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "silkcircuit" } })
    vim.o.background = opts.background or (variant == "dawn" and "light" or "dark")
    require("silkcircuit").setup({
      transparent = opts.transparency,
      terminal_colors = true,
      variant = variant,
      integrations = { octo = false },
    })
    vim.cmd("colorscheme silkcircuit")

    -- silkcircuit renders a constant #12101a editor bg for every variant,
    -- ignoring each variant's own palette bg. Correct it to the variant's
    -- palette bg on Normal and every group that inherited the wrong value.
    local bg_fix = { vibrant = "#0f0c1a", soft = "#1a1626" }
    local want = bg_fix[variant]
    if want then
      local wrong = tonumber("12101a", 16)
      local right = tonumber(want:sub(2), 16)
      for group in pairs(vim.api.nvim_get_hl(0, {})) do
        local s = vim.api.nvim_get_hl(0, { name = group })
        local dirty = false
        for _, k in ipairs({ "bg", "fg", "sp" }) do
          if s[k] == wrong then s[k] = right; dirty = true end
        end
        if dirty then vim.api.nvim_set_hl(0, group, s) end
      end
    end
  end,
}
