-- lua/plugins/undo.lua
return {
  -- Folding
  {
    "kevinhwang91/nvim-ufo", -- This already exists but needs tweaking
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        -- Keep existing handler but optimize performance
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0

        -- Process fewer items to improve performance
        for i, chunk in ipairs(virtText) do
          if i > 10 then
            break
          end -- Limit processing to first 10 chunks
          local chunkText, chunkWidth = chunk[1], vim.fn.strdisplaywidth(chunk[1])
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            table.insert(newVirtText, { chunkText, chunk[2] })
            if curWidth + vim.fn.strdisplaywidth(chunkText) < targetWidth then
              suffix = suffix .. string.rep(" ", targetWidth - curWidth - vim.fn.strdisplaywidth(chunkText))
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end

        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
    },
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
      {
        "zr",
        function()
          require("ufo").openFoldsExceptKinds()
        end,
        desc = "Open folds except kinds",
      },
      {
        "zm",
        function()
          require("ufo").closeFoldsWith()
        end,
        desc = "Close folds with",
      },
      {
        "zp",
        function()
          require("ufo").peekFoldedLinesUnderCursor()
        end,
        desc = "Peek fold",
      },
    },
  },

  -- Add proper undo configuration
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
    },
    config = function()
      -- Create undo directory if it doesn't exist
      local undodir = vim.fn.stdpath("data") .. "/undodir"
      if vim.fn.isdirectory(undodir) == 0 then
        vim.fn.mkdir(undodir, "p")
      end

      -- Set undo configuration
      vim.opt.undodir = undodir
      vim.opt.undofile = true
      vim.opt.undolevels = 1000
      vim.opt.undoreload = 10000

      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_WindowLayout = 2
    end,
  },
}
