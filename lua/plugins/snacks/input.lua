-- Input configuration for snacks.nvim
return {
  input = {
    enabled = true,
    default_prompt = " ",
    prompt_align = "left",
    insert_only = true,
    start_in_insert = true,
    border = "rounded",
    mappings = {
      ["<Esc>"] = "Close",
      ["<CR>"] = "Confirm",
      ["<C-c>"] = "Close",
      ["<Up>"] = "HistoryPrev",
      ["<Down>"] = "HistoryNext",
    },
    -- Gruvbox-inspired highlights
    highlights = function()
      local hl = vim.api.nvim_get_hl(0, {})
      local bg1 = hl.GruvboxBg1 and hl.GruvboxBg1.bg or 0x32302f
      local yellow = hl.GruvboxYellow and hl.GruvboxYellow.fg or 0xd8a657
      return {
        InputBorder = { fg = string.format("#%06x", yellow) },
        InputNormal = { bg = string.format("#%06x", bg1) },
      }
    end,
  },
}
