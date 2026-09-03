-- Screenshot, Clipboard and Hotkey Bindings for Omarchy / Hyprland
-- Location: Append to ~/.config/hypr/bindings.lua

-- =============================================================================
-- Omasnap Screenshot Overlay
-- =============================================================================
-- Unbind default keys
hl.unbind("PRINT")
hl.unbind("F12")

-- Note: SUPER + CTRL + A is mapped to Audio panel in Omarchy defaults.
-- Unbind it first before mapping to screenshot tool (omasnap):
hl.unbind("SUPER + CTRL + A")
o.bind("SUPER + CTRL + A", "Screenshot", "omasnap")

-- Alternative / Additional macOS Cmd+Shift+4 binding (ALT + SHIFT + 4):
-- hl.unbind("ALT + SHIFT + 4")
-- o.bind("ALT + SHIFT + 4", "Screenshot (macOS Cmd+Shift+4)", "omasnap")

-- Default function keys
o.bind("PRINT", "Screenshot", "omasnap")
o.bind("F12", "Screenshot", "omasnap")

-- Instant overlay layer rules (no animation, no screen share leak)
hl.layer_rule({
  match = { namespace = "^omasnap$" },
  no_anim = true,
  animation = "none",
  no_screen_share = true,
})

-- =============================================================================
-- Clipboard History Manager (Alfred Parity)
-- =============================================================================
-- In Omarchy, Super+C and Super+V are universal copy and paste (like Cmd+C/V).
-- Default clipboard manager is SUPER + CTRL + V.
-- Replicate Alfred muscle memory (Cmd + Shift + Z -> SUPER + SHIFT + Z):
hl.unbind("SUPER + SHIFT + Z")
o.bind("SUPER + SHIFT + Z", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")

-- =============================================================================
-- Optional: Swap Super+Space (IME) and Ctrl+Space (Omarchy Menu)
-- =============================================================================
-- In modern macOS, Cmd+Space toggles input source, while Ctrl+Space / Alt+Space launches apps.
-- If preferred, unbind Super+Space from Hyprland (pass-through to Fcitx5) and bind Ctrl+Space to Menu:
-- hl.unbind("SUPER + SPACE")
-- o.bind("CTRL + SPACE", "Omarchy menu", "omarchy-menu toggle")
