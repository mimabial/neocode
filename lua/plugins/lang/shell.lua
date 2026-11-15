return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = opts.servers or {}
    opts.ensure_installed = opts.ensure_installed or {}
    opts.tools = opts.tools or {}
    vim.list_extend(opts.tools, { "shfmt", "shellcheck" })
    if vim.fn.executable("node") == 1 then
      table.insert(opts.ensure_installed, "bashls")
    end
    -- Override filetypes to attach bashls to zsh files as well as sh/bash.
    opts.servers.bashls = { filetypes = { "sh", "bash", "zsh" } }
    return opts
  end,
}
