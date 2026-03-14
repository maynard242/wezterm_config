# GEMINI.md

## Project Overview
This repository contains a high-performance, cross-platform WezTerm configuration optimized for Neovim users. It unifies terminal settings across macOS and Windows (WSL) and implements native multiplexing as a `tmux` replacement.

### Main Technologies
- **Terminal Emulator:** WezTerm
- **Configuration Language:** Lua
- **Theme:** Catppuccin Mocha
- **Font:** JetBrains Mono (Medium)
- **Engine:** WebGPU (GPU-accelerated rendering)

### Core Architecture
The configuration is split into two primary entry points based on the operating system:
- `wezterm.lua`: Optimized for macOS (**Golden Truth**).
- `wezterm_windows.lua`: Optimized for Windows and WSL.

**Maintenance Note:** Both configurations must be kept in sync. Any changes or improvements should be implemented in `wezterm.lua` first, as it serves as the source of truth for the project's logic and aesthetics.

Both configurations share a similar logic for "Smart Splits," which allows seamless navigation between WezTerm panes and Neovim splits when using the `smart-splits.nvim` plugin.

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

## Development Conventions
- **Neovim Integration:** Changes to pane navigation must remain compatible with `smart-splits.nvim`. The `is_vim` function in the Lua config detects active Vim/Neovim processes.
- **Aesthetics:** Maintain the Catppuccin Mocha color scheme and JetBrains Mono font consistency.
- **Performance:** Keep `WebGpu` as the default front-end for high-refresh-rate support.
