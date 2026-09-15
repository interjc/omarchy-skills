-- Keep only your personal input overrides here.
-- MacBook (Apple Multi-Touch Trackpad bcm5974) Ergonomics & Gesture Tuning
-- Location: ~/.config/hypr/input.lua

hl.config({
  input = {
    -- Hardware acceleration profile for smooth pointer feel
    sensitivity = 0,
    accel_profile = "adaptive",

    touchpad = {
      -- Palm rejection: Disable trackpad while typing on keyboard
      disable_while_typing = true,

      -- Scrolling direction:
      -- natural_scroll = false (Traditional: 2 fingers swipe UP moves page UP)
      -- natural_scroll = true  (Natural: 2 fingers swipe UP moves page DOWN)
      natural_scroll = false,

      -- Left-click-and-drag with three fingers (macOS Accessibility style)
      drag_3fg = 1,

      -- Clickfinger mapping (1 finger = Left, 2 fingers = Right, 3 fingers = Middle)
      clickfinger_behavior = true,

      -- Tap to click (soft touch)
      tap_to_click = true,

      -- Single-finger double tap and drag
      tap_and_drag = true,

      -- Fine-tuned smooth scrolling factor
      scroll_factor = 0.45,

      -- Clean two-finger right click without middle-click confusion
      middle_button_emulation = false,
    },
  },

  gestures = {
    -- Fluid macOS-like workspace swipe physics
    workspace_swipe_distance = 300,
    workspace_swipe_cancel_ratio = 0.3,
    workspace_swipe_min_speed_to_force = 15,
    workspace_swipe_direction_lock = true,
    workspace_swipe_direction_lock_threshold = 10,
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

-- 4-finger swipe up: Toggle scratchpad / special workspace (Mission Control style)
hl.gesture({
  fingers = 4,
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
  end,
})

-- 4-finger swipe down: Dismiss / toggle scratchpad
hl.gesture({
  fingers = 4,
  direction = "down",
  action = function()
    hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
  end,
})

-- 4-finger pinch in: Launchpad / Application launcher (omarchy-menu)
hl.gesture({
  fingers = 4,
  direction = "pinchin",
  action = function()
    hl.dispatch(hl.dsp.exec_cmd("omarchy-menu toggle"))
  end,
})

