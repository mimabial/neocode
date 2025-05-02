return {
  "nvim-tree/nvim-web-devicons",
  lazy = false,
  priority = 100,
  opts = function()
    local colors = {
      green = "#89b482",
      yellow = "#d8a657",
      teal = "#7daea3",
      red = "#ea6962",
      pink = "#d3869b",
      orange = "#f2594b",
    }

    return {
      override_by_extension = {
        lua = { color = colors.green },
        js = { color = colors.yellow },
        ts = { color = colors.teal },
        jsx = { color = colors.red },
        tsx = { color = colors.red },
        go = { color = colors.teal },
        templ = { icon = "", color = colors.green, name = "Templ" },
        html = { color = colors.red },
        css = { color = colors.teal },
        json = { color = colors.yellow },
        md = { color = colors.pink },
      },
      override_by_filename = {
        ["go.mod"] = { icon = "󰟓", color = colors.teal, name = "GoMod" },
        ["go.sum"] = { icon = "󰟓", color = colors.yellow, name = "GoSum" },
        [".gitignore"] = { icon = "", color = colors.orange, name = "Gitignore" },
        ["package.json"] = { icon = "", color = colors.yellow, name = "PackageJson" },
        ["package-lock.json"] = { icon = "", color = colors.red, name = "PackageLockJson" },
        [".env"] = { icon = "", color = colors.green, name = "Env" },
        [".prettierrc"] = { icon = "", color = colors.pink, name = "PrettierConfig" },
        [".eslintrc.json"] = { icon = "", color = colors.teal, name = "EslintConfig" },
        ["tsconfig.json"] = { icon = "", color = colors.teal, name = "TSConfig" },
        ["next.config.js"] = { icon = "", color = colors.yellow, name = "NextConfig" },
        ["tailwind.config.js"] = { icon = "󱏿", color = colors.teal, name = "TailwindConfig" },
      },
    }
  end,
  config = function(_, opts)
    require("nvim-web-devicons").setup(opts)
    vim.defer_fn(function()
      require("nvim-web-devicons").refresh()
    end, 100)
  end,
}
