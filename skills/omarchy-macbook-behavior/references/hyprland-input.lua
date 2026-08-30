-- Hyprland Input Configuration for macOS / MacBook Trackpad Behavior
-- Location: ~/.config/hypr/input.lua

hl.config({
  input = {
    -- Palm rejection: Disable trackpad while typing on keyboard
    touchpad = {
      disable_while_typing = true,
      natural_scroll = true,          -- macOS-style natural scrolling
      drag_3fg = 1,                   -- macOS Accessibility three-finger drag
      clickfinger_behavior = true,    -- 1 finger = left, 2 fingers = right, 3 fingers = middle
      tap_to_click = true,            -- Tap to click
      scroll_factor = 0.4,            -- Smooth scrolling speed
    },
  },
})

-- App-specific scroll speed adjustments
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
