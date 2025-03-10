local wezterm = require "wezterm"

local fonts = {
    CommitMono = { name = "CommitMono Nerd Font",    height = 1.1 },
    FiraMono   = { name = "FiraMono Nerd Font Mono", height = 1 },
}

local font = fonts.CommitMono

wezterm.on("toggle-opacity", function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if not overrides.window_background_opacity then
        overrides.text_background_opacity = 0.3
        overrides.window_background_opacity = 0.3
        overrides.macos_window_background_blur = 0
    else
        overrides.window_background_opacity = nil
        overrides.text_background_opacity = nil
        overrides.macos_window_background_blur = nil
    end
    window:set_config_overrides(overrides)
end)

local config = {
    window_background_opacity = 1,
    text_background_opacity = 1,
    macos_window_background_blur = 40,
    keys = {
        {
            key = "O",
            mods = "CMD",
            action = wezterm.action.EmitEvent "toggle-opacity",
        },
        {
            key = "w",
            mods = "CMD",
            action = wezterm.action.CloseCurrentTab { confirm = false }
        }
    },
    font = wezterm.font_with_fallback({ font.name, "JetBrains Mono" }),
    font_size = 14,
    line_height = font.height,
    hide_tab_bar_if_only_one_tab = true
}

return config


