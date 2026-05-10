return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    if vim.fn.executable("python3") ~= 1 then
      return opts
    end
    opts.servers = opts.servers or {}
    opts.ensure_installed = opts.ensure_installed or {}
    vim.list_extend(opts.ensure_installed, { "pyright", "ruff" })
    opts.servers.pyright = {
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "workspace",
            useLibraryCodeForTypes = true,
            typeCheckingMode = "basic",
          },
        },
      },
    }
    return opts
  end,
}
