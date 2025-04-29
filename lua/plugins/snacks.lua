return {
  "folke/snacks.nvim",
  event = "VeryLazy",
  priority = 800, -- High priority to ensure it loads early
  opts = {
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
  },
  keys = {
    { "<leader>e", function() require("snacks.explorer").toggle() end, desc = "Toggle Snacks Explorer" },
    { "<leader>E", function() require("snacks.explorer").toggle_float() end, desc = "Toggle Snacks Explorer (float)" },
    -- Replace oil keymaps with snacks equivalents
    { "-", function() require("snacks.explorer").toggle() end, desc = "Open parent directory" },
    { "_", function() require("snacks.explorer").toggle({ path = "." }) end, desc = "Open project root" },
    { "<leader>o", function() require("snacks.explorer").toggle_float() end, desc = "Float Explorer" },
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
    
    -- Register with which-key if available
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
