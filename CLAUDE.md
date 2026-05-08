# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Cross-platform WezTerm configuration. Two parallel Lua configs:

- `wezterm.lua` — macOS config. **Source of truth ("Golden Truth")** per `GEMINI.md`. Make changes here first.
- `wezterm_windows.lua` — Windows/WSL config. Mirrors `wezterm.lua` with platform-specific divergences at the bottom.

Both files share the same logical structure (smart-splits → font → env → colors → window → tabs → cursor → perf → keys → key_tables → mouse). When changing shared behavior, update macOS first, then propagate to Windows.

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

`split_nav()` and `is_vim()` at the top of each file implement transparent navigation between WezTerm panes and Neovim splits.

- `is_vim(pane)` checks two signals: `pane:get_user_vars().IS_NVIM == "true"` (set by `smart-splits.nvim` via `set_gui_var = true`) **and** the foreground process name matching `n?vim`. Either triggers passthrough. The function nil-guards `get_foreground_process_name()` — keep that guard, it prevents crashes when the process name is briefly nil.
- **Modifier asymmetry** (deliberate): the WezTerm-side binding for resize uses `LEADER|SHIFT`, but when passed through to Neovim the SendKey uses `ALT`. The Neovim side (smart-splits.nvim) is configured to expect Alt-based resize. Don't "fix" this to match.
- Move uses plain `CTRL` on both sides.

### Leader Key Convention

Leader is `Ctrl+a` (tmux-compatible) with a 1-second timeout. The config replaces `tmux` for local use; `tmux` is reserved for remote SSH session persistence per the README.

### Color Scheme

Both files set `config.color_scheme = "Catppuccin Mocha"` **and** redefine `config.colors` with explicit Catppuccin hex values. The redundancy is intentional — fallback for WezTerm versions that don't ship the named scheme. Keep both.

### Search Binding Syntax

Search bindings use `act.Search({ CaseInSensitiveString = "" })`, not the older `act.Search("CurrentSelectionOrEmptyString")` form. Use the table form when adding new search keybindings.

### Environment Variables

Both files set `COLORTERM = "truecolor"` via `config.set_environment_variables` so child shells get true-color hints.

### Windows-Specific Divergence

`wezterm_windows.lua` adds beyond the macOS version:
- Font fallbacks include `Cascadia Code`, `Consolas`, `Segoe UI Emoji`
- `config.default_prog = { "wsl.exe" }` — launches WSL with the user's default distro (no hard-coded distro name)
- `config.wsl_domains` and `config.launch_menu` for switching between WSL and PowerShell
- `Leader+u` keybinding spawns a new tab in WSL
- `config.initial_window_position = { x = 50, y = 50 }`
- A `gui-startup` handler that maximizes on launch — currently commented out; uncomment to re-enable

When syncing changes between the two files, preserve these Windows-only sections at the bottom of `wezterm_windows.lua`.

## Documentation Files

- `README.MD` — user-facing keybinding reference and install steps
- `GEMINI.md` — parallel doc for Gemini CLI; declares macOS as the Golden Truth
- `CLAUDE.md` — this file, for Claude Code

If you change architecture or keybindings, check whether `README.MD` and `GEMINI.md` also need updating.

## Editing Notes

- The user has explicitly unified the macOS and Windows configs. Preserve that parity.
- Tab indentation is hard tabs throughout — match it.
- Section banners use `-- =====...` blocks; keep them when adding new sections.
