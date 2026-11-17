local wezterm = require("wezterm")
local config = wezterm.config_builder()

local is_macos = wezterm.target_triple:find("apple") ~= nil
local is_windows = wezterm.target_triple:find("windows") ~= nil

if is_windows then
  config.default_domain = "WSL:Ubuntu-26.04"
elseif is_macos then
  config.default_prog = { "/opt/homebrew/bin/zsh", "-l" }
end

config.font = wezterm.font_with_fallback({
  "MonoLisa",
  "MesloLGS Nerd Font Mono",
})
config.font_size = is_macos and 17.0 or 15.0
config.line_height = 1.1

-- Panda Syntax-inspired palette shared by macOS and Windows.
config.colors = {
  foreground = "#E6E6E6",
  background = "#292A2B",
  cursor_bg = "#FFCC95",
  cursor_border = "#FFCC95",
  cursor_fg = "#292A2B",
  selection_bg = "#515253",
  selection_fg = "#E6E6E6",
  ansi = {
    "#292A2B",
    "#FF2C6D",
    "#19F9D8",
    "#FFB86C",
    "#45A9F9",
    "#FF75B5",
    "#6FC1FF",
    "#E6E6E6",
  },
  brights = {
    "#676B79",
    "#FF2C6D",
    "#19F9D8",
    "#FFCC95",
    "#6FC1FF",
    "#B084EB",
    "#6FC1FF",
    "#FFFFFF",
  },
  tab_bar = {
    background = "#292A2B",
    active_tab = { bg_color = "#515253", fg_color = "#FFFFFF" },
    inactive_tab = { bg_color = "#343536", fg_color = "#B3B3B3" },
    inactive_tab_hover = { bg_color = "#3E3F40", fg_color = "#FFFFFF" },
    new_tab = { bg_color = "#292A2B", fg_color = "#B3B3B3" },
    new_tab_hover = { bg_color = "#3E3F40", fg_color = "#FFFFFF" },
  },
}

config.window_background_opacity = 1.0
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 32
config.scrollback_lines = 10000
config.default_cursor_style = "BlinkingBar"
config.audible_bell = "Disabled"
config.check_for_updates = false
config.copy_on_select = true
config.hide_mouse_cursor_when_typing = true

if is_macos then
  config.keys = {
    { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
    { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "d", mods = "CMD|ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "LeftArrow", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "Enter", mods = "CMD", action = wezterm.action.SendString("\n") },
  }
else
  config.keys = {
    { key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
    { key = "d", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "d", mods = "CTRL|ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  }
end

return config
