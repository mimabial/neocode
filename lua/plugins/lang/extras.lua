-- Conditional installs that don't need per-server settings (rely on
-- nvim-lspconfig's bundled defaults). Add a runtime check, install via mason.
return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    local function add(cmd, servers)
      if vim.fn.executable(cmd) == 1 then
        vim.list_extend(opts.ensure_installed, servers)
      end
    end
    add("ruby",     { "ruby_lsp", "solargraph" })
    add("elixir",   { "elixirls" })
    add("cmake",    { "cmake" })
    add("java",     { "jdtls" })
    add("dotnet",   { "omnisharp" })
    add("pwsh",     { "powershell_es" })
    add("docker",   { "dockerls", "docker_compose_language_service" })
    add("terraform",{ "terraformls" })
    add("helm",     { "helm_ls" })
    add("sqlite3",  { "sqlls" })
    return opts
  end,
}
