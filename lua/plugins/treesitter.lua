-- lua/plugins/treesitter.lua
-- Treesitter configuration with full parser, textobject, and injection setups
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
      "HiPhish/rainbow-delimiters.nvim",
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<C-space>", desc = "Increment selection" },
      { "<BS>", mode = "x", desc = "Decrement selection" },
    },
    opts = {
      ensure_installed = {
        -- Core languages
        "bash", "c", "cpp", "css", "diff", "dockerfile",
        "lua", "luadoc", "luap", "vim", "vimdoc", "query",

        -- Web languages
        "html", "javascript", "jsdoc", "json", "jsonc",
        "scss", "graphql", "tsx", "typescript",

        -- GOTH stack
        "go", "gomod", "gosum", "gowork", "templ",

        -- Next.js / Prisma
        "prisma", "regex", "markdown", "markdown_inline",

        -- Additional useful parsers
        "sql", "svelte", "terraform", "toml", "yaml",
      },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        -- for 'templ' files, still use regex highlighting
        additional_vim_regex_highlighting = { "templ" },
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<BS>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aP"] = "@parameter.outer",
            ["iP"] = "@parameter.inner",
            ["aa"] = "@assignment.outer",
            ["ia"] = "@assignment.inner",
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            ["ar"] = "@return.outer",
            ["ir"] = "@return.inner",
            ["aC"] = "@comment.outer",
            ["iC"] = "@comment.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]i"] = "@conditional.outer",
            ["]l"] = "@loop.outer",
            ["]s"] = { query = "@scope", query_group = "locals" },
            ["]z"] = { query = "@fold", query_group = "folds" },
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]I"] = "@conditional.outer",
            ["]L"] = "@loop.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[i"] = "@conditional.outer",
            ["[l"] = "@loop.outer",
            ["[s"] = { query = "@scope", query_group = "locals" },
            ["[z"] = { query = "@fold", query_group = "folds" },
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[I"] = "@conditional.outer",
            ["[L"] = "@loop.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = { ["<leader>a"] = "@parameter.inner" },
          swap_previous = { ["<leader>A"] = "@parameter.inner" },
        },
        lsp_interop = {
          enable = true,
          border = "rounded",
          peek_definition_code = {
            ["<leader>pf"] = "@function.outer",
            ["<leader>pF"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      -- Remove duplicates and install missing
      local parsers = require("nvim-treesitter.parsers")
      local has_parser = parsers.has_parser
      -- dedupe
      local seen = {}
      opts.ensure_installed = vim.tbl_filter(function(lang)
        if seen[lang] then return false end
        seen[lang] = true; return true
      end, opts.ensure_installed)
      -- install
      local missing = {}
      for _, lang in ipairs(opts.ensure_installed) do
        if not has_parser(lang) then table.insert(missing, lang) end
      end
      if #missing > 0 then
        vim.notify("Installing missing TreeSitter parsers: " .. table.concat(missing, ", "), vim.log.levels.INFO)
        vim.cmd("TSInstall " .. table.concat(missing, " "))
      end

      -- Custom parser configs and filetype mappings
      pcall(function()
        local cfg = parsers.get_parser_configs()
        -- templ
        if not cfg.templ then
          cfg.templ = {
            install_info = {
              url = "https://github.com/vrischmann/tree-sitter-templ.git",
              files = { "src/parser.c", "src/scanner.c" },
              branch = "main",
            }, filetype = "templ",
          }
        end
        -- jsx via javascript grammar
        if not cfg.jsx then
          cfg.jsx = {
            install_info = {
              url = "https://github.com/tree-sitter/tree-sitter-javascript.git",
              files = { "src/parser.c", "src/scanner.c" },
              branch = "master",
            }, filetype = "javascriptreact",
          }
        end
        -- mappings
        if parsers.filetype_to_parsername then
          parsers.filetype_to_parsername.templ = "templ"
          parsers.filetype_to_parsername.html = "html"
          parsers.filetype_to_parsername.javascriptreact = "jsx"
        end
      end)

      -- Register TSX for JSX filetypes
      pcall(function()
        vim.treesitter.language.register("tsx", "javascriptreact")
        vim.treesitter.language.register("tsx", "jsx")
        local cfg = parsers.get_parser_configs()
        cfg.tsx.used_by = { "javascriptreact", "typescript.tsx", "jsx" }
      end)

      -- HTMX injections
      pcall(function()
        local set_query = vim.treesitter.query.set
        local inj = [[
          ((attribute (attribute_name) @_attr_name (attribute_value) @injection.content)
           (#match? @_attr_name "^hx-.*$") (#set! injection.language "javascript"))
        ]]
        for _, lang in ipairs({"html","templ","jsx","tsx"}) do
          set_query(lang, "injections", inj)
        end
      end)

      -- Setup Treesitter
      local ok, err = pcall(function()
        require("nvim-treesitter.configs").setup(opts)
      end)
      if not ok then
        vim.notify("TreeSitter setup error: " .. tostring(err), vim.log.levels.ERROR)
      end

      -- Rainbow & highlights
      local has_rainbow, rainbow = pcall(require, "rainbow-delimiters")
      if has_rainbow then
        vim.g.rainbow_delimiters = {
          strategy = { [""] = rainbow.strategy.global, vim = rainbow.strategy.local },
          query = { [""] = "rainbow-delimiters", lua = "rainbow-blocks", html = "rainbow-tags", tsx = "rainbow-tags" },
        }
      end
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          if vim.g.colors_name == "gruvbox-material" then
            local cols = (_G.get_gruvbox_colors and _G.get_gruvbox_colors()) or { red="#ea6962", orange="#e78a4e", yellow="#d8a657", green="#89b482", blue="#7daea3", purple="#d3869b", cyan="#89b482" }
            for _, name in ipairs({"Red","Yellow","Blue","Orange","Green","Violet","Cyan"}) do
              vim.api.nvim_set_hl(0, "RainbowDelimiter"..name, { fg = cols[string.lower(name)] })
            end
            vim.api.nvim_set_hl(0, "@attribute.htmx", { fg = cols.green, italic = true, bold = true })
            vim.api.nvim_set_hl(0, "@tag.attribute.htmx", { fg = cols.green, italic = true, bold = true })
            vim.api.nvim_set_hl(0, "@type.go", { fg = cols.yellow })
            vim.api.nvim_set_hl(0, "@function.go", { fg = cols.blue })
            for _, ft in ipairs({"tsx","jsx"}) do
              vim.api.nvim_set_hl(0, "@tag."..ft, { fg = cols.red })
              vim.api.nvim_set_hl(0, "@tag.delimiter."..ft, { fg = cols.orange })
              vim.api.nvim_set_hl(0, "@constructor."..ft, { fg = cols.purple })
            end
          end
        end,
      })
    end,
  },

  -- Autopairs with Treesitter support
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter", "hrsh7th/nvim-cmp" },
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string" }, javascript = { "template_string" }, javascriptreact = { "template_string", "jsx_element" },
        typescript = { "template_string" }, typescriptreact = { "template_string", "jsx_element" },
        go = { "string" }, templ = { "string" },
      },
      disable_filetype = { "TelescopePrompt" },
    },
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
      local ok, cmp = pcall(require, "cmp")
      if ok then
        require("nvim-autopairs.completion.cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      end
    end,
  },

  -- Autotag for JSX/TSX and others
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-ts-autotag").setup({
        filetypes = { "html","xml","javascriptreact","typescriptreact","jsx","tsx","svelte","vue","templ","erb" },
        skip_tags = { "area","base","br","col","command","embed","hr","img","input","keygen","link","meta","param","source","track","wbr" },
      })
    end,
  },
}
