-- Plugin spec for Snacks.nvim (Focused on Picker functionality, not Explorer)
return {
  "folke/snacks.nvim",
  event = "VeryLazy",
  priority = 800,

  opts = {
    explorer = {
      enabled = false, -- Disable explorer functionality to use Oil instead
    },

    picker = {
      enabled = true,
      border = "rounded",
      width = 0.8,
      height = 0.8,
      telesync = true,

      fzf = {
        fuzzy = true,
        override_file_sorter = true,
        override_generic_sorter = true,
        case_mode = "smart_case",
      },

      highlights = function()
        local hl = vim.api.nvim_get_hl(0, {})
        local yellow = hl.GruvboxYellow and hl.GruvboxYellow.fg or 0xd8a657
        local green = hl.GruvboxGreen and hl.GruvboxGreen.fg or 0x89b482
        local aqua = hl.GruvboxAqua and hl.GruvboxAqua.fg or 0x7daea3
        return {
          PickerMatches = { fg = string.format("#%06x", green), bold = true },
          PickerSelected = { fg = string.format("#%06x", yellow) },
          PickerBorder = { fg = string.format("#%06x", aqua) },
        }
      end,

      file_browser = {
        git_icons = true,
        hidden = true,
        respect_gitignore = true,
        follow_symlinks = true,
      },

      find_files = {
        hidden = true,
        find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" },
        follow = true,
      },

      live_grep = {
        additional_args = function()
          return {
            "--hidden",
            "--glob=!.git/",
            "--glob=!node_modules/",
            "--glob=!vendor/",
            "--glob=!.next/",
            "--glob=!dist/",
            "--glob=!build/",
          }
        end,
        disable_coordinates = false,
        case_sensitive = false,
      },

      custom_pickers = {
        goth_files = {
          command = function()
            return [[
              find . -type f \( -name '*.go' -o -name '*.templ' \)
                -not -path '*/vendor/*'
                -not -path '*/node_modules/*'
            ]]
          end,
          prompt = "GOTH Files",
        },
        nextjs_files = {
          command = function()
            return [[
            find . -type f \( -name '*.tsx' -o -name '*.jsx' -o -name '*.ts' -o -name '*.js' \)
              -not -path */node_modules/*
              -not -path */.next/*
            ]]
          end,
          prompt = "Next.js Files",
        },
        lsp_references = {
          init = function()
            local params = vim.lsp.util.make_position_params()
            return vim.lsp.buf_request_sync(0, "textDocument/references", params, 1000)
          end,
          format = function(results)
            local locations = {}
            for _, result in pairs(results or {}) do
              for _, loc in pairs(result.result or {}) do
                table.insert(locations, loc)
              end
            end
            return vim.lsp.util.locations_to_items(locations)
          end,
          prompt = "LSP References",
        },
        lsp_definitions = {
          init = function()
            local params = vim.lsp.util.make_position_params()
            return vim.lsp.buf_request_sync(0, "textDocument/definition", params, 1000)
          end,
          format = function(results)
            local locations = {}
            for _, result in pairs(results or {}) do
              for _, loc in pairs(result.result or {}) do
                table.insert(locations, loc)
              end
            end
            return vim.lsp.util.locations_to_items(locations)
          end,
          prompt = "LSP Definitions",
        },
        lsp_implementations = {
          init = function()
            local params = vim.lsp.util.make_position_params()
            return vim.lsp.buf_request_sync(0, "textDocument/implementation", params, 1000)
          end,
          format = function(results)
            local locations = {}
            for _, result in pairs(results or {}) do
              for _, loc in pairs(result.result or {}) do
                table.insert(locations, loc)
              end
            end
            return vim.lsp.util.locations_to_items(locations)
          end,
          prompt = "LSP Implementations",
        },
      },
    },
  },

  keys = {
    -- Explorer keymaps - explicitly listed to ensure they appear in which-key
    {
      "<leader>se",
      function()
        require("snacks").explorer()
      end,
      desc = "Toggle Snacks Explorer",
    },
    {
      "<leader>sE",
      function()
        require("snacks").explorer({ float = true })
      end,
      desc = "Toggle Snacks Explorer (float)",
    },
    -- Picker keymaps - explicitly listed to ensure they appear in which-key
    {
      "<leader>ff",
      function()
        require("snacks.picker").files()
      end,
      desc = "Find Files",
    },
    {
      "<leader>fg",
      function()
        require("snacks.picker").grep()
      end,
      desc = "Live Grep",
    },
    {
      "<leader>fb",
      function()
        require("snacks.picker").buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>fh",
      function()
        require("snacks.picker").help()
      end,
      desc = "Help Tags",
    },
    {
      "<leader>fr",
      function()
        require("snacks.picker").recent()
      end,
      desc = "Recent Files",
    },
    {
      "<leader>fR",
      function()
        require("snacks.picker").smart()
      end,
      desc = "Smart Files",
    },
    {
      "<leader>fp",
      function()
        require("snacks.picker").projects()
      end,
      desc = "Projects",
    },
    {
      "<leader>fc",
      function()
        require("snacks.picker").commands()
      end,
      desc = "Commands",
    },
    {
      "<leader>fk",
      function()
        require("snacks.picker").keymaps()
      end,
      desc = "Keymaps",
    },
    {
      "<leader>f/",
      function()
        require("snacks.picker").lines()
      end,
      desc = "Buffer Fuzzy Find",
    },
    {
      "<leader>f.",
      function()
        require("snacks.picker").resume()
      end,
      desc = "Resume Search",
    },

    -- Git integration
    {
      "<leader>gs",
      function()
        require("snacks.picker").git_status()
      end,
      desc = "Git Status",
    },
    {
      "<leader>gc",
      function()
        require("snacks.picker").git_log()
      end,
      desc = "Git Commits",
    },
    {
      "<leader>gb",
      function()
        require("snacks.picker").git_branches()
      end,
      desc = "Git Branches",
    },

    -- LSP integration
    {
      "<leader>fd",
      function()
        require("snacks.picker").diagnostics({ bufnr = 0 })
      end,
      desc = "Doc Diagnostics",
    },
    {
      "<leader>fD",
      function()
        require("snacks.picker").diagnostics()
      end,
      desc = "Workspace Diagnostics",
    },
    {
      "<leader>fs",
      function()
        require("snacks.picker").lsp_symbols()
      end,
      desc = "Doc Symbols",
    },
    {
      "<leader>fS",
      function()
        require("snacks.picker").lsp_workspace_symbols()
      end,
      desc = "Workspace Symbols",
    },

    -- Stack-specific
    {
      "<leader>sgg",
      function()
        require("snacks.picker").pick("goth_files")
      end,
      desc = "GOTH Files",
    },
    {
      "<leader>sng",
      function()
        require("snacks.picker").pick("nextjs_files")
      end,
      desc = "Next.js Files",
    },

    -- LSP navigation replacements (instead of telescope)
    {
      "gr",
      function()
        require("snacks.picker").pick("lsp_references")
      end,
      desc = "Go to References",
    },
    {
      "gd",
      function()
        require("snacks.picker").pick("lsp_definitions")
      end,
      desc = "Go to Definition",
    },
    {
      "gi",
      function()
        require("snacks.picker").pick("lsp_implementations")
      end,
      desc = "Go to Implementation",
    },
  },

  config = function(_, opts)
    require("snacks").setup(opts)

    -- Reset default explorer to Oil even if config loads snacks explorer accidentally
    vim.g.default_explorer = "oil"

    -- Export the pickers to _G so they can be easily accessed from keymaps
    _G.snacks_picker = require("snacks.picker")
  end,
}
