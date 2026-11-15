return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main branch does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    vim.treesitter.language.register("tsx", "typescriptreact")
    vim.treesitter.language.register("javascript", "javascriptreact")
    -- jsonc has no dedicated parser on the nvim-treesitter main branch; reuse json.
    vim.treesitter.language.register("json", "jsonc")

    local treesitter = require("nvim-treesitter")
    treesitter.setup()

    local function install_parsers()
      treesitter.install({
        "bash",
        "css",
        "html",
        "htmldjango",
        "hyprlang",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "ron",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })
    end

    if vim.fn.executable(require("lib.c_compiler")) == 1 then
      if vim.fn.executable("tree-sitter") == 1 then
        install_parsers()
      else
        require("lib.mason_tools").ensure_available({ "tree-sitter-cli" }, install_parsers)
      end
    end

    -- main no longer wires highlight/indent on its own.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if vim.b[args.buf].bigfile then
          return
        end
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
