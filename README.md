# neocode

A Neovim configuration built directly on `lazy.nvim` — not a distribution. Designed to work standalone but with first-class HyDE/Hyprland theme sync when present.

## ✨ Highlights

- **Modular plugin layout** — one file per concern under `lua/plugins/<category>/`, plus per-language LSP/formatter wiring under `lua/plugins/lang/`.
- **HyDE/Hyprland theme sync** — picks up the system theme from `~/.config/hypr/themes/theme.conf`, watches `staterc` and `auto_theme_state.json` via `vim.uv.fs_event`, and reapplies on focus/file change. ~850 lines of dedicated theme manager.
- **20 bundled themes** with per-theme variant support, including a pywal theme that derives directly from `~/.cache/wal/colors.json`.
- **AI completions + chat** — `codeium.nvim` for inline completion, `avante.nvim` for chat (Claude / GPT / etc.).
- **LSP via `vim.lsp.config()`** — Neovim 0.11+ native LSP API; `mason-lspconfig` is used only for `automatic_enable = true`. Per-language settings live in `lua/plugins/lang/<lang>.lua` and extend the spec via `opts.servers`.
- **Bigfile handling** — files >1.5 MB or with single lines >1000 chars get the synthetic `bigfile` filetype: LSP, treesitter, indent guides, illuminate and rainbow delimiters all opt out automatically.
- **Capability-gated LSP keymaps** — `gd`/`gr`/`K`/`<leader>ca` etc. are only bound on a buffer when the attaching server actually supports the method.
- **Telescope with two custom layouts** — `ivory` (bottom pane) for wide windows, `ebony` (vertical) for narrow; auto-switches at the 120-column threshold and persists the choice.

## 📋 Requirements

- **Neovim 0.11+** (uses `vim.lsp.config`, `vim.lsp.inlay_hint`, `vim.diagnostic.jump`, `vim.hl.on_yank`).
- **git**, **ripgrep**, **fd** — required.
- **lazygit** — for `<leader>gg`.
- **A nerd font** — JetBrains Mono Nerd Font recommended.
- **Node** — unlocks tailwindcss, emmet, vue, svelte, astro language servers (auto-detected).
- Per-language runtimes (`go`, `rustc`, `python3`, `php`, `clang`, etc.) — auto-detected; the matching LSP servers install only when the runtime is present.

## 🚀 Installation

```bash
mv ~/.config/nvim ~/.config/nvim.bak    # backup if you have an existing config
git clone <your-repo-url> ~/neocode
ln -s ~/neocode ~/.config/nvim
nvim                                     # plugins install on first launch
```

## 📂 Layout

```
~/.config/nvim/  →  ~/neocode/
├── init.lua
├── lazy-lock.json
├── lazyvim.json                         # not used; LazyVim is not loaded
└── lua/
    ├── config/
    │   ├── autocmds.lua                 # diagnostics, line numbers, filetype tweaks
    │   ├── commands.lua                 # :Layout, :PluginCheck, :ReloadConfig, …
    │   ├── django.lua                   # Django project detection / commands
    │   ├── health.lua                   # :ConfigHealth
    │   ├── keymaps.lua                  # global + LspAttach keymaps
    │   ├── lazy.lua                     # lazy.nvim setup
    │   ├── options.lua                  # vim options, swap/undo dirs in stdpath('state')
    │   ├── terminal_sync.lua            # OSC color sync to host terminal
    │   └── ui.lua                       # shared highlight setup
    ├── lib/
    │   ├── autoclose.lua                # auto-:q when only special wins remain
    │   ├── bigfile.lua                  # synthetic bigfile filetype
    │   ├── colors.lua                   # pull current theme bg/fg/etc. from highlights
    │   ├── icons.lua                    # central icon registry (diagnostics, kinds, …)
    │   ├── root.lua                     # project-root resolver (.git → markers → cwd)
    │   └── theme_manager.lua            # HyDE/Hyprland sync, theme commands
    ├── types/
    │   └── notify.lua                   # ---@meta stub for nvim-notify
    └── plugins/
        ├── ai/      avante.lua, codeium.lua
        ├── coding/  autopairs, completion, search-replace, snippets, textobjects, treesitter
        ├── debug/   nvim-dap + adapters
        ├── editor/  comment, harpoon, illuminate, indentation, kitty/tmux navigators, oil/nvim-tree
        ├── git/     gitsigns, lazygit, octo
        ├── lang/    one file per language: c, go, lua, php, python, rust, shell, web, extras
        ├── lsp/     lspconfig, mason, formatting (conform), linting (nvim-lint), signature
        ├── search/  telescope, hlslens
        ├── themes/  colorscheme.lua + per-theme definitions/
        └── ui/      bufferline, lualine, mini.starter, navic, noice, notifications,
                     keybindings (which-key), terminal, …
```

## ⌨️ Key Mappings

