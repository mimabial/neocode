-- Theme definitions live in themes/definitions/, manager logic in lib/theme_manager.lua.

return {
  -- Standard colorschemes load on demand through lib.live_theme.
  { "rebelot/kanagawa.nvim", lazy = true, priority = 950 },

  -- Aether remains a dormant capture source for frozen custom palettes.
  { "bjarneo/aether.nvim", branch = "v2", lazy = true, priority = 950 },

  { "ficcdaf/ashen.nvim", lazy = true, priority = 950 },
  { "Shatur/neovim-ayu", lazy = true, priority = 950 },
  { "ribru17/bamboo.nvim", lazy = true, priority = 950 },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, priority = 950 },
  { "zootedb0t/citruszest.nvim", lazy = true, priority = 950 },
  { "scottmckendry/cyberdream.nvim", lazy = true, priority = 950 },
  { "aliqyan-21/darkvoid.nvim", lazy = true, priority = 950 },
  { "decaycs/decay.nvim", lazy = true, priority = 950 },
  { "Mofiqul/dracula.nvim", lazy = true, priority = 950 },
  { "kbraggins/duskhaven.nvim", lazy = true, priority = 950 },
  { "sainnhe/everforest", lazy = true, priority = 950 },
  { "kepano/flexoki-neovim", name = "flexoki", lazy = true, priority = 950 },
  { "maxmx03/fluoromachine.nvim", lazy = true, priority = 950 },
  { "ellisonleao/gruvbox.nvim", lazy = true, priority = 950 },
  { "sainnhe/gruvbox-material", lazy = true, priority = 950 },
  { "blazkowolf/gruber-darker.nvim", lazy = true, priority = 950 },
  { "savq/melange-nvim", name = "melange", lazy = true, priority = 950 },
  { "xero/miasma.nvim", lazy = true, priority = 950 },
  { "loctvl842/monokai-pro.nvim", lazy = true, priority = 950 },
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = true, priority = 950 },
  { "shaunsingh/nord.nvim", lazy = true, priority = 950 },
  { "navarasu/onedark.nvim", lazy = true, priority = 950 },
  { "nyoom-engineering/oxocarbon.nvim", lazy = true, priority = 950 },
  { "olivercederborg/poimandres.nvim", lazy = true, priority = 950 },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, priority = 950 },
  { "hyperb1iss/silkcircuit", lazy = true, priority = 950 },
  { "maxmx03/solarized.nvim", lazy = true, priority = 950 },
  { "jpwol/thorn.nvim", lazy = true, priority = 950 },
  { "ThorstenRhau/token", lazy = true, priority = 950 },
  { "folke/tokyonight.nvim", lazy = true, priority = 950 },
  { "zenbones-theme/zenbones.nvim", name = "zenbones", dependencies = "rktjmp/lush.nvim", lazy = true, priority = 950 },
}
