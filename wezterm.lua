-- WezTerm Configuration
-- Font: JetBrains Mono
-- Theme: Monokai Pro
-- Vim/Neovim-compatible keybindings

local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

-- Use config_builder for better error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- =============================================================================
-- SMART SPLITS LOGIC (Vim/Neovim Integration)
-- =============================================================================

-- True when the pane's foreground process is vim or nvim, so we forward
-- window-navigation keys into the editor instead of switching WezTerm panes.
-- Detection is purely by process name — "n?vim" matches both `vim` and `nvim`.
-- Keep the nil-guard above: get_foreground_process_name() is briefly nil during
-- process spawn and indexing nil would crash the callback.
local function is_vim(pane)
	local process_name = pane:get_foreground_process_name()
	if process_name == nil then
		return false
	end
	return process_name:find("n?vim") ~= nil
end

-- A pane is "interactive" if its foreground program has its own meaning for
-- Ctrl+u / Ctrl+d and we must NOT steal those keys for scrolling. This includes
-- plain shells (bash/zsh/fish) — splits launch a bare shell, where Ctrl+u =
-- kill-line and Ctrl+d = EOF must keep working — as well as vim/nvim and tmux. The
-- ScrollByPage fallback only fires for other fullscreen programs; Shift+PageUp/
-- Down remains the always-available scroll.
local function is_interactive(pane)
	local process_name = pane:get_foreground_process_name()
	if process_name == nil then
		return false
	end
	return process_name:find("n?vim") ~= nil
		or process_name:find("tmux") ~= nil
		or process_name:find("bash") ~= nil
		or process_name:find("zsh") ~= nil
		or process_name:find("fish") ~= nil
end

local function smart_scroll(key, mods, action)
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(win, pane)
			if is_interactive(pane) then
				win:perform_action({ SendKey = { key = key, mods = mods } }, pane)
			else
				win:perform_action(action, pane)
			end
		end),
	}
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "move" and "CTRL" or "LEADER|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			if resize_or_move == "move" then
				if is_vim(pane) then
					-- Inside vim: forward Ctrl+h/j/k/l so vim switches its own
					-- windows. Map these to <C-w>h/j/k/l in your .vimrc.
					win:perform_action({ SendKey = { key = key, mods = "CTRL" } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			else
				-- Resize always acts on the WezTerm pane. Leader+Shift+h/j/k/l is
				-- not a vim binding, so there is nothing to forward to the editor.
				win:perform_action({ AdjustPaneSize = { direction_keys[key], 5 } }, pane)
			end
		end),
	}
end

-- =============================================================================
-- FONT CONFIGURATION
-- =============================================================================

config.font = wezterm.font_with_fallback({
	{
		family = "JetBrains Mono",
		weight = "Medium",
		harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	},
	"Symbols Nerd Font Mono",
	"Noto Color Emoji",
})

config.font_size = 13.0
config.line_height = 1.1
config.cell_width = 1.0

-- =============================================================================
-- ENVIRONMENT VARIABLES
-- =============================================================================

config.set_environment_variables = {
	COLORTERM = "truecolor",
	TERM_PROGRAM = "wezterm",
}

-- =============================================================================
-- TERMINAL IDENTITY
-- =============================================================================

-- Use the wezterm terminfo entry for full capability support:
-- undercurl, kitty graphics protocol, proper SGR mouse reporting.
config.term = "wezterm"

-- =============================================================================
-- COLOR SCHEME - Monokai Pro
-- =============================================================================

config.color_scheme = "Monokai Pro (Gogh)"

