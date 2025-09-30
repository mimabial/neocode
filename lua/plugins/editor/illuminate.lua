return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  opts = {
    filetypes_denylist = {
      "dirbuf",
      "dirvish",
      "fugitive",
      "NvimTree",
      "oil",
      "Trouble",
      "lazy",
      "mason",
      "notify",
      "toggleterm",
      "TelescopePrompt",
    },
    large_file_cutoff = nil,
    min_count_to_highlight = 1,
    under_cursor = false,
  },
  config = function(_, opts)
    require("illuminate").configure(opts)

    local function map(key, dir, buffer)
      vim.keymap.set("n", key, function()
        require("illuminate")["goto_" .. dir .. "_reference"](false)
      end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " reference", buffer = buffer })
    end

    map("]]", "next")
    map("[[", "prev")

    -- Also set it after loading ftplugins, since ftplugins may override defaults
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()
        map("]]", "next", buffer)
        map("[[", "prev", buffer)
      end,
    })
  end,
  keys = {
    { "]]", desc = "Next reference" },
    { "[[", desc = "Prev reference" },
  },
}
