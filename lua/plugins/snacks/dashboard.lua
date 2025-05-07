-- lua/plugins/snacks/dashboard.lua
-- Dashboard configuration for snacks.nvim with improved stack switching
return {
  enabled = true,
  -- Theme compatible with gruvbox-material
  theme = function()
    local hl = vim.api.nvim_get_hl(0, {})
    local bg = hl.GruvboxBg0 and hl.GruvboxBg0.bg or 0x282828
    local fg = hl.Normal and hl.Normal.fg or 0xd4be98
    local green = hl.GruvboxGreen and hl.GruvboxGreen.fg or 0x89b482
    local yellow = hl.GruvboxYellow and hl.GruvboxYellow.fg or 0xd8a657
    local blue = hl.GruvboxBlue and hl.GruvboxBlue.fg or 0x7daea3
    local aqua = hl.GruvboxAqua and hl.GruvboxAqua.fg or 0x7daea3
    local purple = hl.GruvboxPurple and hl.GruvboxPurple.fg or 0xd3869b
    local red = hl.GruvboxRed and hl.GruvboxRed.fg or 0xea6962
    local orange = hl.GruvboxOrange and hl.GruvboxOrange.fg or 0xe78a4e

    return {
      bg = string.format("#%06x", bg),
      fg = string.format("#%06x", fg),
      green = string.format("#%06x", green),
      yellow = string.format("#%06x", yellow),
      blue = string.format("#%06x", blue),
      aqua = string.format("#%06x", aqua),
      purple = string.format("#%06x", purple),
      red = string.format("#%06x", red),
      orange = string.format("#%06x", orange),
    }
  end,
  sections = {
    -- Header section with Neovim ASCII art
    {
      type = "text",
      opts = {
        position = "center",
        hl = "Title",
        content = {
          "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
          "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
          "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
          "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
          "",
          "   FullStack Developer Edition",
          "",
        },
      },
    },

    -- Stack section with visual indicators
    {
      type = "text",
      opts = {
        position = "center",
        hl = function()
          local stack = vim.g.current_stack or ""
          if stack == "goth" then
            return "String"
          elseif stack == "nextjs" then
            return "Function"
          else
            return "Comment"
          end
        end,
        content = function()
          local stack = vim.g.current_stack or "Not Selected"
          local icon = "⚒️"

          if stack == "goth" then
            icon = "󰟓 "
            stack = "GOTH Stack (Go/Templ/HTMX)"
          elseif stack == "nextjs" then
            icon = " "
            stack = "Next.js Stack (React/TypeScript)"
          end

          return {
            icon .. " Current Stack: " .. stack,
          }
        end,
      },
    },

    -- Quick actions section
    {
      type = "mapping",
      opts = {
        position = "center",
        spacing = 1,
        hl = "String",
        prefix = "     ",
        items = {
          { key = "ff", text = "Find Files", action = "lua require('snacks.picker').files()" },
          { key = "fg", text = "Live Grep", action = "lua require('snacks.picker').grep()" },
          { key = "fr", text = "Recent Files", action = "lua require('snacks.picker').recent()" },
          { key = "e", text = "File Explorer", action = "Oil" },
        },
      },
    },

    -- Stack switching section with colored indicators
    {
      type = "text",
      opts = {
        position = "center",
        hl = "Type",
        content = {
          "",
          "Stack Selection",
        },
      },
    },
    {
      type = "mapping",
      opts = {
        position = "center",
        spacing = 1,
        prefix = "     ",
        items = {
          {
            key = "sg",
            text = "󰟓  GOTH Stack",
            action = "StackFocus goth",
            hl = function()
              return vim.g.current_stack == "goth" and "String" or "Comment"
            end,
          },
          {
            key = "sn",
            text = "  Next.js Stack",
            action = "StackFocus nextjs",
            hl = function()
              return vim.g.current_stack == "nextjs" and "Function" or "Comment"
            end,
          },
        },
      },
    },

    -- Layout section
    {
      type = "text",
      opts = {
        position = "center",
        hl = "Type",
        content = {
          "",
          "Layouts",
        },
      },
    },
    {
      type = "mapping",
      opts = {
        position = "center",
        spacing = 1,
        prefix = "     ",
        items = {
          { key = "L1", text = "  Coding Layout", action = "Layout coding" },
          { key = "L2", text = "  Terminal Layout", action = "Layout terminal" },
          { key = "L3", text = "✍️  Writing Layout", action = "Layout writing" },
          { key = "L4", text = "⚙️  Debug Layout", action = "Layout debug" },
        },
      },
    },

    -- Terminal commands section - depends on current stack
    {
      type = "text",
      opts = {
        position = "center",
        hl = "Type",
        content = function()
          local stack = vim.g.current_stack or ""
          if stack == "goth" then
            return { "", "󰟓  GOTH Commands" }
          elseif stack == "nextjs" then
            return { "", "  Next.js Commands" }
          else
            return { "", "  Terminal Commands" }
          end
        end,
      },
    },
    {
      type = "mapping",
      opts = {
        position = "center",
        spacing = 1,
        prefix = "     ",
        items = function()
          local stack = vim.g.current_stack or ""
          local cmds = {}

          -- Common commands
          table.insert(cmds, { key = "gg", text = "  LazyGit", action = "LazyGit" })

          if stack == "goth" then
            -- GOTH stack commands
            table.insert(cmds, { key = "gs", text = "󰟓  Start GOTH server", action = "GOTHServer" })
            table.insert(cmds, { key = "gt", text = "  Run Go tests", action = "GoTest" })
            table.insert(cmds, { key = "tg", text = "  Generate Templ files", action = "TemplGenerate" })
            table.insert(cmds, { key = "cs", text = "  Show Symbols", action = "SymbolsOutline" })
          end

          if stack == "nextjs" then
            -- Next.js stack commands
            table.insert(cmds, { key = "nd", text = "  Start Next.js dev", action = "NextDev" })
            table.insert(cmds, { key = "nb", text = "  Build Next.js app", action = "NextBuild" })
            table.insert(cmds, { key = "nl", text = "  Run Next.js lint", action = "NextLint" })
            table.insert(cmds, { key = "cs", text = "  Show Symbols", action = "SymbolsOutline" })
          end

          -- Add general terminal command
          table.insert(cmds, { key = "tf", text = "  Floating Terminal", action = "FloatTerm" })

          return cmds
        end,
      },
    },

    -- Theme and UI section
    {
      type = "text",
      opts = {
        position = "center",
        hl = "Type",
        content = {
          "",
          "Theme & UI",
        },
      },
    },
    {
      type = "mapping",
      opts = {
        position = "center",
        spacing = 1,
        prefix = "     ",
        items = {
          { key = "ut", text = "  Toggle Colorscheme", action = "ColorSchemeToggle" },
          { key = "uT", text = "  Toggle Transparency", action = "ToggleTransparency" },
          { key = "uc", text = "  Toggle Copilot", action = "lua require('copilot.command').toggle()" },
          { key = "ui", text = "󰧑  Toggle Codeium", action = "CodeiumToggle" },
        },
      },
    },

    -- Statistics
    {
      type = "text",
      opts = {
        position = "center",
        hl = "Comment",
        content = function()
          local stats = require("lazy").stats()
          return {
            "⚡ " .. stats.loaded .. "/" .. stats.count .. " plugins loaded in " .. (math.floor(
              stats.startuptime * 100 + 0.5
            ) / 100) .. "ms",
          }
        end,
      },
    },

    -- Footer
    {
      type = "text",
      opts = {
        position = "center",
        hl = "NonText",
        content = {
          "",
          "Press q to close",
        },
      },
    },
  },
  mappings = {
    -- Close with q and <Esc>
    ["q"] = function()
      require("snacks.dashboard").close()
    end,
    ["<Esc>"] = function()
      require("snacks.dashboard").close()
    end,
  },
}
