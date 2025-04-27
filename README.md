# Advanced Neovim Configuration

This is a fully-featured Neovim configuration designed for full-stack development with the GOTH (Go/Templ/HTMX) stack and Next.js. It's built with lazy.nvim for plugin management and uses Gruvbox Material as the primary theme with Tokyo Night as an alternative.

## Features

- 🚀 Modern plugin management with lazy.nvim
- 🎨 Beautiful Gruvbox Material theme with Tokyo Night as alternative
- 🌈 Full LSP integration with automatic setup
- 🔍 Syntax highlighting with Treesitter
- 📁 File navigation with Neo-tree
- 🔎 Fuzzy finding with Telescope
- ⚡ Autocompletion with nvim-cmp
- 🌿 Git integration with gitsigns and diffview
- 📊 Status line with lualine
- 💻 Terminal integration with toggleterm
- 🧹 Formatting and linting
- 🐞 Code debugging with nvim-dap
- 📢 Advanced notification system with nvim-notify and noice
- 🚦 Stack-specific tools for GOTH and Next.js development

## Stack-Specific Features

### GOTH Stack (Go/Templ/HTMX)

- Full Go language support with gopls
- Templ file syntax highlighting and LSP support
- Automatic HTMX attribute highlighting
- Go-specific development tools and commands
- Automatic formatting for Go and Templ files

### Next.js

- TypeScript/JavaScript support with tsserver
- JSX/TSX syntax highlighting
- React component snippets
- Next.js specific commands and utilities
- Tailwind CSS integration

## Installation

1. Make sure you have Neovim 0.9.0 or later installed.
2. Install the dependencies:
   - [ripgrep](https://github.com/BurntSushi/ripgrep) for live grep search
   - [fd](https://github.com/sharkdp/fd) for file finding
   - [lazygit](https://github.com/jesseduffield/lazygit) for git integration
   - [Node.js](https://nodejs.org) for LSP servers
   - [Go](https://golang.org) for GOTH stack
   - A [Nerd Font](https://www.nerdfonts.com/) for icons

3. Clone this repository to your Neovim config directory:

```bash
# Backup your existing config if needed
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this repository
git clone https://github.com/yourusername/nvim-config.git ~/.config/nvim
```

4. Start Neovim, and lazy.nvim will automatically install all plugins.

## Directory Structure

```
~/.config/nvim/
├── init.lua                # Main configuration file
├── lua/
│   └── config/             # Configuration files
│       ├── autocmds.lua    # Auto commands
│       ├── keymaps.lua     # Key mappings
│       ├── lazy.lua        # Lazy.nvim setup
│       ├── options.lua     # Neovim options
│       └── utils.lua       # Utility functions
│   └── plugins/            # Plugin configurations
│       ├── colorscheme.lua # Theme configuration
│       ├── completion.lua  # Autocompletion setup
│       ├── dap.lua         # Debugging setup
│       ├── editor.lua      # Editing enhancements
│       ├── formatter.lua   # Code formatting
│       ├── git.lua         # Git integration
│       ├── goth.lua        # GOTH stack specific plugins
│       ├── lsp.lua         # LSP configuration
│       ├── lualine.lua     # Statusline
│       ├── neo-tree.lua    # File explorer
│       ├── nextjs.lua      # Next.js specific plugins
│       ├── notify.lua      # Notification system
│       ├── telescope.lua   # Fuzzy finder
│       ├── toggleterm.lua  # Terminal integration
│       ├── tokyonight.lua  # Tokyo Night theme
│       └── treesitter.lua  # Syntax highlighting
```

## Key Features

### File Navigation

- `<leader>e` - Toggle Neo-tree file explorer
- `<leader>ff` - Find files with Telescope
- `<leader>fg` - Live grep with Telescope
- `<leader>fb` - Browse buffers with Telescope

### LSP

- `gd` - Go to definition
- `gr` - Show references
- `K` - Show hover documentation
- `<leader>ca` - Code actions
- `<leader>cr` - Rename
- `<leader>cf` - Format code

### Git

- `<leader>gg` - Open Lazygit
- `<leader>gd` - Open Diffview
- `]c` / `[c` - Jump between hunks
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk

### Debugging

- `<F5>` - Start/continue debugging
- `<F10>` - Step over
- `<F11>` - Step into
- `<F12>` - Step out
- `<leader>db` - Toggle breakpoint

### Terminal

- `<leader>tf` - Open floating terminal
- `<leader>th` - Open horizontal terminal
- `<leader>tv` - Open vertical terminal

### GOTH Stack Specific

- `<leader>cgt` - Run Go tests
- `<leader>cgm` - Run Go mod tidy
- `<leader>csc` - Create new Templ component

### Next.js Specific

- `<leader>cnc` - Create new Client component
- `<leader>cns` - Create new Server component
- `<leader>cnp` - Create new Page
- `<leader>cnl` - Create new Layout

### UI and Themes

- `<leader>ut` - Toggle colorscheme between Gruvbox Material and Tokyo Night
- `<leader>uT` - Toggle background transparency

### Layouts

- `<leader>L1` - Coding layout (NeoTree + main editor)
- `<leader>L2` - Terminal layout (editor + terminal)
- `<leader>L3` - Writing layout (distraction-free)
- `<leader>L4` - Debug layout (with DAP UI)

## Customization

This configuration is designed to be easy to customize:

1. To add new plugins, create a new file in `lua/plugins/` with your plugin configuration.
2. To modify existing plugins, edit the corresponding file in `lua/plugins/`.
3. For basic settings, modify `init.lua` or the files in `lua/config/`.

## Stack Selection

You can focus on a specific tech stack with:

```
:StackFocus goth    # Focus on Go/Templ/HTMX development
:StackFocus nextjs  # Focus on Next.js development
```

This will adjust settings, linters, and formatters for the selected stack.

## Local Project Configuration

For project-specific settings, create a `.nvim` directory in your project root:

```
project_root/
└── .nvim/
    └── autocmds.lua  # Project-specific auto commands
```

## Credits

This configuration is designed for full-stack developers working with Go/Templ/HTMX and Next.js. Thanks to all the plugin authors for their amazing work!
