-- lua/plugins/hlslens.lua
return {
  "kevinhwang91/nvim-hlslens",
  event = "BufReadPost",
  priority = 60, -- Load after core plugins
  keys = {
    { "n", desc = "Next search result" },
    { "N", desc = "Previous search result" },
    { "*", desc = "Search word under cursor" },
    { "#", desc = "Search word backward" },
  },
  config = function()
    require("hlslens").setup({
      calm_down = true,
      nearest_only = false,
      nearest_float_when = "auto",
      float_shadow_blend = 50,
      virt_priority = 100,
      build_position_cb = function(plist, _, _, _)
        -- Integration with scrollbar plugin if it exists
        if package.loaded["scrollbar.handlers.search"] then
          require("scrollbar.handlers.search").handler.show(plist.start_pos)
        end
      end,
    })

    -- Override search commands to include lens visualization
    local kopts = { silent = true, noremap = true }

    vim.api.nvim_set_keymap(
      "n",
      "n",
      [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
      kopts
    )
    vim.api.nvim_set_keymap(
      "n",
      "N",
      [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
      kopts
    )
    vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

    -- Clear highlight with <Esc>
    vim.api.nvim_set_keymap("n", "<Esc>", "<Cmd>noh<CR><Esc>", kopts)

    -- Add integration with lualine if available
    if package.loaded["lualine"] then
      local function search_result()
        local search = vim.fn.searchcount({ maxcount = 999, timeout = 500 })
        local active = vim.v.hlsearch == 1 and search.total > 0
        if not active then
          return ""
        end
        return string.format("[%d/%d]", search.current, search.total)
      end

      -- This can be used in lualine config
      _G.search_count = search_result
    end

    -- Show search count in the statusline (works with lualine)
    -- If you want to show it in command line, uncomment below
    -- vim.opt.shortmess:remove("S")

    -- Gruvbox material highlight integration
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        -- Only set if using gruvbox-material
        if vim.g.colors_name == "gruvbox-material" then
          vim.api.nvim_set_hl(0, "HlSearchNear", {
            bg = "#4e3e43",
            fg = "#d8a657",
            bold = true,
          })
          vim.api.nvim_set_hl(0, "HlSearchLens", {
            fg = "#7daea3",
            bold = true,
          })
          vim.api.nvim_set_hl(0, "HlSearchFloat", {
            bg = "#32302f",
            fg = "#d8a657",
          })
        end
      end,
    })
  end,
}
