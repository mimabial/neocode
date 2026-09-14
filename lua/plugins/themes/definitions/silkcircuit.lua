local live = require("lib.live_theme")

return live.definition({
  icon = "󰘚",
  plugin = "silkcircuit",
  variants = { "neon", "vibrant", "soft", "glow", "dawn" },
  default = "soft",
  background = function(variant, opts)
    return opts.background or (variant == "dawn" and "light" or "dark")
  end,
  apply = function(variant, opts)
    require("silkcircuit").setup({
      transparent = opts.transparency,
      terminal_colors = true,
      variant = variant,
      integrations = { octo = false },
    })
    vim.cmd.colorscheme("silkcircuit")

    local corrected = { vibrant = "#0f0c1a", soft = "#1a1626" }
    local replacement = corrected[variant]
    if replacement then
      local wrong = tonumber("12101a", 16)
      local right = tonumber(replacement:sub(2), 16)
      for group in pairs(vim.api.nvim_get_hl(0, {})) do
        local spec = vim.api.nvim_get_hl(0, { name = group })
        local changed = false
        for _, key in ipairs({ "bg", "fg", "sp" }) do
          if spec[key] == wrong then
            spec[key] = right
            changed = true
          end
        end
        if changed then
          vim.api.nvim_set_hl(0, group, spec)
        end
      end
    end
  end,
})
