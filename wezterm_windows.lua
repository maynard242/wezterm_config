-- WezTerm Configuration for Windows
-- Font: JetBrains Mono
-- Theme: Catppuccin Mocha
-- Terminals: Ubuntu (WSL) and Windows PowerShell
-- Neovim-compatible keybindings

local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

-- Use config_builder for better error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
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
	"Segoe UI Emoji",
})

config.font_size = 12.0
config.line_height = 1.1
config.cell_width = 1.0

-- =============================================================================
-- COLOR SCHEME - Catppuccin Mocha
-- =============================================================================

config.color_scheme = "Catppuccin Mocha"

-- Custom Catppuccin Mocha colors (in case the built-in scheme is not available)
config.colors = {
	foreground = "#cdd6f4",
	background = "#1e1e2e",
	cursor_bg = "#f5e0dc",
	cursor_fg = "#1e1e2e",
	cursor_border = "#f5e0dc",
	selection_fg = "#1e1e2e",
	selection_bg = "#f5e0dc",
	scrollbar_thumb = "#585b70",
	split = "#6c7086",

	ansi = {
		"#45475a", -- black
		"#f38ba8", -- red
		"#a6e3a1", -- green
		"#f9e2af", -- yellow
		"#89b4fa", -- blue
		"#f5c2e7", -- magenta
		"#94e2d5", -- cyan
		"#bac2de", -- white
	},
	brights = {
		"#585b70", -- bright black
		"#f38ba8", -- bright red
		"#a6e3a1", -- bright green
		"#f9e2af", -- bright yellow
		"#89b4fa", -- bright blue
		"#f5c2e7", -- bright magenta
		"#94e2d5", -- bright cyan
		"#a6adc8", -- bright white
	},

	tab_bar = {
		background = "#11111b",
		active_tab = {
			bg_color = "#cba6f7",
			fg_color = "#11111b",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#181825",
			fg_color = "#cdd6f4",
		},
		inactive_tab_hover = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
		},
		new_tab = {
			bg_color = "#181825",
			fg_color = "#cdd6f4",
		},
		new_tab_hover = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
		},
	},
}

-- =============================================================================
-- WINDOWS-SPECIFIC SHELL CONFIGURATION
-- =============================================================================

-- Default to Ubuntu WSL
config.default_domain = "WSL:Ubuntu"

-- Launch menu with Ubuntu and Windows options
config.launch_menu = {
	{
		label = "Ubuntu (WSL)",
		domain = { DomainName = "WSL:Ubuntu" },
	},
	{
		label = "PowerShell",
		program = "powershell.exe",
	},
	{
		label = "PowerShell 7",
		program = "pwsh.exe",
	},
	{
		label = "Command Prompt",
		program = "cmd.exe",
	},
	{
		label = "Git Bash",
		program = "C:/Program Files/Git/bin/bash.exe",
		args = { "--login", "-i" },
	},
}

-- WSL domains configuration
config.wsl_domains = {
	{
		name = "WSL:Ubuntu",
		distribution = "Ubuntu",
		default_cwd = "~",
	},
}

-- =============================================================================
-- WINDOW CONFIGURATION - Modern Setup
-- =============================================================================

-- Window decorations (RESIZE works well on Windows)
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95

-- Window padding
config.window_padding = {
	left = 15,
	right = 15,
	top = 15,
	bottom = 15,
}

-- Window frame
config.window_frame = {
	font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
	font_size = 10.0,
	active_titlebar_bg = "#11111b",
	inactive_titlebar_bg = "#11111b",
}

-- Initial window size
config.initial_cols = 120
config.initial_rows = 35

-- Scrollback
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- =============================================================================
-- TAB BAR CONFIGURATION
-- =============================================================================

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false  -- Always show to access launch menu
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 32

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
-- KEY BINDINGS - Neovim Compatible
-- =============================================================================

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- Disable default Ctrl+Shift+Enter (for Neovim compatibility)
	{ key = "Enter", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },

	-- ==========================================================================
	-- LAUNCH MENU & DOMAIN SWITCHING
	-- ==========================================================================

	-- Open launch menu to select terminal type
	{ key = "l", mods = "ALT", action = act.ShowLauncher },
	{ key = "l", mods = "LEADER|SHIFT", action = act.ShowLauncher },

	-- Quick spawn specific terminals
	{ key = "u", mods = "LEADER", action = act.SpawnTab({ DomainName = "WSL:Ubuntu" }) },
	{ key = "w", mods = "LEADER", action = act.SpawnCommandInNewTab({ args = { "powershell.exe" } }) },

	-- ==========================================================================
	-- PANE MANAGEMENT (Neovim-style with Ctrl+h/j/k/l)
	-- ==========================================================================

	-- Split panes
	{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "_", mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Navigate panes (Vim-style)
	{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },

	-- Alternative pane navigation with Leader
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- Resize panes
	{ key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

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
	{ key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },

	-- Scroll
	{ key = "u", mods = "CTRL", action = act.ScrollByPage(-0.5) },
	{ key = "d", mods = "CTRL", action = act.ScrollByPage(0.5) },
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },

	-- ==========================================================================
	-- MISC
	-- ==========================================================================

	-- Quick select mode
	{ key = "Space", mods = "LEADER", action = act.QuickSelect },

	-- Search
	{ key = "/", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") },
	{ key = "f", mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },

	-- Font size
	{ key = "+", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
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
		{ key = "/", mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
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
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Add custom hyperlink rules
table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(/)([-\w\d\.]+)["]?]],
	format = "https://github.com/$1/$3",
})

-- Inactive pane dimming
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.7,
}

-- Check for updates
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400

return config
