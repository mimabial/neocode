-- lua/plugins/snacks/picker.lua
return {
  sources = {
    explorer = {
      layout = {
        preview = "main",
        layout = {
          backdrop = false,
          width = 40,
          min_width = 40,
          height = 0,
          position = "left",
          border = "none",
          box = "vertical",
          { win = "input", height = 1, border = "single", title = "{title} {live} {flags}", title_pos = "center" },
          { win = "list", border = "none" },
          { win = "preview", title = "{preview}", height = 0.4, border = "top" },
        },
      },
    },
  },
  layout = {
    layout = {
      box = "vertical",
      backdrop = false,
      row = -1,
      width = 0,
      height = 0.5,
      border = "top",
      title = " {title} {live} {flags}",
      title_pos = "left",
      { win = "input", height = 1, border = "bottom" },
      {
        box = "horizontal",
        { win = "list", border = "none" },
        { win = "preview", title = "{preview}", width = 0.6, border = "left" },
      },
    },
  },
  matcher = { fuzzy = true, smartcase = true, filename_bonus = true },
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
  file_browser = { git_icons = true, hidden = true, respect_gitignore = true, follow_symlinks = true },
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
        return [[find . -type f \( -name '*.go' -o -name '*.templ' \) -not -path '*/vendor/*' -not -path '*/node_modules/*']]
      end,
      prompt = "GOTH Files",
    },
    nextjs_files = {
      command = function()
        return [[find . -type f \( -name '*.tsx' -o -name '*.jsx' -o -name '*.ts' -o -name '*.js' \) -not -path '*/node_modules/*' -not -path '*/.next/*']]
      end,
      prompt = "Next.js Files",
    },
  },
}
