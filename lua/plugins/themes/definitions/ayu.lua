-- Ayu Theme Definition
return {
  icon = "",
  variants = { "dark", "light", "mirage" },
  setup = function(variant, transparency)
    local ayu_config = {
      mirage = variant == "mirage",
      terminal = true,
    }

    -- Handle transparency via overrides
    if transparency then
      ayu_config.overrides = {
        Normal = { bg = "None" },
        NormalFloat = { bg = "None" },
        ColorColumn = { bg = "None" },
        SignColumn = { bg = "None" },
        Folded = { bg = "None" },
        FoldColumn = { bg = "None" },
        CursorLine = { bg = "None" },
        CursorColumn = { bg = "None" },
        VertSplit = { bg = "None" },
      }
    end

    require("ayu").setup(ayu_config)

    -- Set background and apply colorscheme
    if variant == "light" then
      vim.o.background = "light"
      vim.cmd("colorscheme ayu-light")
    elseif variant == "mirage" then
      vim.o.background = "dark"
      vim.cmd("colorscheme ayu-mirage")
    else
      vim.o.background = "dark"
      vim.cmd("colorscheme ayu-dark")
    end
  end,
}
