-- Notifier configuration for snacks.nvim
return {
  notifier = {
    enabled = true,
    fps = 60, -- frames per second for animations
    level = vim.log.levels.INFO, -- minimum log level
    max_width = 0.8, -- max width as percentage of screen width
    timeout = 3000, -- default timeout in ms
    stages = "fade", -- animation style: fade, slide, static
    top_down = true, -- true = new notifications at top
    -- Gruvbox-inspired icons

    icons = {
      [vim.log.levels.ERROR] = "", -- x-circle
      [vim.log.levels.WARN] = "", -- warning triangle
      [vim.log.levels.INFO] = "", -- information bubble
      [vim.log.levels.DEBUG] = "", -- bug
      [vim.log.levels.TRACE] = "✎", -- pencil (already good)
    },

    -- Gruvbox-inspired highlights
    highlights = function()
      local hl = vim.api.nvim_get_hl(0, {})
      local bg0 = hl.GruvboxBg0 and hl.GruvboxBg0.bg or 0x282828
      local red = hl.GruvboxRed and hl.GruvboxRed.fg or 0xea6962
      local green = hl.GruvboxGreen and hl.GruvboxGreen.fg or 0x89b482
      local yellow = hl.GruvboxYellow and hl.GruvboxYellow.fg or 0xd8a657
      local blue = hl.GruvboxBlue and hl.GruvboxBlue.fg or 0x7daea3
      local aqua = hl.GruvboxAqua and hl.GruvboxAqua.fg or 0x7daea3
      local purple = hl.GruvboxPurple and hl.GruvboxPurple.fg or 0xd3869b

      return {
        NotifierBackground = { bg = string.format("#%06x", bg0) },
        NotifierBorder = { fg = string.format("#%06x", aqua) },
        NotifierErrorBorder = { fg = string.format("#%06x", red) },
        NotifierErrorIcon = { fg = string.format("#%06x", red) },
        NotifierErrorTitle = { fg = string.format("#%06x", red) },
        NotifierWarnBorder = { fg = string.format("#%06x", yellow) },
        NotifierWarnIcon = { fg = string.format("#%06x", yellow) },
        NotifierWarnTitle = { fg = string.format("#%06x", yellow) },
        NotifierInfoBorder = { fg = string.format("#%06x", blue) },
        NotifierInfoIcon = { fg = string.format("#%06x", blue) },
        NotifierInfoTitle = { fg = string.format("#%06x", blue) },
        NotifierDebugBorder = { fg = string.format("#%06x", green) },
        NotifierDebugIcon = { fg = string.format("#%06x", green) },
        NotifierDebugTitle = { fg = string.format("#%06x", green) },
        NotifierTraceBorder = { fg = string.format("#%06x", purple) },
        NotifierTraceIcon = { fg = string.format("#%06x", purple) },
        NotifierTraceTitle = { fg = string.format("#%06x", purple) },
      }
    end,
  },
}
