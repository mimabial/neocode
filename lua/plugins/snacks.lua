-- Plugin spec for Snacks.nvim (Explorer & Picker replacement)
return {
  "folke/snacks.nvim",
  event = "VeryLazy",
  priority = 800,

  opts = {
    explorer = {
      enabled = true,
      border = "rounded",
      float = { enabled = true, width = 0.8, height = 0.8 },

      oil = { enabled = true },

      highlights = function()
        local hl = vim.api.nvim_get_hl(0, {})
        local green = hl.GruvboxGreen and hl.GruvboxGreen.fg or 0x89b482
        local aqua  = hl.GruvboxAqua  and hl.GruvboxAqua.fg  or 0x7daea3
        local yellow= hl.GruvboxYellow and hl.GruvboxYellow.fg or 0xd8a657
        return {
          ExplorerDirName    = { fg = string.format("#%06x", aqua),  bold = true },
          ExplorerFileName   = { fg = string.format("#%06x", yellow) },
          ExplorerSymlinkName= { fg = string.format("#%06x", green), underline = true },
        }
      end,

      filter = function(entry)
        local name = entry.name
        if name == ".git" or name == ".DS_Store" then
          return false
        end
        local stack = vim.g.current_stack
        if stack == "goth" then
          local skip = {"node_modules","vendor","bin","dist","build","go.sum"}
          if vim.tbl_contains(skip, name) then return false end
          if entry.type == "file" then
            local ext = name:match("[^.]+$"):lower()
            if ext == "go" or ext == "templ" then entry.priority = 10 end
          end
        elseif stack == "nextjs" then
          local skip = {"node_modules",".next","out",".turbo",".vercel"}
          if vim.tbl_contains(skip, name) then return false end
          if entry.type == "directory" and vim.tbl_contains({"app","pages","components"}, name) then
            entry.priority = 10
          elseif entry.type == "file" then
            local ext = name:match("[^.]+$"):lower()
            if ext == "tsx" or ext == "jsx" or name:match("next.config") then
              entry.priority = 10
            end
          end
        end
        return true
      end,
    },

    picker = {
      enabled = true,
      border = "rounded",
      width = 0.8,
      height = 0.8,
      telesync = true,

      fzf = {
        fuzzy = true,
        override_file_sorter    = true,
        override_generic_sorter = true,
        case_mode = "smart_case",
      },

      highlights = function()
        local hl = vim.api.nvim_get_hl(0, {})
        local yellow = hl.GruvboxYellow and hl.GruvboxYellow.fg or 0xd8a657
        local green  = hl.GruvboxGreen  and hl.GruvboxGreen.fg  or 0x89b482
        local aqua   = hl.GruvboxAqua   and hl.GruvboxAqua.fg   or 0x7daea3
        return {
          PickerMatches  = { fg = string.format("#%06x", green),  bold = true },
          PickerSelected = { fg = string.format("#%06x", yellow) },
          PickerBorder   = { fg = string.format("#%06x", aqua) },
        }
      end,

      file_browser = {
        git_icons           = true,
        hidden              = true,
        respect_gitignore   = true,
        follow_symlinks     = true,
      },

      find_files = {
        hidden       = true,
        find_command = { "fd","--type","f","--strip-cwd-prefix","--hidden","--exclude",".git" },
        follow       = true,
      },

      live_grep = {
        additional_args = function() return {
          "--hidden",
          "--glob=!.git/",
          "--glob=!node_modules/",
          "--glob=!vendor/",
          "--glob=!.next/",
          "--glob=!dist/",
          "--glob=!build/",
        } end,
        disable_coordinates = false,
        case_sensitive     = false,
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
            ]]
          end,
          prompt = "Next.js Files",
        },
      },
    },
  },

  keys = {
    { "<leader>e", function() require('snacks.explorer').open() end,        desc = "Toggle Explorer" },
    { "<leader>E", function() require('snacks.explorer').toggle_float() end,  desc = "Explorer Float" },
    { "-",        function() require('snacks.explorer').open() end,        desc = "Parent Dir" },
    { "_",        function() require('snacks.explorer').open({ path='.' }) end, desc = "Project Root" },

    { "<leader>ff", function() require('snacks.picker').find_files() end,       desc = "Find Files" },
    { "<leader>fg", function() require('snacks.picker').live_grep() end,        desc = "Live Grep" },
    { "<leader>fb", function() require('snacks.picker').buffers() end,          desc = "Buffers" },
    { "<leader>fh", function() require('snacks.picker').help_tags() end,        desc = "Help Tags" },
    { "<leader>fr", function() require('snacks.picker').oldfiles() end,         desc = "Recent Files" },
    { "<leader>fR", function() require('snacks.picker').frecency() end,         desc = "Frecent" },
    { "<leader>fp", function() require('snacks.picker').projects() end,        desc = "Projects" },
    { "<leader>fc", function() require('snacks.picker').commands() end,        desc = "Commands" },
    { "<leader>fk", function() require('snacks.picker').keymaps() end,         desc = "Keymaps" },
    { "<leader>f/", function() require('snacks.picker').current_buffer_fuzzy_find() end, desc = "Buffer Fuzzy Find" },
    { "<leader>f.", function() require('snacks.picker').resume() end,          desc = "Resume Search" },

    { "<leader>gs", function() require('snacks.picker').git_status() end,       desc = "Git Status" },
    { "<leader>gc", function() require('snacks.picker').git_commits() end,      desc = "Git Commits" },
    { "<leader>gb", function() require('snacks.picker').git_branches() end,     desc = "Git Branches" },

    { "<leader>fd", function() require('snacks.picker').diagnostics({ bufnr=0 }) end, desc = "Doc Diagnostics" },
    { "<leader>fD", function() require('snacks.picker').diagnostics() end,      desc = "Workspace Diagnostics" },
    { "<leader>fs", function() require('snacks.picker').lsp_document_symbols() end, desc = "Doc Symbols" },
    { "<leader>fS", function() require('snacks.picker').lsp_workspace_symbols() end, desc = "Workspace Symbols" },

    { "<leader>sgg", function() require('snacks.picker').custom('goth_files') end, desc = "GOTH Files" },
    { "<leader>sng", function() require('snacks.picker').custom('nextjs_files') end, desc = "Next.js Files" },
  },

  config = function(_, opts)
    require("snacks").setup(opts)

    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.register({
        ["<leader>sg"] = { e = { function()
          vim.g.current_stack = "goth"
          require("snacks.explorer").toggle() end, "GOTH Explorer" },
        },
        ["<leader>sn"] = { e = { function()
          vim.g.current_stack = "nextjs"
          require("snacks.explorer").toggle() end, "NextJS Explorer" },
        },
      })
    end
  end,
}

