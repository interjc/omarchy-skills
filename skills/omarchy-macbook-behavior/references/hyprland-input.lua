-- Optional trackpad override, loaded AFTER personal configuration; do not replace input.lua.
-- For this replacement scheme, REQUIRED before require("default.hypr.omarchy"):
-- omarchy_default_gestures = false
-- On newer builds, upstream three-finger gestures steal drag and four-finger ones conflict.
-- The live 4.0.6-1 install has no default/hypr/gestures.lua and no such default conflict.
-- Shortcut-only setup uses --keep-trackpad: no input changes, gestures or disable flag.
-- Review personal gesture definitions separately: this flag only disables upstream defaults.
hl.config({
  input = {
    touchpad = {
      -- Choose explicitly: true = content follows fingers (natural); false = traditional.
      natural_scroll = false,
      disable_while_typing = true,
      drag_3fg = 1,
    },
  },
})

-- Keep upstream pointer acceleration, click/tap behavior and terminal scroll factors.
-- Four-finger workspace navigation leaves three fingers available for dragging.
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "up", action = "special", workspace_name = "scratchpad" })
hl.gesture({ fingers = 4, direction = "down", action = "special", workspace_name = "scratchpad" })
hl.gesture({ fingers = 4, direction = "pinchin", action = function()
  hl.dispatch(hl.dsp.exec_cmd("omarchy-menu toggle"))
end })
