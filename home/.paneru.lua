-- Migrated from ~/.paneru.toml. Paneru reads this file instead of the TOML config.
paneru.setup {
  options = {
    focus_follows_mouse = false,
    mouse_follows_focus = false,
    preset_column_widths = { 0.33333, 0.50, 0.66667 },
    window_resize_cycle = true,
  },
  padding = {
    top = 0,
    bottom = 0,
    left = 0,
    right = 0,
  },
  bindings = {
    ["window focus west"] = "alt - h",
    ["window focus east"] = "alt - l",
    ["window focus north"] = "alt - k",
    ["window focus south"] = "alt - j",
    ["window swap west"] = "alt + shift - h",
    ["window swap east"] = "alt + shift - l",
    ["window swap north"] = "alt + shift - k",
    ["window swap south"] = "alt + shift - j",
    ["window fullwidth"] = "alt - f",
    ["window manage"] = "alt + shift - f",
    ["window resize"] = "alt - r",
    ["window balance"] = "alt - b",
    ["window stack"] = "alt - comma",
    ["window unstack"] = "alt - period",
  },
  swipe = {
    deceleration = 1.0,
    sensitivity = 0.4,
    continuous = false,
    gesture = {
      fingers_count = 4,
      direction = "Natural",
      vertical = false,
    },
  },
  decorations = {
    inactive = { dim = { opacity_night = -0.04 } },
  },
  windows = {
    calculator = {
      title = ".*",
      bundle_id = "com.apple.calculator",
      floating = true,
    },
    quicktime = {
      title = ".*",
      bundle_id = "com.apple.QuickTimePlayerX",
      floating = true,
    },
    ["finder-info"] = {
      title = ".*(简介|簡介|Info|Bilgisi)$",
      bundle_id = "com.apple.finder",
      floating = true,
    },
    all = {
      title = ".*",
      horizontal_padding = 0,
      vertical_padding = 0,
      width = 1.0,
    },
  },
}
