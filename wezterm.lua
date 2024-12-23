local wezterm = require("wezterm")

-- This will hold the configuration.
local act = wezterm.action
local font = wezterm.font
local config = wezterm.config_builder()

-- Color Scheme
local scheme = "Catppuccin Macchiato"
config.color_scheme = scheme

config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.8,
}

config.command_palette_font_size = 12
config.command_palette_rows = 7

-- Window styles
config.window_padding = {
	left = 5,
	right = 5,
	top = 5,
	bottom = 5,
}

config.scrollback_lines = 100000
config.use_dead_keys = false
config.tab_max_width = 25
config.tab_bar_at_bottom = true
config.adjust_window_size_when_changing_font_size = false
config.audible_bell = "Disabled"
config.initial_cols = 110
config.initial_rows = 35
config.window_decorations = "NONE"
config.show_tab_index_in_tab_bar = true
config.window_close_confirmation = "NeverPrompt"
config.unicode_version = 15
config.window_background_opacity = 0.85
config.webgpu_preferred_adapter = wezterm.gui.enumerate_gpus()[0]
config.front_end = "WebGpu"

-- Font Styles
config.font = font("JetBrainsMono NF")
config.harfbuzz_features = {
	"liga = 1",
}
config.freetype_load_flags = "NO_HINTING"
config.font_size = 14
config.hide_mouse_cursor_when_typing = true

-- Cursor Style
config.default_cursor_style = "BlinkingBlock"
config.animation_fps = 60
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "EaseIn"
config.cursor_blink_ease_out = "EaseOut"
config.force_reverse_video_cursor = false

-- Default Terminal
config.default_prog = { "zsh" }
config.default_cwd = os.getenv("PWD")

----------------------------------------------------- Tab Styles -------------------------------------------------------
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true

-------------------------------------------------------- Keybindings -------------------------------------------------------------
config.disable_default_key_bindings = true
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }

config.keys = {

	---------------------- Window Management ----------------------
	{ mods = "CTRL", key = "f", action = act.SendString "fzf\r\n" }, -- Search for entire Computer Files
	{ mods = "CTRL|SHIFT", key = "f", action = act.SendString "fd . --type f --hidden | fzf\r\n" }, -- Search for files in current directory 

	{ mods = "CTRL|SHIFT", key = "p", action = act.ActivateCommandPalette },
	-- Open new Wezterm Window
	{
		mods = "LEADER",
		key = "n",
		action = act.SpawnCommandInNewWindow({ args = { "zsh" }, cwd = default_cwd }),
	},
	{ mods = "LEADER|SHIFT", key = "Q", action = act.QuitApplication },
	-- Scrolling using Shortcut
	{ mods = "SHIFT", key = "PageUp", action = act.ScrollByPage(-0.25) },
	{ mods = "SHIFT", key = "PageDown", action = act.ScrollByPage(0.25) },

	---------------------- Editing Text ----------------------
	{ mods = "CTRL|SHIFT", key = "c", action = act.CopyTo("Clipboard") },
	{ mods = "CTRL|SHIFT", key = "v", action = act.PasteFrom("Clipboard") },
	{ mods = "CTRL|SHIFT|ALT", key = "c", action = act.ActivateCopyMode },
	{ mods = "ALT", key = "Escape", action = act.CopyMode("Close") },

	---------------------- Tab Management ----------------------
	-- Renaming Tab
	{
		mods = "LEADER",
		key = "r",
		action = act.PromptInputLine({
			description = "Rename your Tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		mods = "LEADER",
		key = "t",
		action = act.SpawnCommandInNewTab({ args = { "zsh" }, cwd = default_cwd }),
	},

	-- Navigate through Tabs Relatively
	{ mods = "ALT", key = "LeftArrow", action = act.ActivateTabRelative(-1) },
	{ mods = "ALT", key = "RightArrow", action = act.ActivateTabRelative(1) },
	-- Close current active tab
	{ mods = "CTRL", key = "w", action = act.CloseCurrentTab({ confirm = true }) },

	---------------------- Font Management ----------------------
	{ mods = "CTRL", key = "=", action = act.IncreaseFontSize },
	{ mods = "CTRL", key = "-", action = act.DecreaseFontSize },
	{ mods = "LEADER|CTRL", key = "0", action = act.ResetFontSize },

	---------------------- Pane / Multiplexer Management ----------------------
	{ mods = "LEADER|SHIFT", key = "|", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ mods = "LEADER", key = "\\", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ mods = "CTRL|ALT|SHIFT", key = "|", action = act.PaneSelect({ alphabet = "0123456789" }) },
	{ mods = "LEADER|SHIFT", key = "X", action = act.CloseCurrentPane({ confirm = false }) },
	{ mods = "ALT", key = "Enter", action = act.ToggleFullScreen },
	{ mods = "ALT", key = "h", action = act.Hide },
	{ mods = "CTRL|SHIFT", key = "UpArrow", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ mods = "CTRL|SHIFT", key = "DownArrow", action = act.AdjustPaneSize({ "Down", 1 }) },
	{ mods = "CTRL|SHIFT", key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ mods = "CTRL|SHIFT", key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
	{ mods = "CTRL", key = "LeftArrow", action = act.SendString "\x1bb" }, -- Navigate left 1 word
	{ mods = "CTRL", key = "RightArrow", action = act.SendString "\x1bf" }, -- Navigate right 1 word
}

-- For navigate through tabs based on Index

for i = 0, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i),
	})
end

wezterm.on("update-right-status", function(window, _)
	local SOLID_LEFT_ARROW = ""
	local ARROW_FOREGROUND = { Foreground = { Color = "#C6A0F6" } }
	local prefix = ""

	if window:leader_is_active() then
		prefix = " " .. utf8.char(0x1f30a)
		SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	end

	if window:active_tab():tab_id() ~= 0 then
		ARROW_FOREGROUND = { Foreground = { Color = "#1e2030" } }
	end

	if window:active_tab():tab_id() == 0 then
		ARROW_FOREGROUND = { Foreground = { Color = "#C6A0F6" } }
	end

	window:set_left_status(wezterm.format({
		{ Background = { Color = "#b7bdf8" } },
		{ Text = prefix },
		ARROW_FOREGROUND,
		{ Text = SOLID_LEFT_ARROW },
	}))
end)

-----------------------------------------------------------------------------------
return config
