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

Leader is `Ctrl+a` (tmux-compatible) with a 1-second timeout.

### tmux at the tab level (macOS)

On macOS, `config.default_prog` launches an unnamed tmux session, so each **window/tab** is its own tmux session that outlives the window (reattach with `tmux a`). **Pane splits deliberately bypass this** — the split keybindings (`\`, `-`, `|`, `_`) pass a bare `split_shell` (`$SHELL`) as their `SpawnCommand`, so a split never nests a second tmux inside an already-tmux'd pane. If you add a new split binding, pass `split_shell`, not `{ domain = "CurrentPaneDomain" }`, or you'll reintroduce nesting. Windows uses `wsl.exe` as `default_prog` (no tmux), so its splits keep the plain `CurrentPaneDomain` form.

### Terminal identity (`config.term`)

Both files set `config.term = "wezterm"` for full local capability (undercurl, kitty graphics, SGR mouse). The cost: the `wezterm` terminfo entry must exist on any remote host you SSH into, or apps there misbehave. The README "Terminfo" section documents the install one-liner. Don't change this to `xterm-256color` without updating both files and the README.

### Ctrl+u / Ctrl+d scroll passthrough (`is_interactive`)

`smart_scroll` only sends `Ctrl+u`/`Ctrl+d` to WezTerm's `ScrollByPage` when `is_interactive(pane)` is false. `is_interactive` matches nvim, tmux, **and plain shells (bash/zsh/fish)** — the shell entries are load-bearing: split panes run a bare shell, and without them WezTerm would steal `Ctrl+u` (kill-line) and `Ctrl+d` (EOF) there. Keep the shell names when editing.

### Color Scheme

Both files set `config.color_scheme = "Catppuccin Mocha"` **and** redefine `config.colors` with explicit Catppuccin hex values. The redundancy is intentional — fallback for WezTerm versions that don't ship the named scheme. Keep both.

### Search Binding Syntax

Search bindings use `act.Search({ CaseInSensitiveString = "" })`, not the older `act.Search("CurrentSelectionOrEmptyString")` form. Use the table form when adding new search keybindings.

### Environment Variables

Both files set `COLORTERM = "truecolor"` via `config.set_environment_variables` so child shells get true-color hints.

### Mouse Wheel Scrollback

Only `Shift+Wheel` is custom-bound, to `ScrollByPage(±0.5)`; plain `WheelUp`/`WheelDown` uses WezTerm's default line scroll (there is no custom `ScrollByLine` binding). The Shift variant is deliberate — `ScrollByPage` always operates on WezTerm's scrollback even inside alt-screen apps (`vim`, `less`, `tmux`), giving a reliable escape hatch when those apps would otherwise capture wheel events. Don't replace this with `alternate_buffer_wheel_scroll_speed` — that translates wheel to arrow keys for the *app*, which is the opposite intent.

### Hyperlinks

Both files use only `wezterm.default_hyperlink_rules()`. A custom `owner/repo → github.com` rule was removed because its regex matched any `foo/bar` token (file paths, dates, package names) and produced bogus links. If reintroducing GitHub shorthand, anchor the regex to an explicit prefix so it can't collide with ordinary paths.

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
