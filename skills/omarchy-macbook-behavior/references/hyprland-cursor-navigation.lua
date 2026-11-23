-- macOS-style cursor navigation & selection (Option+Left/Right = word, Super+Arrows = line/document).
-- Uses Omarchy's send_key_state + terminal-tag pattern from default/hypr/bindings/clipboard.lua.
local function macbook_nav_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end

  return false
end

local function macbook_nav_send_pulse(mods, key, hold_ms)
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
  end, { timeout = hold_ms or 15, type = "oneshot" })
end

-- Option + Left/Right (+ Shift): move / select by word (supports key repeat).
o.rebind("ALT + LEFT", "Move cursor one word left", function()
  if macbook_nav_window_is_terminal() then
    macbook_nav_send_pulse("ALT", "Left", 15)
  else
    macbook_nav_send_pulse("CTRL", "Left", 15)
  end
end, { repeating = true })

o.rebind("ALT + RIGHT", "Move cursor one word right", function()
  if macbook_nav_window_is_terminal() then
    macbook_nav_send_pulse("ALT", "Right", 15)
  else
    macbook_nav_send_pulse("CTRL", "Right", 15)
  end
end, { repeating = true })

o.rebind("ALT + SHIFT + LEFT", "Select one word left", function()
  if macbook_nav_window_is_terminal() then
    macbook_nav_send_pulse("ALT SHIFT", "Left", 15)
  else
    macbook_nav_send_pulse("CTRL SHIFT", "Left", 15)
  end
end, { repeating = true })

o.rebind("ALT + SHIFT + RIGHT", "Select one word right", function()
  if macbook_nav_window_is_terminal() then
    macbook_nav_send_pulse("ALT SHIFT", "Right", 15)
  else
    macbook_nav_send_pulse("CTRL SHIFT", "Right", 15)
  end
end, { repeating = true })

-- [BEGIN macos-full]
-- Relocate stock Hyprland window focus & swap from SUPER (+ SHIFT) + arrows to CTRL + ALT (+ SHIFT) + arrows.
o.rebind("CTRL + ALT + LEFT", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.rebind("CTRL + ALT + RIGHT", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.rebind("CTRL + ALT + UP", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.rebind("CTRL + ALT + DOWN", "Focus on below window", hl.dsp.focus({ direction = "d" }))

o.rebind("CTRL + ALT + SHIFT + LEFT", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.rebind("CTRL + ALT + SHIFT + RIGHT", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.rebind("CTRL + ALT + SHIFT + UP", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.rebind("CTRL + ALT + SHIFT + DOWN", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

-- Super + Left/Right (+ Shift): move / select to line start / end.
o.rebind("SUPER + LEFT", "Move cursor to start of line", function()
  if macbook_nav_window_is_terminal() then
    macbook_nav_send_pulse("CTRL", "A", 15)
  else
    macbook_nav_send_pulse("", "Home", 15)
  end
end, { repeating = true })

o.rebind("SUPER + RIGHT", "Move cursor to end of line", function()
  if macbook_nav_window_is_terminal() then
    macbook_nav_send_pulse("CTRL", "E", 15)
  else
    macbook_nav_send_pulse("", "End", 15)
  end
end, { repeating = true })

o.rebind("SUPER + SHIFT + LEFT", "Select to start of line", function()
  macbook_nav_send_pulse("SHIFT", "Home", 15)
end, { repeating = true })

o.rebind("SUPER + SHIFT + RIGHT", "Select to end of line", function()
  macbook_nav_send_pulse("SHIFT", "End", 15)
end, { repeating = true })

-- Super + Up/Down (+ Shift): move / select to document top / bottom.
o.rebind("SUPER + UP", "Move cursor to top of document", function()
  macbook_nav_send_pulse("CTRL", "Home", 15)
end)

o.rebind("SUPER + DOWN", "Move cursor to bottom of document", function()
  macbook_nav_send_pulse("CTRL", "End", 15)
end)

o.rebind("SUPER + SHIFT + UP", "Select to top of document", function()
  macbook_nav_send_pulse("CTRL SHIFT", "Home", 15)
end)

o.rebind("SUPER + SHIFT + DOWN", "Select to bottom of document", function()
  macbook_nav_send_pulse("CTRL SHIFT", "End", 15)
end)
-- [END macos-full]
