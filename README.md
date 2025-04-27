# Neovim Configuration without LazyVim Dependencies

This is a fully-featured Neovim configuration built with lazy.nvim that works without LazyVim dependencies. It includes all the functionality you need while using the gruvbox-material theme.

## Features

- Modern plugin management with lazy.nvim
- Gruvbox-material as the default theme
- LSP integration with automatic setup
- Treesitter for syntax highlighting and text objects
- File navigation with Neo-tree
- Fuzzy finding with Telescope
- Autocompletion with nvim-cmp
- Git integration with gitsigns and diffview
- Statusline with lualine
- Terminal integration with toggleterm
- Formatting and linting
- Code debugging with nvim-dap
- Notification system with nvim-notify and noice
- And much more!

## Installation

1. Make sure you have Neovim 0.9.0 or later installed.
2. Install the dependencies:
   - [ripgrep](https://github.com/BurntSushi/ripgrep) for live grep search
   - [fd](https://github.com/sharkdp/fd) for file finding
   - [lazygit](https://github.com/jesseduffield/lazygit) for git integration
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
├── init.lua              # Main configuration file
└── lua/
    └── plugins/          # Plugin configurations
        ├── colorscheme.lua       # Theme configuration
        ├── completion.lua        # Autocompletion setup
        ├── dap.lua              # Debugging setup
        ├── devicons.lua         # Icons for various plugins
        ├── editor.lua           # Editing enhancements
        ├── formatter.lua        # Code formatting
        ├── git.lua              # Git integration
        ├── gitsigns.lua         # Git markers in the gutter
        ├── keymaps.lua          # Key mappings
        ├── linter.lua           # Code linting
        ├── lsp.lua              # LSP configuration
        ├── lualine.lua          # Statusline
        ├── neo-tree.lua         # File explorer
        ├── noice.lua            # UI enhancements
        ├── notify.lua           # Notification system
        ├── starter.lua          # Start screen
        ├── telescope.lua        # Fuzzy finder
        ├── toggleterm.lua       # Terminal integration
        ├── treesitter.lua       # Syntax highlighting and more
        ├── trouble.lua          # Diagnostics list
        └── util.lua             # Utility functions
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
- `<leader>rn` - Rename
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

## Customization

This configuration is designed to be easy to customize:

1. To add new plugins, create a new file in `lua/plugins/` with your plugin configuration.
2. To modify existing plugins, edit the corresponding file in `lua/plugins/`.
3. For basic settings, modify `init.lua`.

## Credits

This configuration was built to replace LazyVim dependencies while maintaining the functionality provided by LazyVim. Thanks to all the plugin authors for their amazing work!
