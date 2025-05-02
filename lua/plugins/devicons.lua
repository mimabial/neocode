-- lua/plugins/devicons.lua
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
      orange = "#e78a4e",
      purple = "#d3869b",
      blue = "#7daea3",
      gray = "#928374",
    }

    return {
      -- Override some default icons
      override_by_extension = {
        -- Common files
        ["lua"] = { icon = "", color = colors.teal },
        ["json"] = { icon = "", color = colors.yellow },
        ["yaml"] = { icon = "", color = colors.yellow },
        ["toml"] = { icon = "", color = colors.orange },
        ["md"] = { icon = "", color = colors.blue },
        ["txt"] = { icon = "", color = colors.gray },

        -- GOTH stack
        ["go"] = { icon = "󰟓", color = colors.teal },
        ["templ"] = { icon = "", color = colors.green, name = "Templ" },
        ["html"] = { icon = "", color = colors.orange },
        ["css"] = { icon = "", color = colors.blue },

        -- Next.js stack
        ["js"] = { icon = "", color = colors.yellow },
        ["jsx"] = { icon = "", color = colors.orange },
        ["ts"] = { icon = "󰛦", color = colors.blue },
        ["tsx"] = { icon = "󰜈", color = colors.blue },
        ["jsx"] = { icon = "", color = colors.orange },
        ["scss"] = { icon = "", color = colors.pink },
        ["svg"] = { icon = "󰜡", color = colors.orange },

        -- API & data
        ["graphql"] = { icon = "", color = colors.pink },
        ["prisma"] = { icon = "󰔶", color = colors.purple },
        ["sql"] = { icon = "", color = colors.teal },
        ["csv"] = { icon = "󰈛", color = colors.green },
      },

      override_by_filename = {
        -- Stack-specific files
        ["go.mod"] = { icon = "󰟓", color = colors.teal, name = "GoMod" },
        ["go.sum"] = { icon = "󰟓", color = colors.yellow, name = "GoSum" },
        ["package.json"] = { icon = "", color = colors.red, name = "PackageJson" },
        ["package-lock.json"] = { icon = "", color = colors.red, name = "PackageLockJson" },
        ["yarn.lock"] = { icon = "", color = colors.blue, name = "YarnLock" },
        ["pnpm-lock.yaml"] = { icon = "", color = colors.yellow, name = "PnpmLock" },

        -- Next.js files
        ["next.config.js"] = { icon = "", color = colors.purple, name = "NextConfig" },
        ["next.config.mjs"] = { icon = "", color = colors.purple, name = "NextConfig" },
        ["next.config.ts"] = { icon = "", color = colors.purple, name = "NextConfig" },
        ["tailwind.config.js"] = { icon = "󱏿", color = colors.teal, name = "TailwindConfig" },
        ["tsconfig.json"] = { icon = "󰛦", color = colors.blue, name = "TSConfig" },

        -- Common config files
        [".gitignore"] = { icon = "", color = colors.gray, name = "GitIgnore" },
        [".eslintrc.json"] = { icon = "", color = colors.purple, name = "ESLintConfig" },
        [".eslintrc.js"] = { icon = "", color = colors.purple, name = "ESLintConfig" },
        [".prettierrc"] = { icon = "", color = colors.green, name = "PrettierConfig" },
        [".prettierrc.json"] = { icon = "", color = colors.green, name = "PrettierConfig" },
        [".env"] = { icon = "", color = colors.yellow, name = "Env" },
        [".env.local"] = { icon = "", color = colors.yellow, name = "EnvLocal" },
        ["Dockerfile"] = { icon = "", color = colors.blue, name = "Dockerfile" },
        ["docker-compose.yml"] = { icon = "󰡨", color = colors.teal, name = "DockerCompose" },
        ["Makefile"] = { icon = "", color = colors.orange, name = "Makefile" },

        -- Go & HTMX files
        ["main.go"] = { icon = "󰟓", color = colors.green, name = "GoMain" },
        ["htmx.min.js"] = { icon = "", color = colors.orange, name = "HTMX" },

        -- Other important files
        ["README.md"] = { icon = "", color = colors.blue, name = "README" },
        ["LICENSE"] = { icon = "", color = colors.yellow, name = "License" },
      },

      default = true,
    }
  end,
  config = function(_, opts)
    require("nvim-web-devicons").setup(opts)
    -- Force refresh icons
    vim.defer_fn(function()
      require("nvim-web-devicons").refresh()
    end, 100)
  end,
}
