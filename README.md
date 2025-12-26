# Modern Neovim Configuration

A highly modular, performance-focused Neovim configuration designed for full-stack development. Built with lazy.nvim for optimal startup time and organized into logical plugin categories for easy maintenance and scalability.

## ✨ Features

- 🚀 **Lightning fast startup** with lazy.nvim plugin management
- 🎨 **Comprehensive theme support** - 15+ themes with variants
- 🤖 **AI-powered development** - Copilot and Codeium integration
- 🔧 **Full LSP ecosystem** - Mason, formatting, linting, and diagnostics
- 📁 **Modern file navigation** - Oil.nvim as primary explorer with Telescope
- 🎯 **Advanced search** - Telescope with live grep and fuzzy finding
- 🌿 **Git integration** - Multiple Git tools and workflow support
- 🐞 **Debugging support** - nvim-dap with language-specific configurations
- ⌨️ **Smart keybindings** - which-key v3 with contextual descriptions
- 🎭 **System theme integration** - Automatic theme synchronization
- 🔄 **Modular architecture** - Easy to extend and customize

## 🎨 Supported Themes

All themes include variant support:

- **ashen** - Minimalist dark theme
- **catppuccin** - Latte, Frappé, Macchiato, Mocha variants
- **cyberdream** - Cyberpunk-inspired theme
- **everforest** - Soft, Medium, Hard variants
- **gruvbox** - Classic retro groove theme
- **gruvbox-material** - Improved Gruvbox with variants
- **kanagawa** - Wave, Dragon, Lotus variants
- **monokai-pro** - Professional Monokai theme
- **nord** - Arctic-inspired theme
- **nordic** - Nord-based theme with improvements
- **onedark** - Atom One Dark inspired
- **oxocarbon** - IBM Carbon design system
- **rose-pine** - Main, Moon, Dawn variants
- **solarized** - Classic Solarized theme
- **solarized-osaka** - Modern Solarized variant
- **tokyonight** - Night, Storm, Day, Moon variants

## 📋 Requirements

- **Neovim 0.8+** (0.9+ recommended)
- **Git** for plugin management
- **Node.js** for LSP servers
- **ripgrep** for live grep search
- **fd** for file finding
- **lazygit** for Git integration
- **A Nerd Font** for icons (JetBrains Mono recommended)

### Language-Specific Requirements

- **Go** for GOTH stack development
- **Python** for Python development
- **Rust** for system tools and formatters

## 🚀 Installation

```bash
# Backup existing configuration
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this configuration
git clone <your-repo-url> ~/.config/nvim

# Start Neovim (plugins will auto-install)
nvim
```

## 📂 Directory Structure

```
~/.config/nvim/
├── init.lua                 # Main entry point
├── lazy-lock.json          # Plugin version lock file
└── lua/
    ├── config/             # Core configuration
    │   ├── autocmds.lua    # Auto commands
    │   ├── commands.lua    # Custom commands
    │   ├── keymaps.lua     # Key mappings
    │   ├── lazy.lua        # Plugin manager setup
    │   ├── options.lua     # Neovim options
    │   └── ui.lua          # UI configuration
    ├── autocmds/           # Extended auto commands
    ├── commands/           # Extended commands
    ├── utils/              # Utility functions
    └── plugins/            # Modular plugin configuration
        ├── ai/             # AI tools (Copilot, Codeium)
        ├── coding/         # Completion, snippets, treesitter
        ├── debug/          # Debugging tools
        ├── editor/         # Editor enhancements
        ├── git/            # Git integration
        ├── lsp/            # LSP ecosystem
        ├── search/         # Search and navigation
        ├── themes/         # Theme configuration
        └── ui/             # UI components
```

## ⌨️ Key Mappings

> **Note**: `<leader>` is mapped to `<Space>`

### File Navigation
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle Oil file explorer |
| `-` | Open Oil in parent directory |
| `<leader>E` | Fallback to nvim-tree |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>fb` | Browse buffers (Telescope) |
| `<leader>fr` | Recent files (Telescope) |

### Buffer Management
| Key | Action |
|-----|--------|
| `<leader>bb` | Switch to other buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bn`/`<leader>bp` | Next/Previous buffer |
| `<S-h>`/`<S-l>` | Navigate buffers |
| `<leader>b1-9` | Go to buffer 1-9 |

