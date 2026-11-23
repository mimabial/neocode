local MIN_WINBAR_WINDOW_HEIGHT = 5
local MIN_WINBAR_WINDOW_WIDTH = 20
local WINBAR_ROWS = 1

return {
  "SmiteshP/nvim-navic",
  lazy = false,
  opts = {
    highlight = true,
    separator = " ",
    depth_limit = 4,
    depth_limit_indicator = "..",
    safe_output = true,
    lazy_update_context = false,
    click = false,
  },
  config = function(_, opts)
    local navic = require("nvim-navic")
    navic.setup(opts)

    local function setup_highlights()
      local colors = require("config.ui").get_colors()

      vim.api.nvim_set_hl(0, "NavicText", { fg = colors.fg })
      vim.api.nvim_set_hl(0, "NavicSeparator", { fg = colors.border })

      vim.api.nvim_set_hl(0, "NavicIconsFile", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "NavicIconsModule", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "NavicIconsNamespace", { fg = colors.purple })
      vim.api.nvim_set_hl(0, "NavicIconsPackage", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "NavicIconsClass", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "NavicIconsMethod", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "NavicIconsProperty", { fg = colors.green })
      vim.api.nvim_set_hl(0, "NavicIconsField", { fg = colors.green })
      vim.api.nvim_set_hl(0, "NavicIconsConstructor", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "NavicIconsEnum", { fg = colors.purple })
      vim.api.nvim_set_hl(0, "NavicIconsInterface", { fg = colors.purple })
      vim.api.nvim_set_hl(0, "NavicIconsFunction", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "NavicIconsVariable", { fg = colors.red })
      vim.api.nvim_set_hl(0, "NavicIconsConstant", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "NavicIconsString", { fg = colors.green })
      vim.api.nvim_set_hl(0, "NavicIconsNumber", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "NavicIconsBoolean", { fg = colors.red })
      vim.api.nvim_set_hl(0, "NavicIconsArray", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "NavicIconsObject", { fg = colors.purple })
      vim.api.nvim_set_hl(0, "NavicIconsKey", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "NavicIconsNull", { fg = colors.gray })
      vim.api.nvim_set_hl(0, "NavicIconsEnumMember", { fg = colors.purple })
      vim.api.nvim_set_hl(0, "NavicIconsStruct", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "NavicIconsEvent", { fg = colors.red })
      vim.api.nvim_set_hl(0, "NavicIconsOperator", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "NavicIconsTypeParameter", { fg = colors.green })
    end

    setup_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })

    local winbar = "%{%v:lua.require('nvim-navic').get_location()%}"
    local navic_group = vim.api.nvim_create_augroup("navic", { clear = false })
    local enabled = true

    local function attach(client, buf)
      local attached_name = vim.b[buf].navic_client_name
      if client.server_capabilities.documentSymbolProvider and (attached_name == nil or attached_name == client.name) then
        navic.attach(client, buf)
      end
    end

    local function detach(buf)
      vim.api.nvim_clear_autocmds({ group = navic_group, buffer = buf })
      vim.b[buf].navic_client_id = nil
      vim.b[buf].navic_client_name = nil
    end

    local function text_height_with_winbar(win)
      local info = vim.fn.getwininfo(win)[1]
      return info.height + info.winbar - WINBAR_ROWS
    end

    local function update_winbar(win)
      local shows_breadcrumbs = enabled
        and vim.b[vim.api.nvim_win_get_buf(win)].navic_client_id ~= nil
        and vim.api.nvim_win_get_config(win).relative == ""
        and text_height_with_winbar(win) >= MIN_WINBAR_WINDOW_HEIGHT
        and vim.api.nvim_win_get_width(win) >= MIN_WINBAR_WINDOW_WIDTH
      if shows_breadcrumbs then
        vim.wo[win].winbar = winbar
      elseif vim.wo[win].winbar == winbar then
        vim.wo[win].winbar = ""
      end
    end

    local function update_buffer_winbars(buf)
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        update_winbar(win)
      end
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(event)
        if enabled then
          attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
          update_buffer_winbars(event.buf)
        end
      end,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
      callback = function(event)
        if vim.b[event.buf].navic_client_id ~= event.data.client_id then
          return
        end
        detach(event.buf)
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = event.buf })) do
          if client.id ~= event.data.client_id and not vim.b[event.buf].navic_client_id then
            attach(client, event.buf)
          end
        end
        update_buffer_winbars(event.buf)
      end,
    })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      callback = function()
        update_winbar(vim.api.nvim_get_current_win())
      end,
    })

    vim.api.nvim_create_autocmd("WinResized", {
      callback = function()
        for _, win in ipairs(vim.v.event.windows) do
          update_winbar(win)
        end
      end,
    })

    vim.api.nvim_create_user_command("NavicToggle", function()
      enabled = not enabled
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if enabled then
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
            attach(client, buf)
          end
        else
          detach(buf)
        end
      end
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        update_winbar(win)
      end
      vim.notify("Navic " .. (enabled and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle navic breadcrumbs and symbol tracking" })
  end,
}
