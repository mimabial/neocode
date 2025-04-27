return {
  "echasnovski/mini.starter",
  version = false,
  event = "VimEnter",
  opts = function()
    local logo = table.concat({
      "          ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗          ",
      "          ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║          ",
      "          ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║          ",
      "          ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║          ",
      "          ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║          ",
      "          ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝          ",
    }, "\n")

    local starter = require("mini.starter")
    return {
      evaluate_single = true,
      header = logo,
      items = {
        starter.sections.recent_files(10, false),
        starter.sections.recent_files(10, true),
        { name = "Sessions", action = "Telescope persisted", section = "Telescope" },
        { name = "Find file", action = "Telescope find_files", section = "Telescope" },
        { name = "Find word", action = "Telescope live_grep", section = "Telescope" },
        { name = "File browser", action = "Neotree toggle", section = "Neotree" },
        { name = "Configuration", action = "edit ~/.config/nvim/init.lua", section = "Config" },
        { name = "Lazy", action = "Lazy", section = "Config" },
        { name = "New file", action = "ene | startinsert", section = "Built-in" },
        { name = "Quit", action = "qa", section = "Built-in" },
      },
      content_hooks = {
        starter.gen_hook.adding_bullet(),
        starter.gen_hook.indexing("all", { "Builtin actions" }),
        starter.gen_hook.padding(3, 2),
      },
      footer = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        return { "Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
      end,
    }
  end,
  config = function(_, opts)
    require("mini.starter").setup(opts)

    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        local starter_footer = "⚡ Neovim loaded "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins in "
          .. ms
          .. "ms"
        vim.g.starter_footer = starter_footer
      end,
    })
  end,
}
