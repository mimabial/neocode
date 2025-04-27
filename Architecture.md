# NeoCode: Modular Neovim Configuration Architecture

## Overall Structure

NeoCode is organized as a modular, layered configuration:

```
init.lua                          # Main entry point
├── lua/
│   ├── core/                     # Core Neovim settings
│   │   ├── autocmds.lua          # Automatic commands
│   │   ├── keymaps.lua           # Global keybindings
│   │   ├── options.lua           # Neovim options
│   │   └── utils.lua             # Utility functions
│   ├── plugins/                  # Plugin configurations
│   │   ├── init.lua              # Main plugin loader
│   │   ├── coding/               # Coding assistance plugins
│   │   │   ├── init.lua          # Loader for coding modules
│   │   │   ├── ai.lua            # AI coding assistance
│   │   │   ├── completions.lua   # Completion system
│   │   │   ├── snippets.lua      # Code snippets
│   │   │   └── refactoring.lua   # Code refactoring tools
│   │   ├── langs/                # Language-specific plugins
│   │   │   ├── init.lua          # Loader for language modules
│   │   │   ├── python.lua        # Python support
│   │   │   ├── lua.lua           # Lua support
│   │   │   ├── rust.lua          # Rust support
│   │   │   └── ...               # Other language modules
│   │   ├── lsp/                  # LSP configuration
│   │   │   ├── init.lua          # LSP loader
│   │   │   ├── servers.lua       # Server configurations
│   │   │   ├── keymaps.lua       # LSP keybindings
│   │   │   ├── formatters.lua    # Code formatters
│   │   │   ├── linters.lua       # Code linters
│   │   │   ├── ui.lua            # LSP UI components
│   │   │   └── none-ls.lua       # Non-LSP tools integration
│   │   ├── editor/               # Editor enhancements
│   │   │   ├── init.lua          # Editor loader
│   │   │   ├── navigation.lua    # Navigation tools
│   │   │   └── text-objects.lua  # Text objects and motions
│   │   ├── tools/                # Development tools
│   │   │   ├── init.lua          # Tools loader
│   │   │   ├── debug.lua         # Debugging support
│   │   │   ├── git.lua           # Git integration
│   │   │   ├── terminal.lua      # Terminal integration
│   │   │   └── database.lua      # Database tools
│   │   ├── ui/                   # UI components
│   │   │   ├── init.lua          # UI loader
│   │   │   ├── colorscheme.lua   # Color schemes
│   │   │   ├── statusline.lua    # Status line
│   │   │   ├── dashboard.lua     # Welcome dashboard
│   │   │   └── navic.lua         # Code navigation bar
│   │   └── util/                 # Utilities
│   │       ├── init.lua          # Utilities loader
│   │       ├── telescope.lua     # Fuzzy finder
│   │       └── treesitter.lua    # Syntax highlighting
│   └── config/                   # User configuration
│       └── settings.lua          # User-specific settings
```

## Key Design Principles

1. **Modularity**: Each component is isolated and can be enabled/disabled independently.
2. **Extensibility**: Easy to add new languages or tools without changing existing code.
3. **Performance**: Lazy-loading of plugins to minimize startup time.
4. **Discoverability**: Self-documenting configuration with intuitive keymaps.
5. **Consistency**: Similar patterns across different features.

## Layer Explanations

### Core Layer

The foundation that configures Neovim's native functionality without any plugins:

- **options.lua**: Sets Neovim options like line numbers, indentation, etc.
- **keymaps.lua**: Global key mappings that don't depend on plugins.
- **autocmds.lua**: Automatic commands for events like file open/save.
- **utils.lua**: Helper functions used throughout the configuration.

### Plugin System

Built on lazy.nvim for efficient plugin management:

- **plugins/init.lua**: Loads all plugin modules and sets up core plugins.
- Each subdirectory contains related plugins with their configurations.

### Feature Modules

Self-contained modules for specific functionality:

- **coding/**: Intelligent code assistance (completion, snippets, AI).
- **lsp/**: Language Server Protocol integration for code intelligence.
- **editor/**: Enhanced editing capabilities (navigation, text objects).
- **tools/**: Development tools (git, debugging, terminal, databases).
- **ui/**: Visual components (themes, statusline, dashboard).
- **util/**: Helper plugins like telescope and treesitter.

### Language Modules

Language-specific configurations:

- Each language has its own file with dedicated LSP, formatter, and tool settings.
- Common patterns are abstracted to prevent duplication.

### User Settings

User-specific preferences and overrides:

- **config/settings.lua**: Personal settings that won't be overwritten on updates.

## Plugin Management

NeoCode uses lazy.nvim with a declarative configuration style:

```lua
return {
  -- Plugin definition with lazy.nvim's specification format
  {
    "plugin/name",
    dependencies = { "dependency1", "dependency2" },
    event = "EventName", -- Lazy-loading condition
    config = function()
      -- Plugin setup code
    end
  }
}
```

Each plugin is defined with:
- Source location (GitHub repository)
- Dependencies
- Loading conditions (when to load the plugin)
- Configuration function or table

## Extension Points

To customize NeoCode:

1. **Add a new language**: Create a new file in `lua/plugins/langs/`
2. **Configure an existing language**: Edit the corresponding language file
3. **Add global settings**: Modify `lua/config/settings.lua`
4. **Add new plugins**: Create a new file in the appropriate subdirectory

The modular architecture makes it easy to understand, modify, and extend each part independently.
