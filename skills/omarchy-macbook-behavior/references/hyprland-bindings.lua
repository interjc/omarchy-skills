-- EXAMPLES ONLY: select confirmed options; do not copy all of these blindly.
-- Load selected overrides after personal bindings. Inspect hyprctl binds -j first.
-- Leave native Print / Super+Ctrl+Alt+C screenshot bindings unchanged; F12 is not default.
-- Inspect the executable resolved by type -P omarchy-capture-screenshot first.
-- OMARCHY_PATH is installation context only; its source may differ from PATH's wrapper.
-- A line-leading omasnap / exec omasnap call in that executable selects the examples below;
-- confirm both omarchy-capture-screenshot and omasnap are executable on PATH.
-- Legacy grim/tensaku, unknown/unreadable wrapper or none on PATH: use bare omasnap instead.
-- Never run the wrapper to detect it. If a required command is missing, stop before edits.

-- Option A: replaces the native Audio shortcut (or any personal binding on this chord).
-- hl.unbind("SUPER + CTRL + A")
-- o.bind("SUPER + CTRL + A", "Screenshot", "omarchy-capture-screenshot")

-- Option B: an alternative to macOS Cmd+Shift+4, not identical physical modifiers.
-- hl.unbind("ALT + SHIFT + 4")
-- o.bind("ALT + SHIFT + 4", "Screenshot", "omarchy-capture-screenshot")

-- Legacy/direct alternatives: choose these INSTEAD of the wrapper binding above.
-- hl.unbind("SUPER + CTRL + A")
-- o.bind("SUPER + CTRL + A", "Screenshot", "omasnap")
-- hl.unbind("ALT + SHIFT + 4")
-- o.bind("ALT + SHIFT + 4", "Screenshot", "omasnap")

-- Optional clipboard alias; native Super+Ctrl+V remains available unless customized.
-- hl.unbind("SUPER + SHIFT + Z")
-- o.bind("SUPER + SHIFT + Z", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")

-- The newer wrapper supplies notifications and screenshot-directory compatibility.
-- The direct path uses installed omasnap defaults; do not add --notify (not available
-- on the live 4.0.6-1 machine's CLI), --save or --capture-fullscreen to these bindings.
-- No extra overlay layer rule is needed.
-- Do NOT set no_screen_share on omasnap: scrolling capture needs to capture its overlay.
-- Keep native Super+I / Super+Shift+I language cycling and Ctrl+Space terminal prefix.
