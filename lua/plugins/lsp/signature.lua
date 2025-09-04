return {
  "ray-x/lsp_signature.nvim",
  event = "LspAttach",
  opts = {
    bind = true,
    handler_opts = { border = "single" },
    hint_enable = true,
    hint_prefix = "🔍 ",
    hint_scheme = "String",
    hi_parameter = "IncSearch",
    fix_pos = false,
    toggle_key = "<C-k>",
  },
}
