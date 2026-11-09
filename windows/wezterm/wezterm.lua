local wezterm = require("wezterm")
local act = wezterm.action
local nf = wezterm.nerdfonts
local config = wezterm.config_builder()

-- Panda Syntax-inspired palette shared with the macOS terminal setup.
local panda = {
  base = "#292A2B",
  surface = "#343536",
  overlay = "#515253",
  muted = "#676B79",
  text = "#E6E6E6",
  subtext = "#B3B3B3",
  blue = "#6FC1FF",
  orange = "#FFB86C",
  peach = "#FFCC95",
  red = "#FF2C6D",
}

config.default_domain = "WSL:Ubuntu-26.04"
config.launch_menu = {
  { label = "PowerShell", args = { "pwsh.exe", "-NoLogo" }, domain = { DomainName = "local" } },
}

-- MonoLisa is licensed separately; only ask for it when it is installed so WezTerm doesn't warn.
local function font_installed(pattern)
  local user_fonts = (os.getenv("LOCALAPPDATA") or ""):gsub("\\", "/") .. "/Microsoft/Windows/Fonts/"
  return #wezterm.glob(user_fonts .. pattern) > 0 or #wezterm.glob("C:/Windows/Fonts/" .. pattern) > 0
end

local fonts = { "MesloLGS Nerd Font Mono" }
if font_installed("MonoLisa*") then
  table.insert(fonts, 1, "MonoLisa")
end
config.font = wezterm.font_with_fallback(fonts)
config.font_size = 15.0
config.line_height = 1.1
config.adjust_window_size_when_changing_font_size = false

config.colors = {
  foreground = panda.text,
  background = panda.base,
  cursor_bg = panda.peach,
  cursor_border = panda.peach,
  cursor_fg = panda.base,
  compose_cursor = panda.orange,
  selection_bg = panda.overlay,
  selection_fg = panda.text,
  scrollbar_thumb = panda.overlay,
  split = panda.muted,
  visual_bell = panda.overlay,
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
    background = panda.base,
    new_tab = { bg_color = panda.base, fg_color = panda.subtext },
    new_tab_hover = { bg_color = panda.base, fg_color = panda.blue },
  },
}

config.window_background_opacity = 1.0
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 4 }
config.enable_scroll_bar = true
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }
config.command_palette_bg_color = panda.surface
config.command_palette_fg_color = panda.text
config.command_palette_font_size = 13.0

config.use_fancy_tab_bar = false
-- Integrated window buttons live in the tab bar, so it must stay visible.
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32
config.switch_to_last_active_tab_when_closing_tab = true
config.status_update_interval = 1000

config.max_fps = 120
config.animation_fps = 120
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 650
config.cursor_blink_ease_in = "EaseOut"
config.cursor_blink_ease_out = "EaseOut"

config.scrollback_lines = 20000
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 150,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 150,
}
config.check_for_updates = false

-- Rounded tab pills, inspired by https://github.com/KevinSilvester/wezterm-config (MIT).
wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
  local pane = tab.active_pane
  local title = tab.tab_title ~= "" and tab.tab_title or pane.title
  local icon = nf.cod_terminal
  if title:find("^Administrator: ") then
    icon = nf.md_shield_half_full
    title = (title:gsub("^Administrator: ", ""))
  elseif pane.domain_name:find("^WSL") then
    icon = nf.cod_terminal_linux
  end

  local unseen = ""
  if not tab.is_active then
    for _, p in ipairs(tab.panes) do
      if p.has_unseen_output then
        unseen = " " .. nf.fa_circle
        break
      end
    end
  end

  local bg, fg = panda.surface, panda.subtext
  if tab.is_active then
    bg, fg = panda.blue, panda.base
  elseif hover then
    bg, fg = panda.muted, panda.text
  end

  -- Two cells for the rounded caps and two for the icon and its space.
  title = wezterm.truncate_right(title, max_width - 4 - wezterm.column_width(unseen))

  return {
    { Background = { Color = panda.base } },
    { Foreground = { Color = bg } },
    { Text = nf.ple_left_half_circle_thick },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = "Bold" } },
    { Text = icon .. " " .. title },
    { Foreground = { Color = panda.orange } },
    { Text = unseen },
    { Background = { Color = panda.base } },
    { Foreground = { Color = bg } },
    { Text = nf.ple_right_half_circle_thick },
  }
end)

wezterm.on("update-status", function(window)
  window:set_right_status(wezterm.format({
    { Foreground = { Color = panda.peach } },
    { Attribute = { Intensity = "Bold" } },
    { Text = nf.md_clock_outline .. " " .. wezterm.strftime("%a %H:%M") .. "  " },
  }))
end)

-- Right-click the new tab button to pick a shell or WSL distribution.
wezterm.on("new-tab-button-click", function(window, pane, button)
  if button == "Right" then
    window:perform_action(act.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS" }), pane)
    return false
  end
end)

config.keys = {
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "d", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "CTRL|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },
  {
    key = "F2",
    action = act.PromptInputLine({
      description = "Rename tab (leave empty to reset)",
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  { key = "F11", action = act.ToggleFullScreen },
}

return config
