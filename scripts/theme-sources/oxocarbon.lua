-- Plugin-backed applier for oxocarbon, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires oxocarbon.nvim installed.
-- oxocarbon has no variant axis: light/dark is the background, and the plugin
-- reads it straight off vim.o.background.
return {
  exclude = { "^RedrawDebug" }, -- nvim internal repaint debugger
  apply = function(_, opts)
    require("lazy").load({ plugins = { "oxocarbon.nvim" } })
    vim.o.background = opts.background or "dark"
    vim.cmd("colorscheme oxocarbon")
    if opts.transparency then
      for _, g in ipairs({ "Normal", "NormalFloat", "NormalNC" }) do
        vim.api.nvim_set_hl(0, g, { bg = "none" })
      end
    end
  end,
}
