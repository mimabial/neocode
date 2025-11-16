-- lua/plugins/undo.lua
return {
  -- Promise dependency - Added to fix nvim-ufo error
  {
    "kevinhwang91/promise-async",
    lazy = true,
  },

  -- Folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    event = "BufReadPost",
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
    init = function()
      -- Add failsafe initialization to prevent startup errors
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    config = function(_, opts)
      -- Safer configuration with error handling
      local status_ok, ufo = pcall(require, "ufo")
      if not status_ok then
        vim.notify("UFO plugin not loaded properly", vim.log.levels.WARN)
        return
      end
      ufo.setup(opts)
    end,
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

  -- Visual undo tree (undo configuration is in lua/config/options.lua)
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
    },
    config = function()
      -- Note: Undo directory and settings are configured in lua/config/options.lua
      -- This plugin just provides the visual interface

      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_WindowLayout = 2
    end,
  },
}
