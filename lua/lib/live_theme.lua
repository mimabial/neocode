local set_background = require("lib.background").set

local M = {}

local function variant_for_background(spec, background, transparency)
  if not background or type(spec.background) ~= "function" then
    return nil
  end
  local function matches(variant)
    return spec.background(variant, { transparency = transparency }) == background
  end
  if spec.default and matches(spec.default) then
    return spec.default
  end
  for _, variant in ipairs(spec.variants or {}) do
    if matches(variant) then
      return variant
    end
  end
end

function M.definition(spec)
  assert(type(spec.plugin) == "string", "live theme requires a plugin name")
  assert(type(spec.apply) == "function", "live theme requires an apply function")

  return {
    icon = spec.icon or "",
    variants = spec.variants,
    plugin = spec.plugin,
    variant_for_background = function(background)
      return variant_for_background(spec, background, false)
    end,
    setup = function(opts)
      local variant = opts.variant or variant_for_background(spec, opts.background, opts.transparency) or spec.default
      local background = spec.background
      if type(background) == "function" then
        background = background(variant, opts)
      end
      background = background or opts.background

      if background then
        assert(background == "dark" or background == "light", "invalid theme background: " .. tostring(background))
        set_background(background)
      end

      spec.apply(variant, opts)
      return { variant = variant, background = vim.o.background }
    end,
  }
end

return M