`<leader>` is `<Space>`. Run `<leader>` and wait for which-key to show what's available.

### Find (Telescope, `<leader>f*`)

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>ft` | Find text (live grep) |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>fh` | Help tags |
| `<leader>fw` | Find word under cursor |
| `<leader>fc` | Command history |
| `<leader>f/` | Search history |
| `<leader>fd` / `<leader>fD` | Document / workspace diagnostics |
| `<leader>fs` | Treesitter symbols |
| `<leader>fk` | Keymaps |
| `<leader>fl` | Toggle telescope layout (ivory ↔ ebony) |
| `<leader>fg{c,b,s,f}` | Git commits / branches / status / files |
| `q:` `q/` `q?` | Command/search history (replaces command-line window) |

### Code (LSP + diagnostics, `<leader>c*`)

LSP keymaps only bind when the server supports the capability.

| Key | Action |
|---|---|
| `gd` `gD` `gr` `gi` `gt` | Go to definition / declaration / references / implementation / type definition |
| `K` | Hover |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename |
| `<leader>cd` | Show diagnostics at cursor (transient float) |
| `<leader>cj` | Show diagnostics + jump into the float (yank/select inside) |
| `<leader>ch` | Toggle the auto-on-cursor-hold diagnostic popup |
| `<leader>cf` | Format buffer (conform; `lsp_format = "fallback"`) |
| `<leader>cm` | Mason |
| `<leader>cL` | Trigger linting |
| `[d` / `]d` | Previous / next diagnostic |

### Buffers (`<leader>b*`)

