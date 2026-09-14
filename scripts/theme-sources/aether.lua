-- Plugin-backed applier for aether, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires aether.nvim (v2) installed.
--
-- aether is a palette-injection theme: it ships one look but every colour is a
-- caller override. Imported palettes are the variant axis here. This is the one
-- source whose variants are not plugin-declared; aether declares none. Treat
-- all_variants as the palettes to freeze, and add an entry for each new palette.
--
-- "aether" is the stock palette and sorts first, so it is what
-- snapshot.definition falls back to when a pack pins no $NVIM_VARIANT.
local palettes = {
  akaito = {
    bg = "#f3e4cb",
    bg_dark = "#f3e4cb",
    bg_highlight = "#9f8253",

    fg = "#4d2e1a",
    fg_dark = "#080503",
    comment = "#9f8253",

    red = "#a4373c",
    orange = "#d2656a",
    yellow = "#a8611f",
    green = "#a46d2d",
    cyan = "#755833",
    blue = "#a32f1a",
    purple = "#9c3521",
    magenta = "#de553a",
  },
  ["sakura-mochi"] = {
    bg = "#0b0d11",
    bg_dark = "#0b0d11",
    bg_highlight = "#6f9485",

    fg = "#f0b7ca",
    fg_dark = "#d8c6cc",
    comment = "#678270",

    red = "#f23888",
    orange = "#d7be96",
    yellow = "#d7be96",
    green = "#5aa15d",
    cyan = "#6f9485",
    blue = "#67dd82",
    purple = "#ffd0dc",
    magenta = "#ff6aa7",
  },
}

local overrides = {
  ["sakura-mochi"] = function(hl, c)
    hl["@constant.builtin"] = { fg = c.orange }
    hl["@keyword.function"] = { fg = c.magenta, bold = true }
    hl["@module"] = { fg = c.purple }
    hl["@property"] = { fg = c.fg_dark }
    hl["@type.builtin"] = { fg = c.blue }
    hl["@variable.member"] = { fg = c.fg_dark }

    hl.WinSeparator = { fg = c.comment }
    hl.VertSplit = { fg = c.comment }
    hl.NeoTreeWinSeparator = { fg = c.comment }
    hl.NeoTreeVertSplit = { fg = c.comment }
    hl.NvimTreeVertSplit = { fg = c.comment }

    hl["@lsp.type.class"] = { fg = c.yellow }
    hl["@lsp.type.interface"] = { fg = c.yellow }
    hl["@lsp.type.namespace"] = { fg = c.purple }
    hl["@lsp.type.parameter"] = { fg = c.cyan, italic = true }
    hl["@lsp.type.property"] = { fg = c.fg_dark }
    hl["@lsp.type.struct"] = { fg = c.yellow }
    hl["@lsp.type.type"] = { fg = c.yellow }
    hl["@lsp.type.typeParameter"] = { fg = c.blue }
  end,
}

return {
  all_variants = { "aether", "akaito", "sakura-mochi" },
  bootstrap_variants = { "aether", "akaito", "sakura-mochi" },
  exclude = { "^RedrawDebug" },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "aether.nvim" } })
    vim.o.background = opts.background or "dark"
    require("aether").setup({
      transparent = opts.transparency,
      colors = palettes[variant] or {},
      on_highlights = overrides[variant] or function() end,
    })
    vim.cmd("colorscheme aether")
  end,
}
