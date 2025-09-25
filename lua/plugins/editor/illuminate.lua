return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  opts = {
    providers = {
      "lsp",
      "treesitter",
      "regex",
    },
    delay = 100,
    filetype_overrides = {},
    filetypes_denylist = {
      "dirbuf",
      "dirvish",
      "fugitive",
      "neo-tree",
      "NvimTree",
      "oil",
      "Trouble",
      "lazy",
      "mason",
      "notify",
      "toggleterm",
      "TelescopePrompt",
    },
    filetypes_allowlist = {},
    modes_denylist = {},
    modes_allowlist = {},
    providers_regex_syntax_denylist = {},
    providers_regex_syntax_allowlist = {},
    under_cursor = true,
    large_file_cutoff = nil,
    large_file_overrides = nil,
    min_count_to_highlight = 1,
    should_enable = function(bufnr)
      return true
    end,
    case_insensitive_regex = false,
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

    -- Set up highlights with theme integration
    local function setup_highlights()
      local colors = _G.get_ui_colors()
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = colors.select_bg or colors.border, underline = true })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = colors.select_bg or colors.border, underline = true })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite",
        { bg = colors.select_bg or colors.border, underline = true, bold = true })
    end

    setup_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })
  end,
  keys = {
    { "]]", desc = "Next reference" },
    { "[[", desc = "Prev reference" },
  },
}
