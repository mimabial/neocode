return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    if vim.fn.executable("python3") ~= 1 then
      return opts
    end
    opts.servers = opts.servers or {}
    opts.ensure_installed = opts.ensure_installed or {}
    table.insert(opts.ensure_installed, "ruff")
    if vim.fn.executable("node") == 1 then
      table.insert(opts.ensure_installed, "pyright")
    end
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
