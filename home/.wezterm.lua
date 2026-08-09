local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "iceberg-dark"
config.font = wezterm.font("CodeM Nerd Font")
-- The Linux box runs at a different DPI than the Mac
config.font_size = wezterm.target_triple:find("darwin") and 14 or 15
config.cell_width = 0.81
config.ime_preedit_rendering = "System"
config.enable_tab_bar = false
config.default_prog = { "/bin/zsh", "-l", "-c", "zellij attach --index 0 --create" }
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.window_close_confirmation = "NeverPrompt"
config.front_end = "WebGpu"
config.freetype_load_flags = "NO_HINTING"
config.initial_cols = 160
config.initial_rows = 48

return config
