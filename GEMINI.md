# GEMINI.md

## Project Overview
This repository contains a high-performance, cross-platform WezTerm configuration optimized for Vim and Neovim users. It unifies terminal settings across macOS and Windows (WSL). **WezTerm owns the local layout** — tabs and panes are native WezTerm objects that launch the login shell directly. tmux is **not** started automatically; it is used by hand on remote hosts over SSH for session persistence.

### Main Technologies
- **Terminal Emulator:** WezTerm
- **Configuration Language:** Lua
- **Theme:** Monokai Pro
- **Font:** JetBrains Mono (Medium)
- **Engine:** WebGPU (GPU-accelerated rendering)

### Core Architecture
The configuration is split into two primary entry points based on the operating system:
- `wezterm.lua`: Optimized for macOS (**Golden Truth**).
- `wezterm_windows.lua`: Optimized for Windows and WSL.

**Maintenance Note:** Both configurations must be kept in sync. Any changes or improvements should be implemented in `wezterm.lua` first, as it serves as the source of truth for the project's logic and aesthetics.

Both configurations share a similar logic for "Smart Splits," which allows seamless navigation between WezTerm panes and Vim/Neovim splits. Detection is by foreground process name (`vim`/`nvim`), so no editor plugin is required; `smart-splits.nvim` is an optional Neovim add-on for edge-aware navigation.

## Key Files
- **`wezterm.lua`**: The main configuration file for macOS. Handles font rendering, window styling, and advanced keybindings.
- **`wezterm_windows.lua`**: The Windows-specific configuration, likely adjusting for shell paths (PowerShell/WSL) and Windows-specific window behavior.
- **`README.MD`**: Comprehensive documentation detailing installation, features, and a full keybinding reference.

## Installation and Usage

### Setup Commands
- **macOS:** Link the local config to the home directory:
  ```bash
  ln -sf $(pwd)/wezterm.lua ~/.wezterm.lua
  ```
- **Windows:** Copy `wezterm_windows.lua` to `%USERPROFILE%\.wezterm.lua` or `%USERPROFILE%\.config\wezterm\wezterm.lua`.

### Keybindings (Leader: `Ctrl + a`)
- **Smart Splits:** `Ctrl + h/j/k/l` for movement; `Leader + Shift + h/j/k/l` for resizing.
- **Tabs:** `Leader + c` (New), `Leader + n/p` (Next/Prev), `Leader + 1-9` (Direct access).
- **Panes:** `Leader + \` (Horizontal split), `Leader + -` (Vertical split), `Leader + x` (Close), `Leader + z` (Zoom).
- **Copy Mode:** `Leader + [` (Vim-style navigation and yanking).
- **Scrollback:** `Mouse Wheel` (Standard; delegates to apps like tmux/vim), `Shift + Mouse Wheel` (half-page; forces WezTerm scrollback even in alt-screen apps), `Ctrl + u`/`Ctrl + d` (pass through to nvim/tmux/shell, else half-page WezTerm scroll), `Shift + PageUp`/`PageDown` (full page).

## Development Conventions
- **Editor Integration:** The `is_vim` function detects active Vim/Neovim processes by foreground process name and forwards `Ctrl+h/j/k/l` into the editor. Keep this process-name detection working for both `vim` and `nvim`; `smart-splits.nvim` remains an optional Neovim add-on for edge-aware navigation.
- **Aesthetics:** Maintain the Monokai Pro color scheme and JetBrains Mono font consistency.
- **Performance:** Keep `WebGpu` as the default front-end for high-refresh-rate support.
- **Terminfo:** Both configs set `term = "wezterm"`. The `wezterm` terminfo entry must be installed on remote SSH hosts or apps there break — see the README "Terminfo" section.
