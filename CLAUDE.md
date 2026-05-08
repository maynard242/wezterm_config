# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Cross-platform WezTerm configuration. Two parallel Lua configs that should stay structurally aligned but diverge for platform-specific concerns (fonts, default shell, WSL).

- `wezterm.lua` — macOS config
- `wezterm_windows.lua` — Windows/WSL config

Both files implement the same logical structure (smart-splits → font → colors → window → tabs → cursor → perf → keys → key_tables → mouse). When changing behavior, update **both** files unless the change is genuinely platform-specific.

## Installation / "Running" the Code

There is no build, test, or lint step — WezTerm reads the Lua file directly and reloads on save (or via `Leader+r`).

```bash
# macOS — symlink so edits in this repo are live
ln -sf $(pwd)/wezterm.lua ~/.wezterm.lua
```

Windows: copy `wezterm_windows.lua` to `%USERPROFILE%\.wezterm.lua` (or `%USERPROFILE%\.config\wezterm\wezterm.lua`).

To validate config changes, reload via `Leader+r` (`Ctrl+a` then `r`) or open a new WezTerm window — Lua errors surface in the debug overlay (`Leader+d`).

## Architecture: What's Worth Knowing

### Smart Splits (the non-obvious bit)

The `split_nav()` function and `is_vim()` predicate at the top of each file implement transparent `Ctrl+h/j/k/l` navigation between WezTerm panes and Neovim splits. The mechanism:

1. `is_vim(pane)` checks both `pane:get_user_vars().IS_NVIM == "true"` (set by `smart-splits.nvim` via `set_gui_var = true`) **and** the foreground process name match for `n?vim`. Either signal triggers passthrough.
2. When inside Neovim, the keystroke is forwarded with `SendKey`. Otherwise WezTerm performs `ActivatePaneDirection` (move) or `AdjustPaneSize` (resize).
3. Resize uses `LEADER|SHIFT` modifiers, move uses plain `CTRL`.

Breaking either half breaks Neovim integration silently — the user has to install `mrjones2014/smart-splits.nvim` on the Neovim side for the user-var path to work; the process-name fallback covers users who haven't.

### Leader Key Convention

Leader is `Ctrl+a` (tmux-compatible) with a 1-second timeout. The config replaces `tmux` for local use; `tmux` is reserved for remote SSH session persistence per the README.

### Windows-Specific Divergence

`wezterm_windows.lua` adds beyond the macOS version:
- Font fallbacks include `Cascadia Code`, `Consolas`, `Segoe UI Emoji`
- `config.default_prog = { "wsl.exe", "-d", "Ubuntu-24.04", "--cd", "~" }` — WSL Ubuntu is the default shell
- `config.wsl_domains` and `config.launch_menu` for switching between WSL and PowerShell
- An extra keybinding: `Leader+u` spawns a new tab in WSL Ubuntu

When syncing changes between the two files, these Windows-only sections at the bottom of `wezterm_windows.lua` should be preserved.

### Color Scheme

Both files set `config.color_scheme = "Catppuccin Mocha"` **and** redefine `config.colors` with explicit Catppuccin hex values. The redundancy is intentional — it's a fallback for WezTerm versions that don't ship the named scheme. Don't remove either.

## Editing Notes

- The user has explicitly unified the macOS and Windows configs (recent commits: "Unify settings", "Set Ubuntu WSL as default"). Preserve that parity.
- Tab indentation is hard tabs throughout — match it.
- Section banners use `-- =====...` blocks; keep them when adding new sections.
