return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    if vim.fn.executable("rustc") ~= 1 then
      return opts
    end
    opts.servers = opts.servers or {}
    opts.ensure_installed = opts.ensure_installed or {}
    table.insert(opts.ensure_installed, "rust_analyzer")
    opts.servers.rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          imports = { granularity = { group = "module" }, prefix = "self" },
          cargo = { buildScripts = { enable = true } },
          procMacro = { enable = true },
          checkOnSave = { command = "clippy" },
        },
      },
    }
    return opts
  end,
}