-- Custom Monokai Pro colors. Defined explicitly so the look is identical even
-- if the named scheme above isn't in this WezTerm build, and so the tab bar /
-- cursor stay on-palette regardless.
config.colors = {
	foreground = "#fcfcfa",
	background = "#2d2a2e",
	cursor_bg = "#fcfcfa",
	cursor_fg = "#2d2a2e",
	cursor_border = "#fcfcfa",
	selection_fg = "#fcfcfa",
	selection_bg = "#5b595c",
	scrollbar_thumb = "#5b595c",
	split = "#5b595c",

	ansi = {
		"#403e41", -- black
		"#ff6188", -- red
		"#a9dc76", -- green
		"#ffd866", -- yellow
		"#fc9867", -- blue (Monokai uses orange in this slot)
		"#ab9df2", -- magenta (purple)
		"#78dce8", -- cyan
		"#fcfcfa", -- white
	},
	brights = {
		"#727072", -- bright black (comment grey)
		"#ff6188", -- bright red
		"#a9dc76", -- bright green
		"#ffd866", -- bright yellow
		"#fc9867", -- bright blue (orange)
		"#ab9df2", -- bright magenta (purple)
		"#78dce8", -- bright cyan
		"#fcfcfa", -- bright white
	},

	tab_bar = {
		background = "#221f22",
		active_tab = {
			bg_color = "#ab9df2",
			fg_color = "#221f22",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#2d2a2e",
			fg_color = "#fcfcfa",
		},
		inactive_tab_hover = {
			bg_color = "#403e41",
			fg_color = "#fcfcfa",
		},
		new_tab = {
			bg_color = "#2d2a2e",
			fg_color = "#fcfcfa",
		},
		new_tab_hover = {
			bg_color = "#403e41",
			fg_color = "#fcfcfa",
		},
	},
}

-- =============================================================================
-- WINDOW CONFIGURATION - Modern Setup
-- =============================================================================

-- Window decorations
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95
config.macos_window_background_blur = 25

-- Window padding (tighter for a modern, content-forward feel)
config.window_padding = {
	left = 12,
	right = 24,
	top = 12,
	bottom = 12,
}

-- Window frame
config.window_frame = {
	font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
	font_size = 12.0,
	active_titlebar_bg = "#221f22",
	inactive_titlebar_bg = "#221f22",
}

-- Initial window size and position
config.initial_cols = 120
config.initial_rows = 35

-- Scrollback lives in WezTerm now (no local tmux managing its own history).
config.scrollback_lines = 10000
config.enable_scroll_bar = true
config.min_scroll_bar_height = "2cell"

-- No local tmux persistence anymore, so confirm before closing a window to
-- avoid losing running shells/panes by accident.
config.window_close_confirmation = "AlwaysPrompt"

-- =============================================================================
-- TAB BAR CONFIGURATION
-- =============================================================================

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = false

-- Powerline-style tab titles with Monokai Pro accents
wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
	local edge_bg = "#221f22" -- darkest (tab bar background)
	local bg = "#2d2a2e" -- inactive tab
	local fg = "#fcfcfa" -- text

	if tab.is_active then
		bg = "#ab9df2" -- purple accent
		fg = "#221f22"
	elseif hover then
		bg = "#403e41" -- surface
	end

	local title = (tab.tab_index + 1) .. " · " .. (tab.active_pane.title or "")
	title = wezterm.truncate_right(title, max_width - 4)

	return {
		{ Background = { Color = edge_bg } },
		{ Foreground = { Color = bg } },
		{ Text = "" },
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
		{ Text = " " .. title .. " " },
		{ Background = { Color = edge_bg } },
		{ Foreground = { Color = bg } },
		{ Text = "" },
	}
end)

-- Right status: time / date in Monokai Pro cyan
wezterm.on("update-right-status", function(window, _)
	local date = wezterm.strftime("%H:%M  %a %d %b")
	window:set_right_status(wezterm.format({
		{ Background = { Color = "#221f22" } },
		{ Foreground = { Color = "#78dce8" } }, -- cyan
		{ Text = "  " .. date .. "  " },
	}))
end)

-- =============================================================================
-- CURSOR CONFIGURATION
-- =============================================================================

config.default_cursor_style = "SteadyBlock"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.cursor_blink_rate = 500

-- =============================================================================
-- PERFORMANCE
-- =============================================================================

config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.max_fps = 120
config.animation_fps = 60

-- =============================================================================
-- DEFAULT PROGRAM
-- =============================================================================

-- WezTerm owns the local layout (tabs + panes), so tabs and splits launch the
-- user's login shell directly. tmux is NOT started automatically — run it by
-- hand on remote hosts (over SSH) when you want session persistence there.
-- Leaving default_prog unset makes WezTerm spawn the default login shell, which
-- is what new tabs (`Leader+c`) and splits (`CurrentPaneDomain`) inherit.

