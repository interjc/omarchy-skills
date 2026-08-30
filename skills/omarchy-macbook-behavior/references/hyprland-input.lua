-- Keep only your personal input overrides here.
-- MacBook (Apple Multi-Touch Trackpad bcm5974) Ergonomics & Gesture Tuning

hl.config({
  input = {
    -- Hardware acceleration profile for smooth pointer feel
    sensitivity = 0,
    accel_profile = "adaptive",

    touchpad = {
      -- Palm rejection: Disable trackpad while typing on keyboard
      disable_while_typing = true,

      -- macOS-style natural scrolling direction
      natural_scroll = true,

      -- Left-click-and-drag with three fingers (macOS Accessibility style)
      drag_3fg = 1,

      -- Clickfinger mapping (1 finger = Left, 2 fingers = Right, 3 fingers = Middle)
      clickfinger_behavior = true,

      -- Tap to click (soft touch)
      tap_to_click = true,

      -- Single-finger double tap and drag
      tap_and_drag = true,

      -- Fine-tuned macOS-like smooth scrolling factor
      scroll_factor = 0.45,

      -- Clean two-finger right click without middle-click confusion
      middle_button_emulation = false,
    },
  },

  misc = {
    -- Instant display wake upon touching trackpad or keyboard
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

-- Terminal-specific scroll speeds
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.4 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.25 })

-- macOS Multi-Finger Trackpad Gestures
-- 4-finger horizontal swipe: Smoothly switch workspaces (coexists with 3-finger drag)
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

-- 4-finger swipe up: Toggle scratchpad / special workspace
hl.gesture({
  fingers = 4,
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
  end,
})
