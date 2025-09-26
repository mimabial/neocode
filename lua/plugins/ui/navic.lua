return {
  "SmiteshP/nvim-navic",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  lazy = false,
  opts = {
    icons = {
      File = " ",
      Module = " ",
      Namespace = " ",
      Package = " ",
      Class = " ",
      Method = " ",
      Property = " ",
      Field = " ",
      Constructor = " ",
      Enum = " ",
      Interface = " ",
      Function = " ",
      Variable = " ",
      Constant = " ",
      String = " ",
      Number = " ",
      Boolean = " ",
      Array = " ",
      Object = " ",
      Key = " ",
      Null = " ",
      EnumMember = " ",
      Struct = " ",
      Event = " ",
      Operator = " ",
      TypeParameter = " ",
    },
    lsp = {
      auto_attach = true
    },
    highlight = true,
    separator = " ",
    depth_limit = 5,
    depth_limit_indicator = "..",
    safe_output = true,
    lazy_update_context = false,
    click = false,
  },
  config = function(_, opts)
    require("nvim-navic").setup(opts)

    local function setup_highlights()
      local colors = _G.get_ui_colors()

      -- Main navic highlights
      vim.api.nvim_set_hl(0, "NavicText", { fg = colors.fg, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicSeparator", { fg = colors.border, bg = colors.bg })

      -- Navic icon highlights
      vim.api.nvim_set_hl(0, "NavicIconsFile", { fg = colors.blue, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsModule", { fg = colors.orange, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsNamespace", { fg = colors.purple, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsPackage", { fg = colors.yellow, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsClass", { fg = colors.orange, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsMethod", { fg = colors.blue, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsProperty", { fg = colors.green, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsField", { fg = colors.green, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsConstructor", { fg = colors.orange, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsEnum", { fg = colors.purple, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsInterface", { fg = colors.purple, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsFunction", { fg = colors.blue, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsVariable", { fg = colors.red, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsConstant", { fg = colors.yellow, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsString", { fg = colors.green, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsNumber", { fg = colors.orange, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsBoolean", { fg = colors.red, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsArray", { fg = colors.blue, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsObject", { fg = colors.purple, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsKey", { fg = colors.yellow, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsNull", { fg = colors.gray, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsEnumMember", { fg = colors.purple, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsStruct", { fg = colors.orange, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsEvent", { fg = colors.red, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsOperator", { fg = colors.blue, bg = colors.bg })
      vim.api.nvim_set_hl(0, "NavicIconsTypeParameter", { fg = colors.green, bg = colors.bg })
    end

    setup_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })

    -- Create command to toggle navic in winbar
    vim.api.nvim_create_user_command("NavicToggle", function()
      local navic = require("nvim-navic")
      if vim.wo.winbar and vim.wo.winbar:find("navic") then
        vim.wo.winbar = ""
        vim.notify("Navic disabled", vim.log.levels.INFO)
      else
        if navic.is_available() then
          vim.wo.winbar = "%{%v:lua.require('nvim-navic').get_location()%}"
          vim.notify("Navic enabled", vim.log.levels.INFO)
        else
          vim.notify("Navic not available for this buffer", vim.log.levels.WARN)
        end
      end
    end, { desc = "Toggle navic breadcrumbs in winbar" })

    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        local navic = require("nvim-navic")
        if navic.is_available() then
          vim.wo.winbar = "%{%v:lua.require('nvim-navic').get_location()%}"
        end
      end,
    })
  end,
}
