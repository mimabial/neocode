local M = {}

-- Capabilities for nvim-cmp
local cmp_nvim_lsp = require("cmp_nvim_lsp")
M.capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- on_attach: common keymaps for LSP
local function on_attach(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  local map = vim.keymap.set
  -- Navigate diagnostics
  map("n", "[d", vim.diagnostic.goto_prev, bufopts)
  map("n", "]d", vim.diagnostic.goto_next, bufopts)
  map("n", "<leader>ld", vim.diagnostic.open_float, bufopts)
  map("n", "<leader>lq", vim.diagnostic.setloclist, bufopts)
  -- LSP actions
  map("n", "gd", vim.lsp.buf.definition, bufopts)
  map("n", "gD", vim.lsp.buf.declaration, bufopts)
  map("n", "gi", vim.lsp.buf.implementation, bufopts)
  map("n", "gr", vim.lsp.buf.references, bufopts)
  map("n", "K", vim.lsp.buf.hover, bufopts)
  map("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  map("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
  map("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
  map("n", "<leader>cf", function()
    vim.lsp.buf.format({ bufnr = bufnr })
  end, bufopts)
end

function M.setup()
  -- Mason setup
  require("mason").setup()
  require("mason-lspconfig").setup({ ensure_installed = {}, automatic_installation = true })

  -- Null-ls setup for formatters/linters
  local null_ls = require("null-ls")
  null_ls.setup({
    on_attach = on_attach,
    capabilities = M.capabilities,
    sources = {
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.diagnostics.eslint,
      null_ls.builtins.formatting.stylua,
    },
  })

  -- Setup each server
  local lspconfig = require("lspconfig")
  local servers = { "pyright", "tsserver", "gopls", "rust_analyzer", "clangd" }
  for _, name in ipairs(servers) do
    lspconfig[name].setup({
      on_attach = on_attach,
      capabilities = M.capabilities,
    })
  end
end

return M
