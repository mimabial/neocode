return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    if vim.fn.executable("clang") ~= 1 then
      return opts
    end
    opts.servers = opts.servers or {}
    opts.ensure_installed = opts.ensure_installed or {}
    table.insert(opts.ensure_installed, "clangd")
    opts.servers.clangd = {
      capabilities = { offsetEncoding = { "utf-16" } },
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      },
    }
    return opts
  end,
}
