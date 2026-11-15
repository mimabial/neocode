return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    if vim.fn.executable("php") ~= 1 then
      return opts
    end
    opts.servers = opts.servers or {}
    opts.ensure_installed = opts.ensure_installed or {}
    opts.tools = opts.tools or {}
    table.insert(opts.tools, "php-cs-fixer")
    if vim.fn.executable("node") == 1 then
      table.insert(opts.ensure_installed, "intelephense")
    end
    opts.servers.intelephense = {
      settings = {
        intelephense = {
          telemetry = { enabled = false },
          files = {
            maxSize = 1000000,
            exclude = {
              "**/.git/**", "**/.svn/**", "**/.hg/**",
              "**/node_modules/**", "**/vendor/**", "**/storage/**",
              "**/var/**", "**/cache/**", "**/tmp/**",
              "**/build/**", "**/dist/**", "**/coverage/**",
            },
          },
        },
      },
    }
    return opts
  end,
}
