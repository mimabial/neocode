return {
  "folke/snacks.nvim",
  event = "VeryLazy",
  priority = 800, -- High priority to ensure it loads early
  opts = {
    -- Explorer configuration
    explorer = {
      enabled = true,
      border = "rounded",
      float = {
        enabled = true,
        width = 0.8,
        height = 0.8,
      },
      -- Integration with oil.nvim for file management operations
      oil = {
        enabled = true,
      },
      -- Customize icons based on Gruvbox Material colors
      highlights = function()
        local green_color = vim.api.nvim_get_hl(0, { name = "GruvboxGreen" }).fg or "#89b482"
        local aqua_color = vim.api.nvim_get_hl(0, { name = "GruvboxAqua" }).fg or "#7daea3"
        local yellow_color = vim.api.nvim_get_hl(0, { name = "GruvboxYellow" }).fg or "#d8a657"
        
        return {
          ExplorerDirName = { fg = aqua_color, bold = true },
          ExplorerFileName = { fg = yellow_color },
          ExplorerSymlinkName = { fg = green_color, underline = true },
        }
      end,
      -- Stack-specific filters
      filter = function(entry, ctx)
        -- Common filters
        if entry.name == ".git" or entry.name == ".DS_Store" then
          return false
        end
        
        -- Stack-specific filtering
        local stack = vim.g.current_stack
        if stack == "goth" then
          if entry.name == "node_modules" or 
             entry.name == "vendor" or 
             entry.name == "bin" or 
             entry.name == "dist" or 
             entry.name == "build" or
             entry.name == "go.sum" then
            return false
          end
          
          -- Emphasize Go and Templ files
          if entry.type == "file" then
            local ext = vim.fn.fnamemodify(entry.name, ":e"):lower()
            if ext == "go" or ext == "templ" then
              entry.priority = 10 -- Higher priority for GOTH files
            end
          end
        elseif stack == "nextjs" then
          if entry.name == "node_modules" or 
             entry.name == ".next" or 
             entry.name == "out" or 
             entry.name == ".turbo" or
             entry.name == ".vercel" then
            return false
          end
          
          -- Emphasize Next.js specific files and directories
          if entry.type == "directory" and (entry.name == "app" or entry.name == "pages" or entry.name == "components") then
            entry.priority = 10 -- Higher priority for Next.js directories
          elseif entry.type == "file" then
            local ext = vim.fn.fnamemodify(entry.name, ":e"):lower()
            if ext == "tsx" or ext == "jsx" or entry.name:match("next.config") then
              entry.priority = 10 -- Higher priority for Next.js files
            end
          end
        end
        
        return true
      end,
    },
    
    -- Picker configuration - replacing telescope functionality
    picker = {
      enabled = true,
      border = "rounded",
      width = 0.8,
      height = 0.8,
      -- Match telescope's behavior but optimize for performance
      telesync = true, -- Compatibility with telescope plugins when possible
      fzf = {
        fuzzy = true,
        override_file_sorter = true,
        override_generic_sorter = true,
        case_mode = "smart_case",
      },
      -- Customize highlights for picker UI
      highlights = function()
        local yellow = vim.api.nvim_get_hl(0, { name = "GruvboxYellow" }).fg or "#d8a657"
        local green = vim.api.nvim_get_hl(0, { name = "GruvboxGreen" }).fg or "#89b482"
        local aqua = vim.api.nvim_get_hl(0, { name = "GruvboxAqua" }).fg or "#7daea3"
        
        return {
          PickerMatches = { fg = green, bold = true },
          PickerSelected = { fg = yellow },
          PickerBorder = { fg = aqua },
        }
      end,
      -- Use specialized pickers for different file types
      file_browser = {
        git_icons = true,
        hidden = true,
        respect_gitignore = true,
        follow_symlinks = true,
      },
      -- Load telescope-compatible extensions if available
      extensions = {
        fzf = true,
        file_browser = true,
        project = true, 
        frecency = true,
        ["ui-select"] = {
          theme = "dropdown",
        },
      },
      -- Configure default commands for file finding
      find_files = {
        hidden = true,
        -- Similar to telescope's find_files behavior
        find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" },
        follow = true,
      },
      live_grep = {
        -- Similar to telescope's live_grep with some improvements
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
      -- Stack-specific finder configurations 
      custom_pickers = {
        goth_files = {
          command = function()
            return "find . -type f \\( -name '*.go' -o -name '*.templ' \\) -not -path '*/vendor/*' -not -path '*/node_modules/*'"
          end,
          prompt = "GOTH Files",
        },
        nextjs_files = {
          command = function()
            return "find . -type f \\( -name '*.tsx' -o -name '*.jsx' -o -name '*.ts' -o -name '*.js' \\) -not -path '*/node_modules/*' -not -path '*/.next/*'"
          end,
          prompt = "Next.js Files",
        }
      }
    }
  },
  keys = {
    -- Explorer keymaps
    { "<leader>e", function() require("snacks.explorer").toggle() end, desc = "Toggle Snacks Explorer" },
    { "<leader>E", function() require("snacks.explorer").toggle_float() end, desc = "Toggle Snacks Explorer (float)" },
    { "-", function() require("snacks.explorer").toggle() end, desc = "Open Parent Directory" },
    { "_", function() require("snacks.explorer").toggle({ path = "." }) end, desc = "Open Project Root" },
    
    -- Picker keymaps (replacing telescope)
    { "<leader>ff", function() require("snacks.picker").find_files() end, desc = "Find Files" },
    { "<leader>fg", function() require("snacks.picker").live_grep() end, desc = "Find Text (Grep)" },
    { "<leader>fb", function() require("snacks.picker").buffers() end, desc = "Find Buffers" },
    { "<leader>fh", function() require("snacks.picker").help_tags() end, desc = "Find Help" },
    { "<leader>fr", function() require("snacks.picker").oldfiles() end, desc = "Recent Files" },
    { "<leader>fR", function() require("snacks.picker").frecency() end, desc = "Frecent Files" },
    { "<leader>fp", function() require("snacks.picker").projects() end, desc = "Find Projects" },
    { "<leader>fc", function() require("snacks.picker").commands() end, desc = "Find Commands" },
    { "<leader>fk", function() require("snacks.picker").keymaps() end, desc = "Find Keymaps" },
    { "<leader>f/", function() require("snacks.picker").current_buffer_fuzzy_find() end, desc = "Find in Buffer" },
    { "<leader>f.", function() require("snacks.picker").resume() end, desc = "Resume Last Search" },
    
    -- Git related keymaps
    { "<leader>gs", function() require("snacks.picker").git_status() end, desc = "Git Status" },
    { "<leader>gc", function() require("snacks.picker").git_commits() end, desc = "Git Commits" },
    { "<leader>gb", function() require("snacks.picker").git_branches() end, desc = "Git Branches" },
    
    -- LSP related keymaps
    { "<leader>fd", function() require("snacks.picker").diagnostics({ bufnr = 0 }) end, desc = "Find Document Diagnostics" },
    { "<leader>fD", function() require("snacks.picker").diagnostics() end, desc = "Find Workspace Diagnostics" },
    { "<leader>fs", function() require("snacks.picker").lsp_document_symbols() end, desc = "Find Document Symbols" },
    { "<leader>fS", function() require("snacks.picker").lsp_workspace_symbols() end, desc = "Find Workspace Symbols" },
    
    -- Stack-specific keymaps
    { "<leader>sgg", function() require("snacks.picker").custom("goth_files") end, desc = "Find GOTH Files" },
    { "<leader>sng", function() require("snacks.picker").custom("nextjs_files") end, desc = "Find Next.js Files" },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    
    -- Add commands for stack-specific browsing
    vim.api.nvim_create_user_command("SnacksGOTH", function()
      vim.g.current_stack = "goth"
      require("snacks.explorer").toggle()
      vim.notify("Snacks explorer focused on GOTH stack", vim.log.levels.INFO)
    end, { desc = "Snacks explorer with GOTH focus" })

    vim.api.nvim_create_user_command("SnacksNextJS", function()
      vim.g.current_stack = "nextjs"
      require("snacks.explorer").toggle()
      vim.notify("Snacks explorer focused on Next.js stack", vim.log.levels.INFO)
    end, { desc = "Snacks explorer with Next.js focus" })
    
    -- Create Telescope-compatible API functions to make the transition easier
    local picker = require("snacks.picker")
    
    -- Telescope compatibility layer
    if not _G.telescope then
      _G.telescope = {
        builtin = {
          find_files = picker.find_files,
          live_grep = picker.live_grep,
          buffers = picker.buffers,
          oldfiles = picker.oldfiles,
          commands = picker.commands,
          keymaps = picker.keymaps,
          help_tags = picker.help_tags,
          lsp_document_symbols = picker.lsp_document_symbols,
          lsp_workspace_symbols = picker.lsp_workspace_symbols,
          diagnostics = picker.diagnostics,
          git_status = picker.git_status,
          git_commits = picker.git_commits,
          git_branches = picker.git_branches,
          current_buffer_fuzzy_find = picker.current_buffer_fuzzy_find,
          resume = picker.resume,
        },
        extensions = {
          file_browser = { file_browser = picker.file_browser },
          project = { project = picker.projects },
          frecency = { frecency = picker.frecency },
        }
      }
    end
    
    -- Register with which-key
    local wk_ok, wk = pcall(require, "which-key")
    if wk_ok then
      wk.register({
        ["<leader>sg"] = {
          e = { function() 
            vim.g.current_stack = "goth"
            require("snacks.explorer").toggle()
          end, "GOTH Files Explorer" },
        },
        ["<leader>sn"] = {
          e = { function() 
            vim.g.current_stack = "nextjs"
            require("snacks.explorer").toggle()
          end, "Next.js Files Explorer" },
        },
      })
    end
  end,
}
