-- Dashboard configuration for snacks.nvim
---@diagnostic disable: undefined-field
return {
  enabled = true,
  -- Same theme as gruvbox-material
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

    return {
      bg = string.format("#%06x", bg),
      fg = string.format("#%06x", fg),
      green = string.format("#%06x", green),
      yellow = string.format("#%06x", yellow),
      blue = string.format("#%06x", blue),
      aqua = string.format("#%06x", aqua),
      purple = string.format("#%06x", purple),
      red = string.format("#%06x", red),
    }
  end,
  sections = {
    -- Header section
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
    -- Stack section
    {
      type = "text",
      opts = {
        position = "center",
        hl = "String",
        content = function()
          return {
            "Current Stack: " .. (vim.g.current_stack or "Not Selected") .. " ⚒️",
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
        items = {
          { key = "ff", text = "Find Files", action = "lua require('snacks.picker').files()" },
          { key = "fg", text = "Live Grep", action = "lua require('snacks.picker').grep()" },
          { key = "fr", text = "Recent Files", action = "lua require('snacks.picker').recent()" },
          { key = "L1", text = "Coding Layout", action = "Layout coding" },
          { key = "L2", text = "Terminal Layout", action = "Layout terminal" },
          { key = "L3", text = "Writing Layout", action = "Layout writing" },
          { key = "sg", text = "GOTH Stack", action = "StackFocus goth" },
          { key = "sn", text = "Next.js Stack", action = "StackFocus nextjs" },
          { key = "e", text = "File Explorer", action = "Oil" },
        },
      },
    },
    -- Stats section
    { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
    {
      pane = 2,
      icon = " ",
      desc = "Browse Repo",
      padding = 1,
      key = "b",
      action = function()
        Snacks.gitbrowse()
      end,
    },
    function()
      local in_git = Snacks.git.get_root() ~= nil
      local cmds = {
        {
          title = "Notifications",
          cmd = "gh notify -s -a -n5",
          action = function()
            vim.ui.open("https://github.com/notifications")
          end,
          key = "n",
          icon = " ",
          height = 5,
          enabled = true,
        },
        {
          title = "Open Issues",
          cmd = "gh issue list -L 3",
          key = "i",
          action = function()
            vim.fn.jobstart("gh issue list --web", { detach = true })
          end,
          icon = " ",
          height = 7,
        },
        {
          icon = " ",
          title = "Open PRs",
          cmd = "gh pr list -L 3",
          key = "P",
          action = function()
            vim.fn.jobstart("gh pr list --web", { detach = true })
          end,
          height = 7,
        },
        {
          icon = " ",
          title = "Git Status",
          cmd = "git --no-pager diff --stat -B -M -C",
          height = 10,
        },
      }
      return vim.tbl_map(function(cmd)
        return vim.tbl_extend("force", {
          pane = 2,
          section = "terminal",
          enabled = in_git,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        }, cmd)
      end, cmds)
    end,
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
