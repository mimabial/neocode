-- Plugin-backed applier for catppuccin, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires catppuccin.
return {
  all_variants = { "latte", "frappe", "macchiato", "mocha" },
  bootstrap_variants = { "latte", "mocha" },
  exclude = {
    "^RedrawDebug",
    "^Notify",
    "^RenderMarkdown",
    "^Neogit",       -- neogit hunk/diff tint proliferation
    "^Moonfly",      -- foreign colorscheme groups leaked at startup
    "^NvCheatsheet",
    "^Fzf",
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "catppuccin" } })
    vim.o.background = (variant == "latte") and "light" or "dark"
    require("catppuccin").setup({
      flavour = variant,
      term_colors = true,
      transparent_background = opts.transparency,
    })
    require("catppuccin").compile()
    vim.cmd("colorscheme catppuccin-" .. variant)
  end,
}
