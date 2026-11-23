local PARSERS = {
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
}

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

    local function attach(buf)
      if vim.b[buf].bigfile then
        return
      end
      if pcall(vim.treesitter.start, buf) then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    local function attach_buffers_missing_highlighter()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
          vim.api.nvim_buf_is_loaded(buf)
          and vim.bo[buf].filetype ~= ""
          and not vim.treesitter.highlighter.active[buf]
        then
          attach(buf)
        end
      end
    end

    local function install_parsers()
      treesitter.install(PARSERS):await(vim.schedule_wrap(attach_buffers_missing_highlighter))
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
        attach(args.buf)
      end,
    })
  end,
}
