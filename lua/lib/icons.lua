-- Central icon registry.
--
-- Single source of truth for nerd-font icons used across statusline, lspkind,
-- diagnostics, notifications, lazy ui, etc. Swap nerd fonts here once instead
-- of grepping every consumer.

local M = {}

M.diagnostics = {
  Error = " ",
  Warn = " ",
  Info = " ",
  Hint = " ",
}

-- Severity-keyed view of M.diagnostics for vim.diagnostic.config({ signs = ... }).
M.diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = M.diagnostics.Error,
  [vim.diagnostic.severity.WARN] = M.diagnostics.Warn,
  [vim.diagnostic.severity.INFO] = M.diagnostics.Info,
  [vim.diagnostic.severity.HINT] = M.diagnostics.Hint,
}

M.git = {
  added = " ",
  modified = " ",
  removed = " ",
}

M.notify = {
  ERROR = " ",
  WARN = " ",
  INFO = " ",
  DEBUG = " ",
  TRACE = "✎",
}

M.lazy = {
  cmd = " ",
  config = " ",
  event = " ",
  ft = " ",
  init = " ",
  keys = " ",
  plugin = " ",
  runtime = " ",
  source = " ",
  start = " ",
  task = " ",
}

M.mason = {
  package_installed = "✓",
  package_pending = "➜",
  package_uninstalled = "✗",
}

-- LSP completion item kinds (consumed by lspkind).
M.kinds = {
  Text = "󰉿",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "󰆧",
  Field = "󰜢",
  Variable = "󰀫",
  Class = "󰠱",
  Interface = "󰕘",
  Module = "󰏗",
  Property = "󰜢",
  Unit = "󰑭",
  Value = "󰎠",
  Enum = "󰒻",
  Keyword = "󰌋",
  Snippet = "󰅪",
  Color = "󰏘",
  File = "󰈙",
  Reference = "󰈇",
  Folder = "󰉋",
  EnumMember = "󰒻",
  Constant = "󰏿",
  Struct = "󰙅",
  Event = "󰉁",
  Operator = "󰆕",
  TypeParameter = "󰅲",
}

return M
