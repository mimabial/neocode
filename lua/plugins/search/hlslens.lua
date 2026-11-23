-- lua/plugins/hlslens.lua
return {
  "kevinhwang91/nvim-hlslens",
  event = "BufReadPost",
  priority = 60,
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

    local function map(lhs, keys, desc)
      vim.keymap.set("n", lhs, keys .. "<Cmd>lua require('hlslens').start()<CR>", { silent = true, desc = desc })
    end
    local function counted(key)
      return ("<Cmd>execute('normal! ' . v:count1 . '%s')<CR>"):format(key)
    end

    map("n", counted("n") .. "zzzv", "Next search result (centered)")
    map("N", counted("N") .. "zzzv", "Previous search result (centered)")
    map("*", "*zzzv", "Search word forward (centered)")
    map("#", "#zzzv", "Search word backward (centered)")
    map("g*", "g*", "Search partial word forward")
    map("g#", "g#", "Search partial word backward")

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