-- =============================================================================
-- KEY BINDINGS - Vim/Neovim Compatible
-- =============================================================================

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- Disable default Ctrl+Shift+Enter (for Vim/Neovim compatibility)
	{ key = "Enter", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },

	-- ==========================================================================
	-- PANE MANAGEMENT (Smart Splits with Ctrl+h/j/k/l)
	-- ==========================================================================

	-- Split panes (inherit the current pane's program, the login shell)
	{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "_", mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Navigate panes (Smart Splits)
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),

	-- Alternative pane navigation with Leader
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- Resize panes (Smart Splits)
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),

	-- Close pane
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

	-- ==========================================================================
	-- TAB MANAGEMENT
	-- ==========================================================================

	-- Create/Close tabs
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

	-- Navigate tabs
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

	-- Direct tab access (1-9)
	{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = act.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = act.ActivateTab(4) },
	{ key = "6", mods = "LEADER", action = act.ActivateTab(5) },
	{ key = "7", mods = "LEADER", action = act.ActivateTab(6) },
	{ key = "8", mods = "LEADER", action = act.ActivateTab(7) },
	{ key = "9", mods = "LEADER", action = act.ActivateTab(8) },

	-- Move tabs
	{ key = "{", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

	-- ==========================================================================
	-- COPY/PASTE & SCROLLING
	-- ==========================================================================

	-- Copy mode (Vim-style)
	{ key = "[", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "v", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },

	-- Paste
	{ key = "]", mods = "LEADER", action = act.PasteFrom("Clipboard") },

	-- Scroll
	smart_scroll("u", "CTRL", act.ScrollByPage(-0.5)),
	smart_scroll("d", "CTRL", act.ScrollByPage(0.5)),
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },

	-- ==========================================================================
	-- MISC
	-- ==========================================================================

	-- Quick select mode
	{ key = "Space", mods = "LEADER", action = act.QuickSelect },

	-- Search
	{ key = "/", mods = "LEADER", action = act.Search({ CaseInSensitiveString = "" }) },
	{ key = "f", mods = "CTRL|SHIFT", action = act.Search({ CaseInSensitiveString = "" }) },

	-- Font size
	{ key = "+", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },

	-- Reload configuration
	{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },

	-- Show debug overlay
	{ key = "d", mods = "LEADER", action = act.ShowDebugOverlay },

	-- Command palette
	{ key = ":", mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },
	{ key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },

	-- Clear scrollback
	{ key = "K", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
}

-- =============================================================================
-- COPY MODE KEY BINDINGS (Vim-style)
-- =============================================================================

config.key_tables = {
	copy_mode = {
		-- Exit copy mode
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },

		-- Movement
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },

		-- Word movement
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },

		-- Line movement
		{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },

		-- Page movement
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "d", mods = "CTRL", action = act.CopyMode("PageDown") },

		-- Selection
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },

		-- Copy selection
		{
			key = "y",
			mods = "NONE",
			action = act.Multiple({
				act.CopyTo("ClipboardAndPrimarySelection"),
				act.CopyMode("Close"),
			}),
		},

		-- Search
		{ key = "/", mods = "NONE", action = act.Search({ CaseInSensitiveString = "" }) },
		{ key = "n", mods = "NONE", action = act.CopyMode("NextMatch") },
		{ key = "N", mods = "SHIFT", action = act.CopyMode("PriorMatch") },
	},

	search_mode = {
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "Enter", mods = "NONE", action = act.CopyMode("AcceptPattern") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
		{ key = "w", mods = "CTRL", action = act.CopyMode("ClearPattern") },
	},
}

-- =============================================================================
-- MOUSE BINDINGS
-- =============================================================================

config.mouse_bindings = {
	-- Right click to paste
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act.PasteFrom("Clipboard"),
	},

	-- Ctrl+Click to open links
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},

	-- Shift+Wheel: half-page jumps (overrides alt-screen apps)
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "SHIFT",
		action = act.ScrollByPage(-0.5),
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "SHIFT",
		action = act.ScrollByPage(0.5),
	},
}

-- =============================================================================
-- ADDITIONAL SETTINGS
-- =============================================================================

-- Bell
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 75,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 75,
}

-- Hyperlinks
-- Default rules only. A custom `owner/repo -> github.com` rule was removed: its
-- regex matched any `foo/bar` token (file paths, dates, package names) and
-- turned them into bogus links. If you want GitHub shorthand back, anchor it to
-- an explicit prefix so it can't collide with ordinary paths.
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Inactive pane dimming
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.7,
}

-- Check for updates
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400

return config
