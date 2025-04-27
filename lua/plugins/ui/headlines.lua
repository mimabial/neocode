--------------------------------------------------------------------------------
-- Markdown Headlines
--------------------------------------------------------------------------------
--
-- This module configures the headlines.nvim plugin, which enhances the visual
-- representation of markdown, orgmode, and other text documents by adding
-- visual styling to headlines and codeblocks.
--
-- Features:
-- 1. Colorful headline rendering with background highlighting
-- 2. Stylized codeblocks with language tag indicators
-- 3. Automatic highlighting of quote blocks
-- 4. Support for multiple document formats 
-- 5. Custom highlight groups for different heading levels
--
-- This improves readability of documentation files and enhances
-- the overall editing experience for markup files.
--------------------------------------------------------------------------------

return {
  "lukas-reineke/headlines.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  ft = { "markdown", "org", "norg", "rmd", "quarto" },
  opts = {
    -- Markdown configuration
    markdown = {
      -- Enable the plugin for markdown files
      enabled = true,
      -- Which headline levels to style (1 is top level)
      headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4", "Headline5", "Headline6" },
      -- Whether to add a horizontal rule after headlines
      headline_divider = false,
      -- Highlight group for the divider
      headline_divider_highlight = { "DiagnosticUnderlineWarn" },
      -- Style codeblocks with a colored background
      codeblock_highlight = "CodeBlock",
      -- Show language tag for codeblocks
      codeblock_show_label = true,
      -- Add a background to codeblock language tags
      codeblock_label_highlight = "CodeBlockLabel",
      -- Custom treesitter queries for finding headlines/codeblocks
      query = vim.treesitter.query.parse(
        "markdown",
        [[
          (atx_heading [
            (atx_h1_marker)
            (atx_h2_marker)
            (atx_h3_marker)
            (atx_h4_marker)
            (atx_h5_marker)
            (atx_h6_marker)
          ] @headline)

          (fenced_code_block
            (info_string (language) @language)
            (code_fence_content) @content
          )
        ]]
      ),
      -- Bullet point styling
      bullet_highlights = {
        "@text.title.1.marker.markdown",
        "@text.title.2.marker.markdown",
        "@text.title.3.marker.markdown",
        "@text.title.4.marker.markdown",
        "@text.title.5.marker.markdown",
        "@text.title.6.marker.markdown",
      },
    
    -- Neorg configuration
    norg = {
      enabled = true,
      headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4", "Headline5", "Headline6" },
      bullet_highlights = {
        "@neorg.headings.1.prefix",
        "@neorg.headings.2.prefix",
        "@neorg.headings.3.prefix",
        "@neorg.headings.4.prefix",
        "@neorg.headings.5.prefix",
        "@neorg.headings.6.prefix",
      },
      bullets = { "◉", "○", "✸", "✿", "✤", "✦" },
    },
    
    -- Quarto configuration
    quarto = {
      enabled = true,
      headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4", "Headline5", "Headline6" },
    },
    
    -- R Markdown configuration
    rmd = {
      enabled = true,
      headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4", "Headline5", "Headline6" },
      codeblock_highlight = "CodeBlock",
      codeblock_show_label = true,
      codeblock_label_highlight = "CodeBlockLabel",
    },
  },
  config = function(_, opts)
    -- Setup headlines
    require("headlines").setup(opts)
    
    -- Define headline highlight groups
    local colors = {
      headline1 = "#7aa2f7",
      headline2 = "#9ece6a",
      headline3 = "#ff9e64",
      headline4 = "#e0af68",
      headline5 = "#bb9af7",
      headline6 = "#7dcfff",
      codeblock = "#1a1b26",
      codeblock_label = "#7aa2f7",
      quote = "#444b6a",
    }
    
    -- Create highlight groups
    vim.api.nvim_set_hl(0, "Headline1", { bg = "#2a2e42", fg = colors.headline1, bold = true })
    vim.api.nvim_set_hl(0, "Headline2", { bg = "#262d35", fg = colors.headline2, bold = true })
    vim.api.nvim_set_hl(0, "Headline3", { bg = "#2c2924", fg = colors.headline3, bold = true })
    vim.api.nvim_set_hl(0, "Headline4", { bg = "#2a2923", fg = colors.headline4, bold = true })
    vim.api.nvim_set_hl(0, "Headline5", { bg = "#2a2636", fg = colors.headline5, bold = true })
    vim.api.nvim_set_hl(0, "Headline6", { bg = "#222733", fg = colors.headline6, bold = true })
    
    vim.api.nvim_set_hl(0, "CodeBlock", { bg = colors.codeblock })
    vim.api.nvim_set_hl(0, "CodeBlockLabel", { bg = colors.codeblock_label, fg = "#1a1b26", bold = true })
    vim.api.nvim_set_hl(0, "Quote", { bg = colors.quote, italic = true })
    vim.api.nvim_set_hl(0, "OrgTag", { fg = "#7aa2f7", bold = true })
  end,
}  -- Add bullets to lists
      bullets = {
        "◉", "○", "✸", "✿", "✤", "✦", "■", "⟐", "▶"
      },
      -- Detect and highlight quote blocks
      quote_string = "┃ ",
      -- highlight for quotes
      quote_highlight = "Quote",
      -- automatically insert fat bullets when pressing o or O
      fat_headlines = true,
      -- Allow headlines with different markers (e.g., ### Headline) 
      fat_headline_upper_string = "▃",
      fat_headline_lower_string = "▀",
    },
    
    -- Org mode configuration
    org = {
      enabled = true,
      headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4", "Headline5" },
      bullet_highlights = {
        "@org.headline.level.1.marker",
        "@org.headline.level.2.marker",
        "@org.headline.level.3.marker",
        "@org.headline.level.4.marker",
        "@org.headline.level.5.marker",
      },
      bullets = { "◉", "○", "✸", "✿", "✤" },
      -- Org agenda tags styling
      tags_highlight = "OrgTag",
    },
