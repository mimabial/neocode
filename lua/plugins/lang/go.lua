return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    if vim.fn.executable("go") ~= 1 then
      return opts
    end
    opts.servers = opts.servers or {}
    opts.ensure_installed = opts.ensure_installed or {}
    table.insert(opts.ensure_installed, "gopls")
    opts.servers.gopls = {
      settings = {
        gopls = {
          gofumpt = true,
          codelenses = {
            gc_details = false, generate = true, regenerate_cgo = true,
            run_govulncheck = true, test = true, tidy = true,
            upgrade_dependency = true, vendor = true,
          },
          hints = {
            assignVariableTypes = true, compositeLiteralFields = true,
            compositeLiteralTypes = true, constantValues = true,
            functionTypeParameters = true, parameterNames = true,
            rangeVariableTypes = true,
          },
          analyses = {
            fieldalignment = true, nilness = true, unusedparams = true,
            unusedwrite = true, useany = true,
          },
          usePlaceholders = true,
          completeUnimported = true,
          staticcheck = true,
          directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
          semanticTokens = true,
        },
      },
    }
    return opts
  end,
}
