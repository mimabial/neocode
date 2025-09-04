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

    if package.loaded["lualine"] then
      _G.search_count = function()
        local s = vim.fn.searchcount({ maxcount = 999, timeout = 500 })
        if vim.v.hlsearch == 1 and s.total > 0 then
          return string.format("[%d/%d]", s.current, s.total)
        end
        return ""
      end
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        if vim.g.colors_name == "gruvbox-material" then
          vim.api.nvim_set_hl(0, "HlSearchNear", { bg = "#4e3e43", fg = "#d8a657", bold = true })
          vim.api.nvim_set_hl(0, "HlSearchLens", { fg = "#7daea3", bold = true })
          vim.api.nvim_set_hl(0, "HlSearchFloat", { bg = "#32302f", fg = "#d8a657" })
        end
      end,
    })
  end,
}
