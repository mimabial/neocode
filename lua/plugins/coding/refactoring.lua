--------------------------------------------------------------------------------
-- Code Refactoring Tools
--------------------------------------------------------------------------------
--
-- This module provides tools for code refactoring and transformation:
--
-- Features:
-- 1. Extract function/variable operations
-- 2. Inline function/variable operations
-- 3. Language-aware refactoring
-- 4. Structural search and replace
-- 5. AI-assisted refactoring
-- 6. Refactoring preview
--
-- These tools make it easier to modify and restructure code while
-- maintaining correctness and readability.
--------------------------------------------------------------------------------

return {
  -- Main refactoring plugin
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      -- Main refactoring selector
      {
        "<leader>cr",
        function()
          require("refactoring").select_refactor()
        end,
        desc = "Select Refactoring",
        mode = { "n", "x" },
      },

      -- Extraction operations
      {
        "<leader>re",
        function()
          require("refactoring").refactor("Extract Function")
        end,
        desc = "Extract Function",
        mode = "x",
      },
      {
        "<leader>rf",
        function()
          require("refactoring").refactor("Extract Function To File")
        end,
        desc = "Extract Function To File",
        mode = "x",
      },
      {
        "<leader>rv",
        function()
          require("refactoring").refactor("Extract Variable")
        end,
        desc = "Extract Variable",
        mode = "x",
      },

      -- Inline operations
      {
        "<leader>ri",
        function()
          require("refactoring").refactor("Inline Variable")
        end,
        desc = "Inline Variable",
        mode = { "n", "x" },
      },
      {
        "<leader>rI",
        function()
          require("refactoring").refactor("Inline Function")
        end,
        desc = "Inline Function",
        mode = "n",
      },

      -- Debug operations
      {
        "<leader>rb",
        function()
          require("refactoring").refactor("Debug Print")
        end,
        desc = "Debug Print",
        mode = { "n", "x" },
      },
      {
        "<leader>rB",
        function()
          require("refactoring").refactor("Debug Print Var")
        end,
        desc = "Debug Print Variable",
        mode = "n",
      },
      {
        "<leader>rC",
        function()
          require("refactoring").debug.cleanup({})
        end,
        desc = "Clean Debug Prints",
        mode = "n",
      },
    },
    opts = {
      -- Language-specific prompt configuration
      prompt_func_return_type = {
        go = true,
        java = true,
        cpp = true,
        c = true,
        h = true,
        hpp = true,
        cxx = true,
        typescript = true,
        javascript = true,
        python = true,
        rust = true,
      },
      prompt_func_param_type = {
        go = true,
        java = true,
        cpp = true,
        c = true,
        h = true,
        hpp = true,
        cxx = true,
        typescript = true,
        javascript = true,
        python = true,
        rust = true,
      },
      -- Configure print statement formatting by language
      printf_statements = {
        cpp = {
          'std::cout << "%s = " << %s << std::endl;',
        },
        c = {
          'printf("%%s = %%s\\n", "%s", %s);',
        },
        go = {
          'fmt.Println("%s =", %s)',
        },
        java = {
          'System.out.println("%s = " + %s);',
        },
        javascript = {
          'console.log("%s =", %s)',
        },
        python = {
          'print(f"%s = {%s}")',
        },
        typescript = {
          'console.log("%s =", %s)',
        },
        rust = {
          'println!("%s = {:?}", %s);',
        },
        php = {
          'echo "%s = " . %s;',
        },
      },
      -- Preferred debug print variable format
      print_var_statements = {
        cpp = {
          'std::cout << "%s = " << %s << std::endl;',
        },
        c = {
          'printf("%%s = %%s\\n", "%s", %s);',
        },
        go = {
          'fmt.Println("%s =", %s)',
        },
        java = {
          'System.out.println("%s = " + %s);',
        },
        javascript = {
          'console.log("%s =", %s)',
        },
        python = {
          'print(f"%s = {%s}")',
        },
        typescript = {
          'console.log("%s =", %s)',
        },
        rust = {
          'println!("%s = {:?}", %s);',
        },
        php = {
          'echo "%s = " . %s;',
        },
      },
    },
  },

  -- Additional refactoring tools
  {
    "nvim-treesitter/nvim-treesitter-refactor",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter.configs").setup({
        refactor = {
          -- Highlight definition and usages
          highlight_definitions = {
            enable = true,
            clear_on_cursor_move = true,
          },
          -- Smart rename with treesitter awareness
          smart_rename = {
            enable = true,
            keymaps = {
              smart_rename = "<leader>rr",
            },
          },
          -- Navigation between definition and implementation
          navigation = {
            enable = true,
            keymaps = {
              goto_definition = "gnd",
              list_definitions = "gnD",
              list_definitions_toc = "gO",
              goto_next_usage = "<a-*>",
              goto_previous_usage = "<a-#>",
            },
          },
        },
      })
    end,
  },

  -- Structural search and replace
  {
    "cshuaimin/ssr.nvim",
    keys = {
      {
        "<leader>rs",
        function()
          require("ssr").open()
        end,
        desc = "Structural Search and Replace",
        mode = { "n", "x" },
      },
    },
    config = function()
      require("ssr").setup({
        border = "rounded",
        min_width = 50,
        min_height = 5,
        max_width = 120,
        max_height = 25,
        keymaps = {
          close = "q",
          next_match = "n",
          prev_match = "N",
          replace_all = "<leader>r",
        },
      })
    end,
  },

  -- Better search and replace
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>sr",
        function()
          require("spectre").open()
        end,
        desc = "Search and Replace (Spectre)",
      },
      {
        "<leader>sR",
        function()
          require("spectre").open_visual({ select_word = true })
        end,
        desc = "Search and Replace Current Word",
      },
      {
        "<leader>sx",
        function()
          require("spectre").open_file_search()
        end,
        desc = "Search and Replace in Current File",
      },
    },
    config = function()
      require("spectre").setup({
        color_devicons = true,
        open_cmd = "vnew",
        live_update = true,
        is_insert_mode = true,
        highlight = {
          ui = "String",
          search = "DiffChange",
          replace = "DiffDelete",
        },
        mapping = {
          ["toggle_line"] = {
            map = "t",
            cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
            desc = "toggle current item",
          },
          ["enter_file"] = {
            map = "<cr>",
            cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
            desc = "goto current file",
          },
          ["send_to_qf"] = {
            map = "Q",
            cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
            desc = "send all items to quickfix",
          },
          ["replace_cmd"] = {
            map = "c",
            cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
            desc = "input replace command",
          },
          ["show_option_menu"] = {
            map = "o",
            cmd = "<cmd>lua require('spectre').show_options()<CR>",
            desc = "show options",
          },
          ["run_current_replace"] = {
            map = "R",
            cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
            desc = "replace current line",
          },
          ["run_replace"] = {
            map = "r",
            cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
            desc = "replace all",
          },
          ["change_view_mode"] = {
            map = "m",
            cmd = "<cmd>lua require('spectre').change_view()<CR>",
            desc = "change result view mode",
          },
          ["toggle_ignore_case"] = {
            map = "I",
            cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
            desc = "toggle ignore case",
          },
          ["toggle_ignore_hidden"] = {
            map = "H",
            cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
            desc = "toggle search hidden",
          },
        },
      })
    end,
  },

  -- LSP-based code actions
  {
    "weilbith/nvim-code-action-menu",
    cmd = "CodeActionMenu",
    keys = {
      {
        "<leader>ca",
        "<cmd>CodeActionMenu<cr>",
        desc = "Code Action Menu",
      },
    },
    config = function()
      vim.g.code_action_menu_window_border = "rounded"
      vim.g.code_action_menu_show_details = true
      vim.g.code_action_menu_show_diff = true
    end,
  },

  -- AI-powered refactoring
  {
    "polypus74/trusty_rusty_replacer",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/conform.nvim",
    },
    keys = {
      {
        "<leader>ra",
        function()
          require("trusty_rusty_replacer").refactor()
        end,
        desc = "AI Refactor Selection",
        mode = { "x" },
      },
    },
    config = function()
      require("trusty_rusty_replacer").setup({
        formatters = {
          -- Define formatters by language
          lua = {
            cmd = { "stylua", "-" },
            options = {},
          },
          python = {
            cmd = { "black", "--quiet", "-" },
            options = {},
          },
          javascript = {
            cmd = { "prettier", "--parser", "typescript" },
            options = {},
          },
        },
        add_to_conform = true,
        refactor_prompt = "Refactor the following code to improve readability, maintainability, and performance without changing its behavior. Make sure to use best practices and idiomatic patterns for the language.",
      })
    end,
  },
}
