return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VeryLazy",
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")

    local function map_select(lhs, query)
      vim.keymap.set({ "x", "o" }, lhs, function()
        select.select_textobject(query, "textobjects")
      end, { silent = true, desc = "Select " .. query })
    end

    map_select("af", "@function.outer")
    map_select("if", "@function.inner")
    map_select("ac", "@class.outer")
    map_select("ic", "@class.inner")
    map_select("ab", "@block.outer")
    map_select("ib", "@block.inner")
    map_select("aa", "@parameter.outer")
    map_select("ia", "@parameter.inner")

    local function map_move(lhs, dir, query)
      vim.keymap.set({ "n", "x", "o" }, lhs, function()
        move["goto_" .. dir](query, "textobjects")
      end, { silent = true, desc = dir:gsub("_", " ") .. " " .. query })
    end

    map_move("]f", "next_start", "@function.outer")
    map_move("]F", "next_end", "@function.outer")
    map_move("[f", "previous_start", "@function.outer")
    map_move("[F", "previous_end", "@function.outer")

    map_move("]c", "next_start", "@class.outer")
    map_move("]C", "next_end", "@class.outer")
    map_move("[c", "previous_start", "@class.outer")
    map_move("[C", "previous_end", "@class.outer")

    map_move("]a", "next_start", "@parameter.inner")
    map_move("]A", "next_end", "@parameter.inner")
    map_move("[a", "previous_start", "@parameter.inner")
    map_move("[A", "previous_end", "@parameter.inner")
  end,
}
