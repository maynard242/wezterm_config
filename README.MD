# WezTerm Configuration

A modern WezTerm configuration with JetBrains Mono font, Catppuccin Mocha theme, and Neovim-compatible keybindings.

## Features

- **Font**: JetBrains Mono with ligatures
- **Theme**: Catppuccin Mocha (dark)
- **Window**: Modern, minimal decorations with transparency
- **Keybindings**: Neovim/tmux-compatible workflow
- **Performance**: WebGPU rendering at 120fps

## Installation

### Quick Install

```bash
# Linux/macOS
mkdir -p ~/.config/wezterm
cp wezterm.lua ~/.config/wezterm/wezterm.lua

# Or symlink for easy updates
ln -sf $(pwd)/wezterm.lua ~/.config/wezterm/wezterm.lua
```

### Windows

```powershell
Copy-Item wezterm.lua $HOME\.config\wezterm\wezterm.lua
```

## Requirements

- [WezTerm](https://wezfurlong.org/wezterm/) (latest version recommended)
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/) font
- [Nerd Fonts](https://www.nerdfonts.com/) (optional, for icons)

### Installing Fonts

```bash
# macOS (Homebrew)
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono font-symbols-only-nerd-font

# Linux (Ubuntu/Debian)
sudo apt install fonts-jetbrains-mono

# Arch Linux
sudo pacman -S ttf-jetbrains-mono ttf-nerd-fonts-symbols
```

## Keybindings

**Leader Key**: `Ctrl+a` (1 second timeout)

### Pane Management

| Action | Keybinding |
|--------|------------|
| Navigate Left | `Ctrl+h` |
| Navigate Down | `Ctrl+j` |
| Navigate Up | `Ctrl+k` |
| Navigate Right | `Ctrl+l` |
| Split Horizontal | `Leader + \` |
| Split Vertical | `Leader + -` |
| Resize Left | `Leader + Shift + H` |
| Resize Down | `Leader + Shift + J` |
| Resize Up | `Leader + Shift + K` |
| Resize Right | `Leader + Shift + L` |
| Close Pane | `Leader + x` |
| Toggle Zoom | `Leader + z` |

### Tab Management

| Action | Keybinding |
|--------|------------|
| New Tab | `Leader + c` or `Ctrl+Shift+t` |
| Next Tab | `Leader + n` or `Ctrl+Tab` |
| Previous Tab | `Leader + p` or `Ctrl+Shift+Tab` |
| Go to Tab 1-9 | `Leader + 1-9` |
| Move Tab Left | `Leader + Shift + {` |
| Move Tab Right | `Leader + Shift + }` |
| Close Tab | `Leader + Shift + &` |

### Copy Mode (Vim-style)

| Action | Keybinding |
|--------|------------|
| Enter Copy Mode | `Leader + [` |
| Exit | `Escape` or `q` |
| Movement | `h/j/k/l` |
| Word Forward | `w` |
| Word Back | `b` |
| Start of Line | `0` |
| End of Line | `$` |
| Top of Buffer | `g` |
| Bottom of Buffer | `G` |
| Select Characters | `v` |
| Select Lines | `V` |
| Block Select | `Ctrl+v` |
| Copy & Exit | `y` |
| Search | `/` |
| Next Match | `n` |
| Previous Match | `N` |

### Other Bindings

| Action | Keybinding |
|--------|------------|
| Search | `Leader + /` or `Ctrl+Shift+f` |
| Command Palette | `Leader + Shift + :` or `Ctrl+Shift+p` |
| Quick Select | `Leader + Space` |
| Reload Config | `Leader + r` |
| Debug Overlay | `Leader + d` |
| Increase Font | `Ctrl+Shift++` |
| Decrease Font | `Ctrl+-` |
| Reset Font | `Ctrl+0` |
| Scroll Up (half) | `Ctrl+u` |
| Scroll Down (half) | `Ctrl+d` |
| Paste | `Leader + ]` or `Ctrl+v` |
| Clear Scrollback | `Ctrl+Shift+K` |

### Mouse

- **Right Click**: Paste from clipboard
- **Ctrl+Click**: Open link

## Customization

### Change Font Size

Edit line 30 in `wezterm.lua`:
```lua
config.font_size = 13.0  -- Change to your preference
```

### Change Opacity

Edit line 105:
```lua
config.window_background_opacity = 0.95  -- 0.0 to 1.0
```

### Change Leader Key

Edit line 164:
```lua
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
-- Change to Space: { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
```

### Disable Transparency

```lua
config.window_background_opacity = 1.0
```

### Use Different Shell

Uncomment and modify line 396:
```lua
config.default_prog = { "/bin/zsh", "-l" }
-- Or for fish: config.default_prog = { "/usr/bin/fish", "-l" }
```

## Neovim Integration

For seamless pane navigation between WezTerm and Neovim, install [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) or [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim).

### smart-splits.nvim setup

```lua
-- In your Neovim config
require('smart-splits').setup({
  at_edge = 'stop',
})

-- Keymaps
vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
```

## Troubleshooting

### Font Not Found

If JetBrains Mono isn't loading:
1. Verify installation: `fc-list | grep -i jetbrains`
2. Restart WezTerm
3. Check the font name matches exactly

### WebGPU Issues

If you experience rendering issues, switch to OpenGL:
```lua
config.front_end = "OpenGL"
```

### Colors Look Wrong

The config includes custom Catppuccin Mocha colors as fallback. If colors look off, ensure you have WezTerm 20230320 or newer for the built-in color scheme.

## License

MIT License - feel free to use and modify.

## Credits

- [WezTerm](https://wezfurlong.org/wezterm/) by Wez Furlong
- [Catppuccin](https://github.com/catppuccin/catppuccin) color scheme
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/) font
