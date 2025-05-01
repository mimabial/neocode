-- Dim configuration for snacks.nvim
return {
  dim = {
    enabled = true,
    art = 80, -- animation refresh time in ms
    blend = 30, -- max blend level (0-100)
    exclude_filetypes = { "neo-tree", "dashboard", "alpha", "NvimTree", "Outline", "qf", "oil" },
    exclude_floating = true,
  },
}
