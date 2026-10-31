-- OPTIONAL example only. Keep the stock binding unless the user requests a change.
-- Back up ~/.config/hypr/bindings.lua, inspect collisions, and choose a key first.
-- The stock SUPER + SHIFT + CTRL + A already dispatches through --pick.

hl.unbind("SUPER + SHIFT + CTRL + A")
o.bind("SUPER + SHIFT + CTRL + A", "Agent", "omarchy-agent --pick")
