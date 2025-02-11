local wezterm = require "wezterm"

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
    window_background_opacity = 0.75,
    text_background_opacity = 0.75,
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
    font = wezterm.font_with_fallback({
        "FiraMono Nerd Font Mono",
        "JetBrains Mono"
    }),
    font_size = 14,
    hide_tab_bar_if_only_one_tab = true
}

return config


