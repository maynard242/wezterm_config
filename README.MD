# WezTerm Configuration

A high-performance, cross-platform WezTerm configuration optimized for Vim and Neovim users. This setup unifies settings across macOS and Windows (WSL) and implements native multiplexing to replace `tmux`.

## 🚀 Key Features

- **Smart Splits**: Seamlessly navigate between WezTerm panes and Vim/Neovim splits using `Ctrl+h/j/k/l`.
- **Multiplexing**: Built-in support for tabs and panes with `tmux`-style leader key (`Ctrl+a`).
- **Cross-Platform**: Unified configuration for macOS (`wezterm.lua`) and Windows/WSL (`wezterm_windows.lua`).
- **Aesthetic**: Catppuccin Mocha theme with JetBrains Mono font and 95% background opacity.
- **Performance**: GPU-accelerated rendering using WebGPU (120fps).

## 🛠️ Installation

### macOS / Linux
```bash
./install.sh
```
Symlinks `wezterm.lua` → `~/.wezterm.lua` (edits in this repo stay live), backs up any existing config, and installs the bundled `wezterm` terminfo entry (needed so Backspace etc. work under `term = "wezterm"`). Equivalent manual step:
```bash
ln -sf "$(pwd)/wezterm.lua" ~/.wezterm.lua
```

### Windows
```powershell
./install.ps1
```
Copies `wezterm_windows.lua` → `%USERPROFILE%\.wezterm.lua` and backs up any existing config. Re-run after pulling updates. Equivalent manual step: copy `wezterm_windows.lua` to `%USERPROFILE%\.wezterm.lua` (or `%USERPROFILE%\.config\wezterm\wezterm.lua`).

## ⌨️ Keybindings

**Leader Key**: `Ctrl + a`

### Pane & Split Management (Smart)
The following keys automatically detect if you are inside Vim/Neovim and switch splits/panes accordingly.

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

## 🔀 Multiplexing & Tmux

**WezTerm owns the local layout.** Tabs (`Leader+c`) and panes (`Leader+\`, `Leader+-`) are native WezTerm objects and just launch your login shell — WezTerm does **not** start tmux automatically. This keeps tab/window/pane creation fast and avoids the prefix conflict you get when WezTerm's leader (`Ctrl+a`) and tmux's prefix fight over the same key.

Use **tmux only where it earns its keep: on remote hosts over SSH**, for session persistence across disconnects. Start it by hand:

```bash
ssh you@host
tmux new -A -s main   # attach if it exists, else create
```

When you do run tmux (locally or remote), the scroll keys still behave: `Ctrl+u` / `Ctrl+d` pass through to tmux (and to vim/nvim and plain shells, where those keys mean half-page / kill-line / EOF), and mouse scrolling works if tmux has `mouse on`:

```tmux
# ~/.tmux.conf — enable mouse so WezTerm can pass wheel events to tmux
set -g mouse on
```

*Note: Hold `Shift` while scrolling the mouse wheel to force WezTerm to scroll its own native buffer, bypassing any alt-screen app (vim/less/tmux) entirely.*

## 🖥️ Terminfo (required `term = "wezterm"` entry)

Both configs set `term = "wezterm"` for full capability (undercurl, kitty graphics, SGR mouse). The `wezterm` terminfo entry must exist **wherever your shell runs** — including the **local** machine. If it's missing, an interactive shell misbehaves (e.g. Backspace stops erasing) in new tabs/windows. The entry is bundled in this repo as `wezterm.terminfo`, and `install.sh` installs it automatically.

Install it manually (locally or on a remote SSH host) with either:

```bash
# from this repo (offline):
tic -x -o ~/.terminfo wezterm.terminfo

# or fetch the latest entry:
curl -fsSL https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo \
  | tic -x -o ~/.terminfo -
```

Verify with `infocmp wezterm`. If you can't install it somewhere, set `TERM=xterm-256color` for that session.

## 🔌 Editor Integration (Vim & Neovim)

WezTerm detects an active editor purely by **process name** (`vim` or `nvim` in the
foreground), so smart navigation works for both — no GUI user-var plugin is required.
When the editor is focused, `Ctrl+h/j/k/l` are forwarded *into* the editor instead of
switching WezTerm panes; otherwise they switch panes.

### Vim

Add the window-navigation maps so the forwarded keys actually switch Vim windows
(by default Vim's `Ctrl+h` just moves the cursor left):

```vim
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
```

> **Edge caveat:** plain Vim does not hand the key back to WezTerm when you're already
> at the outermost window, so `Ctrl+h/j/k/l` navigates *within* Vim only. To jump from
> Vim out into a sibling WezTerm pane, use **`Leader + h/j/k/l`**.

### Neovim (optional, for edge-aware navigation)

If you want `Ctrl+h/j/k/l` to cross seamlessly between Neovim splits **and** WezTerm
panes (including at the edges), install [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim):

```lua
require('smart-splits').setup({})

vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
```

## 💡 Best Practices

- **Layout is WezTerm's job**: use WezTerm tabs and panes for local layout — they spawn instantly and there's no multiplexer to fight your leader key.
- **tmux is for remote persistence**: run `tmux` (e.g. `tmux new -A -s main`) on remote servers over SSH so sessions survive disconnects. No need for it locally.
- **Hyperlinks**: `Ctrl+Click` any URL to open it. (GitHub `user/repo` shorthand is no longer auto-linked — it produced too many false matches on file paths.)

## ⚙️ Settings Overview

| Setting | Value |
| :--- | :--- |
| **Font** | JetBrains Mono (Medium), 15pt |
| **Theme** | Catppuccin Mocha |
| **Opacity** | 0.95 |
| **Front End** | WebGPU |
| **Scrollback** | 10,000 lines |
| **Tab Bar** | Bottom, always visible |

---
*Maintained by levi. Wednesday, February 11, 2026.*