### LSP & Code
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Show references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format code |
| `<leader>cd` | Show diagnostics |
| `[d`/`]d` | Previous/Next diagnostic |

### Git Integration
| Key | Action |
|-----|--------|
| `<leader>gg` | Open LazyGit |
| `<leader>gd` | Open DiffView |
| `<leader>gs` | Git status |
| `<leader>gb` | Git branches |
| `<leader>gc` | Git commits |

### AI Tools
| Key | Action |
|-----|--------|
| `<leader>ap` | Toggle Copilot |
| `<leader>am` | Toggle Codeium |
| `<leader>ac` | Cycle AI providers |
| `<leader>ad` | Disable AI providers |

### Theme Management
| Key | Action |
|-----|--------|
| `<leader>us` | Cycle color scheme |
| `<leader>uS` | Select color scheme |
| `<leader>uv` | Cycle color variant |
| `<leader>ud` | Toggle dark/light mode |
| `<leader>uy` | Sync with system theme |

### Terminal
| Key | Action |
|-----|--------|
| `<leader>tf` | Float terminal |
| `<leader>th` | Horizontal terminal |
| `<leader>tv` | Vertical terminal |
| `<leader>tt` | Toggle terminal |

### Debugging
| Key | Action |
|-----|--------|
| `<F5>` | Start/Continue debugging |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>db` | Toggle breakpoint |

### Refactoring
| Key | Action |
|-----|--------|
| `<leader>rr` | Refactoring menu |
| `<leader>re` | Extract function |
| `<leader>rv` | Extract variable |
| `<leader>ri` | Inline variable |
| `<leader>rp` | Debug print |
| `<leader>rc` | Clean debug prints |

## 🛠️ Customization

### Adding New Plugins

1. Create a new file in the appropriate `lua/plugins/` subdirectory
2. Follow the existing plugin structure
3. Add keymaps in the plugin file itself
4. Add which-key descriptions in `lua/plugins/ui/keybindings.lua`

### Theme Configuration

Themes are managed in `lua/plugins/themes/colorscheme.lua`. To add a new theme:

1. Add the plugin specification
2. Add theme configuration to the themes table
3. Include color extraction function if needed

### System Theme Integration

The configuration can automatically sync with your system theme by reading from:
- `~/.config/hypr/themes/theme.conf`
- `~/.config/hypr/theme.conf`
- Environment variables `NVIM_SCHEME` and `NVIM_VARIANT`

## 🚦 Commands

| Command | Description |
|---------|-------------|
| `:SystemSyncTheme` | Sync with system theme |
| `:SystemSetTheme <theme> [variant]` | Set system theme |
| `:SystemListThemes` | List available themes |
| `:DiagnosticsToggle` | Toggle diagnostic display |
| `:ConfigReload` | Reload Neovim configuration |
| `:PluginSync` | Sync and update plugins |

## 🧪 Language Support

### Supported Languages
- **Go** - Full LSP, debugging, testing
- **TypeScript/JavaScript** - Modern tooling
- **Python** - Complete development environment
- **Lua** - Neovim configuration development
- **Rust** - Systems programming
- **HTML/CSS** - Web development
- **JSON/YAML** - Configuration files
- **Markdown** - Documentation

### LSP Servers (Auto-installed via Mason)
- `gopls` - Go
- `typescript-language-server` - TypeScript/JavaScript
- `pyright` - Python
- `lua-language-server` - Lua
- `rust-analyzer` - Rust
- `html` - HTML
- `cssls` - CSS
- `jsonls` - JSON
- `yamlls` - YAML

## ⚡ Performance

- **Fast startup** - Lazy loading and optimized plugin management
- **Minimal resource usage** - Disabled unnecessary default plugins
- **Cached modules** - Improved require() performance
- **Fail-safe loading** - Graceful degradation if plugins fail

## 🤝 Contributing

This configuration follows strict principles:

1. **Modular design** - Each plugin in its appropriate category
2. **Minimal complexity** - Avoid unnecessary abstractions
3. **Performance first** - Lazy loading and efficient startup
4. **Fail-safe** - Graceful degradation and error handling
5. **Scalable** - Easy to extend and maintain

## 📜 License

This configuration is provided as-is for educational and personal use.

---

**Happy coding!** 🎉
