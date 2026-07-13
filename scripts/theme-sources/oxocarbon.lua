-- Plugin-backed applier for oxocarbon, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires oxocarbon.nvim installed.
return {
  all_variants = { "dark", "light" },
  bootstrap_variants = { "dark" },
  exclude = { "^RedrawDebug" }, -- nvim internal repaint debugger
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "oxocarbon.nvim" } })
    vim.o.background = (variant == "light") and "light" or "dark"
    vim.cmd("colorscheme oxocarbon")
    if opts.transparency then
      for _, g in ipairs({ "Normal", "NormalFloat", "NormalNC" }) do
        vim.api.nvim_set_hl(0, g, { bg = "none" })
      end
    end
  end,
}
