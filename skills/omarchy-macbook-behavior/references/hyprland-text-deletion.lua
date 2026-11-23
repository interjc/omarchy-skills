-- macOS-style text deletion (Option+Delete = word, Super+Delete = line).
-- Uses Omarchy's send_key_state + terminal-tag pattern from default/hypr/bindings/clipboard.lua.
local function macbook_active_window_is_terminal()
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

local function macbook_send_key_pulse(mods, key, hold_ms)
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
  end, { timeout = hold_ms or 15, type = "oneshot" })
end

-- Option + Delete (ALT + BACKSPACE): delete previous word (supports key repeat).
-- Terminals keep native Alt+BackSpace (readline backward-kill-word); GUI apps receive Ctrl+BackSpace.
o.rebind("ALT + BACKSPACE", "Delete previous word", function()
  if macbook_active_window_is_terminal() then
    macbook_send_key_pulse("ALT", "BackSpace", 15)
  else
    macbook_send_key_pulse("CTRL", "BackSpace", 15)
  end
end, { repeating = true })

-- Super + Delete (SUPER + BACKSPACE): delete to start of line.
-- Relocate stock "Toggle transparency on a window" to SUPER + ALT + BACKSPACE.
o.rebind("SUPER + ALT + BACKSPACE", "Toggle transparency on a window", "omarchy-hyprland-window-transparency-toggle")
o.rebind("SUPER + BACKSPACE", "Delete to start of line", function()
  if macbook_active_window_is_terminal() then
    macbook_send_key_pulse("CTRL", "U", 20)
  else
    macbook_send_key_pulse("SHIFT", "Home", 20)
    hl.timer(function()
      macbook_send_key_pulse("", "BackSpace", 20)
    end, { timeout = 35, type = "oneshot" })
  end
end)
