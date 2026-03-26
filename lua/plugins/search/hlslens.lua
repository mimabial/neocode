-- lua/plugins/hlslens.lua
return {
  "kevinhwang91/nvim-hlslens",
  event = "BufReadPost",
  priority = 60,
  keys = {
    { "n", desc = "Next search result" },
    { "N", desc = "Previous search result" },
    { "*", desc = "Search word under cursor" },
    { "#", desc = "Search word backward" },
  },
  config = function()
    local hlslens = require("hlslens")
    local colors_lib = require("lib.colors")

    hlslens.setup({
      calm_down = true,
      nearest_only = false,
      nearest_float_when = "auto",
      float_shadow_blend = 50,
      virt_priority = 100,
      build_position_cb = function(plist)
        local ok, search_handler = pcall(require, "scrollbar.handlers.search")
        if ok then
          search_handler.handler.show(plist.start_pos)
        end
      end,
    })

    local map = vim.keymap.set
    local opts = { silent = true, noremap = true }
    local function lens(cmd)
      return string.format("<Cmd>execute('normal! ' . v:count1 . '%s')<CR><Cmd>lua require('hlslens').start()<CR>", cmd)
    end

    map("n", "n", lens("n"), opts)
    map("n", "N", lens("N"), opts)
    map("n", "*", "*<Cmd>lua require('hlslens').start()<CR>", opts)
    map("n", "#", "#<Cmd>lua require('hlslens').start()<CR>", opts)
    map("n", "g*", "g*<Cmd>lua require('hlslens').start()<CR>", opts)
    map("n", "g#", "g#<Cmd>lua require('hlslens').start()<CR>", opts)
    map("n", "<Esc>", "<Cmd>noh<CR><Esc>", opts)

    local function set_hlslens_highlights()
      local colors = colors_lib.extract_all()

      vim.api.nvim_set_hl(0, "HlSearchNear", {
        bg = colors.select_bg,
        fg = colors.select_fg,
        bold = true,
      })
      vim.api.nvim_set_hl(0, "HlSearchLens", {
        fg = colors.blue,
        bold = true,
      })
      vim.api.nvim_set_hl(0, "HlSearchLensNear", {
        bg = colors.select_bg,
        fg = colors.select_fg,
        bold = true,
      })
      vim.api.nvim_set_hl(0, "HlSearchFloat", {
        bg = colors.popup_bg,
        fg = colors.yellow,
      })
    end

    set_hlslens_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_hlslens_highlights,
    })
  end,
}