| Key | Action |
|---|---|
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bn` | New buffer |
| `<leader>bb` | Switch to other buffer |
| `<leader>bd` | Delete buffer |
| `<leader>b]` / `<leader>b[` | Cycle buffers |
| `<leader>bf` / `<leader>bl` | First / last buffer |
| `<leader>bp` | Pick buffer |
| `<leader>bo` | Close other buffers |
| `<leader>bc` | Pick close |
| `<leader>b1` … `<leader>b9` | Go to buffer N |
| `<leader>b<` / `<leader>b>` | Move buffer left / right |
| `<leader>b.` / `<leader>b,` | Sort by directory / extension |

### Git

| Key | Action |
|---|---|
| `<leader>gg` | LazyGit |
| `<leader>h{s,r,p,b}` | Stage / reset / preview / blame hunk (gitsigns) |
| `<leader>hS` / `<leader>hR` | Stage / reset buffer |
| `]c` / `[c` | Next / previous hunk |
| `ih` (op/visual) | Hunk text object |
| `<leader>fg{c,b,s,f}` | Telescope git commits / branches / status / files |

### AI

| Key | Action |
|---|---|
| `<leader>aa` `<leader>ae` `<leader>ar` | Avante: ask / edit / refresh |
| `<leader>ac` | Codeium: open chat |
| `<leader>as` / `<leader>at` | AI status / toggle provider |

### UI / Theme (`<leader>u*`)

| Key | Action |
|---|---|
| `<leader>us` / `<leader>uS` | Cycle / select color scheme |
| `<leader>uv` / `<leader>uV` | Cycle / select color variant |
| `<leader>ud` | Toggle dark / light |
| `<leader>ut` | Toggle transparency |
| `<leader>uy` | Sync with system theme |
| `<leader>uY` | Show color mode status |
| `<leader>uz` | Set system `NVIM_SCHEME` |
| `<leader>uL` | List available system themes |

### Terminal / Toggles (`<leader>t*`)

| Key | Action |
|---|---|
| `<leader>tf` / `<leader>th` / `<leader>tv` / `<leader>tt` | Float / horizontal / vertical / generic toggle |
| `<leader>ta` / `<leader>tA` | Toggle auto-format (global / buffer) |
| `<leader>tw` | Toggle line wrap |
| `<leader>td` | Toggle gitsigns deleted |

### Misc

| Key | Action |
|---|---|
| `-` | Open Oil in parent directory |
| `<leader>e` | Toggle nvim-tree |
| `<leader>l` | Lazy plugin manager |
| `<leader>nb` | Toggle navic breadcrumbs |
| `<leader>U` | Toggle undotree |
| `<leader>L1` … `<leader>L4` | Layout presets (coding / terminal / writing / debug) |
| `<leader>w{v,s,c,o,d,f}` | Window vsplit / split / close / only / delete / save without format |
| `<leader>qq` | Quit all |
| `<C-h/j/k/l>` | Window navigation (via tmux-navigator or kitty-navigator) |

## 🛠️ Commands

| Command | Description |
|---|---|
| `:ConfigHealth` | Run config health checks (tools, plugin errors, LSP, keymap conflicts) |
| `:PluginCheck` | Report plugins with load errors (uses `lazy.core.plugin.has_errors`) |
| `:PluginSync` / `:UpdateAll` | Sync lazy / update lazy + Mason |
| `:ReloadConfig` | Re-source the entire config |
| `:Layout {coding,terminal,writing,debug}` | Apply a layout preset |
| `:SystemSync` | Sync to current system theme |
| `:SystemSetTheme [name]` | Write `NVIM_SCHEME` to Hyprland's theme.conf |
| `:SystemListThemes` / `:SystemDetect` | List available themes / show current system selection |
| `:Theme [name]` / `:CycleColorScheme` / `:ColorScheme` | Theme picker / cycle / select |
| `:CycleColorVariant` / `:ColorVariant` | Variant cycle / pick |
| `:ToggleBackground` / `:ToggleTransparency` | Light/dark, transparent/opaque |
| `:TerminalSync` / `:TerminalReset` | Push current bg/fg to host terminal via OSC |
| `:DiagnosticsToggle` / `:DiagnosticsReset` | Toggle / reset diagnostic display |
| `:MasonToolsRefresh` | Re-evaluate per-project formatter list |
| `:FormatToggle` / `:FormatToggleBuffer` | Toggle format-on-save (global / buffer) |
| `:Format[!]` / `:FormatWith <name>` | Format with conform (range supported) |
| `:Django{Enable,Disable,Auto,Status}` | Django mode controls |

## 🎨 Themes

20 themes bundled. All include variant support where the upstream theme provides it.

`ashen` · `ayu` · `bamboo` · `catppuccin` (latte/frappe/macchiato/mocha) · `darkvoid` · `decay` · `dracula` · `everforest` (soft/medium/hard) · `gruvbox` · `gruvbox-material` · `kanagawa` (wave/dragon/lotus) · `monokai-pro` · `nord` · `onedark` · `oxocarbon` · `pywal` (reads `~/.cache/wal/colors.json`) · `rose-pine` (main/moon/dawn) · `solarized` · `thorn` · `tokyonight` (night/storm/day/moon)

Kanagawa is loaded eagerly (`priority = 1000`) as the bootstrap theme; all others load on demand.

## 🎭 System theme integration

If `~/.config/hypr/themes/theme.conf` exists, the theme manager reads:

- `$NVIM_SCHEME` — colorscheme name
- `$NVIM_VARIANT` — variant
- `$NVIM_BACKGROUND` / `$COLOR_SCHEME` — dark/light
- `$NVIM_TRANSPARENCY` — true/false

It also reads `~/.local/state/hypr/staterc` (`selected_color_mode`, `BACKGROUND_MODE`) and the auto-theme daemon's `auto_theme_state.json`. File watchers via `vim.uv.fs_event` plus a `FocusGained` hook keep the editor in sync.

`<leader>uz` writes back: updates `$NVIM_SCHEME` / `$NVIM_VARIANT` in the system theme file and signals other nvim instances to reload.

## 🛡️ Bigfile protection

Files with size > 1.5 MB or any line longer than 1000 characters get the synthetic `bigfile` filetype. The bufferlocal flag `vim.b.bigfile = true` is set, swapfile/undo/spell/list/foldmethod are disabled, treesitter is stopped, and syntax is cleared. Plugins opt out automatically:

- LSP servers don't attach (no server has `bigfile` in its filetype list).
- Treesitter, illuminate, indent-blankline, rainbow-delimiters all gate on the filetype or `vim.b.bigfile`.
- A one-shot notification confirms when a file was treated as big.

Tunable from `lua/lib/bigfile.lua`; thresholds are settable via `require("lib.bigfile").setup({ size = …, line_length = …, notify = false })`.

## 🛠️ Customizing

- **Add a language**: drop a file in `lua/plugins/lang/<lang>.lua` that extends `nvim-lspconfig`'s `opts.servers` and `opts.ensure_installed`. Mirror an existing one (e.g. `python.lua`).
- **Add a plugin**: any file in the matching `lua/plugins/<category>/` returning a lazy spec is picked up by the `{ import = "plugins.<category>" }` line in `lua/config/lazy.lua`.
- **Change icons globally**: edit `lua/lib/icons.lua` — single source of truth for diagnostic / git / completion-kind / lazy / mason / notify icons.

## 📦 Notes on architecture

- LSP servers are configured via `vim.lsp.config()` (Neovim 0.11 native API). Mason-lspconfig is used only for `automatic_enable = true` and `ensure_installed`. The main spec at `lua/plugins/lsp/lspconfig.lua` iterates `opts.servers` from the per-language files.
- `vim.notify` is wrapped at startup to filter Codeium network errors.
- Backup, swap, and undo dirs live under `stdpath("state")` so lua_ls (which scans the data tree) doesn't index `*.lua~` backup files and double-count type annotations.
- `lua/types/notify.lua` is a `---@meta` stub that adds the `__call` overload nvim-notify installs at runtime but lua_ls can't infer.

## 📜 License

Personal configuration. Provided as-is.
