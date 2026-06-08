# WezTerm Configuration

A high-performance, cross-platform WezTerm configuration optimized for Neovim users. This setup unifies settings across macOS and Windows (WSL) and implements native multiplexing to replace `tmux`.

## 🚀 Key Features

- **Smart Splits**: Seamlessly navigate between WezTerm panes and Neovim splits using `Ctrl+h/j/k/l`.
- **Multiplexing**: Built-in support for tabs and panes with `tmux`-style leader key (`Ctrl+a`).
- **Cross-Platform**: Unified configuration for macOS (`wezterm.lua`) and Windows/WSL (`wezterm_windows.lua`).
- **Aesthetic**: Catppuccin Mocha theme with JetBrains Mono font and 95% background opacity.
- **Performance**: GPU-accelerated rendering using WebGPU (120fps).

## 🛠️ Installation

### macOS
```bash
ln -sf $(pwd)/wezterm.lua ~/.wezterm.lua
```

### Windows
Copy `wezterm_windows.lua` to your WezTerm configuration directory (usually `%USERPROFILE%\.config\wezterm\wezterm.lua` or `%USERPROFILE%\.wezterm.lua`).

## ⌨️ Keybindings

**Leader Key**: `Ctrl + a`

### Pane & Split Management (Smart)
The following keys automatically detect if you are inside Neovim and switch splits/panes accordingly.

| Action | Keybinding |
| :--- | :--- |
| **Navigate Left** | `Ctrl + h` |
| **Navigate Down** | `Ctrl + j` |
| **Navigate Up** | `Ctrl + k` |
| **Navigate Right** | `Ctrl + l` |
| **Resize Left** | `Leader + Shift + h` |
| **Resize Down** | `Leader + Shift + j` |
| **Resize Up** | `Leader + Shift + k` |
| **Resize Right** | `Leader + Shift + l` |
| **Split Horizontal** | `Leader + \` |
| **Split Vertical** | `Leader + -` |
| **Zoom Pane** | `Leader + z` |
| **Close Pane** | `Leader + x` |

### Tab Management
| Action | Keybinding |
| :--- | :--- |
| **New Tab** | `Leader + c` or `Ctrl + Shift + t` |
| **Next Tab** | `Leader + n` or `Ctrl + Tab` |
| **Previous Tab** | `Leader + p` or `Ctrl + Shift + Tab` |
| **Go to Tab 1-9** | `Leader + 1-9` |
| **Close Tab** | `Leader + Shift + &` |

### Copy Mode (Vim-style)
Enter with `Leader + [`:
- `h/j/k/l`: Movement
- `v / V / Ctrl+v`: Select (Visual/Line/Block)
- `y`: Yank selection and exit
- `/`: Search buffer
- `q / Escape`: Exit copy mode

### Scrollback
| Action | Keybinding |
| :--- | :--- |
| **Scroll 3 lines** | `Mouse Wheel` |
| **Scroll half-page** (forces scrollback in `vim`/`less`/`tmux`) | `Shift + Mouse Wheel` |
| **Scroll half-page** | `Ctrl + u` / `Ctrl + d` |
| **Scroll full page** | `Shift + PageUp` / `Shift + PageDown` |
| **Clear scrollback** | `Ctrl + Shift + k` |

## 🔀 Tmux Integration

On macOS, **each tab starts its own tmux session** (`default_prog` runs `tmux new-session`, falling back to `$SHELL` if tmux is missing). Sessions outlive the window — reattach with `tmux a`. **Pane splits launch a bare shell, not tmux**, so splitting a pane never nests a second multiplexer. Windows launches WSL directly and does not start tmux.

WezTerm keeps a "native-feeling" scrollback experience alongside tmux: `Ctrl+u` / `Ctrl+d` pass through to tmux (and to nvim and plain shells, where those keys mean half-page / kill-line / EOF), and mouse scrolling works natively if tmux has `mouse on`.

### Setup Instructions for `~/.tmux.conf`:
```tmux
# Enable mouse support (allows WezTerm to pass mouse events to tmux)
set -g mouse on

# Optional: if you prefer WezTerm to natively capture all tmux scrollback,
# bypass the alternate screen (note: this disables tmux's own copy mode scroll):
# set -ga terminal-overrides ',xterm*:smcup@:rmcup@'
```

*Note: Hold `Shift` while scrolling the mouse wheel to force WezTerm to scroll its native buffer, bypassing tmux entirely.*

## 🖥️ Terminfo (required for `Ctrl+u`/undercurl over SSH)

Both configs set `term = "wezterm"` for full local capability (undercurl, kitty graphics, SGR mouse). The `wezterm` terminfo entry must exist on every host you SSH into, or remote apps misbehave. Install it on a remote host with:

```bash
# Copy from your local machine, or fetch the entry, then compile:
curl -fsSL https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo \
  | tic -x -o ~/.terminfo -
```

If you can't install terminfo on a host, set `TERM=xterm-256color` for that session.

## 🔌 Neovim Integration (Required)

To enable the "Smart" navigation between Neovim and WezTerm, you must install [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) in your Neovim configuration.

### Setup Instructions:
1. Install `mrjones2014/smart-splits.nvim`.
2. Configure it in your `init.lua`:

```lua
require('smart-splits').setup({
  -- Essential: This tells WezTerm that Neovim is active
  set_gui_var = true, 
})

-- Recommended Keymaps
vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
```

## 💡 Best Practices

- **tmux at the tab level**: New tabs start a tmux session for persistence (reattach with `tmux a`); pane splits stay as bare shells. Use WezTerm panes for in-session layout and tmux for session survival.
- **Remote Sessions**: Use `tmux` on remote servers for session persistence over SSH.
- **Hyperlinks**: `Ctrl+Click` any URL to open it. (GitHub `user/repo` shorthand is no longer auto-linked — it produced too many false matches on file paths.)

## ⚙️ Settings Overview

| Setting | Value |
| :--- | :--- |
| **Font** | JetBrains Mono (Medium), 15pt |
| **Theme** | Catppuccin Mocha |
| **Opacity** | 0.95 |
| **Front End** | WebGPU |
| **Scrollback** | 2,000 lines (macOS) / 10,000 (Windows) |
| **Tab Bar** | Bottom, always visible |

---
*Maintained by levi. Wednesday, February 11, 2026.*
