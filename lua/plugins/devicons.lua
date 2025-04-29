return {
  "nvim-tree/nvim-web-devicons",
  lazy = false, -- Load early since many plugins depend on it
  priority = 100, -- High priority to ensure it's available for plugins that need it
  opts = {
    -- Override default icon colors based on gruvbox-material
    override_by_extension = {
      -- Example overrides (you can customize these based on your preference)
      ["lua"] = {
        color = "#89b482",
      },
      ["js"] = {
        color = "#d8a657",
      },
      ["ts"] = {
        color = "#7daea3",
      },
      ["jsx"] = {
        color = "#ea6962",
      },
      ["tsx"] = {
        color = "#ea6962",
      },
      ["go"] = {
        color = "#7daea3",
      },
      ["templ"] = {
        icon = "",
        color = "#89b482",
        name = "Templ",
      },
      ["html"] = {
        color = "#ea6962",
      },
      ["css"] = {
        color = "#7daea3",
      },
      ["json"] = {
        color = "#d8a657",
      },
      ["md"] = {
        color = "#d3869b",
      },
    },
    -- Add custom filetype icons
    override_by_filename = {
      ["go.mod"] = {
        icon = "󰟓",
        color = "#7daea3",
        name = "GoMod",
      },
      ["go.sum"] = {
        icon = "󰟓",
        color = "#d8a657",
        name = "GoSum",
      },
      [".gitignore"] = {
        icon = "",
        color = "#f2594b",
        name = "Gitignore",
      },
      ["package.json"] = {
        icon = "",
        color = "#d8a657",
        name = "PackageJson",
      },
      ["package-lock.json"] = {
        icon = "",
        color = "#ea6962",
        name = "PackageLockJson",
      },
      [".env"] = {
        icon = "",
        color = "#89b482",
        name = "Env",
      },
      [".prettierrc"] = {
        icon = "",
        color = "#d3869b",
        name = "PrettierConfig",
      },
      [".eslintrc.json"] = {
        icon = "",
        color = "#7daea3",
        name = "EslintConfig",
      },
      ["tsconfig.json"] = {
        icon = "",
        color = "#7daea3",
        name = "TSConfig",
      },
      ["next.config.js"] = {
        icon = "",
        color = "#d8a657",
        name = "NextConfig",
      },
      ["tailwind.config.js"] = {
        icon = "󱏿",
        color = "#7daea3",
        name = "TailwindConfig",
      },
    },
  },
}
