-- lua/plugins/snacks/dim.lua
return {
  enabled = true,
  art = 80, -- Dim after 80 characters
  blend = 30, -- 30% opacity for dimmed text
  exclude_filetypes = {
    "neo-tree",
    "dashboard",
    "alpha",
    "NvimTree",
    "Outline",
    "qf",
    "oil",
    "help",
    "lazy",
    "mason",
    "toggleterm",
  },
  exclude_buftypes = {
    "terminal",
    "nofile",
    "prompt",
  },
  exclude_floating = true,
  include_string_maxlines = 100, -- Max lines for string highlighting
  include_comment_maxlines = 100, -- Max lines for comment highlighting
  dynamic_throttle = true, -- Dynamic performance throttling
  throttle_limit = 100, -- Maximum throttle limit in ms
  colorcolumn = { -- Highlight the color column
    enable = true,
    apply_to_whitespace = true,
    blend = 20,
  },
}
