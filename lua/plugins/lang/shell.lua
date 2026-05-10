return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = opts.servers or {}
    opts.ensure_installed = opts.ensure_installed or {}
    table.insert(opts.ensure_installed, "bashls")
    -- Override filetypes to attach bashls to zsh files as well as sh/bash.
    opts.servers.bashls = { filetypes = { "sh", "bash", "zsh" } }
    return opts
  end,
}
