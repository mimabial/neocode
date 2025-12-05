# Theme Definitions

Each theme has its own file here. To complete the migration, you need to extract the remaining theme definitions from `colorscheme.lua.backup`.

## Completed Theme Definitions:
- ✅ ashen.lua
- ✅ ayu.lua
- ✅ bamboo.lua
- ✅ catppuccin.lua
- ✅ darkvoid.lua
- ✅ decay.lua
- ✅ everforest.lua
- ✅ gruvbox.lua
- ✅ gruvbox-material.lua
- ✅ kanagawa.lua
- ✅ monokai-pro.lua
- ✅ nord.lua
- ✅ onedark.lua
- ✅ oxocarbon.lua
- ✅ rose-pine.lua
- ✅ solarized.lua
- ✅ tokyonight.lua

All 17 theme definitions have been successfully extracted!

## How to Extract:

1. Open `colorscheme.lua.backup`
2. Find the theme definition (search for `["theme-name"] = {`)
3. Copy the icon, variants, and setup function
4. Create new file using `_TEMPLATE.lua` as a guide
5. Save as `theme-name.lua`

## Example:

From backup file:
```lua
["tokyonight"] = {
  icon = "",
  variants = { "night", "storm", "day", "moon" },
  setup = function(variant, transparency)
    require("tokyonight").setup({
      style = variant or "night",
      transparent = transparency,
    })
    vim.cmd("colorscheme tokyonight" .. (variant and ("-" .. variant) or ""))
  end,
},
```

Create `tokyonight.lua`:
```lua
return {
  icon = "",
  variants = { "night", "storm", "day", "moon" },
  setup = function(variant, transparency)
    require("tokyonight").setup({
      style = variant or "night",
      transparent = transparency,
    })
    vim.cmd("colorscheme tokyonight" .. (variant and ("-" .. variant) or ""))
  end,
}
```

## Testing:

After creating a theme definition:
```vim
:Theme theme-name
```

The theme manager will automatically load it!
